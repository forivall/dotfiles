/* WARNING */
/* THIS FEATURE IS POTENTIALLY DANGEROUS */
/* IF YOU ARE NOT A DEVELOPER CLOSE THIS EDITOR NOW */

// Write some custom JavaScript here...

/* global window */
/* eslint-disable yoda */
/// <reference path="./notable-custom.d.ts" />

const path = require('path');
const fsp = require('fs/promises');

if (typeof window.__themeListenerUnsubscribe === 'function') {
  window.__themeListenerUnsubscribe();
  window.__themeListenerUnsubscribe = undefined;
}

const configFilename = path.join(
  process.env.HOME || require('os').homedir(),
  '.config/notable/settings.json',
);
/** @param {boolean} isDark */
const setTheme = async (isDark) => {
  const theme = isDark ? 'dark' : 'light';
  const config = JSON.parse(await fsp.readFile(configFilename, 'utf8'));
  if (config.themes.active !== theme) {
    config.themes.active = theme;
    await fsp.writeFile(
      configFilename,
      JSON.stringify(config, null, 2),
      'utf8',
    );
  }
};

const mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)');
setTheme(mediaQueryList.matches);
/** @param {MediaQueryListEvent} change */
const listener = async (change) => {
  await setTheme(change.matches);
};
mediaQueryList.addEventListener('change', listener);

window.__themeListenerUnsubscribe = () => {
  mediaQueryList.removeEventListener('change', listener);
};

if (
  typeof window.__themeStyleMutationObserver === 'object' &&
  window.__themeStyleMutationObserver
) {
  window.__themeStyleMutationObserver.disconnect();
  window.__themeStyleMutationObserver = undefined;
}
/** @param {HTMLStyleElement} styleNode */
const isPrintThemeStyle = (styleNode) => {
  return styleNode.innerHTML.includes(
    '.viewbar{background-color: #ffffff !important',
  );
};
/** @param {boolean} value */
const setPrintThemeAttr = (value) => {
  document.firstElementChild.setAttribute('is-theme-print', `${value}`);
};
const mo = new MutationObserver((mutations) => {
  let isPrintTheme = false;
  for (const mutation of mutations) {
    if (mutation.type === 'childList') {
      const styleNode = mutation.target;
      isPrintTheme = isPrintThemeStyle(styleNode);
      if (isPrintTheme) {
        break;
      }
    }
  }
  setPrintThemeAttr(isPrintTheme);
});
/** @type {HTMLStyleElement | null} */
const style = document.querySelector('style[data-theme]');
if (style) {
  setPrintThemeAttr(isPrintThemeStyle(style));
  mo.observe(style, { childList: true });
}
window.__themeStyleMutationObserver = mo;
