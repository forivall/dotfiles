// https://github.com/forivall/dotfiles/blob/osx/userscripts/github-review-keyboard-shortcuts.js
/* global document */
;(() => {
  /**
   * @param {{[key: string]: (ev: KeyboardEvent) => any}} handlers
   * @returns {(event: KeyboardEvent) => any}
   */
  const reviewKeyboardHandler = (handlers) => (event) => {
    if (!/\/files(?:\/[0-9a-f]{40}..[0-9a-f]{40})?$/.test(document.location.pathname)) return
    const ae = document.activeElement
    if (ae && ae.nodeName !== 'BODY') return
    const handler = handlers[event.key]
    return handler?.(event)
  }

  /** @type {string=} */
  let prev
  const getCurrentLink = () => {
    const { hash } = document.location;
    if (hash) {
      const m = /^#diff-[0-9a-f]+/.exec(hash);
      if (m) return m[0]
    }
    return prev;
  }
  
  /** @param a {HTMLAnchorElement | null} */
  const focusFile = (a) => {
    if (!a) return
    prev = a.href
    const h = new URL(prev).hash;
    // github a11y bug! it says expanded on initial page load even if it is hidden. So use the classes instead
    const wasExpanded = !document.querySelector(
      h + ' [aria-label="Toggle diff contents"] .octicon-chevron-right.Details-content--shown,' +
      h + ' [aria-label="Toggle diff contents"][aria-expanded="false"]'
    );
    a.click()
    if (wasExpanded) return;

    setTimeout(() => {
    /** @type {HTMLInputElement | null} */
    const t = document.querySelector(h + ' .js-reviewed-checkbox')
    if (t?.checked) {
      /** @type {HTMLButtonElement | null} */
      const expander = document.querySelector(h + ' [aria-label="Toggle diff contents"][aria-expanded="true"]');
      expander?.click();
    }}, 10)
  }
  const navHandler =
    /** @param {1 | -1} offset */
    (offset) => /** @param {KeyboardEvent} ev */ (ev) => {
      const h = getCurrentLink()
      if (!h) {
        /** @type {HTMLAnchorElement | null} */
        const a = document.querySelector('.file-info a[href^="#"]')
        return focusFile(a)
      }

      /** @type {NodeListOf<HTMLAnchorElement>} */
      const files = document.querySelectorAll('.file-info a[href^="#"]')
      const i = [...files].findIndex((a) => a.href.endsWith(h))
      return focusFile(files[i + offset])
    }
  const toggle = () => {
    const h = getCurrentLink()
    if (!h) return
    /** @type {HTMLElement | null} */
    const t = document.querySelector(h + ' .js-reviewed-toggle')
    t?.click()
  }

  document.onkeyup = reviewKeyboardHandler({
    j: navHandler(1),
    k: navHandler(-1),
    v: toggle,
    x: toggle,
    // D: () => { debugger }
  })
})()
