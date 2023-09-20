#!/usr/bin/env node

import open from 'open';
import { URL } from 'url';

const urlString = process.argv[2];
const u = new URL(urlString);
// velja regex: ^accounts\.google\.com/AccountChooser\?(.*&)?continue=https%3A%2F%2Fmeet.google.com%2F
const continueUrl = u.searchParams.get('continue');
if (continueUrl?.startsWith('https://meet.google.com')) {
  open(continueUrl);
} else {
  open(urlString);
}
