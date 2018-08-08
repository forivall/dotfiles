// ==UserScript==
// @name       Dochub.io keyboard shortcuts
// @namespace  http://forivall.github.io
// @version    0.1
// @description  hotkeys for dochub.io
// @match      http://dochub.io/*
// @require    http://code.jquery.com/jquery-2.0.0.min.js
// @require    http://cdn.craig.is/js/mousetrap/mousetrap.min.js?c13bc
// @copyright  2013+, Emily Marigold Klassen (forivall)
// ==/UserScript==

var jQuery_2 = $.noConflict();
jQuery = $;
jQuery_2(function($) {
    Mousetrap.bind(['ctrl+alt++left'], function(e) {
        var newlang = $('div.navbar li.active').prev().find('a.pointer').data('lang');
        document.location.hash = '#' + newlang + '/';
        //var oldlang = /^#([^/]+)/.exec(document.location.hash)
        return false;
    });
    Mousetrap.bind(['ctrl+alt+right'], function(e) {
        var newlang = $('div.navbar li.active').next().find('a.pointer').data('lang');
        document.location.hash = '#' + newlang + '/';
        return false;
    });
    Mousetrap.bind(['ctrl+alt+y'], function(e) {
        document.location.hash = '#python/';
        return false;
    });
    Mousetrap.bind(['ctrl+alt+j'], function(e) {
        console.log('js');
        document.location.hash = '#javascript/';
        return false;
    });
    $('#search-box')
        .addClass('mousetrap')
        .attr('type','search')
    ;
});
