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

  tabs: {}
  fetched: false
  messages: []

  constructor: ->
    super
    NoteCouch.fetch()
    @running()
    window.tabs = @tabs

  running: ->
    @listen()
    @listenRecords()

  listen: ->
    ChromeTabs.listenUpdate @onTabUpdate
    ChromeTabs.listenActive @onTabActive
    ChromeTabs.listenCreate @onTabCreate
    ChromeTabs.listenRemove @onTabRemove
    BrowserAction.listenClick @onClick
    ChromeExtension.listenMessage @onMessageQueue

  listenRecords: ->
    NoteCouch.bind "refresh", (records) =>
      @fetched = true
      console.log 'refresh', records
      @pageRefreshRecord record for record in records
    NoteCouch.bind "update", (record) ->
      # console.log 'update', record      

  pageRefreshRecord: (record)->
    message = 
      action: 'refresh-record'
      record: record
    chrome.tabs.getSelected null, (tab)=>
      return if not @isAllowed tab
      @sendMessage tab.id, message
    # @sendMessage tid, message for tid, tab of @tabs

  injectPageApp: (tab)->
    tid = parseInt(tab.id)
    ChromeTabs.injectStyle tid, 'content-scripts/css/page-note-scale.css'
    ChromeTabs.injectScript tid, 'application.js'
    ChromeTabs.injectScript tid, 'js/page-app.js'
    @tabs[tid] = tab
    console.log 'injectPageApp', tab

  arrDel: (arr, value)->
    arr.splice(arr.indexOf(value), 1)

  isAllowed: (tab)->
    allowed = false
    allowed = true if tab.url.indexOf('http') is 0
    allowed = true if tab.url.indexOf('https') is 0
    allowed

  sendMessage: (tabId, message, onRespond = ->)->
    ChromeTabs.sendMessage tabId, message, onRespond

  onMessageQueue: (request, sender, sendBack)=>
    @messages.push {request: request, sender: sender, sendBack: sendBack}
    @onMessage()
    # The chrome.extension.onMessage listener must return true if you want to 
    # send a response after the listener returns
    true

  onMessage: =>
    return window.setTimeout @onMessage, 100 if not @fetched
    ms = @messages.shift()
    return if not ms.sender.tab
    switch ms.request.action
      when 'page-get-note'
      then @onPageGetNote ms.sender.tab, ms.request, ms.sendBack
      when 'page-save-note'
      then @onPageSaveNote ms.sender.tab, ms.request, ms.sendBack
      else return

  onPageGetNote: (tab, request, respond)=>
    # return @log 'tab', tab
    id = MD5 request.url
    if NoteCouch.exists id
      respond NoteCouch.find id
      return NoteCouch.fetch id: id
    else
      now = new Date
      respond NoteCouch.create
        id: id
        title: tab.title
        content: ''
        url: request.url
        time: now.getTime()

  onPageSaveNote: (tab, request, respond)=>
    note = NoteCouch.find request.note.id
    note.title = request.note.title
    note.content = request.note.content
    note.save()
    respond 'saved'

  onClick: (tab)=>
    return if not @isAllowed(tab)
    return if @tabs[tab.id]
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
    return if not @isAllowed(tab)
    return if changeInfo.status isnt 'complete'
    @injectPageApp tab

  onTabCreate: (tab)=>
    # @log 'onTabCreate'
    # @log 'tab', tab

  onTabActive: (tab)=>
    # @log 'onTabActive'
    # @log 'tab', tab

  onTabRemove: (tabId, info)=>
    delete @tabs[tabId]


module.exports = Background