/** biome-ignore-all lint/suspicious/noAssignInExpressions: partially minified bookmarklet */
/** biome-ignore-all lint/suspicious/useIterableCallbackReturn: smaller arrow statements */
/** biome-ignore-all lint/correctness/noInnerDeclarations: i know what im doing */
// terser: { ecma: 2015, compress: { defaults: false, }, mangle: false }
((go) => {
  var s =
     document.querySelector("body script:last-of-type") ||
     document.createElement("script");
  s.innerText = `(${go.toString()})();`;
  document.body.appendChild(s);
})(() => {
  document.location.protocol === "about:" && (document.title = "Scratchpad");
  /** @type {Record<string, HTMLElement> & { c: HTMLInputElement }} */
  var { s, c, d } = window.___scd ?? {};

  s ||= document.querySelector("head style") || document.createElement("style");
  s.innerText ||=
    "@media(prefers-color-scheme:dark){html{background-color:rgba(0, 0, 0, 0);}body{color:#eee;}a{color:rgb(29, 155, 209);}}" +
    "body{font-family:sans-serif;}.toggle-editable{position:absolute;top:4px;right:4px;}.content{height:-webkit-fill-available;}" +
    ".c-link:hover{text-decoration:underline;}.c-link[style]:hover{text-decoration-line:revert!important;}";
  document.head.appendChild(s);

  c ||= document.querySelector("input.toggle-editable") || document.createElement("input");
  c.type = "checkbox";
  c.className = "toggle-editable";
  c.onchange = () => {
    d.contentEditable = c.checked;
  };
  document.body.appendChild(c);

  d ||= document.querySelector("main.content") || document.createElement("main");
  if (document.location.protocol === "about:") {
    if (document.location.hash) {
     d.innerHTML = decodeURIComponent(document.location.hash.slice(1));
    }
    window.onhashchange = () => {
     d.innerHTML = decodeURIComponent(document.location.hash.slice(1));
    };
    d.oninput = () => {
      var newurl =
       document.location.href.slice(0, -document.location.hash.length) +
       "#" +
       encodeURIComponent(d.innerHTML);
      try {
       history.replaceState(null, "", newurl);
      } catch {}
    };
    d.onblur = () => {
      document.location.hash = "#" + encodeURIComponent(d.innerHTML);
    };
  } else if (document.location.protocol === "file:") {
    var h;
    if (
     document.location.hash &&
     (h = window.localStorage.getItem(
      `scratchpad-${document.location.pathname}${document.location.hash}`,
     ))
    ) {
      d.innerHTML = h;
    }
    window.onhashchange = () => {
     h = window.localStorage.getItem(
      `scratchpad-${document.location.pathname}${document.location.hash}`,
     );
      h && (d.innerHTML = h);
    };
    d.oninput = () => {
      const i = parseInt(document.location.hash.slice(1), 10);
      const n = ((i || 0) + 1) % 100;
      window.localStorage.setItem(
      `scratchpad-${document.location.pathname}#${n}`,
      d.innerHTML,
     );
    };
    d.onblur = () => {
      const i = parseInt(document.location.hash.slice(1), 10);
      const n = ((i || 0) + 1) % 100;
      window.localStorage.setItem(
      `scratchpad-${document.location.pathname}#${n}`,
      d.innerHTML,
     );
      document.location.hash = `#${n}`;
    };
  }
  window.onbeforeunload = /** @type {() => void} */ (d.onblur);
  var pastedata;
  d.onpaste = (e) => {
    pastedata = e.clipboardData;
  };
  d.onbeforeinput = (e) => {
    if (e.inputType !== "insertFromPaste") return;
    var s = window.getSelection();
    if (!s.rangeCount || s.isCollapsed) return;
    var d = e.dataTransfer || window.clipboardData || pastedata;
    var text = d.getData("text").trim();
    if (/^https?:\/\/|^file:/i.test(text)) {
     e.preventDefault();
     var r = s.getRangeAt(0);
     var a = document.createElement("a");
     a.target = "_blank";
     a.href = text;
     // try { r.surroundContents(a); } catch { a.appendChild(r.extractContents()); r.insertNode(a); }
     // s.removeAllRanges();
     // r = document.createRange();
     // r.selectNodeContents(a);
     // r.collapse(false);
     // s.addRange(r);
      var c = r.startContainer, o = r.startOffset;
      a.appendChild(r.cloneContents());
      document.execCommand("insertHTML", false, a.outerHTML);
      var a2 = c.childNodes[o] || c.previousSibling;
      r = document.createRange();
      r.selectNodeContents(a2);
      r.collapse(false);
      s.addRange(r);
    }
  };
  d.className = "content";
  document.body.appendChild(d);

  window.___scd = { s, c, d };

  document.querySelectorAll("body script")
    .forEach((s) => document.body.appendChild(s));
});
