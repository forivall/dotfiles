import weechat
import re

SCRIPT_NAME = "chanmon_like_buftag"
SCRIPT_AUTHOR = "User"
SCRIPT_VERSION = "1.0"
SCRIPT_LICENSE = "GPL3"
SCRIPT_DESC = "Goto buffer from chanmon"

# uses the chanmon_like config from https://gist.github.com/Strykar/ebcc0dbfec27ddcc303e73e7f809c072#channel-monitor

def goto_buffer_cb(data, signal, hashtable):
    """Process the Hsignal and extract buftag from the hashtable, then goto the buffer"""

    tags = hashtable.get("_chat_line_tags", "")

    if not tags:
        buffer_pointer = hashtable.get("_buffer", "")
        if buffer_pointer:
            weechat.prnt(buffer_pointer, "Error: Line has no tags or _chat_line_tags is missing.")
        return weechat.WEECHAT_RC_OK

    match = re.search(r'chanmon_like_buffer_([^,]+)', tags)
    if not match:
        return weechat.WEECHAT_RC_OK

    buffer_pointer = match.group(1)
    buffer_name = weechat.buffer_get_string(buffer_pointer, "name")
    current_buffer = hashtable.get("_buffer", "")
    if current_buffer:
        weechat.command(current_buffer, "/buffer {}".format(buffer_name))
    else:
        weechat.prnt("", "missing current buffer")
    return weechat.WEECHAT_RC_OK

if weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION, SCRIPT_LICENSE, SCRIPT_DESC, "",""):
    weechat.prnt("", "script loaded")
    weechat.hook_hsignal("goto_buffer_hsignal", "goto_buffer_cb", "")
