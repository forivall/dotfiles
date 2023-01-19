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

  const anchors = [];
  document.querySelectorAll('clipboard-copy').forEach((element) => {
    const anchor = document.createElement('a');
    const loc = element.value;
    anchor.innerText = 'open';
    anchor.href = `vscode://file${cwd}/${loc}`;
    anchor.className = 'Link--onHover color-fg-muted ml-2 mr-2';
    anchors.push({ anchor, loc });
    element.after(anchor);
  });

  localRepoInput.onblur = () => {
    anchors.forEach(({ anchor, loc }) => {
      anchor.href = `vscode://file${cwd}/${loc}`;
    });
  };
})();
