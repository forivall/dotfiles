/// <reference types="@manuelpuyol/turbo" />
/// <reference types="navigation-api-types" />
// use terser compress: {evaluate: false, reduce_vars: false},
(async () => {
  const DEFAULT_CWD = '';
  /** @type {string} */
  const PERSONAL_TOKEN = '';
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
  container.appendChild(localRepoInput);

  /** @type {{anchor: HTMLAnchorElement, loc: string, hash?: string | null}[]} */
  const anchors = [];
  if (!isFilesPage) {
    const apiQuery =
      PERSONAL_TOKEN &&
      repoName &&
      owner &&
      resource === 'pull' &&
      Number(prNumber) &&
      /*graphql*/ `{
      repository(name: ${JSON.stringify(repoName)}, owner: ${JSON.stringify(
        owner,
      )}) {
        pullRequest(number: ${JSON.stringify(Number(prNumber))}) {
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
    }`.replace(/\n */g, ' ');
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
    const apiResponseBody = apiResponse && (await apiResponse.json());
    const reviewThreads = apiResponseBody
      ? apiResponseBody.data.repository.pullRequest.reviewThreads.nodes
      : [];
    const selector = `.js-comment-container a[href^=${JSON.stringify(
      `${pathBase}/files`,
    )}]`;
    document.querySelectorAll(selector).forEach((element) => {
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

      const lineNumber = summary?.nextElementSibling?.querySelector(
        '.blob-num-addition[data-line-number]',
      )?.dataset.lineNumber;
      const anchor = document.createElement('a');
      anchor.innerText = 'open';
      let href = `vscode://file${cwd}/${loc}`;
      if (lineNumber) {
        href += `:${lineNumber}`;
      }
      anchor.href = href;
      anchor.className = 'Link--onHover color-fg-muted ml-2 mr-2';
      anchors.push({ anchor, loc });
      element.parentElement?.classList.remove('mr-3');
      element.after(anchor);
    });
  }
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
        anchor.href = `vscode://file${cwd}/${loc}:${
          currenthash.slice(hash.length + 1).split('-')[0]
        }`;
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
