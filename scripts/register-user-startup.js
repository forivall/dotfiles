#!/usr/bin/env node --experimental-toplevel-await
import child from 'node:child_process';
import os from 'node:os';
import EventEmitter from 'node:events';
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import util from 'node:util';
import userStartup from 'user-startup';
import { pipeline } from 'node:stream/promises';
import which from 'which';

const script = process.argv[2];
console.log(script)
const scriptName = script.replace(/\.py$/, '');
const serviceName = `com.forivall.${scriptName}`;
const logFile = path.resolve(`${scriptName}.log`);

const serviceFile = userStartup.getFile(serviceName);
const registered = fs.existsSync(serviceFile);
if (registered) {
  userStartup.remove(serviceName);
}
userStartup.add(
  serviceName,
  which.sync('pyenv'),
  ['exec', 'python3', fs.realpathSync(script)],
  logFile,
);

child.execFileSync('sleep', ['1'], { stdio: 'inherit' });
child.execFileSync('launchctl', ['load', serviceFile], {
  stdio: 'inherit',
});
child.execFileSync('sleep', ['1'], { stdio: 'inherit' });

child.execFileSync(
  'launchctl',
  ['kickstart', `gui/${process.getuid()}/${serviceName}`],
  { stdio: 'inherit' },
);

spawnDetached('tail', ['-f', logFile]);

/**
 * @param {string} command
 * @param {string[]} args
 */
function spawnDetached(command, args = []) {
  const dtachSession = `/tmp/${serviceName}.dtach`;
  child
    .spawn('dtach', ['-A', dtachSession, '-r', 'none', command, ...args], {
      shell: false,
      stdio: 'inherit',
    })
    .on('error', (err) => {
      if (err.code === 'ENOENT') {
        child
          .spawn(command, args, {
            detached: true,
            shell: false,
            stdio: 'inherit',
          })
          .unref();
      }
    })
    .on('spawn', () => {
      setTimeout(() => {
        console.log('$', 'dtach -a', dtachSession);
      });
    })
    .unref();
}
