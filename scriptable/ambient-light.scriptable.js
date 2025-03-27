const PORT = 45967;
const INTERVAL = 3000;

/**
 * @param {number} [wait]
 */
async function getBrightness(wait) {
  let url = `http://localhost:${PORT}/currentBrightness`;
  if (wait) url += `?wait=${wait}`;
  let req = new Request(url);
  let json = await req.loadJSON();
  return json;
}

/** @param {{ currentBrightness: number, darknessThreshold?: number }} json */
function createWidget(json) {
  let widget = new ListWidget();
  // const bg = new LinearGradient()
  // w.backgroundGradient = bg;

  let c = widget.addText('Ambient Light');
  c.font = Font.caption1();
  let s = widget.addStack();
  s.bottomAlignContent();
  let t = s.addText(`${json.currentBrightness}`);
  // t.font = Font.semiboldSystemFont(12 / 0.3);
  t.font = Font.blackSystemFont(38);
  let s2 = s.addStack();
  s2.setPadding(0, 0, 2, 0);
  let u = s2.addText('lux');
  u.textOpacity = 0.5;
  u.font = Font.lightSystemFont(28);
  widget.addSpacer();
  if (json.darknessThreshold) {
    let d = widget.addText(`${json.darknessThreshold.toFixed(1)}`);
    d.textOpacity = 0.3;
    d.font = Font.italicSystemFont(18);
  }
  widget.refreshAfterDate = new Date(Date.now() + INTERVAL);
  return { widget, text: t };
}

let json = await getBrightness();
const { widget, text } = createWidget(json);
Script.setWidget(widget);

let wv;
let doUpdate = async () => {
  json = await getBrightness();
  text.text = `${json.currentBrightness}`;
  if (wv) {
    wv.evaluateJavaScript(
      `document.getElementById('value').innerText = '${json.currentBrightness}'`,
    );
  }
};
const t = new Timer();
t.timeInterval = INTERVAL;
t.repeats = true;
t.schedule(doUpdate);

const html = /*html*/ `<!DOCTYPE html>
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
    <span id="value">${json.currentBrightness}</span><span id="unit"> lux</span>
  </div>
  <button>&nbsp;&nbsp;&nbsp;</button>
  <div>
    <span id="threshold">${
      json.darknessThreshold ? json.darknessThreshold.toFixed(1) : ''
    }</span>
  </div>
</main>
<script src="./ambient-light.web.js"></script>
</body>
<script>(function () {
  const PORT = ${PORT};
  const INTERVAL = ${INTERVAL};

  let valueEl = document.getElementById('value');
  let thresholdEl = document.getElementById('threshold');
  let buttonEl = document.querySelector('button');

  buttonEl.onclick = () => {
    fetch('/darkMode', {
      method: 'POST',
      body: JSON.stringify({ setting: 'toggle' }),
      headers: { 'Content-Type': 'application/json' },
    });
  }

  /** @param {{ currentBrightness: number, darknessThreshold?: number }} json */
  function updateDisplay(json) {
    valueEl.innerText = '' + json.currentBrightness;
    if (json.darknessThreshold) {
      thresholdEl.innerText = '' + json.darknessThreshold.toFixed(1);
    }
  }
  const ws = new WebSocket('ws://localhost:' + PORT + '/');
  ws.onmessage = (ev) => {
    const json = JSON.parse(ev.data);
    updateDisplay(json);
  };
  ws.onerror = () => {
    ws.close();
    update();
  };
  async function getBrightness() {
    const url = 'http://localhost:45967/currentBrightness';
    const res = await fetch(url);

    return await res.json();
  }
  async function update() {
    const json = await getBrightness();
    updateDisplay(json);
    setTimeout(update, INTERVAL);
  }
})();</script>
</body>
`;

if (!config.runsInWidget) {
  const url = `http://localhost:${PORT}/currentBrightness.html`;
  console.log('loadUrl ' + url);
  const size = new Size(200, 200);
  await WebView.loadHTML(html, `http://localhost:${PORT}/`, size);
  // wv = new WebView();
  // await wv.loadHTML(html, `http://localhost:${PORT}/`);
  // await wv.present();
  t.invalidate();
  Script.complete();
}
