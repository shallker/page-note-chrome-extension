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
  ports: {}
  fetched: false
  messages: []

  setInterval = (func, secs)-> window.setInterval func, secs
  setTimeout = (func, secs)-> window.setTimeout func, secs

  constructor: ->
    super
    @listen()
    NoteCouch.fetch()
    NoteCouch.bind "refresh", @onRefreshNotes
    NoteCouch.bind "update", @onUpdateNote

  # run: ->
    # setInterval @onRun, 1000*60*3

  # check new data from server
  # onRun: =>

  listen: ->
    BrowserAction.listenClick @onClick
    ChromeExtension.listenConnect @onConnect

  onRefreshNotes: (notes)=>
    @log 'refresh', notes
    @fetched = true
    @flashBadge 'load'
    @sendRefreshNote note for note in notes

  onUpdateNote: (note)=>
    # @log 'update', note

  sendRefreshNote: (note)->
    mesg =
      action: 'refresh-note'
      note: note
    @postMessage port, mesg for pid, port of @ports

  onConnect: (port)=>
    # @log 'onConnect', port
    pid = port.portId_
    @ports[pid] = port
    port.onMessage.addListener (mesg)=> @onMessageQueue port, mesg
    port.onDisconnect.addListener @onDisconnect

  onMessageQueue: (port, mesg)=>
    @messages.push {port: port, mesg: mesg}
    @onMessage()
    true

  onMessage: =>
    return setTimeout @onMessage, 100 if not @fetched
    m = @messages.shift()
    switch m.mesg.action
      when 'page-load-note'
      then @onPageLoadNote m.port, m.mesg
      when 'page-save-note'
      then @onPageSaveNote m.port, m.mesg
      else return

  onDisconnect: (port)=>
    delete @ports[port.portId_]

  # injectPageApp: (tab)->
  #   return if not @isAllowed tab
  #   tid = parseInt(tab.id)
  #   ChromeTabs.injectStyle tid, 'content-scripts/css/page-note-scale.css'
  #   ChromeTabs.injectScript tid, 'application.js'
  #   ChromeTabs.injectScript tid, 'js/page-app.js'
  #   @tabs[tid] = tab
  #   console.log 'injectPageApp', tab

  # arrDel: (arr, value)->
  #   arr.splice(arr.indexOf(value), 1)

  postMessage: (port, mesg)->
    port.postMessage mesg

  onPageLoadNote: (port, mesg)=>
    # return @log 'tab', tab
    id = MD5 mesg.url
    if NoteCouch.exists id
      NoteCouch.fetch id: id
      note = NoteCouch.find id
    else
      now = new Date
      note = NoteCouch.create
        id: id
        title: tab.title
        content: ''
        url: request.url
        time: now.getTime()    
    port.postMessage
      action: 're-page-load-note'
      note: note

  onPageSaveNote: (port, mesg)=>
    note = NoteCouch.find mesg.note.id
    note.title = mesg.note.title
    note.content = mesg.note.content
    note.save()

  setTitle: (text)->
    BrowserAction.setTitle text

  setBadge: (text)->
    BrowserAction.setBadge text

  flashBadge: (flashText)->
    milsecs = 500
    BrowserAction.getBadge (text)=>
      @setBadge flashText
      setTimeout (=> @setBadge text), milsecs

  onClick: (tab)=>
    # @log tab

  # onTabUpdate: (tabId, changeInfo, tab)=>
    # return if not @isAllowed(tab)
    # return if changeInfo.status isnt 'complete'
    # @injectPageApp tab

  # onTabCreate: (tab)=>
    # @log 'onTabCreate'
    # @log 'tab', tab

  # onTabActive: (tab)=>
    # @log 'onTabActive'
    # @log 'tab', tab

  # onTabRemove: (tabId, info)=>
    # delete @tabs[tabId]


module.exports = Background