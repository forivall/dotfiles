// javascript:(async()=>{const e=e=>new Promise((t=>setTimeout(t,e)));var t='[bgid^="basic"]:not(.a7J)',c='[aria-label="Theme"] + button',o=document.querySelector(t),a=!o;if(!o){var r=document.querySelector(c);r||(document.querySelector('[data-tooltip="Settings"]').click(),await e(250),r=document.querySelector(c)),r.click(),await e(200),o=document.querySelector(t)}o.click(),a&&document.querySelector('[data-tooltip="Save & close"]').click()})();
(async () => {
  const wait = (e) => new Promise((t) => setTimeout(t, e));
  const newThemeSelector = '[bgid^="basic"]:not(.a7J)';
  let newThemeEl = document.querySelector(newThemeSelector);
  const wasMenuClosed = !newThemeEl;
  if (!newThemeEl) {
    var settingsButton;
    while (
      !(settingsButton = document.querySelector('[data-tooltip="Settings"]'))
    ) {
      wait(250);
    }
    settingsButton.click();
    var themeButton;
    while (
      !(themeButton = document.querySelector('[aria-label="Theme"] + button'))
    ) {
      await wait(250);
    }
    themeButton.click();
    while (!(newThemeEl = document.querySelector(newThemeSelector))) {
      await wait(200);
    }
    await wait(200);
  }
  newThemeEl.click();
  if (wasMenuClosed) {
    document.querySelector('[data-tooltip="Save & close"]').click();
  }
})();
