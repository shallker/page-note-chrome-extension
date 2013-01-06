require('lib/setup')
Mousetrap = require 'lib/mousetrap'

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
    url

  listenKeys: ->
    Mousetrap.bind '`', @onTogglePageNote

  onTogglePageNote: (ev)=>
    if @note then @closeNote() else @openNote()

  closeNote: ->
    $(html).removeClass 'page-note-open'
    @note = null
    @clearDocument()

  openNote: ->
    @note = new Notes(@url)
    @html @note
    $(html).addClass 'page-note-init'
    $(html).addClass 'page-note-open'
    window.clearTimeout @clearing

  removeHtmlClass: =>
    return if @note
    $(html).removeClass 'page-note-init'
    
  clearDocument: ->
    @clearing = window.setTimeout @removeHtmlClass, 1000

module.exports = Page