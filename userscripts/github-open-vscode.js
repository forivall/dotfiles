// compress with terser `compress: {unsafe: true}`
(async () => {
  /*@__NOINLINE__*/
  const { DEFAULT_CWD, PERSONAL_TOKEN } = {
    DEFAULT_CWD: '',
    PERSONAL_TOKEN: '',
  };
  const pathBase = document.location.pathname;
  const [owner, repoName, resource, prNumber] = pathBase
    .replace(/^\//, '')
    .split('/');
  const storagePrefix = 'userscript-vscode-repo-dir';
  const storageKey = `${storagePrefix}.${JSON.stringify(
    `${owner}/${repoName}`,
  )}`;
  const container = document.querySelector('.subnav-search, .gh-header-meta');
  const localRepoInput = document.createElement('input');
  localRepoInput.type = 'text';
  localRepoInput.className =
    'form-control input-block pl-5 js-filterable-field';
  localRepoInput.placeholder = 'local repo root';
  localRepoInput.setAttribute('aria-label', 'local repo root');
  let cwd =
    localStorage.getItem(storageKey) ||
    localStorage.getItem(storagePrefix) ||
    DEFAULT_CWD;
  localRepoInput.value = cwd;
  localRepoInput.onchange = () => {
    cwd = localRepoInput.value;
    localStorage.setItem(storageKey, cwd);
  };

  const isFilesPage = container?.classList.contains('subnav-search');
  if (container) {
    container.appendChild(localRepoInput);
  }
  const gqlQuery = /*graphql*/ `{
    repository(name: $name, owner: $owner) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            line
            path
            id
            comments(first: 100) {
              nodes {
                id
                url
              }
            }
            subjectType
          }
          totalCount
          pageInfo {
            hasNextPage
            startCursor
          }
        }
      }
    }
  }`
    .replace(/\n  /g, ' ')
    .replace(/   /g, ' ')
    .replace(/   /g, ' ')
    .replace(/   /g, ' ')
    .replaceAll(' }', '}')
    .replaceAll('{ ', '{')
    .replaceAll(') ', ')');
  /** @type {{anchor: HTMLAnchorElement, loc: string, hash?: string | null, lineNumber?: string }[]} */
  const anchors = [];
  if (!isFilesPage) {
    const apiQuery =
      PERSONAL_TOKEN &&
      repoName &&
      owner &&
      resource === 'pull' &&
      Number(prNumber) &&
      gqlQuery.replace(
        /\$\w+/g,
        (
          (vars) => (/** @type {string} */ n) =>
            JSON.stringify(vars[n])
        )({ $name: repoName, $owner: owner, $pr: Number(prNumber) }),
      );
    const apiResponse =
      apiQuery &&
      (await fetch('https://api.github.com/graphql', {
        method: 'POST',
        headers: {
          accept: 'application/vnd.github.merge-info-preview+json',
          authorization: `bearer ${PERSONAL_TOKEN}`,
          'User-Agent': 'github-open-vscode bookmarklet',
        },
        body: JSON.stringify({ query: apiQuery }),
      }));
    /** @typedef {0 | '' | false | null | undefined} Falsey */
    /**
     * @typedef ReviewThreadNode
     * @property line
     * @property {string} path
     * @property {string} id
     * @property {{ nodes: { id: string, url: string }[]}} comments
     * @property {string} subjectType
     */
    /** @type {Falsey | { data: { repository: { pullRequest: { reviewThreads: { nodes: ReviewThreadNode[] } } } } }} */
    const apiResponseBody = apiResponse && (await apiResponse.json());
    const reviewThreads = apiResponseBody
      ? apiResponseBody.data.repository.pullRequest.reviewThreads.nodes
      : [];
    const selector = `.js-comment-container a[href^=${JSON.stringify(
      `${pathBase}/files`,
    )}]`;
    /** @type {NodeListOf<HTMLAnchorElement>} */
    const commentLinks = document.querySelectorAll(selector);
    commentLinks.forEach((element) => {
      const summary = element.closest('summary');
      /** @type {NodeListOf<HTMLAnchorElement> | undefined} */
      const commentLinks = summary?.parentElement?.querySelectorAll(
        'a[href^="#discussion"]',
      );
      const commentHrefs = new Set(
        [...(commentLinks ?? [])].map((anchor) => anchor.href),
      );
      const loc =
        reviewThreads.find((thread) =>
          thread.comments.nodes.some((it) => commentHrefs.has(it.url)),
        )?.path || element.innerText?.trim();

      /** @type {HTMLElement | null | undefined} */
      const lineNumberElement = summary?.nextElementSibling?.querySelector(
        '.blob-num-addition[data-line-number]',
      );
      const lineNumber = lineNumberElement?.dataset.lineNumber;
      const anchor = document.createElement('a');
      anchor.innerText = 'open';
      let href = `vscode://file${cwd}/${loc}`;
      if (lineNumber) {
        href += `:${lineNumber}`;
      }
      anchor.href = href;
      anchor.className = 'Link--onHover color-fg-muted ml-2 mr-2';
      anchors.push({ anchor, loc, lineNumber });
      element.parentElement?.classList.remove('mr-3');
      element.after(anchor);
    });
  }
  /** @typedef {HTMLElement & { value: string }} ClipboardCopyElement */
  /** @type {NodeListOf<ClipboardCopyElement>} */
  const copyElements = document.querySelectorAll('clipboard-copy');
  copyElements.forEach((element) => {
    const anchor = document.createElement('a');
    const loc = element.value;
    /** @type {Element & Partial<Pick<HTMLAnchorElement, 'href'>> | null} */
    const linkanchor = element.previousElementSibling;
    /** @type {HTMLElement | null | undefined} */
    const lineNumberElement = element
      .closest('.js-file')
      ?.querySelector('.blob-num-addition[data-line-number]');
    const lineNumber = lineNumberElement?.dataset.lineNumber;
    let href = `vscode://file${cwd}/${loc}`;
    if (lineNumber) {
      href += `:${lineNumber}`;
    }
    const hash = linkanchor?.getAttribute('href');
    anchor.innerText = 'open';
    anchor.href = href;
    anchor.className = 'Link--onHover color-fg-muted ml-2 mr-2';
    anchors.push({ anchor, loc, hash });
    element.after(anchor);
  });

  let currenthash = '';
  const update = () => {
    anchors.forEach(({ anchor, loc, hash, lineNumber }) => {
      let href = `vscode://file${cwd}/${loc}`;
      if (hash && currenthash.startsWith(hash)) {
        const hashLineNumber = currenthash.slice(hash.length + 1).split('-')[0];
        if (hashLineNumber) {
          lineNumber = hashLineNumber;
        }
      }
      if (lineNumber) {
        href += `:${lineNumber}`;
      }
      anchor.href = href;
    });
  };

  localRepoInput.onblur = update;
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
