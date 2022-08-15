/* WARNING */
/* THIS FEATURE IS POTENTIALLY DANGEROUS */
/* IF YOU ARE NOT A DEVELOPER CLOSE THIS EDITOR NOW */

// Write some custom JavaScript here...

const path = require('path');
const fsp = require('fs/promises');

if (typeof window.__themeListenerUnsubscribe === 'function') {
  window.__themeListenerUnsubscribe();
  window.__themeListenerUnsubscribe = undefined;
}

const configFilename = path.join(process.env.HOME, '.config/notable/settings.json');
const mediaQueryList = window.matchMedia("(prefers-color-scheme: dark)")
/** @param {MediaQueryListEvent} change */
const listener = async (change) => {
  const config = JSON.parse(await fsp.readFile(configFilename, 'utf8'));
  const newTheme = change.matches ? 'dark' : 'light';
  if (config.themes.active !== newTheme) {
    config.themes.active = newTheme;
    await fsp.writeFile(configFilename, JSON.stringify(config, null, 2), 'utf8');
  }
}
mediaQueryList.addEventListener('change', listener);

window.__themeListenerUnsubscribe = () => {
  mediaQueryList.removeEventListener('change', listener);
}
