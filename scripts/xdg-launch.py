#!/usr/bin/python

from gi.repository import Gio
import sys

def main(myname, desktop, *uris):
    launcher = Gio.DesktopAppInfo.new_from_filename(desktop)
    launcher.launch_uris(uris, None)

if __name__ == "__main__":
    main(*sys.argv)
