#!/usr/bin/env node
import child from 'node:child_process';
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const THIS_FILE = fileURLToPath(import.meta.url);
const PORT = 45967;
const INTERVAL = 3000;

const lmutracker = path.resolve(
  path.dirname(THIS_FILE),
  '../util/macos-ambient-light-sensor/lmutracker',
);

let currentBrightness = 0;
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
    currentBrightness = parseFloat(value.toString().trim());
  });

  c.once('exit', (code, signal) => {
    if (!shutdown) {
      startTracker();
    }
  });
}
startTracker();

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
    @media (prefers-color-scheme: dark) {
      html, body {
        background: #333;
        color: white;
      }
    }
  </style>
</head>
<body>
<main id="content"><span id="value">${currentBrightness}</span><span id="unit"> lux</span></main>
<script>(function() {
let valueEl = document.getElementById('value');
async function getBrightness() {
  let url = 'http://localhost:${PORT}/currentBrightness';
  let res = await fetch(url);

  let json = await res.json();
  return json;
}
;(async function update() {
  const json = await getBrightness();
  valueEl.innerText = '' + json.currentBrightness;
  setTimeout(update, ${INTERVAL});
})();

})();</script>
</body>`;

const server = http.createServer(async (req, res) => {
  console.log(new Date().toString(), req.method, req.url, req.headers);
  if (req.method !== 'GET') {
    res.statusCode = 400;
    res.statusMessage = 'Bad Request';
    res.end();
    return;
  }
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const wait = url.searchParams.get('wait');
  if (wait) {
    await new Promise((resolve) =>
      setTimeout(resolve, parseInt(wait, 10) || 0),
    );
  }
  switch (url.pathname) {
    case '/currentBrightness':
      console.log(new Date(lastUpdate).toString(), currentBrightness);
      res.statusCode = 200;
      res.statusMessage = 'OK';
      res.setHeader('Content-Type', 'application/json');
      res.write(JSON.stringify({ currentBrightness }));
      res.end();
      break;
    case '/currentBrightness.html':
      res.statusCode = 200;
      res.statusMessage = 'OK';
      res.setHeader('Content-Type', 'text/html');
      res.write(html());
      res.end();
      break;
    default:
      res.statusCode = 404;
      res.statusMessage = 'Not Found';
      res.write('Not Found');
      res.end();
  }
});

server.listen(PORT, () => {
  console.log(`listening on ${PORT}`);
});

/** @type {NodeJS.SignalsListener} */
const handleTermination = (signal) => {
  shutdown = true;
  c.kill(signal);
  server.close();
  process.exitCode = { SIGINT: 128 + 2, SIGTERM: 128 + 15 }[signal] || 1;
};
process.once('SIGINT', handleTermination);
process.once('SIGTERM', handleTermination);
