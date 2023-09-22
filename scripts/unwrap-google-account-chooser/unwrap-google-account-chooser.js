#!/usr/bin/env node

import open from 'open'
import { execFile } from 'child_process'
import { URL } from 'url'

const urlString = process.argv[2]
const u = new URL(urlString)
// velja regex: ^accounts\.google\.com/AccountChooser\?(.*&)?continue=https%3A%2F%2Fmeet.google.com%2F
const continueUrl = u.searchParams.get('continue')
if (continueUrl?.startsWith('https://meet.google.com')) {
  console.log(continueUrl)
  execFile('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', [
    '--app-id=kjgfgldnnfoeklkmfkjfagphfepbbdan',
    `--app-launch-url-for-shortcuts-menu-item=${continueUrl}`,
  ])
  open(continueUrl)
} else {
  open(urlString)
}
