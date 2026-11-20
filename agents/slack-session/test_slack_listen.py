import tempfile
from pathlib import Path
from types import SimpleNamespace

import slack_listen
from slack_listen import on_request, session_prompt

me = {"U1"}
dm = {"type": "message", "channel_type": "im", "user": "U1", "channel": "D1", "ts": "1.0", "text": "hi\nthere"}

assert session_prompt(dm, me) == "[slack ch=D1 ts=1.0] hi there"
assert session_prompt({**dm, "thread_ts": "0.5"}, me) == "[slack ch=D1 ts=1.0 thread=0.5] hi there"
assert session_prompt(dm, set()) is None
assert session_prompt({**dm, "user": "U2"}, me) is None
assert session_prompt({**dm, "bot_id": "B1"}, me) is None
assert session_prompt({**dm, "subtype": "message_changed"}, me) is None
assert session_prompt({**dm, "channel_type": "channel"}, me) is None
assert session_prompt({**dm, "type": "app_mention", "channel_type": None, "channel": "C1"}, me) == "[slack ch=C1 ts=1.0] hi there"
assert session_prompt({**dm, "type": "app_home_opened"}, me) is None
assert session_prompt({**dm, "text": "a\x1b[201~b‮c\x03"}, me) == "[slack ch=D1 ts=1.0] a[201~bc"

reactions, forwarded = [], []


def failing_reactions_add(**kwargs):
    reactions.append(kwargs)
    raise RuntimeError("missing_scope")


client = SimpleNamespace(
    send_socket_mode_response=lambda response: None,
    web_client=SimpleNamespace(reactions_add=failing_reactions_add),
)


def deliver(ev):
    on_request(client, SimpleNamespace(envelope_id="e", type="events_api", payload={"event": ev}))


slack_listen.type_into_session = forwarded.append
with tempfile.TemporaryDirectory() as tmp:
    slack_listen.ALLOW_FILE = Path(tmp) / "allowed_users"
    slack_listen.ALLOW_FILE.write_text("U1\n")
    deliver({**dm, "user": "U2"})
    assert reactions == [] and forwarded == []
    deliver(dm)
    assert reactions == [{"channel": "D1", "timestamp": "1.0", "name": "eyes"}]
    assert forwarded == ["[slack ch=D1 ts=1.0] hi there"]
print("ok")
