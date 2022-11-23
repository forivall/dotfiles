const api_v4 = async (query) => {
  const personalToken = '<TOKEN>'
  const response = await fetch('https://api.github.com/graphql', {
    headers: {
      'User-Agent': 'Refined GitHub',
      Authorization: `bearer ${personalToken}`,
      Accept: 'application/vnd.github.merge-info-preview+json',
    },
    method: 'POST',
    body: JSON.stringify({query: `{${query}}`}),
  })
  const apiResponse = await response.json()
  const {data = {}, errors = []} = apiResponse
  if (errors.length > 0) {
    throw new Error(
      'GraphQL: ' + errors.map((error) => error.message).join(', ')
    )
  }
  if (response.ok) {
    return data
  }
  throw new Error(apiResponse.message || 'Unknown Error')
}
const getAuthorDates = async (commits) => {
  const match = /^\/([^/]+)\/([^/]+)\//.exec(document.location.pathname)
  if (!match) throw new Error('repo not found')
  const [, owner, repo] = match
  const {repository} = await api_v4(/*graphql*/ `\
repository(owner: "${owner}", name: "${repo}") {\
${commits.map((commit) => /*graphql*/ `\
_${commit}: object(expression: "${commit}") {\
... on Commit {authoredDate}}`
  ).join('\n')}}`)
  return Object.values(repository).map((c) => c.authoredDate)
}
function getCommitHash(commit) {
  return commit.querySelector('a.markdown-title').pathname.split('/').pop()
}
;(async () => {
  const pageCommits = document.querySelectorAll(
    [
      '.js-commits-list-item',
      '[data-test-selector="pr-timeline-commits-list"] .TimelineItem', // `isPRConversation`
    ].join(',')
  )
  const commitHashes = new Array(pageCommits.length)
  pageCommits.forEach((commit, i) => {
    commitHashes[i] = getCommitHash(commit)
  })
  const authoredDates = await getAuthorDates(commitHashes)
  pageCommits.forEach((commit, i) => {
    const container = commit.querySelector('.commit-author')?.parentElement
    if (container) {
      const commitTime = container.querySelector('relative-time')
      const authorDate = authoredDates[i]
      if (commitTime?.getAttribute('datetime') !== authorDate) {
        const relTime = document.createElement('relative-time')
        relTime.setAttribute('datetime', authoredDates[i])
        container.append('(authored ', relTime, ')')
      }
    }
  })
})()
