// ==UserScript==
// @name         Jell project tag helper
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Add a sidebar helper for tagging tasks in Jell
// @copyright    2018, Emily Marigold Klassen (http://forivall.com)
// @author       Emily Marigold Klassen <forivall@gmail.com>
// @updateURL    https://openuserjs.org/meta/forivall/Jell_project_tag_helper.meta.js
// @source       https://github.com/forivall/dotfiles/blob/osx/userscripts/jell.user.js
// @license      ISC
// @match        https://jell.com/app/organizations/*/home
// @match        https://jell.com/app/teams/*/status*
// @grant GM_setValue
// @grant GM_listValues
// @grant GM_getValue
// @grant GM_deleteValue
// @run-at document-idle
// ==/UserScript==

import 'greasemonkey'

(function() {
//

if (window.top !== window) {
  return
}
console.log('loaded Jell project tag helper')

const style = `
custom-tag-helper .btn {
  min-width: 10px;
  -webkit-user-select: auto;
  -moz-user-select: auto;
  -ms-user-select: auto;
  user-select: auto;
}
custom-tag-helper .btn.btn-sm {
  margin-top: 4px;
  margin-left: 2px;
  margin-right: 2px;
}
custom-tag-helper .btn-flex-cloud {
  display: flex;
  flex-flow: wrap;
  justify-content: space-around;
}
custom-tag-helper .btn-flex-cloud .btn {
  flex-grow: 1;
}
custom-tag-helper .btn-flex-cloud .input-group--flex {
  flex-grow: 1;
}
custom-tag-helper .btn.btn-sm.btn--secondary {
  padding: 5px 10px !important;
}
custom-tag-helper .input-group--flex {
  display: flex;
}
custom-tag-helper .input-group-flex-addon {
  padding: 6px 0px;
  font-size: 14px;
  font-weight: 400;
  line-height: 1;
  color: #555;
  text-align: center;
  background-color: #eee;

  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
}
custom-tag-helper .input-group-flex-addon--del {
  display: none;
}
custom-tag-helper.can-delete-tag .input-group-flex-addon.input-group-flex-addon--del {
  display: flex;
}
custom-tag-helper .input-group-flex-addon:last-child {
  padding-right: 6px;
}
custom-tag-helper .form-group.form-group--flex {
  display: flex;
}
custom-tag-helper .btn-flex-cloud.form-group {
  margin-bottom: 0;
}
custom-tag-helper .form-group-sm input.form-control.form-control {
  padding-top: 15px;
  padding-bottom: 15px;
}
custom-tag-helper .form-group-sm .input-group-addon {
  padding-top: 2px;
  padding-bottom: 2px;
}
custom-tag-helper .form-group.form-group-sm {
  margin-bottom: 6px;
}
custom-tag-helper .input-group-sm .input-group-addon:first-child {
  padding-right: 1px;
}
custom-tag-helper .input-group-sm .input-group-addon:first-child + .form-control {
  padding-left: 1px;
}
custom-tag-helper .form-group-sm .input-group-addon .btn {
  margin-top: 0;
}
`
let styleTag = document.getElementById('jell-project-tag-helper-style') as HTMLStyleElement
if (styleTag) {
  styleTag.innerHTML = style
} else {
  document.head.insertAdjacentHTML('beforeend', `<style type="text/css" id="jell-project-tag-helper-style">${style}</style>`);
}

const linkTmpl = (projects) => (pn) => `
<div class="input-group input-group--no-border input-group--flex hoverable">
  <a class="btn btn--secondary btn-flat btn-sm js-add-tag" data-value="#${pn}">${pn} ${projects[pn]}</a>
  <span class="input-group-flex-addon input-group-flex-addon--del">
    <a href="" title="Remove tag" class="link--gray js-del-tag" tabindex="-1" data-animation="am-fade-and-scale" data-value="${pn}">
      <i class="fa fa-times"></i>
    </a>
  </span>
</div>
`

const mgmtTmpl = () => `
<form class="js-create-tag-form">
<div class="form-group form-group-sm form-group--flex">
  <div class="input-group input-group-sm input-group--no-border">
    <span class="input-group-addon">#</span>
    <input type="text" class="js-tag-name form-control" aria-label="Tag" placeholder="Tag">
  </div>
  <div class="input-group input-group--no-border">
    <input type="text" class="js-tag-desc form-control" aria-label="Description" placeholder="Description (Optional)">
    <span class="input-group-addon">
      <button type="submit" href="" title="Add tag" class="link--gray btn btn-link" tabindex="-1" data-bs-tooltip="" data-animation="am-fade-and-scale" data-toggle="tooltip" data-placement="bottom">
        <i class="fa fa-plus"></i>
      </a>
    </button>
  </div>
</div>
</form>
<form>
<div class="form-group form-group-sm text-right">
  <a class="btn btn-link btn-sm js-show-delete">Delete Tag</a>
</div>
</form>
`

createTagHelper()

async function createTagHelper() {
  let parentEl = document.querySelector('fl-productivity-sidebar')
  const inProductivity = parentEl != null

  if (!inProductivity) {
    const tasksSidebar = document.querySelector('fl-tasks-sidebar')
    if (tasksSidebar) {
      parentEl = tasksSidebar.parentElement
    }
  }

  if (parentEl == null) {
    setTimeout(createTagHelper, 500)
    return
  }


  ////////////////
  // CREATE UI  //
  ////////////////
  const projects = await loadProjects()

  const el = document.createElement('custom-tag-helper')

  let linksHtml = Object.keys(projects).map(linkTmpl(projects)).join('');
  linksHtml = `<div class="btn-flex-cloud form-group">${linksHtml}</div>`
  if (inProductivity) linksHtml = `<div class="col-md-12">${linksHtml}</div>`

  let mgmtHtml = mgmtTmpl()
  if (inProductivity) mgmtHtml = `<div class="col-md-12">${mgmtHtml}</div>`

  el.innerHTML = `<div>
    <div class="row">${linksHtml}</div>
    <div class="row">${mgmtHtml}</div>
  </div>`

  let activeElement = document.activeElement
  function cacheActiveElement() {
    activeElement = document.activeElement
  }

  ////////////////////
  // ADD TAG TO TASK//
  ////////////////////
  function addTag(this: HTMLElement, ev: Event) {
    ev.preventDefault()
    ev.stopPropagation()

    const sel = window.getSelection()
    const focusNode = sel.focusNode
    if (isHtmlElement(focusNode)) {
      const placeholder = focusNode.querySelector('.plans__text')
      if (placeholder) {
        placeholder.dispatchEvent(new MouseEvent('click', {bubbles: true}))
      }
    }
    else {
      console.log('No node focused')
    }
    const input: HTMLInputElement | null =
      (isHtmlElement(focusNode) && focusNode.querySelector('input[data-ng-model="plan.answer"]')) ||
      (activeElement instanceof HTMLInputElement ? activeElement : null)

    if (!input) {
      console.log('No input')
      return
    }
    input.value += ' ' + this.dataset.value
    input.dispatchEvent(new Event('input', {bubbles: true}))

    return false
  }
  el.querySelectorAll('.js-add-tag').forEach((button) => {
    button.addEventListener('click', addTag)
    button.addEventListener('mouseover', cacheActiveElement)
  })

  ////////////
  // DELETE //
  ////////////
  function toggleDelete(ev: Event) {
    el.classList.toggle('can-delete-tag')
  }
  el.querySelectorAll('.js-show-delete').forEach((button) => {
    button.addEventListener('click', toggleDelete);
  });
  async function deleteTag(this: HTMLElement, ev: Event) {
    ev.preventDefault()
    ev.stopPropagation()

    const tag = this.dataset.value
    console.log(`Deleting tag ${tag}`)
    await GM_deleteValue(`tags.${tag}`)
    redraw(el)

    return false
  }
  el.querySelectorAll('.js-del-tag').forEach((button) => {
      button.addEventListener('click', deleteTag);
  });

  ////////////
  // CREATE //
  ////////////
  async function createTag(ev) {
    ev.preventDefault()
    ev.stopPropagation()
    const tag = el.querySelector<HTMLInputElement>('.js-tag-name')!.value
    const desc = el.querySelector<HTMLInputElement>('.js-tag-desc')!.value
    console.log(`Adding ${tag}: ${desc}`)
    await GM_setValue(`tags.${tag}`, desc)

    redraw(el)
  }
  el.querySelector<HTMLFormElement>('.js-create-tag-form')!.addEventListener('submit', createTag);
  parentEl.insertAdjacentElement('afterbegin', el);

  // START LISTENER FOR CHANGES
  setTimeout(ensureTagHelperExists, 10000);
}
function ensureTagHelperExists() {
  if (document.querySelector('custom-tag-helper') == null) {
    createTagHelper()
    return
  }

  setTimeout(ensureTagHelperExists, 5000);
}

async function loadProjects() {
  const keys = (await GM_listValues()).filter((k) => k.startsWith('tags.'))
  keys.sort()

  return (
    await Promise.all(keys.map((k): [string, string] => [k, GM_getValue(k)]))
  ).reduce((o, [k, v]) => {
    o[k.split('.')[1]] = v
    return o
  }, {} as {[key: string]: string})
}

function isHtmlElement(n: Node | undefined): n is HTMLElement {
  return Boolean(n && (n as HTMLElement).querySelector)
}

function redraw(el: HTMLElement) {
  el.remove()
  setTimeout(createTagHelper, 0)
}
//
})()