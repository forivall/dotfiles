const ts = require('typescript')
const { isMap } = require('util/types')

/** @type {import('./types').CommandLineOption[]} */
const allOptions = [
  ...ts.optionsForBuild,
  ...ts.optionsForWatch,
  ...ts.optionDeclarations,
]

console.log('#compdef tsc')
console.log('# mode: Shell-Script')
console.log('# code: language=shellscript')
console.log('# vim:set filetype=sh:')

console.log(
  `# Completion script for tsc v${ts.version}. (https://www.typescriptlang.org/)`
)
/**
 * @param {import('./types').CommandLineOption} option
 */
function prefix(option) {
  if (option.shortName) {
    return `'(-${option.shortName} --${option.name})'{-${option.shortName},--${option.name}}`
  }
  return `--${option.name}`
}

const camelCase = (/** @type {string} */ s) =>
  s.toLowerCase().replace(/ (\s)/g, (_, c) => c.toUpperCase())
const snakeCase = (/** @type {string} */ s) =>
  s.toLowerCase().replace(/ /g, '_')

console.log('local spec=(')

/** @type {Map<string, import('./types').CommandLineOption[]>} */
const categoryMap = new Map()
for (const option of allOptions) {
  if (option.shortName === '?') {
    continue
  }
  const description = option.description
    ? JSON.stringify(
        `[${ts.getDiagnosticText(option.description).replace(/\.$/, '')}]`
      )
        .replaceAll("'", "\\'")
        .replaceAll('`', '\\`')
    : ''
  // TOOD: :config:_files' \ suffix for completion of arguments
  let subcompletion = ''
  let comment = ''
  if (option.paramType) {
    const subcompleter = [
      'FILE',
      'LOCATION',
      'FILE OR DIRECTORY',
      'DIRECTORY',
    ].includes(option.paramType.message)
      ? '_files' + (option.paramType.message === 'DIRECTORY' ? ' -/' : '')
      : isMap(option.type)
      ? `_values ${snakeCase(option.paramType.message)} ${[
          ...option.type.keys(),
        ].join(' ')}`
      : '_default'

    if (subcompleter === '_default') console.warn(option)
    subcompletion = `:${snakeCase(option.paramType.message)}:'${subcompleter}'`
    // comment += ts.getDiagnosticText(option.paramType)
  }
  if (comment) {
    comment = ` # ${comment}`
  }
  console.log(`  ${prefix(option)}${description}${subcompletion}${comment}`)
}
console.log("  '*:: :_files'")
console.log(')')
console.log('_arguments $spec && return 0')
