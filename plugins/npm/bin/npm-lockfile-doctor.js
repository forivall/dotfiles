#!/usr/bin/env node

const npmExecPath =
  process.env.npm_execpath ||
  require('child_process')
    .execFileSync('npm', ['exec', '-c', 'echo $npm_execpath'], {
      encoding: 'utf8',
    })
    .trim()

const COMMAND_NAME = 'lockfile-doctor'

process.argv.splice(2, 0, COMMAND_NAME)

const Module = require('module')
const path = require('path')
const { once } = require('events')
const npmRequire = Module.createRequire(npmExecPath)
const Npm = npmRequire('../lib/npm')
const ArboristWorkspaceCmd = npmRequire('../lib/arborist-cmd')

const npmlog = npmRequire('proc-log')
/** @type {typeof import('proc-log')} */
const log = !npmlog.silly && npmlog.log ? npmlog.log : npmlog
/** @type {typeof import('@npmcli/arborist')} */
const Arborist = npmRequire('@npmcli/arborist')
/** @type {typeof import('pacote')} */
const pacote = npmRequire('pacote')

async function main() {
  const npm = new Npm()
  await npm.load()
  if (npm.argv[0] === COMMAND_NAME) {
    npm.argv.shift()
  }
  const command = new LockfileDoctor(npm)
  await command.exec(npm.argv)
  await npm.unload?.()
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

  /**
   * @param {string[]} args
   */
  async exec(args) {
    const opts = {
      path: this.npm.prefix,
      workspaces: this.workspaceNames,
      ...this.npm.flatOptions,
    }
    let arb = new Arborist(opts)
    let tree = await arb.buildIdealTree()

    const invalidLinks = this.fixInvalidLinks(tree)

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

    const packagesToHoist = args.length
      ? args
      : /** @type {string[]} */ (tree.inventory.query('name'))
    for (const packageName of packagesToHoist) {
      const deduped = await this.dedupeOrHoistPackage(tree, packageName, opts)
      pruned.push(...deduped)
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
        let info
        try {
          info = await pacote.manifest(pkgid, {
            ...tree.meta.resolveOptions,
            preferOffline: true,
          })
        } catch (err1) {
          try {
            info = await pacote.manifest(pkgid, tree.meta.resolveOptions)
          } catch (err) {
            log.warn('pacote', err)
          }
        }
        if (info) {
          node.resolved = info._resolved
          node.integrity = info._integrity
          node.package.deprecated = info.deprecated
        }
        arb.finishTracker('fixintegrity', node.name, node.location)
      }
      const nodePackage = node.package
      if (node.resolved) {
        // delete nodePackage.license
      }
    }
    arb.finishTracker('fixintegrity')

    if (!this.npm.flatOptions.dryRun) {
      await tree.meta.save()
    }

    if (this.npm.flatOptions.json) {
      await this.rawOutput(JSON.stringify({ invalidLinks, pruned, fixed }))
    } else {
      if (invalidLinks.length > 0) {
        this.rawOutput(
          `removed ${invalidLinks.length} invalid links:\n  ` +
            invalidLinks.join('\n  ')
        )
        if (!this.npm.flatOptions.force) {
          this.rawOutput('Run lockfile-doctor again to apply additional fixes')
        }
      }
      if (pruned.length > 0) {
        this.rawOutput(
          `pruned ${pruned.length} entries:\n  ` + pruned.join('\n  ')
        )
      }
      if (fixed.length > 0) {
        this.rawOutput(
          `fixed ${fixed.length} entries:\n  ` + fixed.join('\n  ')
        )
      }
    }
  }

  /**
   * @param {import('@npmcli/arborist').Node} tree
   */
  fixInvalidLinks(tree) {
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
    return invalidLinks
  }

  rawOutput(message) {
    if (npmlog.output) {
      return npmlog.output.standard(message)
    } else {
      return this.npm.output(message)
    }
  }

  async prompt(query) {
    const process = require('process')
    if (!process.stdin.isTTY) {
      return false;
    }
    this.rawOutput(`${query} (y/N): `)
    process.stdin.setRawMode(true)
    process.stdin.resume()
    const [data] = await once(process.stdin, 'data')
    if (data[0] === 0x03) {
      process.kill(process.pid, 'SIGINT');
    }
    process.stdin.setRawMode(false)
    process.stdin.pause()
    return /(^|\b)y(es)?/i.test(data.toString())
  }


  /**
   * @param {import('@npmcli/arborist').Node} tree
   * @param {string} packageName
   * @param {import('@npmcli/arborist').Options} options
   * @returns
   */
  async dedupeOrHoistPackage(tree, packageName, options) {
    /** @type {Set<import('@npmcli/arborist').Node>} */
    const nodeSet = tree.inventory.query('name', packageName)
    if (1 >= nodeSet.size) {
      const iterResult = nodeSet.values().next()
      if (iterResult.done) {
        return []
      }
      const node = iterResult.value
      if (!node.resolveParent || !node.resolveParent.resolveParent) {
        return []
      }
      log.warn(
        'hoist',
        `${options.force ? 'hoisting' : 'could hoist'} ${
          node.pkgid
        } for ${packageName}`
      )
      if (options.force) {
        node.parent = tree
      }
      return []
    }
    let rootDepNode
    for (const node of nodeSet) {
      if (!node.resolveParent || !node.resolveParent.resolveParent) {
        rootDepNode = node
        break
      }
    }
    if (!rootDepNode) {
      for (const node of nodeSet) {
        if (!rootDepNode) {
          rootDepNode = node
        } else if (node.pkgid !== rootDepNode.pkgid) {
          rootDepNode = undefined
          break
        }
      }
      if (rootDepNode) {
        const doHoist = (options.force ||
          await this.prompt(`hoist ${rootDepNode.pkgid} for ${packageName}?`))
        log.warn(
          'hoist',
          `${doHoist ? 'hoisting' : 'could hoist'} ${rootDepNode.pkgid} for ${packageName}`
        )
        if (doHoist) {
          rootDepNode.parent = tree
        }
      }
    }
    const pruned = []
    if (rootDepNode) {
      for (const node of nodeSet) {
        const other = (node.resolveParent.resolveParent?.resolve(node.name));
        if (other === rootDepNode && !node.overrides) {
          node.overrides = other.overrides;
        }
        if (node.canDedupe(options.preferDedupe)) {
          for (const depNode of gatherDeps(
            node,
            (edge) => edge.to !== node && edge.valid
          )) {
            pruned.push(depNode.location)
            depNode.parent = null
          }
        }
      }
    }
    return pruned
  }
}

/**
 *
 * @param {import('@npmcli/arborist').Node} node
 * @param {(edge: import('@npmcli/arborist').Edge) => boolean} edgeFilter
 * @returns
 */
function gatherDeps(node, edgeFilter) {
  const deps = new Set([node])

  for (const node of deps) {
    for (const edge of node.edgesOut.values()) {
      if (edge.to && edgeFilter(edge)) {
        deps.add(edge.to)
      }
    }
  }

  let changed = true
  while (changed && 0 < deps.size) {
    changed = false
    for (const dep of deps) {
      for (const edge of dep.edgesIn) {
        if (!deps.has(edge.from) && edgeFilter(edge)) {
          changed = true
          deps.delete(dep)
          break
        }
      }
    }
  }

  return deps
}

main().then(null, (error) => {
  process.exitCode = 1
  throw error
})
