/* global document */
;(() => {
  /**
   * @param {{[key: string]: (ev: KeyboardEvent) => any}} handlers
   * @returns {(event: KeyboardEvent) => any}
   */
  const reviewKeyboardHandler = (handlers) => (event) => {
    if (!document.location.pathname.endsWith('/files')) return
    const ae = document.activeElement
    if (ae && ae.nodeName !== 'BODY') return
    const handler = handlers[event.key]
    return handler && handler(event)
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
  const navHandler =
    /** @param {1 | -1} offset */
    (offset) => /** @param {KeyboardEvent} ev */ (ev) => {
      const h = getCurrentLink()
      if (!h) {
        /** @type {HTMLAnchorElement | null} */
        const a = document.querySelector('.file-info a[href^="#"]')
        if (!a) return
        prev = a.href
        a.click()
        return
      }

      /** @type {NodeListOf<HTMLAnchorElement>} */
      const files = document.querySelectorAll('.file-info a[href^="#"]')
      const i = [...files].findIndex((el) => el.href.endsWith(h))
      const a = files[i + offset]
      prev = a.href
      a.click()
    }

  document.onkeyup = reviewKeyboardHandler({
    j: navHandler(1),
    k: navHandler(-1),
    v: () => {
      const h = getCurrentLink()
      if (!h) return
      /** @type {HTMLElement | null} */
      const t = document.querySelector(h + ' .js-reviewed-toggle')
      t && t.click()
    },
    // D: () => { debugger }
  })
})()
