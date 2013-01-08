ChromeExtension = require 'lib/ChromeExtension'

Spine = require('spine')

class Notes extends Spine.Controller

  url: ''

  className: 'page-note-wrapper'

  elements:
    'input.note-index': 'index'
    'textarea.note-content': 'content'

  events:
    'change input.note-index': 'onIndexChange'
    'change textarea.note-content': 'onContentChange'

  constructor: (url)->
    super
    @url = url
    @append @render()
    @getNote @start

  start: =>
    @fill @note.index, @note.content
    @enable()

  fill: (index, content)->
    @index.val index
    @content.val content

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

  render: ->
    @template = require('views/notes')()

  disable: ->
    @index.prop 'disabled', true
    @content.prop 'disabled', true

  enable: ->
    @index.prop 'disabled', false
    @content.prop 'disabled', false

  onIndexChange: (ev)=>
    @note.index = @index.val()
    @saveNote()

  onContentChange: (ev)=>
    @note.content = @content.val()
    @saveNote()

module.exports = Notes