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
    @getNote @running

  running: =>
    @append @render @note

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

  onIndexChange: (ev)=>
    @note.index = @index.val()
    @saveNote()

  onContentChange: (ev)=>
    @note.content = @content.val()
    @saveNote()

module.exports = Notes