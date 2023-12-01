#!/usr/bin/env python3

import datetime
import os
import psutil
import itertools

uid = os.getuid()
PROC_NAMES = ('git-credential-manager', 'rg')


def should_reap(proc: psutil.Process):
    if uid not in proc.uids():
        return False

    try:
        name = proc.name()
        if proc.status() != psutil.STATUS_RUNNING:
            return False

    except (psutil.ZombieProcess, psutil.NoSuchProcess, psutil.AccessDenied):
        return False

    if not any(proc_name in name for proc_name in PROC_NAMES):
        return False

    created = datetime.datetime.fromtimestamp(proc.create_time())
    delta = created - datetime.datetime.now()
    return delta.seconds > 300  # 5 min


def do_reap():
    reaped = False
    for proc in psutil.process_iter():
        reap = False
        with proc.oneshot():
            reap = should_reap(proc)

        if reap:
            try:
                proc.cpu_percent()
                if proc.cpu_percent(0.2) > 98:
                    now = datetime.datetime.now().strftime("%c")
                    print(f'{now} | killing {proc!r}...')
                    proc.kill()
                    reaped = True
            except psutil.NoSuchProcess:
                print('already killed %r!' % proc)
    return reaped


if __name__ == '__main__':
    import sys

    reaped = do_reap()

    if reaped and sys.stdin.isatty():
        sys.stdout.write('!\033[D')
        sys.stdout.flush()

    if '--watch' in sys.argv:
        import time
        for i in itertools.count():
            time.sleep(60)
            if sys.stdin.isatty():
                sys.stdout.write('.o0O'[i % 4] + '\033[D')
                sys.stdout.flush()
            reaped = do_reap()

            if reaped and sys.stdin.isatty():
                sys.stdout.write('!\033[D')
                sys.stdout.flush()
