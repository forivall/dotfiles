/* eslint-module */
import Module, { createRequire } from 'module'
import { fileURLToPath } from 'url'
import * as path from 'path'
import * as fs from 'fs'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const require = createRequire(import.meta.url)

import { version as prettierVersion, getSupportInfo } from 'prettier'
var prettierCliPath = require.resolve('prettier/internal/cli.mjs')
const prettierCliContents = fs.readFileSync(prettierCliPath, 'utf8')
fs.writeFileSync(
  path.resolve(__dirname, 'prettier_internal_cli.mjs'),
  prettierCliContents.replaceAll('from "../index.mjs"', 'from "prettier"') +
    /* js */ `
export {
  getContextOptions
}
`,
  'utf8',
)

const { getContextOptions } = await import('./prettier_internal_cli.mjs')

const contextOptions = await getContextOptions([])

/**
 * @typedef PrettierCliOption
 * @property {string} name
 * @property {"boolean" | "choice" | "int"} type
 * @property {string} [alias]
 * @property [default]
 * @property {string} [category]
 * @property {string} [description]
 * @property {string} [oppositeDescription]
 * @property {Array<string | { value: string, description?: string, deprecated?: boolean, redirect?: string }>} [choices]
 * @property {string | true} [deprecated]
 */

/** @typedef {import('prettier').SupportOption & { alias?: string }} CliOption */

/** @type {CliOption[]} */
const allOptions = [
  ...contextOptions.supportOptions,
  ...contextOptions.detailedOptions,
]

console.log('#compdef prettier')
console.log('# mode: Shell-Script')
console.log('# code: language=shellscript')
console.log('# vim:set filetype=sh:')

console.log(
  `# Completion script for eslint v${prettierVersion}. (https://prettier.io)`,
)
/**
 * @param {CliOption} option
 */
function prefix(option) {
  if (option.alias) {
    return `'(-${option.alias.length > 1 ? '-' : ''}${option.alias} --${
      option.name
    })'{-${option.alias},--${option.name}}`
  }
  return `--${option.name}`
}

const camelCase = (/** @type {string} */ s) =>
  s.toLowerCase().replace(/ (\s)/g, (_, c) => c.toUpperCase())
const snakeCase = (/** @type {string} */ s) =>
  s.toLowerCase().replace(/[[\] ]/g, '_')

console.log('local spec=(')

/**
 * @template K
 * @template V
 * @extends {Map<K, V[]>}
 */
class ArrayMap extends Map {
  /**
   * @param {K} key
   * @param {V} value
   */
  push(key, value) {
    const group = this.get(key)
    if (group) {
      return group.push(value)
    }
    this.set(key, [value])
    return 1
  }
}

/** @type {ArrayMap<string, CliOption>} */
const categoryMap = new ArrayMap([
  ['Config', []],
  ['Editor', []],
  ['Format', []],
  ['Other', []],
  ['Output', []],
  ['Global', []],
  ['Special', []],
])
for (const option of allOptions) {
  if (option.alias === '?') {
    continue
  }
  categoryMap.push(option.category, option)
}
for (const option of (function* () {
  for (const [category, options] of categoryMap) {
    console.log(`# ${category}`)
    yield* options
  }
})()) {
  const description = JSON.stringify(`[${option.description}]`)
    .replaceAll("'", "\\'")
    .replaceAll('`', '\\`')
  // TOOD: :config:_files' \ suffix for completion of arguments
  let subcompletion = ''
  let comment = ''
  let subcompleter
  if (option.type === 'choice') {
    if (option.choices) {
      subcompleter = `_values ${snakeCase(option.type)} ${option.choices.map((choice) => ('string' === typeof choice ? choice : choice.value)).join(' ')}`
    } else {
      subcompleter = '_default'
    }
  } else if (option.type === 'int') {
    subcompleter = '_numbers'
  } else if (option.type !== 'boolean') {
    subcompleter = '_default'
  }
  if (subcompleter) {
    subcompletion = `:${snakeCase(option.type)}:'${subcompleter}'`
  }
  if (comment) {
    comment = ` # ${comment}`
  }
  console.log(`  ${prefix(option)}${description}${subcompletion}${comment}`)
}
console.log("  '*:: :_files'")
console.log(')')
console.log('_arguments $spec && return 0')
