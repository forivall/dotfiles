#!/usr/bin/env node
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

const THIS_FILE = fileURLToPath(import.meta.url);
const THIS_DIR = path.dirname(THIS_FILE);
const SERVICE_NAME = 'com.forivall.ambient-light-scriptable';

const execFileAsync = util.promisify(child.execFile);

{
  const binDir = path.dirname(process.execPath);
  const splitPath = process.env.PATH.split(':');
  if (!splitPath.includes(binDir)) {
    process.env.PATH = [...splitPath, binDir].join(':');
  }
}

const arg = process.argv[2];
if (arg === 'server') {
  server();
} else {
  const explicitRegister = arg === 'register';
  const LOGFILE = `${THIS_DIR}/ambient-light.log`;
  const SERVICE_FILE = userStartup.getFile(SERVICE_NAME);
  const registered = fs.existsSync(SERVICE_FILE);
  if (explicitRegister || !registered) {
    if (explicitRegister) console.log(SERVICE_FILE, registered);
    userStartup.remove(SERVICE_NAME);
    userStartup.add(
      SERVICE_NAME,
      process.execPath,
      [...process.execArgv, THIS_FILE, 'server'],
      LOGFILE,
    );
    child.execFileSync('sleep', ['1'], { stdio: 'inherit' });
    child.execFileSync('launchctl', ['load', SERVICE_FILE], {
      stdio: 'inherit',
    });
    child.execFileSync('sleep', ['1'], { stdio: 'inherit' });
  }
  child.execFileSync(
    'launchctl',
    ['kickstart', `gui/${process.getuid()}/${SERVICE_NAME}`],
    { stdio: 'inherit' },
  );
  if (!explicitRegister) {
    spawnDetached('tail', ['-f', LOGFILE]);
  }
}

/**
 *
 * @param {NodeJS.ReadableStream} stream
 */
async function streamToPromise(stream) {
  let len = 0;
  let buf = '';
  for await (const chunk of stream) {
    len += chunk.length;
    if (len > 5000) {
      throw new HttpError(413);
    }
    buf += chunk.toString('utf8');
  }
  return buf;
}

/**
 * @param {string} command
 * @param {string[]} args
 */
function spawnDetached(command, args = []) {
  const dtachSession = `/tmp/${SERVICE_NAME}.dtach`;
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

class HttpError extends Error {
  /**
   * @param {number} code
   */
  constructor(code) {
    super(http.STATUS_CODES[code] || 'Unknown');
    this.code = code;
  }
}
async function server() {
  /** @param {string} a */
  function arg(a) {
    const i = process.argv.indexOf(a, 2);
    if (i >= 0) return process.argv[i + 1];
    const j = process.argv.findIndex((r, i) => i >= 2 && r.startsWith(`${a}=`));
    if (j >= 0) return process.argv[j].slice(a.length + 1);
  }

  const PORT = parseInt(arg('--port'), 10) || 45967;
  const INTERVAL = 3000;

  const lmutracker = path.resolve(
    THIS_DIR,
    '../util/macos-ambient-light-sensor/lmutracker',
  );

  const events = new EventEmitter();

  let currentBrightness = 0;
  let darknessThreshold = 0;
  let lastUpdate = 0;
  let shutdown = false;

  /** @type {child.ChildProcessWithoutNullStreams} */
  let c;
  function startTracker() {
    c = child.spawn(lmutracker, ['-w'], {
      stdio: 'pipe',
    });

    c.stdout.on('data', (/** @type {Buffer} */ value) => {
      lastUpdate = Date.now();
      const old = currentBrightness;
      currentBrightness = parseFloat(value.toString().trim());
      if (currentBrightness !== old) {
        events.emit('currentBrightness', currentBrightness);
      }
    });

    c.once('exit', (code, signal) => {
      if (!shutdown) {
        startTracker();
      }
    });
  }
  startTracker();

  async function updateThreshold() {
    const dmbPref = `${os.homedir()}/Library/Preferences/codes.rambo.DarkModeBuddy.plist`;
    const result = await execFileAsync('plutil', [
      '-extract',
      'darknessThreshold',
      'raw',
      dmbPref,
    ]);
    darknessThreshold = parseFloat(result.stdout.trim());
    return darknessThreshold;
  }

  /**
   * @template R
   * @template {unknown[]} A
   * @param {(...args: A) => R} fn
   * @param {A} args
   * @returns {Promise<Awaited<R>>}
   */
  async function tryCall(fn, ...args) {
    try {
      return await fn(...args);
    } catch (err) {
      console.warn(`Error in ${fn.name}`);
    }
  }

  const html = () => /*html*/ `<!DOCTYPE html>
<head>
  <style type="text/css">
    html, body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
      background: #CCC;
      min-height: 80svh;
    }
    body {
      display: flex;
      align-items: center;
      justify-items: center;
      justify-content: center;
    }
    main {
      font-size: 80pt;
      width: 50vw;
    }
    #value {
      font-weight: 1000;
    }
    #unit {
      font-size: 56pt;
      font-weight: 200;
      opacity: 0.5;
    }
    #threshold {
      font-size: 32pt;
      font-weight: 300;
      font-style: italic;
      opacity: 0.3;
      text-decoration: overline;
    }
    @media (prefers-color-scheme: dark) {
      html, body {
        background: #333;
        color: white;
      }
    }
    button {
      float: right;
    }
  </style>
</head>
<body>
<main id="content">
  <div>
    <span id="value">${currentBrightness}</span><span id="unit"> lux</span>
  </div>
  <button>&nbsp;&nbsp;&nbsp;</button>
  <div>
    <span id="threshold">${
      darknessThreshold ? darknessThreshold.toFixed(1) : ''
    }</span>
  </div>
</main>
<script src="./ambient-light.web.js"></script>
</body>`;

  /**
   * @param {http.ServerResponse} res
   * @returns {(error: Partial<NodeJS.ErrnoException>) => void}
   */
  const errorHandler = (res) => (error) => {
    console.error(error);
    if (res.headersSent) {
      if (!res.closed) {
        res.end();
      }
      return;
    }
    res.statusCode =
      typeof error.code === 'number'
        ? error.code
        : error.code === 'ENOENT'
        ? 404
        : 500;
    res.statusMessage = http.STATUS_CODES[res.statusCode];
    res.setHeader('Content-Type', 'text/plain');
    res.write(util.inspect(error));
    res.end();
  };

  /** @satisfies {Record<string, (res: http.ServerResponse, req: http.IncomingMessage) => Promise<void>} */
  const routes = {
    '/ambient-light.web.js': async (res, req) => {
      if (req.method !== 'GET') throw new HttpError(405);
      const rawContent = await fs.promises.readFile(
        `${THIS_DIR}/ambient-light.web.js`,
        'utf8',
      );
      const content = rawContent
        .replace(/(?<=\bconst PORT = )\d+/, `${PORT}`)
        .replace(/(?<=\bconst INTERVAL = )\d+/, `${INTERVAL}`);

      res.statusCode = 200;
      res.statusMessage = 'OK';
      res.setHeader('Content-Type', 'text/javascript');
      res.write(content);
      res.end();
    },
    '/currentBrightness': async (res, req) => {
      if (req.method !== 'GET') throw new HttpError(405);
      await tryCall(updateThreshold);
      console.log(new Date(lastUpdate).toISOString(), currentBrightness);

      res.statusCode = 200;
      res.statusMessage = 'OK';
      res.setHeader('Content-Type', 'application/json');
      res.write(JSON.stringify({ currentBrightness, darknessThreshold }));
      res.end();
    },
    '/currentBrightness.html': async (res, req) => {
      if (req.method !== 'GET') throw new HttpError(405);
      await tryCall(updateThreshold);

      res.statusCode = 200;
      res.statusMessage = 'OK';
      res.setHeader('Content-Type', 'text/html');
      res.write(html());
      res.end();
    },
    '/darkMode': async (res, req) => {
      if (req.method === 'GET') {
        const status = (
          await execFileAsync('/opt/homebrew/bin/dark-mode', ['status'])
        ).stdout.trim();
        res.statusCode = 200;
        res.statusMessage = 'OK';
        res.setHeader('Content-Type', 'application/json');
        res.write(JSON.stringify({ status }));
        res.end();
      }
      if (
        req.method !== 'POST' ||
        req.headers['content-type'] !== 'application/json'
      ) {
        throw new HttpError(400);
      }

      const body = await pipeline(req, streamToPromise);
      const { setting } = JSON.parse(body);
      if (typeof setting !== 'string') {
        throw new HttpError(400);
      }

      await execFileAsync('dark-mode', setting === 'toggle' ? [] : [setting]);
    },
  };

  const server = http.createServer(async (req, res) => {
    const now = new Date().toISOString();
    console.log(now, req.method, req.url, req.headers);
    const url = new URL(req.url, `http://localhost:${PORT}`);
    const wait = url.searchParams.get('wait');
    if (wait) {
      await new Promise((resolve) =>
        setTimeout(resolve, parseInt(wait, 10) || 0),
      );
    }
    /** @type {typeof routes[keyof typeof routes] | undefined} */
    const handler = routes[url.pathname];
    if (handler) {
      handler(res, req).catch(errorHandler(res));
    } else {
      res.statusCode = 404;
      res.statusMessage = 'Not Found';
      res.write('Not Found');
      res.end();
    }
    res.on('finish', () => {
      console.log(now, res.statusCode, { ...res.getHeaders() });
    });
  });

  /** @type {typeof import('ws') | undefined} */
  let ws;
  /** @type {import('ws').WebSocketServer | undefined} */
  let wss;
  try {
    ws = await import('ws');
  } catch (err) {
    if (err.code !== 'ERR_MODULE_NOT_FOUND') {
      throw err;
    }
  }
  if (ws) {
    wss = new ws.WebSocketServer({ server, clientTracking: true });
    wss.on('connection', (socket) => {
      const listener = () => {
        socket.send(JSON.stringify({ currentBrightness }));
      };
      events.on('currentBrightness', listener);
      socket.once('close', () => {
        events.off('currentBrightness', listener);
      });
    });
  }

  server.listen(PORT, () => {
    console.log(`listening on ${PORT}`);
  });

  /** @type {NodeJS.SignalsListener} */
  const handleTermination = (signal) => {
    shutdown = true;
    c.kill(signal);
    wss.clients.forEach((socket) => {
      socket.close(1012, signal);
    });
    wss.close();
    server.close();
    process.exitCode = { SIGINT: 128 + 2, SIGTERM: 128 + 15 }[signal] || 1;
  };
  process.once('SIGINT', handleTermination);
  process.once('SIGTERM', handleTermination);
}
