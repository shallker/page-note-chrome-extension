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
    $(body).append @el
    @url = @getURL()
    @listenKeys()

  getURL: ->
    loc = window.location
    url = loc.origin + loc.pathname + loc.search
    # trim last backslash /
    url = url.replace(/\/$/g, "")

  listenKeys: ->
    Mousetrap.bind '`', @onTogglePageNote

  onTogglePageNote: (ev)=>
    if @note then @closeNote() else @openNote()

  saveNote: (note, onResponse)->
    requests =
      action: 'page-save-note'
      url: note.url
      note: note
    ChromeExtension.sendMessage requests, (response)=>
      onResponse?()

  closeNote: ->
    $(html).removeClass 'page-note-open'
    @saveNote @note.note if @note.modified
    delete @note
    @clearDocument()

  openNote: ->
    @note = new Notes(@url)
    @html @note
    $(html).addClass 'page-note-init'
    $(html).addClass 'page-note-open'
    window.clearTimeout @clearing

  removeHtmlClass: =>
    return if $(html).hasClass('page-note-open')
    $(html).removeClass 'page-note-init'
    
  clearDocument: ->
    @clearing = window.setTimeout @removeHtmlClass, 1000

module.exports = Page