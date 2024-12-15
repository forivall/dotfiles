import Module, { createRequire } from 'module'
import { fileURLToPath } from 'url'
import * as path from 'path'
import * as fs from 'fs'
import globalDir from 'global-directory';

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const require = createRequire(globalDir.npm.packages + '/dummy-global.js');

const herebyPackage = require('hereby/package.json');
const herebyCliPath = require.resolve('hereby/cli');
const herebyRequire = createRequire(herebyCliPath);

const herebyCliParseArgs = herebyRequire('./cli/parseArgs');


const getHerebyUsage = new Function(
  'commandLineUsage',
  'return ' +
  herebyCliParseArgs.getUsage.toString()
)((options) => options)



const herebyUsage = getHerebyUsage();
/** @type {import('command-line-usage').OptionDefinition[]} */
const herebyOptions = herebyUsage.flatMap((item) => item.optionList ?? [])

console.log('#compdef hereby')
console.log('# mode: Shell-Script')
console.log('# code: language=shellscript')
console.log('# vim:set filetype=sh:')

console.log(
  `# Completion script for hereby v${herebyPackage.version}. (https://npm.im/hereby)\n`
)
/**
 * @param {import('command-line-usage').OptionDefinition} option
 */
function prefix(option) {
  if (option.alias) {
    return `'(-${option.alias?.length > 1 ? '-' : ''}${option.alias} --${
      option.name
    })'{-${option.alias},--${option.name}}`
  }
  return `--${option.name}`
}

const snakeCase = (/** @type {string} */ s) =>
  s.toLowerCase().replace(/[[\:\] ]/g, '_')

console.log('_hereby() {')
console.log('  local spec=(')

for (const option of herebyOptions) {
  if (option.alias === '?') {
    continue
  }
  const description = JSON.stringify(`[${option.description}]`)
    .replaceAll("'", "\\'")
    .replaceAll('`', '\\`')
  let subcompletion = ''
  if (option.type && option.type !== Boolean) {
    const subcompleter =
      option.typeLabel === '{underline path}' ? '_files' : '_default'

    subcompletion = `:${snakeCase(option.type?.name || ' ')}:'${subcompleter}'`
  }
  console.log(`    ${prefix(option)}${description}${subcompletion}`)
}
console.log("    '*:: :_hereby_tasks'")
console.log('  )')
console.log('  _arguments $spec && return 0')
console.log('}')

console.log(`
_hereby_tasks () {
  _values tasks $(_call_program tasks hereby --tasks-simple)
}
`)

console.log('_hereby "$@"')
