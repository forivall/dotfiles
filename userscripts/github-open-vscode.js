/// <reference types="@manuelpuyol/turbo" />
/// <reference types="navigation-api-types" />
(() => {
  const DEFAULT_CWD = '';
  const storageKey = 'userscript-vscode-repo-dir';
  const container = document.querySelector('.subnav-search');
  const localRepoInput = document.createElement('input');
  localRepoInput.type = 'text';
  localRepoInput.className =
    'form-control input-block pl-5 js-filterable-field';
  localRepoInput.placeholder = 'local repo root';
  localRepoInput.setAttribute('aria-label', 'local repo root');
  let cwd = localStorage.getItem(storageKey) || DEFAULT_CWD;
  localRepoInput.value = cwd;
  localRepoInput.onchange = () => {
    cwd = localRepoInput.value;
    localStorage.setItem(storageKey, cwd);
  };

  container.appendChild(localRepoInput);

  /** @type {{anchor: HTMLAnchorElement, loc: string, hash?: string | null}[]} */
  const anchors = [];
  document.querySelectorAll('clipboard-copy').forEach((element) => {
    const anchor = document.createElement('a');
    const loc = element.value;
    /** @type {Element & Partial<Pick<HTMLAnchorElement, 'href'>> | null} */
    const linkanchor = element.previousElementSibling;
    const hash = linkanchor?.getAttribute('href');
    anchor.innerText = 'open';
    anchor.href = `vscode://file${cwd}/${loc}`;
    anchor.className = 'Link--onHover color-fg-muted ml-2 mr-2';
    anchors.push({ anchor, loc, hash });
    element.after(anchor);
  });

  let currenthash = '';
  const update = () => {
    anchors.forEach(({ anchor, loc, hash }) => {
      if (hash && currenthash.startsWith(hash)) {
        anchor.href = `vscode://file${cwd}/${loc}:${currenthash.slice(
          hash.length + 1,
        )}`;
      } else {
        anchor.href = `vscode://file${cwd}/${loc}`;
      }
    });
  };

  localRepoInput.onblur = update;
  /** @type {typeof import('@manuelpuyol/turbo')} */
  // const Turbo = window.Turbo;
  // Turbo.navigator.history.onPopState
  if (window.navigation) {
    window.navigation.onnavigate = (ev) => {
      const u = new URL(ev.destination.url);
      if (u.hash) {
        currenthash = u.hash;
        update();
      }
    };
  }
})();
