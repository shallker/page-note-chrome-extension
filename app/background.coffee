require('lib/setup')
CouchDB = require 'lib/couchDB'
BrowserAction = require 'lib/BrowserAction'
ChromeTabs = require 'lib/ChromeTabs'
ChromeExtension = require 'lib/ChromeExtension'
MD5 = require 'lib/md5-min'

Spine = require('spine')

Note = require 'models/note'

class Background extends Spine.Controller
  constructor: ->
    super
    @running()
    # couch = new CouchDB 'https://shallker.iriscouch.com/', 'test'
    # has = => @log 'yes'
    # hasnt = => @log 'no'
    # couch.has 'new_id', has, hasnt
    
    # get = (text)=> @log text
    # getnt = => @log 'get not'
    # couch.get 'my_id', get, getnt

    # insert = (text)=> @log text
    # insertnt = => @log 'insert failed'
    # couch.insert 'my_id', name: 'Jack', insert, insertnt

  running: ->
    ChromeTabs.listenUpdate @onTabUpdate
    ChromeTabs.listenActive @onTabActive
    ChromeTabs.listenCreate @onTabCreate
    BrowserAction.listenClick @onClick
    ChromeExtension.listenMessage @onMessage
    Note.fetch()

  onMessage: (request, sender, sendBack)=>
    return if not sender.tab
    switch request.action
      when 'page-get-note' then @onPageGetNote request, sendBack
      when 'page-save-note' then @onPageSaveNote request, sendBack
      else return

  onPageGetNote: (request, sendBack)=>
    id = MD5 request.url
    return sendBack Note.find id if Note.exists id
    now = new Date
    sendBack Note.create
      id: id
      index: ''
      content: ''
      url: request.url
      time: now.getTime()

  onPageSaveNote: (request, sendBack)=>
    Note.update request.note.id, request.note
    sendBack 'saved'

  onClick: (tab)=>
    # if tab.url is "chrome://extensions/" or 
    # tab.url is "chrome://newtab/"
    # then return
    
    # return if tab.url.indexOf('chrome') is 0

    # console.log tab, @
    # noteId = MD5 tab.url
    # console.log noteId
    # note = Note.exists noteId
    # console.log note

    # @injectContentScripts tab.id

  injectPageApp: (tabId)->
    ChromeTabs.injectStyle tabId, 'content-scripts/css/page-note-scale.css'
    ChromeTabs.injectScript tabId, 'application.js'
    ChromeTabs.injectScript tabId, 'js/page-app.js'

  onTabUpdate: (tabId, changeInfo, tab)=>
    allowed = false
    allowed = true if tab.url.indexOf('http') is 0
    allowed = true if tab.url.indexOf('https') is 0
    return if not allowed
    return if changeInfo.status isnt 'complete'
    @injectPageApp tabId

    # @log 'onTabUpdate'
    # @log 'changeInfo', changeInfo
    # @log 'tab', tab
    # PageAction.show tabId if MD5(tab.url) is 'd09057f8a646d24ef7287f02359deb9c'

  onTabCreate: (tab)=>
    # @log 'onTabCreate'
    # @log 'tab', tab

  onTabActive: (tab)=>
    # @log 'onTabActive'
    # @log 'tab', tab


module.exports = Background