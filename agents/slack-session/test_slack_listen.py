from slack_listen import session_prompt

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
print("ok")
