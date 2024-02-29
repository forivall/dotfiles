const Module = require('module');
const eslint = require('eslint');
const eslintOptionsFn = Module.createRequire(require.resolve('eslint'))('./options')
const { isMap } = require('util/types')


const getEslintOptions = new Function(
  'optionator',
  'return ' +
    Module.createRequire(require.resolve('eslint'))('./options').toString()
)((options) => options)

const baseOptions = getEslintOptions(false).options.filter((opt) => !opt.heading);
const flatConfigOptions = getEslintOptions(true).options.filter((opt) => !opt.heading && !baseOptions.some(baseOpt => baseOpt.option === opt.option))

/**
 * @typedef OptionatorOption
 * @property {string} option
 * @property {string} [alias]
 * @property {string} [type]
 * @property {string} description
 * @property {string[]} [enum]
 */

/** @type {OptionatorOption[]} */
const allOptions = [
  ...baseOptions,
  ...flatConfigOptions,
]

console.log('#compdef eslint')
console.log('# mode: Shell-Script')
console.log('# code: language=shellscript')
console.log('# vim:set filetype=sh:')

console.log(
  `# Completion script for eslint v${eslint.ESLint.version}. (https://eslint.org)`
)
/**
 * @param {OptionatorOption} option
 */
function prefix(option) {
  if (option.alias) {
    return `'(-${option.alias.length > 1 ? '-' : ''}${option.alias} --${option.option})'{-${option.alias},--${option.option}}`
  }
  return `--${option.option}`
}

const camelCase = (/** @type {string} */ s) =>
  s.toLowerCase().replace(/ (\s)/g, (_, c) => c.toUpperCase())
const snakeCase = (/** @type {string} */ s) =>
  s.toLowerCase().replace(/[[\] ]/g, '_')

console.log('local spec=(')

/** @type {Map<string, OptionatorOption[]>} */
const categoryMap = new Map()
for (const option of allOptions) {
  if (option.alias === '?') {
    continue
  }
  const description = JSON.stringify(`[${option.description}]`)
    .replaceAll("'", "\\'")
    .replaceAll('`', '\\`')
  // TOOD: :config:_files' \ suffix for completion of arguments
  let subcompletion = ''
  let comment = ''
  if (option.type && option.type !== 'Boolean') {
    const subcompleter = [
      'path::String',
      '[path::String]',
    ].includes(option.type)
      ? '_files' + (option.type === 'DIRECTORY' ? ' -/' : '')
      : option.enum
      ? `_values ${snakeCase(option.type)} ${option.enum.join(' ')}`
      : '_default'

    // if (subcompleter === '_default') console.warn(option)
    subcompletion = `:${snakeCase(option.type)}:'${subcompleter}'`
    // comment += ts.getDiagnosticText(option.type)
  }
  if (comment) {
    comment = ` # ${comment}`
  }
  console.log(`  ${prefix(option)}${description}${subcompletion}${comment}`)
}
console.log("  '*:: :_files'")
console.log(')')
console.log('_arguments $spec && return 0')
