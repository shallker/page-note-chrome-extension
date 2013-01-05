var pageUrl = window.location.origin + window.location.pathname;
if (pageUrl == 'http://www.baidu.com/search/error.html') {
    alert('has page note');
}

Mousetrap.bind('`', openPageNote);

function openPageNote() {
  $('#page-note').toggle();
}

$('body').append('<div id="page-note" class="none"><textarea>hello</textarea></div>');
$(function() {
})