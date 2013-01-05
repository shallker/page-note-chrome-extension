
function addClass( element, name ) {
    element.className = element.className.replace( /\s+$/gi, '' ) + ' ' + name;
}

function removeClass( element, name ) {
    element.className = element.className.replace( name, '' );
}

Mousetrap.bind('`', togglePageNote);

var opend = false;
function togglePageNote() {
    if (opend) return closePageNote();
    return openPageNote();
}

function openPageNote() {
    opend = true;
    $(document.documentElement).addClass('page-note-init');
    $(document.documentElement).addClass('page-note-open');
}

function closePageNote() {
    opend = false;
    $(document.documentElement).removeClass('page-note-open');
    recoverDocument();
}

function recoverDocument() {
    window.setTimeout(function() {
        if (!opend) {
            $(document.documentElement).removeClass('page-note-init');
        }
    }, 1000)    
}

insertNote()
function insertNote() {
    $(document.body).append('<div id="page-note" class="page-note"><input type="text" class="note-title" ><textarea class="note-content">Hello world</textarea></div>')
}
