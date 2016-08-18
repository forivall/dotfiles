
var id = process.argv[2];
var zip = process.argv[3];

var Nightmare = require('nightmare');
require('nightmare-upload')(Nightmare);
var Cookie = require('cookie');

// TODO: store in os keychain instead
var config = require('./config.json');

var nightmare = Nightmare();
nightmare.goto('https://mcs-ledcorind.mobile.us2.oraclecloud.com/mobileui')
.then(function (result) {
  if (result.url.startsWith('https://login')) {
    return nightmare
    .insert('#username', config.username)
    .insert('#password', config.password)
    .click('#signin')
    .wait('.mcs-body')
    ;
  }
  return result;
})
.then(function () {
  console.log('logged in');

  return nightmare
  .goto('https://mcs-ledcorind.mobile.us2.oraclecloud.com/mobileui/env/dev/api/'+ id +'/implementation')
  .wait('#implUploadInputText')
})
.then(function (result) {
  // console.log(JSON.stringify(cookies, null, '  '));
  console.log('navigated to implementation');

  nightmare
  .upload('#implUploadInputText', zip)
  .wait(function () {
    return document.getElementById('implUploadDone').style.display !== 'none';
  })
  .visible('#implUploadDone')
  .end()
  .then(function (result) {
    console.log('uploaded');
  })
  ;
})
;
