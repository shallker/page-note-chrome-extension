require('lib/setup')
CouchDB = require 'lib/couchDB'
BrowserAction = require 'lib/BrowserAction'
ChromeTabs = require 'lib/ChromeTabs'
ChromeExtension = require 'lib/ChromeExtension'
MD5 = require 'lib/md5-min'

Spine = require('spine')

# Note = require 'models/note'
NoteCouch = require 'models/note-couch'

class Background extends Spine.Controller

  pageAppTabs: {}
  fetched: false
  messages: []

  constructor: ->
    super
    @running()

  running: ->
    ChromeTabs.listenUpdate @onTabUpdate
    ChromeTabs.listenActive @onTabActive
    ChromeTabs.listenCreate @onTabCreate
    BrowserAction.listenClick @onClick
    ChromeExtension.listenMessage @onMessageQueue
    NoteCouch.fetch()

    NoteCouch.bind "refresh", (records) =>
      @fetched = true
      console.log 'refresh', records
      @refreshRecord record for record in records
      # damn = NoteCouch.find '7a48e2531cf60ecc27eec288d904d9bc'
      # damn.content = 'damn content 05'
      # damn.save()

    NoteCouch.bind "update", (record) ->
      # console.log 'update', record

  refreshRecord: (record)->
    message = 
      action: 'refresh-record'
      record: record
    ChromeTabs.sendMessage id, message for id, tab of @pageAppTabs
    # ChromeTabs.sendMessage(tab.id, {greeting: "hello"}, function(response) {


  injectPageApp: (tab)->
    # tabId = parseInt(tab.id)
    ChromeTabs.injectStyle tab.id, 'content-scripts/css/page-note-scale.css'
    ChromeTabs.injectScript tab.id, 'application.js'
    ChromeTabs.injectScript tab.id, 'js/page-app.js'
    @pageAppTabs[tab.id] = tab
    console.log 'injectPageApp', tab

  arrDel: (arr, value)->
    arr.splice(arr.indexOf(value), 1)

  onMessage: =>
    return window.setTimeout @onMessage, 500 if not @fetched
    msg = @messages.shift()
    return if not msg.sender.tab
    switch msg.request.action
      when 'page-get-note' then @onPageGetNote msg.request, msg.sendBack
      when 'page-save-note' then @onPageSaveNote msg.request, msg.sendBack
      else return

  onMessageQueue: (request, sender, sendBack)=>
    @messages.push {request: request, sender: sender, sendBack: sendBack}
    @onMessage()
    # The chrome.extension.onMessage listener must return true if you want to 
    # send a response after the listener returns
    true

  onPageGetNote: (request, sendBack)=>
    id = MD5 request.url
    if NoteCouch.exists id
      note = NoteCouch.find id
      # console.log note.reload
      # console.log note.reload()
      sendBack note
      return NoteCouch.fetch id: id
    else
      now = new Date
      sendBack NoteCouch.create
        id: id
        index: ''
        content: ''
        url: request.url
        time: now.getTime()

  onPageSaveNote: (request, sendBack)=>
    note = NoteCouch.find request.note.id
    note.index = request.note.index
    note.content = request.note.content
    note.save()
    sendBack 'saved'

  onClick: (tab)=>
    allowed = false
    allowed = true if tab.url.indexOf('http') is 0
    allowed = true if tab.url.indexOf('https') is 0
    return if not allowed
    return if @pageAppTabs[tab.id]
    @injectPageApp tab

    # if tab.url is "chrome://extensions/" or 
    # tab.url is "chrome://newtab/"
    # then return
    
    # return if tab.url.indexOf('chrome') is 0

    # console.log tab, @
    # noteId = MD5 tab.url
    # console.log noteId
    # note = NoteCouch.exists noteId
    # console.log note

  onTabUpdate: (tabId, changeInfo, tab)=>
    allowed = false
    allowed = true if tab.url.indexOf('http') is 0
    allowed = true if tab.url.indexOf('https') is 0
    return if not allowed
    return if changeInfo.status isnt 'complete'
    @injectPageApp tab

  onTabCreate: (tab)=>
    # @log 'onTabCreate'
    # @log 'tab', tab

  onTabActive: (tab)=>
    # @log 'onTabActive'
    # @log 'tab', tab

  onTabRemove: (tab)=>
    @log 'onTabRemove', tab
    delete @pageAppTabs[tab.id] if @pageAppTabs[tab.id]


module.exports = Background