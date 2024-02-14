/**
 * @param {TemplateStringsArray} strings
 * @param {string[][]} args
 */
const expandPattern = (strings, ...args) =>
  args.reduce(
    (result, current, i) =>
      current.flatMap((s) =>
        result.map((prefix) => prefix + s + strings[i + 1])
      ),
    [strings[0]]
  )

const patterns = {
  '*.js': [
    ...expandPattern`$\{capture}${[
      '.spec',
      '.integration.spec',
      '.integration.test-*',
      '.integration.*.spec',
      '.test',
    ]}.${['js', 'ts']}`,
    '${capture}.js.map',
  ].join(','),
  '*.ts':  [
    ...expandPattern`$\{capture}${[
      '.spec',
      '.integration.spec',
      '.integration.test-*',
      '.test',
      '-ci.test',
    ]}.${['js', 'ts']}`,
    '${capture}.js.map',
  ].join(','),
  '.eslintrc.json': '.eslintrc.*.json',
  'package.json': [
    'package-lock.json',
    'yarn.lock',
    'pnpm-lock.yaml',
  ].join(','),
  'tsconfig.json': 'tsconfig.*.json',
}

module.exports.expandPattern = expandPattern

console.log(JSON.stringify(patterns, null, 2))
