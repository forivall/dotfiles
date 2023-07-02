const PORT = 45967;
const INTERVAL = 3000;

async function getBrightness(wait) {
  let url = `http://localhost:${PORT}/currentBrightness`;
  if (wait) url += `?wait=${wait}`;
  let req = new Request(url);
  let json = await req.loadJSON();
  return json;
}

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
    wv.evaluateJavaScript(`document.getElementById('value').innerText = '${json.currentBrightness}'`);
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
      background: ${config.runsInApp ? '#CCC' : 'transparent'};
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
        background: ${config.runsInApp ? '#333' : 'transparent'};
        color: white;
      }
    }
  </style>
</head>
<body>
<main id="content"><span id="value">${json.currentBrightness}</span><span id="unit"> lux</span></main>
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
</body>
`

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
