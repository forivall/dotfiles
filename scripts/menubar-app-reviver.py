#!/usr/bin/env python3

import datetime
import itertools
import os
import subprocess
import time
import sys

try:
    import psutil
except ModuleNotFoundError:
    print(sys.prefix, file=sys.stderr)
    print(sys.argv[0], file=sys.stderr)
    print(f'{sys.version}', file=sys.stderr)
    raise

GB = 1 << 30
uid = os.getuid()

APPS = (
    "Dato",
    # "Mos",
    "Stats",
)


def get_processes():
    for proc in psutil.process_iter():
        if uid not in proc.uids():
            continue

        try:
            name = proc.name()
            if proc.status() != psutil.STATUS_RUNNING:
                continue
        except (
            psutil.ZombieProcess, psutil.NoSuchProcess, psutil.AccessDenied
        ):
            continue

        if name in APPS:
            yield (name, proc)


class ReviveError(Exception):
    def __init__(self, *args, apps: dict[str, psutil.Process], **kwargs):
        super().__init__(*args, **kwargs)
        self.missing = tuple(set(APPS).difference(apps.keys()))


def do_revive(restart=False, strict=False) -> dict[str, psutil.Process]:
    apps = {app: proc for app, proc in get_processes()}
    revived = False
    for app in APPS:
        if app in apps:
            continue
        now = datetime.datetime.now().strftime("%c")
        print(f"{now} | {'re' if restart else ''}starting {app}...")
        sys.stdout.flush()
        subprocess.run(("open", "-a", app))
        revived = True
    if revived:
        if strict:
            raise ReviveError(restart=restart, apps=apps)
        time.sleep(1)
        return do_revive(restart, strict=True)
    return apps


def ensure_running(apps: dict[str, psutil.Process]):
    ok = True
    for proc in apps.values():
        if not proc.is_running():
            ok = False

    return apps if ok else do_revive(restart=True)


if __name__ == "__main__":
    import sys

    apps = do_revive()

    if "--oneshot" not in sys.argv:
        now = datetime.datetime.now().strftime("%c")
        print(f"{now} | Polling processes...")
        sys.stdout.flush()
        for i in itertools.count():
            time.sleep(1)
            old_apps = apps
            apps = ensure_running(apps)
            if sys.stdin.isatty() and apps == old_apps:
                sys.stdout.write(".o0O"[i % 4] + "\033[D")
                sys.stdout.flush()
