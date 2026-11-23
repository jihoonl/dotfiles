import getpass
import json
import os
import subprocess
import sys
import threading
import time
import unicodedata
from pathlib import Path

from slack_sdk import WebClient
from slack_sdk.socket_mode import SocketModeClient
from slack_sdk.socket_mode.response import SocketModeResponse

SESSION_PANE = os.environ.get("SLACK_SESSION_PANE", "")
STATE_DIR = Path.home() / ".config" / "slack-session"
ALLOW_FILE = STATE_DIR / "allowed_users"
REPLY_FIFO = STATE_DIR / "reply.fifo"
SEND_LOCK = threading.Lock()


def session_prompt(ev, allowed, in_group_dm_with_allowed=lambda channel: False):
    """Text to type into the session pane, or None when the event must not reach it."""
    if ev.get("bot_id") or ev.get("subtype") or not ev.get("user"):
        return None
    is_dm = ev.get("type") == "message" and ev.get("channel_type") == "im"
    is_mention = ev.get("type") == "app_mention"
    if ev["user"] in allowed:
        if not (is_dm or is_mention):
            return None
        kind, sender = "slack", ""
    elif is_mention and in_group_dm_with_allowed(ev["channel"]):
        kind, sender = "slack-guest", f" user={ev['user']}"
    else:
        return None
    thread = f" thread={ev['thread_ts']}" if ev.get("thread_ts") else ""
    # ponytail: newlines collapse to spaces so each message stays one [slack …] line; keep them if formatting matters.
    text = " ".join(ev.get("text", "").split())
    # An ESC would reach the TUI as a key and interrupt the session's turn.
    text = "".join(c for c in text if unicodedata.category(c) not in ("Cc", "Cf"))
    return f"[{kind} ch={ev['channel']} ts={ev['ts']}{thread}{sender}] {text}"


def in_group_dm_with(web, channel, users):
    """Whether the channel is a group DM one of the users is in; False when Slack refuses the lookup."""
    try:
        if not web.conversations_info(channel=channel)["channel"].get("is_mpim"):
            return False
        # ponytail: first page only (100 members); Slack caps a group DM at 9.
        return bool(users & set(web.conversations_members(channel=channel)["members"]))
    except Exception as e:
        print(f"group DM lookup failed: {e}", flush=True)
        return False


def type_into_session(prompt):
    # herdr refuses a prompt while an approval or question dialog is up, so the text cannot answer it;
    # Claude Code queues a prompt that arrives while it works.
    with SEND_LOCK:
        while True:
            out = subprocess.run(["herdr", "agent", "prompt", SESSION_PANE, prompt], capture_output=True, text=True)
            if out.returncode == 0:
                return
            if "agent_blocked" not in out.stdout + out.stderr:
                raise RuntimeError(out.stdout + out.stderr)
            time.sleep(2)


def on_request(client, req):
    # Slack redelivers an envelope that is not acked within 3 s.
    client.send_socket_mode_response(SocketModeResponse(envelope_id=req.envelope_id))
    if req.type != "events_api":
        return
    ev = req.payload["event"]
    allowed = set(ALLOW_FILE.read_text().split()) if ALLOW_FILE.exists() else set()
    body = f": {ev.get('text')}" if ev.get("user") in allowed else ""
    print(f"{ev.get('type')} user={ev.get('user')} ch={ev.get('channel')}{body}", flush=True)
    prompt = session_prompt(ev, allowed, lambda channel: in_group_dm_with(client.web_client, channel, allowed))
    if not prompt:
        return
    try:
        client.web_client.reactions_add(channel=ev["channel"], timestamp=ev["ts"], name="eyes")
    except Exception as e:
        print(f"reaction failed: {e}", flush=True)
    try:
        type_into_session(prompt)
        print(f"→ {SESSION_PANE}", flush=True)
    except Exception as e:
        print(f"forward failed: {e}", flush=True)


def relay_replies(web):
    """Post each JSON line written to REPLY_FIFO: {"channel", "text", "thread_ts"?}."""
    if not REPLY_FIFO.exists():
        os.mkfifo(REPLY_FIFO, 0o600)
    while True:
        with open(REPLY_FIFO) as fifo:
            for line in fifo:
                try:
                    msg = json.loads(line)
                    web.chat_postMessage(channel=msg["channel"], text=msg["text"], thread_ts=msg.get("thread_ts"))
                    print(f"replied ch={msg['channel']}", flush=True)
                except Exception as e:
                    print(f"reply failed: {e}", flush=True)


def main():
    if not SESSION_PANE:
        sys.exit("SLACK_SESSION_PANE에 Claude pane id를 지정해야 합니다.")
    STATE_DIR.mkdir(mode=0o700, exist_ok=True)
    app_token = os.environ.get("SLACK_APP_TOKEN") or getpass.getpass("SLACK_APP_TOKEN (xapp-...): ")
    bot_token = os.environ.get("SLACK_BOT_TOKEN") or getpass.getpass("SLACK_BOT_TOKEN (xoxb-...): ")
    if not app_token.startswith("xapp-") or not bot_token.startswith("xoxb-"):
        sys.exit("SLACK_APP_TOKEN은 xapp-, SLACK_BOT_TOKEN은 xoxb-로 시작해야 합니다.")

    web = WebClient(token=bot_token)
    threading.Thread(target=relay_replies, args=(web,), daemon=True).start()
    client = SocketModeClient(app_token=app_token, web_client=web)
    client.socket_mode_request_listeners.append(on_request)
    client.connect()
    print(f"connected → {SESSION_PANE}, allowlist: {ALLOW_FILE} (없으면 아무것도 전달하지 않음)", flush=True)
    threading.Event().wait()


if __name__ == "__main__":
    main()
