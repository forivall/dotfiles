"use strict";
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
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
require("greasemonkey");
(function () {
    //
    if (window.top !== window) {
        return;
    }
    console.log('loaded Jell project tag helper');
    var style = "\ncustom-tag-helper .btn {\n  min-width: 10px;\n  -webkit-user-select: auto;\n  -moz-user-select: auto;\n  -ms-user-select: auto;\n  user-select: auto;\n}\ncustom-tag-helper .btn.btn-sm {\n  margin-top: 4px;\n  margin-left: 2px;\n  margin-right: 2px;\n}\ncustom-tag-helper .btn-flex-cloud {\n  display: flex;\n  flex-flow: wrap;\n  justify-content: space-around;\n}\ncustom-tag-helper .btn-flex-cloud .btn {\n  flex-grow: 1;\n}\ncustom-tag-helper .btn-flex-cloud .input-group--flex {\n  flex-grow: 1;\n}\ncustom-tag-helper .btn.btn-sm.btn--secondary {\n  padding: 5px 10px !important;\n}\ncustom-tag-helper .input-group--flex {\n  display: flex;\n}\ncustom-tag-helper .input-group-flex-addon {\n  padding: 6px 0px;\n  font-size: 14px;\n  font-weight: 400;\n  line-height: 1;\n  color: #555;\n  text-align: center;\n  background-color: #eee;\n\n  display: flex;\n  flex-direction: row;\n  align-items: center;\n  justify-content: center;\n}\ncustom-tag-helper .input-group-flex-addon--del {\n  display: none;\n}\ncustom-tag-helper.can-delete-tag .input-group-flex-addon.input-group-flex-addon--del {\n  display: flex;\n}\ncustom-tag-helper .input-group-flex-addon:last-child {\n  padding-right: 6px;\n}\ncustom-tag-helper .form-group.form-group--flex {\n  display: flex;\n}\ncustom-tag-helper .btn-flex-cloud.form-group {\n  margin-bottom: 0;\n}\ncustom-tag-helper .form-group-sm input.form-control.form-control {\n  padding-top: 15px;\n  padding-bottom: 15px;\n}\ncustom-tag-helper .form-group-sm .input-group-addon {\n  padding-top: 2px;\n  padding-bottom: 2px;\n}\ncustom-tag-helper .form-group.form-group-sm {\n  margin-bottom: 6px;\n}\ncustom-tag-helper .input-group-sm .input-group-addon:first-child {\n  padding-right: 1px;\n}\ncustom-tag-helper .input-group-sm .input-group-addon:first-child + .form-control {\n  padding-left: 1px;\n}\ncustom-tag-helper .form-group-sm .input-group-addon .btn {\n  margin-top: 0;\n}\n";
    var styleTag = document.getElementById('jell-project-tag-helper-style');
    if (styleTag) {
        styleTag.innerHTML = style;
    }
    else {
        document.head.insertAdjacentHTML('beforeend', "<style type=\"text/css\" id=\"jell-project-tag-helper-style\">" + style + "</style>");
    }
    var linkTmpl = function (projects) { return function (pn) { return "\n<div class=\"input-group input-group--no-border input-group--flex hoverable\">\n  <a class=\"btn btn--secondary btn-flat btn-sm js-add-tag\" data-value=\"#" + pn + "\">" + pn + " " + projects[pn] + "</a>\n  <span class=\"input-group-flex-addon input-group-flex-addon--del\">\n    <a href=\"\" title=\"Remove tag\" class=\"link--gray js-del-tag\" tabindex=\"-1\" data-animation=\"am-fade-and-scale\" data-value=\"" + pn + "\">\n      <i class=\"fa fa-times\"></i>\n    </a>\n  </span>\n</div>\n"; }; };
    var mgmtTmpl = function () { return "\n<form class=\"js-create-tag-form\">\n<div class=\"form-group form-group-sm form-group--flex\">\n  <div class=\"input-group input-group-sm input-group--no-border\">\n    <span class=\"input-group-addon\">#</span>\n    <input type=\"text\" class=\"js-tag-name form-control\" aria-label=\"Tag\" placeholder=\"Tag\">\n  </div>\n  <div class=\"input-group input-group--no-border\">\n    <input type=\"text\" class=\"js-tag-desc form-control\" aria-label=\"Description\" placeholder=\"Description (Optional)\">\n    <span class=\"input-group-addon\">\n      <button type=\"submit\" href=\"\" title=\"Add tag\" class=\"link--gray btn btn-link\" tabindex=\"-1\" data-bs-tooltip=\"\" data-animation=\"am-fade-and-scale\" data-toggle=\"tooltip\" data-placement=\"bottom\">\n        <i class=\"fa fa-plus\"></i>\n      </a>\n    </button>\n  </div>\n</div>\n</form>\n<form>\n<div class=\"form-group form-group-sm text-right\">\n  <a class=\"btn btn-link btn-sm js-show-delete\">Delete Tag</a>\n</div>\n</form>\n"; };
    createTagHelper();
    function createTagHelper() {
        return __awaiter(this, void 0, void 0, function () {
            function cacheActiveElement() {
                activeElement = document.activeElement;
            }
            ////////////////////
            // ADD TAG TO TASK//
            ////////////////////
            function addTag(ev) {
                ev.preventDefault();
                ev.stopPropagation();
                var sel = window.getSelection();
                var focusNode = sel.focusNode;
                if (isHtmlElement(focusNode)) {
                    var placeholder = focusNode.querySelector('.plans__text');
                    if (placeholder) {
                        placeholder.dispatchEvent(new MouseEvent('click', { bubbles: true }));
                    }
                }
                else {
                    console.log('No node focused');
                }
                var input = (isHtmlElement(focusNode) && focusNode.querySelector('input[data-ng-model="plan.answer"]')) ||
                    (activeElement instanceof HTMLInputElement ? activeElement : null);
                if (!input) {
                    console.log('No input');
                    return;
                }
                input.value += ' ' + this.dataset.value;
                input.dispatchEvent(new Event('input', { bubbles: true }));
                return false;
            }
            ////////////
            // DELETE //
            ////////////
            function toggleDelete(ev) {
                el.classList.toggle('can-delete-tag');
            }
            function deleteTag(ev) {
                return __awaiter(this, void 0, void 0, function () {
                    var tag;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0:
                                ev.preventDefault();
                                ev.stopPropagation();
                                tag = this.dataset.value;
                                console.log("Deleting tag " + tag);
                                return [4 /*yield*/, GM_deleteValue("tags." + tag)];
                            case 1:
                                _a.sent();
                                redraw(el);
                                return [2 /*return*/, false];
                        }
                    });
                });
            }
            ////////////
            // CREATE //
            ////////////
            function createTag(ev) {
                return __awaiter(this, void 0, void 0, function () {
                    var tag, desc;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0:
                                ev.preventDefault();
                                ev.stopPropagation();
                                tag = el.querySelector('.js-tag-name').value;
                                desc = el.querySelector('.js-tag-desc').value;
                                console.log("Adding " + tag + ": " + desc);
                                return [4 /*yield*/, GM_setValue("tags." + tag, desc)];
                            case 1:
                                _a.sent();
                                redraw(el);
                                return [2 /*return*/];
                        }
                    });
                });
            }
            var parentEl, inProductivity, tasksSidebar, projects, el, linksHtml, mgmtHtml, activeElement;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        parentEl = document.querySelector('fl-productivity-sidebar');
                        inProductivity = parentEl != null;
                        if (!inProductivity) {
                            tasksSidebar = document.querySelector('fl-tasks-sidebar');
                            if (tasksSidebar) {
                                parentEl = tasksSidebar.parentElement;
                            }
                        }
                        if (parentEl == null) {
                            setTimeout(createTagHelper, 500);
                            return [2 /*return*/];
                        }
                        return [4 /*yield*/, loadProjects()];
                    case 1:
                        projects = _a.sent();
                        el = document.createElement('custom-tag-helper');
                        linksHtml = Object.keys(projects).map(linkTmpl(projects)).join('');
                        linksHtml = "<div class=\"btn-flex-cloud form-group\">" + linksHtml + "</div>";
                        if (inProductivity)
                            linksHtml = "<div class=\"col-md-12\">" + linksHtml + "</div>";
                        mgmtHtml = mgmtTmpl();
                        if (inProductivity)
                            mgmtHtml = "<div class=\"col-md-12\">" + mgmtHtml + "</div>";
                        el.innerHTML = "<div>\n    <div class=\"row\">" + linksHtml + "</div>\n    <div class=\"row\">" + mgmtHtml + "</div>\n  </div>";
                        activeElement = document.activeElement;
                        el.querySelectorAll('.js-add-tag').forEach(function (button) {
                            button.addEventListener('click', addTag);
                            button.addEventListener('mouseover', cacheActiveElement);
                        });
                        el.querySelectorAll('.js-show-delete').forEach(function (button) {
                            button.addEventListener('click', toggleDelete);
                        });
                        el.querySelectorAll('.js-del-tag').forEach(function (button) {
                            button.addEventListener('click', deleteTag);
                        });
                        el.querySelector('.js-create-tag-form').addEventListener('submit', createTag);
                        parentEl.insertAdjacentElement('afterbegin', el);
                        // START LISTENER FOR CHANGES
                        setTimeout(ensureTagHelperExists, 10000);
                        return [2 /*return*/];
                }
            });
        });
    }
    function ensureTagHelperExists() {
        if (document.querySelector('custom-tag-helper') == null) {
            createTagHelper();
            return;
        }
        setTimeout(ensureTagHelperExists, 5000);
    }
    function loadProjects() {
        return __awaiter(this, void 0, void 0, function () {
            var keys;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, GM_listValues()];
                    case 1:
                        keys = (_a.sent()).filter(function (k) { return k.startsWith('tags.'); });
                        keys.sort();
                        return [4 /*yield*/, Promise.all(keys.map(function (k) { return [k, GM_getValue(k)]; }))];
                    case 2: return [2 /*return*/, (_a.sent()).reduce(function (o, _a) {
                            var k = _a[0], v = _a[1];
                            o[k.split('.')[1]] = v;
                            return o;
                        }, {})];
                }
            });
        });
    }
    function isHtmlElement(n) {
        return Boolean(n && n.querySelector);
    }
    function redraw(el) {
        el.remove();
        setTimeout(createTagHelper, 0);
    }
    //
})();
