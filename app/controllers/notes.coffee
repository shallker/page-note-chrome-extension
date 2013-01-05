Mousetrap = require 'lib/mousetrap'
MD5 = require 'lib/md5-min'

Spine = require('spine')
Note = require 'models/note'

html = document.documentElement

class Notes extends Spine.Controller
  
  opend: false

  elements:
    'input.note-index': 'index'
    'textarea.note-content': 'content'

  events:
    'change input.note-index': 'onIndexChange'
    'change textarea.note-content': 'onContentChange'

  constructor: (url)->
    super
    @url = url
    @id = MD5(url)
    @append @render @load()
    @listenKeys()

  render: (note)->
    @log note
    require('views/notes')(note)

  load: ->
    Note.fetch()
    if Note.exists(@id)
    then @note = Note.find(@id)
    else @note = @newNote(@id, @url)
    @note

  newNote: (id, url)->
    now = new Date
    Note.create
      id: id
      index: ''
      content: ''
      url: url
      time: now.getTime()

  listenKeys: ->
    Mousetrap.bind '`', @onTogglePageNote

  onIndexChange: (ev)=>
    @note.index = @index.val()
    @note.save()

  onContentChange: (ev)=>
    @note.content = @content.val()
    @note.save()

  onTogglePageNote: (ev)=>
    if @opend then @closePageNote() else @openPageNote()

  openPageNote: ->
    @opend = true
    $(html).addClass 'page-note-init'
    $(html).addClass 'page-note-open'
    window.clearTimeout @recovering

  closePageNote: ->
    @opend = false
    $(html).removeClass 'page-note-open'
    @recoverDocument()

  removeHtmlClass: =>
    return if @opend
    $(html).removeClass 'page-note-init'
    
  recoverDocument: ->
    @recovering = window.setTimeout @removeHtmlClass, 1000

module.exports = Notes