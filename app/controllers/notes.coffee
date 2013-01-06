Mousetrap = require 'lib/mousetrap'
MD5 = require 'lib/md5-min'
ChromeExtension = require 'lib/ChromeExtension'

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
    @id = MD5 url
    @getNote @running

  running: =>
    @append @render @note
    @listenKeys()

  getNote: (call = ->)->
    requests = 
      action: 'page-get-note'
      url: @url
    ChromeExtension.sendMessage requests, (response)=> 
      @note = response
      call()

  saveNote: (call = ->)->
    requests =
      action: 'page-save-note'
      url: @url
      note: @note
    ChromeExtension.sendMessage requests, (response)=>
      call()

  render: (note)->
    require('views/notes')(note)

  listenKeys: ->
    Mousetrap.bind '`', @onTogglePageNote

  onIndexChange: (ev)=>
    @note.index = @index.val()
    @saveNote()

  onContentChange: (ev)=>
    @note.content = @content.val()
    @saveNote()

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