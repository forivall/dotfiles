(function () {
  const PORT = 45967;
  const INTERVAL = 3000;

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
})();
