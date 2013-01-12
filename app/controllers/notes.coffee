ChromeExtension = require 'lib/ChromeExtension'

Spine = require('spine')

class Notes extends Spine.Controller

  url: ''

  closed: true
  changed: false

  className: 'page-note-wrapper'

  elements:
    'input.note-title': 'title'
    'textarea.note-content': 'content'

  events:
    'change input.note-title': 'onTitleChange'
    'change textarea.note-content': 'onContentChange'

  constructor: (url)->
    super
    @url = url
    @append @render()
    @connect()

  fill: (note)->
    @title.val note.title
    @content.val note.content

  refresh: ->
    @disable()
    @fill @note
    @enable()

  mesgLoadNote: ->
    @postMessage
      action: 'page-load-note'
      url: @url

  mesgSaveNote: ->
    @postMessage
      action: 'page-save-note'
      note: @note

  render: ->
    @template = require('views/notes')()

  connect: ->
    @port = ChromeExtension.connect name: @url
    @port.onMessage.addListener @onMessage

  postMessage: (msg)->
    @port.postMessage msg

  onMessage: (mesg)=>
    switch mesg.action
      when 're-page-load-note'
      then @onMesgLoadNote mesg
      when 're-page-save-note'
      then @onMesgSaveNote mesg
      when 'refresh-note'
      then @onMesgRefreshNote mesg
      else return

  close: ->
    @closed = true
    @mesgSaveNote() if @changed

  open: ->
    @closed = false
    @mesgLoadNote()

  disable: ->
    @title.prop 'disabled', true
    @content.prop 'disabled', true

  enable: ->
    @title.prop 'disabled', false
    @content.prop 'disabled', false

  onMesgLoadNote: (mesg)=>
    @note = mesg.note
    @refresh()

  onMesgSaveNote: (mesg)=>
    # mesg.result

  onMesgRefreshNote: (mesg)=>
    return if mesg.note.id isnt @note.id
    @note = mesg.note
    @refresh()

  onTitleChange: (ev)=>
    @note.title = @title.val()
    @changed = true
    
  onContentChange: (ev)=>
    @note.content = @content.val()
    @changed = true

module.exports = Notes