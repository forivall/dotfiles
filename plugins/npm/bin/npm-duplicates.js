const prefix = process.argv[2]
process.argv[2] = 'duplicates'

const table = require('table')
const {
  calculateMaximumColumnWidths,
} = require('table/dist/src/calculateMaximumColumnWidths')
const Npm = require(`${prefix}/lib/node_modules/npm/lib/npm`)
const ArboristWorkspaceCmd = require(`${prefix}/lib/node_modules/npm/lib/arborist-cmd`)

/** @type {typeof import('@npmcli/arborist')} */
const Arborist = require(`${prefix}/lib/node_modules/npm/node_modules/@npmcli/arborist`)

async function main() {
  const npm = new Npm()
  await npm.load()
  npm.argv.shift()
  const command = new Duplicates(npm)
  await command.exec(npm.argv)
}

class Duplicates extends ArboristWorkspaceCmd {
  static description = 'Find duplicates'
  static name = 'duplicates'
  static usage = ['<package-spec>']
  static params = ['json', 'workspace']

  static ignoreImplicitWorkspace = false

  async exec(args) {
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

    /** @type {Map<string, import('@npmcli/arborist').Node>} */
    const rootPkgs = new Map()
    /** @type {Map<string, Set<import('@npmcli/arborist').Node>>} */
    const pkgNodes = new Map()
    for (const [pkg, node] of tree.inventory.entries()) {
      const filteredOut =
        this.filterSet && this.filterSet.size > 0 && !this.filterSet.has(node)
      if (node.parent?.isRoot) {
        rootPkgs.set(node.name, node)
      }
      if (!filteredOut) {
        pkgNodes.get(node.pkgid)?.add(node) ??
          pkgNodes.set(node.pkgid, new Set([node]))
      }
    }
    if (pkgNodes.size === 0) {
      throw new Error(`No dependencies found`)
    }

    const expls = []
    for (const [pkg, nodes] of pkgNodes) {
      if (nodes.size <= 1) {
        continue
      }
      const rootPkg = rootPkgs.get(nodes.values().next().value.name)
      if (rootPkg) {
        // todo: count how many dependents require root dep version vs how many are in leaves
        continue
      }
      for (const node of nodes) {
        const {
          extraneous,
          dev,
          optional,
          devOptional,
          peer,
          inBundle,
          overridden,
        } = node
        const expl = node.explain()
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
        expls.push(expl)
      }
    }

    if (this.npm.flatOptions.json) {
      await this.npm.output(JSON.stringify(expls))
    } else {
      this.output(expls)
    }
  }

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
          .map(({ spec, from }) => ({ spec, location: from.location }))
          .map((dependent) => ({ version, flags, dependent, location }))
          .sort(
            (a, b) =>
              ~~a.dependent.location.startsWith('node_modules') -
              ~~b.dependent.location.startsWith('node_modules')
          )
      }
    )
    const groups = Object.values(
      flattened.reduce(
        (
          r,
          v,
          i,
          a,
          k = `${v.dependent.spec}\t${v.version}\t${v.flags}\t${v.location}`
        ) => ((r[k] || (r[k] = [])).push(v), r),
        {}
      )
    )
    const hasFlags = groups.some((g) => g[0].flags)
    const header = [
      'SPEC',
      'VERSION',
      ...(hasFlags ? [''] : []),
      'LOCATION',
      'DEPENDENT(S)',
    ]
    const rows = groups.map((g) => [
      g[0].dependent.spec,
      g[0].version,
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
    const space = widths.slice(0, 3).reduce((a, b) => a + b) + 4
    const lastColumn = header.length - 1
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
}

main().then(null, (error) => {
  process.exitCode = 1
  throw error
})
