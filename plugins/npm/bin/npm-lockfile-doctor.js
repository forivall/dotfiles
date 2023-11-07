#!/usr/bin/env node

const prefix = process.argv[2]
process.argv[2] = 'lockfile-doctor'

const Npm = require(`${prefix}/lib/node_modules/npm/lib/npm`)
const ArboristWorkspaceCmd = require(`${prefix}/lib/node_modules/npm/lib/arborist-cmd`)

/** @type {typeof import('@npmcli/arborist')} */
const Arborist = require(`${prefix}/lib/node_modules/npm/node_modules/@npmcli/arborist`)
/** @type {typeof import('pacote')} */
const pacote = require(`${prefix}/lib/node_modules/npm/node_modules/pacote`)

async function main() {
  const npm = new Npm()
  await npm.load()
  npm.argv.shift()
  const command = new LockfileDoctor(npm)
  await command.cmdExec(npm.argv)
}

class LockfileDoctor extends ArboristWorkspaceCmd {
  static description = 'Clean up sha1 and extraneous deps'
  static name = 'lockfile-doctor'
  static usage = []
  static params = ['json', 'workspace', 'dry-run', ...super.params]

  static ignoreImplicitWorkspace = false

  async exec(args) {
    const arb = new Arborist({
      path: this.npm.prefix,
      ...this.npm.flatOptions,
    })
    const tree = await arb.buildIdealTree()

    const removed = []
    for (const fsChild of tree.fsChildren) {
      if (fsChild.extraneous) {
        removed.push(fsChild.location)
        fsChild.parent = null
        fsChild.root = null
      }
    }

    const localNodes = new Set(
      /** @returns {Generator<import('@npmcli/arborist').Node>} */
      (function* iterLocalNodes(node) {
        yield node
        for (const fsChild of node.fsChildren) {
          yield* iterLocalNodes(fsChild)
        }
      })(tree)
    )
    const fixed = []
    arb.addTracker('fixintegrity')
    for (const node of tree.inventory.values()) {
      if (node.isLink || node.isRoot || '' === node.location) {
        continue
      }
      if (!localNodes.has(node) && !node.inBundle && !node.resolved) {
        const { pkgid, location } = node
        arb.addTracker('fixintegrity', node.name, node.location)
        fixed.push(location)
        const info = await pacote.manifest(pkgid, tree.meta.resolveOptions)
        node.resolved = info._resolved
        node.integrity = info._integrity
        arb.finishTracker('fixintegrity', node.name, node.location)
      }
      const nodePackage = node.package
      if (node.resolved) {
        delete nodePackage.license
      }
    }
    arb.finishTracker('fixintegrity')

    if (!this.npm.flatOptions.dryRun) {
      await tree.meta.save()
    }

    if (this.npm.flatOptions.json) {
      await this.npm.output(JSON.stringify({ removed, fixed }))
    } else {
      if (removed.length > 0) {
        console.log(
          `removed ${removed.length} entries:\n  `,
          removed.join('\n  ')
        )
      }
      if (fixed.length > 0) {
        console.log(`fixed ${fixed.length} entries:\n `, fixed.join('\n  '))
      }
    }
  }
}

main().then(null, (error) => {
  process.exitCode = 1
  throw error
})
