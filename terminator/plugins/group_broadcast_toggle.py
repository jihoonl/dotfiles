# group_broadcast_toggle.py
#
# 현재 윈도우의 모든 터미널을 하나의 그룹으로 묶고 broadcast(group)를 켜는 동작을
# 단축키 한 번 / 우클릭 메뉴 한 번으로 토글한다.
#
#   - 비활성 -> 활성: 윈도우의 모든 터미널을 새 그룹에 합류 + groupsend='group'
#   - 활성  -> 비활성: groupsend='off' + 윈도우의 모든 터미널을 그룹에서 제거
#
# Terminator 2.1.3 기준으로 API를 검증해 작성했다.
#
# 설치: 이 파일을 ~/.config/terminator/plugins/ 에 두고
#       Preferences -> Plugins 에서 "GroupBroadcastToggle" 체크.

import time

import terminatorlib.plugin as plugin
from terminatorlib.terminal import Terminal
from terminatorlib.terminator import Terminator
from terminatorlib.translation import _

from gi.repository import Gtk

AVAILABLE = ['GroupBroadcastToggle']

# 단축키. 비우면('') 단축키 없이 우클릭 메뉴로만 동작한다.
# <Super>b 는 Terminator 2.1.3 기본 바인딩 및 현재 사용자 config 와 충돌하지 않는다.
KEYBINDING = '<Super>b'

# keybinding 디스패처(getattr(self, 'key_' + action))가 호출할 액션 이름.
ACTION = 'group_broadcast_toggle'

# 터미널 안에서 IME(ibus)를 완전히 끄려면 True. 단, broadcast 안 할 때의 평소
# 한글 입력까지 막히므로 기본은 False. (영어 broadcast 중복은 아래 dedup 이 처리)
FORCE_SIMPLE_IM = False

# --- IME(ibus/fcitx) broadcast 중복 입력 방지 ---------------------------------
# ibus 가 켜져 있으면 키 하나에 key-press-event 가 두 번 발생(원본 + IME forward)해
# broadcast 대상 터미널에 같은 글자가 두 번 입력된다. 아래가 켜져 있으면
# group_emit/all_emit 을 감싸 같은 키의 중복 전파를 한 번만 보내도록 거른다.
ENABLE_IME_DEDUP = True
# 같은 (keyval,state) 가 이 시간(ms) 안에 다시 들어오면 중복으로 보고 버린다.
# 키 반복(autorepeat) 간격(보통 ~30ms)보다 작아야 한다.
DEDUP_WINDOW_MS = 15
# ibus 가 forward(중복 전파)한 합성 키 이벤트의 state 에 붙는 표시 비트.
# 진단 로그에서 원본 state=16, forward state=16|0x2000000 으로 확인됨.
IBUS_FORWARD_MASK = 1 << 25  # 0x2000000

# True 면 전파되는 키 이벤트를 /tmp/gbt_broadcast.log 에 기록(진단용).
DEBUG = False


def _toggle(terminal):
    """terminal 이 속한 윈도우의 모든 터미널에 대해 group+broadcast 를 토글한다."""
    terminator = Terminator()
    window = terminal.get_toplevel()

    # 현재 윈도우의 터미널만 수집 (terminator.terminals 는 전체 윈도우를 포함).
    terms = [t for t in terminator.terminals if t.get_toplevel() == window]
    if not terms:
        return

    gtype = terminator.groupsend_type  # {'all':0, 'group':1, 'off':2} (값은 버전별로 다름)

    # 활성 판정: broadcast 가 'group' 이고, 이 윈도우의 모든 터미널이
    # 같은(None 아닌) 그룹에 속해 있으면 우리가 켜둔 상태로 본다.
    groups = {t.group for t in terms}
    is_active = (
        terminator.groupsend == gtype['group']
        and len(groups) == 1
        and None not in groups
    )

    if is_active:
        # 비활성화: broadcast off + 그룹 해제.
        terminal.set_groupsend(None, gtype['off'])
        for t in terms:
            t.set_group(None, None)        # group_hoover 가 빈 그룹을 정리한다.
    else:
        # 활성화: 새 그룹 생성 -> 합류 -> broadcast group.
        # 내장 group_win 과 동일한 명명 규칙을 따른다.
        group = _('Window group %s') % (len(terminator.groups) + 1)
        while group in terminator.groups:   # 이름 충돌 방지
            group += '+'
        terminator.create_group(group)
        for t in terms:
            t.set_group(None, group)
        terminal.set_groupsend(None, gtype['group'])

    # 타이틀바 색/broadcast 아이콘 갱신 (내장 key_broadcast_* 와 동일한 방식).
    terminator.focus_changed(terminal)


# 단축키 디스패처는 Terminal 인스턴스에서 key_<action>() 을 호출하므로
# Terminal 클래스에 해당 메서드를 주입한다.
def _key_method(self):
    _toggle(self)


setattr(Terminal, 'key_' + ACTION, _key_method)


def _force_simple_im():
    """GTK 입력 모듈을 simple 로 바꿔 ibus forward(중복 입력)를 없앤다.

    프로세스 전체(모든 터미널)에 적용된다. 이미 만들어진 VTE 도 GtkIMMulticontext
    가 설정 변경을 받아 다음 포커스 때 simple 컨텍스트로 전환한다.
    """
    if not FORCE_SIMPLE_IM:
        return
    try:
        settings = Gtk.Settings.get_default()
        if settings is not None:
            settings.set_property('gtk-im-module', 'gtk-im-context-simple')
    except Exception:
        pass


def _install_broadcast_dedup():
    """group_emit/all_emit 을 감싸 IME forward 로 인한 중복 키 전파를 거른다.

    원본/forward 두 이벤트는 같은 (keyval, state) 로 거의 동시에 들어온다.
    동일 키가 DEDUP_WINDOW_MS 안에 또는 같은 X 타임스탬프로 다시 오면 버린다.
    포커스된 터미널의 입력은 네이티브 처리라 영향받지 않는다.
    """
    if not ENABLE_IME_DEDUP:
        return
    if getattr(Terminator, '_gbt_dedup', False):
        return

    state = {'keyval': None, 'mono': 0.0, 'etime': None}

    def _state(event):
        for getter in (lambda e: e.state, lambda e: e.get_state()):
            try:
                return int(getter(event))
            except Exception:
                continue
        return 0

    def is_dup(event):
        try:
            keyval = event.keyval
        except Exception:
            return False
        st = _state(event)
        etime = getattr(event, 'time', 0) or 0
        now = time.monotonic()
        # 1) 결정적: ibus 가 forward 한 합성 이벤트는 원본의 중복이므로 버린다.
        forwarded = bool(st & IBUS_FORWARD_MASK)
        # 2) 안전망: 같은 keyval 이 같은 타임스탬프/짧은 시간 안에 다시 들어오면 버린다.
        windowed = (keyval == state['keyval']
                    and ((etime and etime == state['etime'])
                         or (now - state['mono']) * 1000.0 < DEDUP_WINDOW_MS))
        dup = forwarded or windowed
        state['keyval'], state['mono'], state['etime'] = keyval, now, etime
        if DEBUG:
            try:
                sendev = getattr(event, 'send_event', None)
                with open('/tmp/gbt_broadcast.log', 'a') as fh:
                    fh.write('emit keyval=%s(%s) state=%s fwd=%s etime=%s send_event=%s -> %s\n'
                             % (keyval, chr(keyval) if 32 <= keyval < 127 else '?',
                                st, forwarded, etime, sendev, 'DROP' if dup else 'SEND'))
            except Exception:
                pass
        return dup

    orig_group = Terminator.group_emit
    orig_all = Terminator.all_emit

    def group_emit(self, terminal, group, etype, event, _o=orig_group):
        if etype == 'key-press-event' and is_dup(event):
            return
        return _o(self, terminal, group, etype, event)

    def all_emit(self, terminal, etype, event, _o=orig_all):
        if etype == 'key-press-event' and is_dup(event):
            return
        return _o(self, terminal, etype, event)

    Terminator.group_emit = group_emit
    Terminator.all_emit = all_emit
    Terminator._gbt_dedup = True


class GroupBroadcastToggle(plugin.MenuItem):
    """우클릭 메뉴 항목 + 단축키로 group/broadcast 를 토글한다."""

    capabilities = ['terminal_menu']

    def __init__(self):
        plugin.MenuItem.__init__(self)
        _force_simple_im()
        self._install_keybinding()
        _install_broadcast_dedup()

    def _install_keybinding(self):
        """런타임에 keybindings 에 액션을 주입한다.

        커스텀 액션 이름은 config 검증(configspec)에서 제거되므로 config 파일이 아닌
        메모리상의 keybindings 에 직접 넣는다. 또한 Preferences 저장 시
        Keybindings.configure() 가 config 값으로 keys 를 덮어쓰므로, 그 직후
        우리 바인딩을 다시 넣도록 configure 를 한 번만 래핑한다.
        """
        if not KEYBINDING:
            return
        terminator = Terminator()
        keybindings = terminator.keybindings
        if keybindings is None:
            return

        kls = keybindings.__class__
        if not getattr(kls, '_gbt_wrapped', False):
            original_configure = kls.configure

            def configure(self, bindings, _orig=original_configure):
                _orig(self, bindings)
                self.keys[ACTION] = KEYBINDING
                self.reload()

            kls.configure = configure
            kls._gbt_wrapped = True

        keybindings.keys[ACTION] = KEYBINDING
        keybindings.reload()

    def callback(self, menuitems, menu, terminal):
        # keybindings 가 __init__ 시점에 아직 없었을 경우를 대비해 재시도(멱등).
        self._install_keybinding()

        item = Gtk.MenuItem.new_with_mnemonic(_('Toggle Group + _Broadcast'))
        item.connect('activate', lambda _w: _toggle(terminal))
        menuitems.append(item)
