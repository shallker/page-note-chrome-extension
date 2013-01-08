ChromeExtension = require 'lib/ChromeExtension'

Spine = require('spine')

class Notes extends Spine.Controller

  url: ''

  modified: false

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
    @fill @note
    @enable()
    @listen()

  listen: ->
    ChromeExtension.listenMessage @onMessage

  fill: (note)->
    @index.val note.index
    @content.val note.content

  getNote: (onResponse)->
    requests = 
      action: 'page-get-note'
      url: @url
    ChromeExtension.sendMessage requests, (response)=> 
      @note = response
      onResponse?()

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