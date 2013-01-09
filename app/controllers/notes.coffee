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
    @append @render()
    @loadNote @start

  start: =>
    @fill @note
    @enable()
    @listen()

  listen: ->
    ChromeExtension.listenMessage @onMessage

  fill: (note)->
    @title.val note.title
    @content.val note.content

  loadNote: (onLoad)->
    requests = 
      action: 'page-load-note'
      url: @url
    onResponse = (response)=>
      @note = response
      onLoad?()
    @sendMessage requests, onResponse

  render: ->
    @template = require('views/notes')()

  sendMessage: (message, onResponse = ->)->
    ChromeExtension.sendMessage message, onResponse

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

  onRefresh: (record)=>
    return if record.id isnt @note.id
    @fill record

  onMessage: (message, sender, sendBack)=>
    # @log 'message', message
    # @log 'sender', sender
    # @log 'sendBack', sendBack
    switch message.action
      when 'refresh-record'
        @onRefresh message.record
      else return


module.exports = Notes