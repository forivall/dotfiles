#!/usr/bin/env python3

from datetime import datetime, timedelta
import itertools
import os
import subprocess
import time

import psutil
import humanfriendly

GB = 1 << 30
uid = os.getuid()

APPS = (
    "AltTab",
    "DockView",
    # 'DockMate',
    "codewhisperer_desktop",  # CodeWhisperer',
    "Trailer",
)
APP_BUNDLE_NAMES = {
    name: name if name != "codewhisperer_desktop" else "CodeWhisperer" for name in APPS
}


def get_footprint(proc: psutil.Process):
    vmmap = subprocess.run(("vmmap", "-summary", str(proc.pid)), capture_output=True)
    marker = b"Physical footprint:"
    i = vmmap.stdout.find(marker) + len(marker)
    j = vmmap.stdout.find(b"\n", i)
    footprint_text = vmmap.stdout[i:j].strip().decode()
    if not footprint_text:
        return -1
    return humanfriendly.parse_size(footprint_text)


def get_processes():
    for proc in psutil.process_iter():
        if uid not in proc.uids():
            continue

        try:
            name = proc.name()
            if proc.status() != psutil.STATUS_RUNNING:
                continue
        except (psutil.ZombieProcess, psutil.NoSuchProcess, psutil.AccessDenied):
            continue

        if name in APPS:
            yield (name, proc)


def quit_osascript(app):
    return f"""tell application "{app}"
  quit
end tell"""


def do_reap():
    reaped = False
    seen = set()
    for app_process_name, proc in get_processes():
        app = APP_BUNDLE_NAMES[app_process_name]
        seen.add(app)
        footprint = get_footprint(proc)
        print(app, proc)
        print("footprint", humanfriendly.format_size(footprint))
        timediff = datetime.now() - datetime.fromtimestamp(proc.create_time())
        print("running time", timediff)
        reap = (
            footprint > 2 * GB
            or app in ("AltTab", "DockView")
            and timediff > timedelta(hours=1)
        )

        if reap:
            try:
                now = datetime.now().strftime("%c")
                print(f"{now} | restarting {proc!r}...")
                subprocess.run(("osascript", "-e", quit_osascript(app)))
                reaped = True
                time.sleep(1)
                subprocess.run(("open", "-a", app))
            except psutil.NoSuchProcess:
                print("already killed %r!" % proc)
    for app in APP_BUNDLE_NAMES.values():
        if app in seen:
            continue
        now = datetime.now().strftime("%c")
        print(f"{now} | starting {app}...")
        subprocess.run(("open", "-a", app))
    return reaped


if __name__ == "__main__":
    import sys

    reaped = do_reap()

    if "--watch" in sys.argv:
        if reaped and sys.stdin.isatty():
            sys.stdout.write("!\033[D")
            sys.stdout.flush()
        for i in itertools.count():
            time.sleep(60)
            if sys.stdin.isatty():
                sys.stdout.write(".o0O"[i % 4] + "\033[D")
                sys.stdout.flush()
            reaped = do_reap()

            if reaped and sys.stdin.isatty():
                sys.stdout.write("!\033[D")
                sys.stdout.flush()
