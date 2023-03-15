import datetime
import os
import psutil

uid = os.getuid()


def should_reap(proc: psutil.Process):
    if uid not in proc.uids():
        return False

    try:
        name = proc.name()
        if proc.status() != psutil.STATUS_RUNNING:
            return False

    except (psutil.ZombieProcess, psutil.NoSuchProcess, psutil.AccessDenied):
        return False

    if 'git-credential-manager' not in name:
        return False

    proc.cpu_percent(0)
    created = datetime.datetime.fromtimestamp(proc.create_time())
    delta = created - datetime.datetime.now()
    return delta.seconds > 300  # 5 min


def do_reap():
    for proc in psutil.process_iter():
        reap = False
        with proc.oneshot():
            reap = should_reap(proc)

        if reap:
            proc.cpu_percent()
            if proc.cpu_percent(0.2) > 98:
                print('killing %r...' % proc)
                proc.kill()


if __name__ == '__main__':
    import sys

    do_reap()

    if '--watch' in sys.argv:
        import time
        while True:
            time.sleep(60)
            print('checking...')
            do_reap()

