#!/usr/bin/env node

import open from 'open'
import { execFile } from 'child_process'
import { URL } from 'url'

const urlString = process.argv[2]
const u = new URL(urlString)
// velja regex: ^accounts\.google\.com/AccountChooser\?(.*&)?continue=https%3A%2F%2Fmeet.google.com%2F
let destination = urlString;
if (u.host === 'accounts.google.com') {
  const continueUrl = u.searchParams.get('continue')
  if (continueUrl) {
    destination = continueUrl;
  }
}
if (destination?.startsWith('https://meet.google.com')) {
  execFile('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', [
    '--app-id=kjgfgldnnfoeklkmfkjfagphfepbbdan',
    `--app-launch-url-for-shortcuts-menu-item=${destination}`,
  ]);
} else {
  open(urlString, { app: { name: 'google chrome' } });
}
