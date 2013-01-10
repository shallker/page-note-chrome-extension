ChromeExtension = require 'lib/ChromeExtension'

Spine = require('spine')

class Notes extends Spine.Controller

  url: ''

  modified: false

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
    @port = @connect @url
    @append @render()
    @loadNote()

  start: =>
    @fill @note
    @enable()

  fill: (note)->
    @title.val note.title
    @content.val note.content

  loadNote: ->
    @postMessage
      action: 'page-load-note'
      url: @url

  onLoadNote: (note)=>
    @note = note
    @start()

  onRefreshNote: (note)=>
    return if note.id isnt @note.id
    @note = note
    @fill @note

  render: ->
    @template = require('views/notes')()

  connect: (name)->
    port = ChromeExtension.connect name
    port.onMessage.addListener @onMessage
    port

  postMessage: (msg)->
    @port.postMessage msg

  onMessage: (msg)=>
    # @log 'onMessage', msg
    switch msg.action
      when 're-page-load-note'
      then @onLoadNote msg.note
      when 're-page-save-note'
      then ''
      when 'refresh-note'
      then @onRefreshNote msg.note
      else return

  disable: ->
    @title.prop 'disabled', true
    @content.prop 'disabled', true

  enable: ->
    @title.prop 'disabled', false
    @content.prop 'disabled', false

  onTitleChange: (ev)=>
    @note.title = @title.val()
    @modified = true

  onContentChange: (ev)=>
    @note.content = @content.val()
    @modified = true


module.exports = Notes