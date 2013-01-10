require('lib/setup')
Mousetrap = require 'lib/mousetrap'
ChromeExtension = require 'lib/ChromeExtension'

Spine = require('spine')
Notes = require 'controllers/notes'

html = document.documentElement
body = document.body

class Page extends Spine.Controller

  className: 'page-note-app'

  elements:
    '.page-note-container'

  constructor: ->
    super
    $('body').append @el
    @url = @getURL()
    @port = @connect @url
    @listenKeys()

  getURL: ->
    loc = window.location
    url = loc.origin + loc.pathname + loc.search
    # trim last backslash /
    url = url.replace(/\/$/g, "")

  connect: (name)->
    ChromeExtension.connect name

  postMessage: (mesg)->
    @port.postMessage mesg

  listenKeys: ->
    Mousetrap.bind '`', @onTogglePageNote

  saveNote: (note)->
    mesg =
      action: 'page-save-note'
      note: note
    @postMessage mesg

  closeNotes: ->
    $(html).removeClass 'page-note-open'
    @saveNote @notes.note if @notes.modified
    delete @notes
    @clearDocument()

  openNotes: ->
    @notes = new Notes(@url)
    @html @notes
    $(html).addClass 'page-note-init'
    $(html).addClass 'page-note-open'
    window.clearTimeout @clearing

  removeHtmlClass: =>
    return if $(html).hasClass('page-note-open')
    $(html).removeClass 'page-note-init'
    
  clearDocument: ->
    @clearing = window.setTimeout @removeHtmlClass, 1000

  onTogglePageNote: (ev)=>
    if @notes then @closeNotes() else @openNotes()

module.exports = Page