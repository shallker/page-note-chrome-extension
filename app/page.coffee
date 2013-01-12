require 'lib/setup'
Mousetrap = require 'lib/mousetrap'
ChromeExtension = require 'lib/ChromeExtension'

Spine = require 'spine'
Notes = require 'controllers/notes'

html = document.documentElement

class Page extends Spine.Controller

  location = window.location

  setTimeout = (func, milsecs)->
    window.setTimeout func, milsecs

  clearTimeout = (tid)->
    window.clearTimeout tid

  el: document.body

  constructor: ->
    super
    @url = @getURL location
    @connect()
    @notes = new Notes @url
    @listenKeys()

  getURL: (loc)->
    url = loc.origin + loc.pathname + loc.search
    # trim last backslash /
    url = url.replace(/\/$/g, "")

  connect: ->
    @port = ChromeExtension.connect name: @url
    @port.onMessage.addListener @onMessage

  onMessage: (mesg)=>
    switch mesg.action
      when 'toggle-page-note'
      then @onMesgTogglePageNote mesg
      else return

  onMesgTogglePageNote: (mesg)=>
    @onTogglePageNote()

  listenKeys: ->
    Mousetrap.bind '`', @onTogglePageNote

  closeNotes: ->
    $(html).removeClass 'page-note-open'
    @notes.close()
    @clearDocument()

  appendNotes: (notes)->
    @append notes
    @isNotesAppended = true

  openNotes: ->
    @appendNotes @notes if not @isNotesAppended
    @notes.open()
    $(html).addClass 'page-note-init'
    $(html).addClass 'page-note-open'
    clearTimeout @clearing

  removeHtmlClass: =>
    return if $(html).hasClass('page-note-open')
    $(html).removeClass 'page-note-init'
    
  clearDocument: ->
    @clearing = setTimeout @removeHtmlClass, 1000

  onTogglePageNote: (ev)=>
    if @notes.closed then @openNotes() else @closeNotes()

module.exports = Page
