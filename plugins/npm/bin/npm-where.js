const prefix = process.argv[2]
process.argv[2] = 'where'

const table = require('table')
const {
  calculateMaximumColumnWidths,
} = require('table/dist/src/calculateMaximumColumnWidths')
const { relative, resolve } = require('path')
const Npm = require(`${prefix}/lib/node_modules/npm/lib/npm`)
const ArboristWorkspaceCmd = require(`${prefix}/lib/node_modules/npm/lib/arborist-cmd`)

/** @type {typeof import('@npmcli/arborist')} */
const Arborist = require(`${prefix}/lib/node_modules/npm/node_modules/@npmcli/arborist`)
const validName = require(`${prefix}/lib/node_modules/npm/node_modules/validate-npm-package-name`)
/** @type {typeof import('pacote')} */
const pacote = require(`${prefix}/lib/node_modules/npm/node_modules/pacote`)

/** @type {typeof import('npm-package-arg')} */
const npa = require(`${prefix}/lib/node_modules/npm/node_modules/npm-package-arg`)
const semver = require(`${prefix}/lib/node_modules/npm/node_modules/semver`)

async function main() {
  const npm = new Npm()
  await npm.load()
  npm.argv.shift()
  const command = new Where(npm)
  await command.exec(npm.argv)
}

class Where extends ArboristWorkspaceCmd {
  static description = 'Locate installed packages'
  static name = 'where'
  static usage = ['<package-spec>']
  static params = ['json', 'workspace']

  static ignoreImplicitWorkspace = false

  /**
   * @param {string[]} args
   */
  async exec(args) {
    if (!args.length) {
      throw this.usageError()
    }

    const arb = new Arborist({
      path: this.npm.prefix,
      ...this.npm.flatOptions,
    })
    const tree = await arb.loadActual()
    if (
      this.npm.flatOptions.workspacesEnabled &&
      this.workspaceNames &&
      this.workspaceNames.length
    ) {
      this.filterSet = arb.workspaceDependencySet(tree, this.workspaceNames)
    } else if (!this.npm.flatOptions.workspacesEnabled) {
      this.filterSet = arb.excludeWorkspacesDependencySet(tree)
    }

    const nodes = new Set()
    for (const arg of args) {
      for (const node of this.getNodes(tree, arg)) {
        const filteredOut =
          this.filterSet && this.filterSet.size > 0 && !this.filterSet.has(node)
        if (!filteredOut) {
          nodes.add(node)
        }
      }
    }
    if (nodes.size === 0) {
      throw new Error(`No dependencies found matching ${args.join(', ')}`)
    }

    const expls = []
    for (const node of nodes) {
      let expl = this.explain(node)
      expl.dependents = await Promise.all(
        expl.dependents.map(async (dep) => ({
          ...dep,
          latest: await pacote.manifest(`${dep.name}@${dep.spec}`),
        }))
      )
      expls.push(expl)
    }

    if (this.npm.flatOptions.json) {
      await this.npm.output(JSON.stringify(expls))
    } else {
      this.output(expls)
    }
  }

  /**
   * @param {import('@npmcli/arborist').Node} node
   */
  explain(node) {
    const {
      extraneous,
      dev,
      optional,
      devOptional,
      peer,
      inBundle,
      overridden,
    } = node
    /** @type {{version: string, dependents: any[]}} */
    const nodeExpl = node.explain()
    /**
     * @typedef {object} Expl
     * @property {string} version
     * @property {{type: string; name: string; spec: string; latest?: import('pacote').AbbreviatedManifest; from: { name: string, version: string; location: string; isWorkspace: boolean, linksIn: { link?: boolean }[]}}[]} dependents
     * @property {string} [location]
     * @property {boolean} [extraneous]
     * @property {boolean} [dev]
     * @property {boolean} [peer]
     * @property {boolean} [optional]
     * @property {boolean} [devOptional]
     * @property {boolean} [bundled]
     * @property {boolean} [overridden]
     * @property {boolean} [latest]
     */
    /** @type {Expl} */
    const expl = { ...nodeExpl }
    expl.dependents = expl.dependents.map((d) => ({
      ...d,
      from: {
        ...d.from,
        dependents: undefined,
        linksIn: d.from.linksIn?.map((l) => ({
          ...l,
          dependents: undefined,
        })),
      },
    }))
    if (extraneous) {
      expl.extraneous = true
    } else {
      expl.dev = dev
      expl.optional = optional
      expl.devOptional = devOptional
      expl.peer = peer
      expl.bundled = inBundle
      expl.overridden = overridden
    }
    return expl
  }

  /**
   * @param {Array<ReturnType<Where['explain']>>} expls
   */
  output(expls) {
    const flattened = expls.flatMap(
      ({ version, dependents, location, dev, peer, optional, devOptional }) => {
        const flags = peer
          ? 'peer'
          : devOptional
          ? 'devopt'
          : dev
          ? 'dev'
          : optional
          ? 'opt'
          : ''
        return dependents
          .map(({ spec, from, latest }) => ({
            spec,
            location: from.location,
            latest,
            update:
              !latest?.version || version === latest.version
                ? ''
                : latest.version,
          }))
          .map((dependent) => ({ version, flags, dependent, location }))
          .sort(
            (a, b) =>
              ~~a.dependent.location.startsWith('node_modules') -
              ~~b.dependent.location.startsWith('node_modules')
          )
      }
    )
    /** @type {typeof flattened[]} */
    const groups = Object.values(
      flattened.reduce(
        (
          r,
          v,
          i,
          a,
          k = `${v.dependent.spec}\t${v.version}\t${v.flags}\t${v.location}`
        ) => ((r[k] || (r[k] = [])).push(v), r),
        /** @type { [k: string]: typeof flattened } */
        {}
      )
    )
    const hasFlags = groups.some((g) => g[0].flags)
    const hasUpdate = groups.some((g) => g[0].dependent.update)
    const header = [
      'SPEC',
      'VERSION',
      ...(hasUpdate ? ['UPDATE'] : []),
      ...(hasFlags ? [''] : []),
      'LOCATION',
      'DEPENDENT(S)',
    ]
    const rows = groups.map((g) => [
      g[0].dependent.spec,
      g[0].version,
      ...(hasUpdate ? [g[0].dependent.update] : []),
      ...(hasFlags ? [g[0].flags] : []),
      g[0].location,
      g
        .map((it) => it.dependent.location)
        .map((l) => (l.startsWith('node_modules') ? l : this.npm.chalk.bold(l)))
        .join(' '),
    ])
    const data = [header, ...rows]
    const widths = calculateMaximumColumnWidths(data)
    /**
     * @template T
     * @typedef {{-readonly [K in keyof T]: T[K]}} Writable
     */
    /** @type {table.Indexable<Writable<table.ColumnUserConfig> & { width: number }>} */
    const columns = widths.map((width) => ({ width }))
    if (columns[0].width > 16) {
      columns[0].width = 16
      columns[0].wrapWord = true
    }
    const lastColumn = header.length - 1
    const space = widths.slice(0, -1).reduce((a, b) => a + b) + header.length
    columns[lastColumn].wrapWord = true
    columns[lastColumn].width = Math.min(
      columns[lastColumn].width,
      Math.max(80, process.stdout.columns) - space
    )

    this.npm.output(
      table.table(data, {
        columns,
        border: table.getBorderCharacters('void'),
        columnDefault: { paddingLeft: 0, paddingRight: 1 },
        drawHorizontalLine: () => false,
      })
    )
  }

  /**
   * @param {import('@npmcli/arborist').Node} tree
   * @param {string} arg
   * @returns {Iterable<import('@npmcli/arborist').Node>}
   */
  getNodes(tree, arg) {
    // if it's just a name, return packages by that name
    const { validForOldPackages: valid } = validName(arg)
    if (valid) {
      return tree.inventory.query('packageName', arg)
    }

    // if it's a location, get that node
    const maybeLoc = arg.replace(/\\/g, '/').replace(/\/+$/, '')
    const nodeByLoc = tree.inventory.get(maybeLoc)
    if (nodeByLoc) {
      return [nodeByLoc]
    }

    // maybe a path to a node_modules folder
    const maybePath = relative(this.npm.prefix, resolve(maybeLoc))
      .replace(/\\/g, '/')
      .replace(/\/+$/, '')
    const nodeByPath = tree.inventory.get(maybePath)
    if (nodeByPath) {
      return [nodeByPath]
    }

    // otherwise, try to select all matching nodes
    try {
      return this.getNodesByVersion(tree, arg)
    } catch (er) {
      return []
    }
  }

  /**
   * @param {import('@npmcli/arborist').Node} tree
   * @param {string} arg
   */
  getNodesByVersion(tree, arg) {
    const spec = npa(arg, this.npm.prefix)
    if (spec.type !== 'version' && spec.type !== 'range') {
      return []
    }

    return tree.inventory.filter((node) => {
      return (
        node.package.name === spec.name &&
        semver.satisfies(node.package.version, spec.rawSpec)
      )
    })
  }
}

main().then(null, (error) => {
  process.exitCode = 1
  throw error
})
