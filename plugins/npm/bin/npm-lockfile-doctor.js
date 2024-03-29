#!/usr/bin/env node

const npmExecPath =
  process.env.npm_execpath ||
  require('child_process')
    .execFileSync('npm', ['exec', '-c', 'echo $npm_execpath'], {
      encoding: 'utf8',
    })
    .trim()

process.argv[2] = 'lockfile-doctor'

const Module = require('module')
const path = require('path')
const npmRequire = Module.createRequire(npmExecPath)
const Npm = npmRequire('../lib/npm')
const ArboristWorkspaceCmd = npmRequire('../lib/arborist-cmd')

/** @type {typeof import('npmlog')} */
const log = npmRequire('npmlog')
/** @type {typeof import('@npmcli/arborist')} */
const Arborist = npmRequire('@npmcli/arborist')
/** @type {typeof import('pacote')} */
const pacote = npmRequire('pacote')

async function main() {
  const npm = new Npm()
  await npm.load()
  npm.argv.shift()
  const command = new LockfileDoctor(npm)
  await command.cmdExec(npm.argv)
}

/**
 * @param {Iterable<unknown>} iterable
 */
function isEmpty(iterable) {
  for (const _unused of iterable) {
    return false
  }
  return true
}

/**
 * @template T
 * @param {Iterable<T>} iterable
 * @param {(value: T) => boolean} iteratee
 */
function every(iterable, iteratee) {
  for (const value of iterable) {
    if (!iteratee(value)) {
      return false
    }
  }
  return true
}

/**
 * @template T
 * @param {Iterable<T>} iterable
 * @param {(value: T) => boolean} iteratee
 */
function some(iterable, iteratee) {
  for (const value of iterable) {
    if (iteratee(value)) {
      return true
    }
  }
  return false
}

/** @param {string} to */
const relPath = (to) => path.relative('.', to)

class LockfileDoctor extends ArboristWorkspaceCmd {
  static description = 'Clean up sha1 and extraneous deps'
  static name = 'lockfile-doctor'
  static usage = []
  static params = ['json', 'workspace', 'dry-run', 'force', ...super.params]

  static ignoreImplicitWorkspace = false

  async exec(args) {
    const opts = {
      path: this.npm.prefix,
      workspaces: this.workspaceNames,
      ...this.npm.flatOptions,
    }
    let arb = new Arborist(opts)
    let tree = await arb.buildIdealTree()

    const invalidLinks = []
    ;(function removeInvalidLinks(node) {
      for (const fsChild of node.fsChildren) {
        for (const link of /** @type {Set<import('@npmcli/arborist').Link>} */ (
          fsChild.linksIn
        )) {
          if (!some(link.edgesIn, (edge) => edge.valid)) {
            invalidLinks.push(link.location)
            link.parent = null
          } else {
            for (const edge of link.edgesIn) {
              if (!edge.valid) {
                log.warn(
                  'invalid link',
                  `from ${relPath(edge.from.path)} to ${relPath(edge.to.path)}`
                )
              }
            }
          }
        }
        removeInvalidLinks(fsChild)
      }
    })(tree)

    if (
      this.npm.flatOptions.force &&
      invalidLinks.length > 0 &&
      !this.npm.flatOptions.dryRun
    ) {
      await tree.meta.save()
      arb = new Arborist(opts)
      tree = await arb.buildIdealTree()
    }

    const pruned = []
    ;(function pruneExtraneous(node) {
      for (const fsChild of node.fsChildren) {
        if (fsChild.extraneous) {
          pruned.push(fsChild.location)
          fsChild.parent = null
          fsChild.root = null
        } else {
          pruneExtraneous(fsChild)
        }
      }
    })(tree)

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
        const info = await pacote.manifest(pkgid, {
          ...tree.meta.resolveOptions,
          preferOffline: true,
        })
        node.resolved = info._resolved
        node.integrity = info._integrity
        node.package.deprecated = info.deprecated
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
      await this.npm.output(JSON.stringify({ invalidLinks, pruned, fixed }))
    } else {
      if (invalidLinks.length > 0) {
        this.npm.output(
          `removed ${invalidLinks.length} invalid links:\n  ` +
            invalidLinks.join('\n  ')
        )
        if (!this.npm.flatOptions.force) {
          this.npm.output('Run lockfile-doctor again to apply additional fixes')
        }
      }
      if (pruned.length > 0) {
        this.npm.output(
          `pruned ${pruned.length} entries:\n  ` + pruned.join('\n  ')
        )
      }
      if (fixed.length > 0) {
        this.npm.output(
          `fixed ${fixed.length} entries:\n  ` + fixed.join('\n  ')
        )
      }
    }
  }
}

main().then(null, (error) => {
  process.exitCode = 1
  throw error
})
