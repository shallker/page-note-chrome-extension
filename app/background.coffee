require('lib/setup')
CouchDB = require 'lib/couchDB'
Extension = require 'lib/BrowserAction'
ChromeTabs = require 'lib/ChromeTabs'
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
    Extension.listenClick @onClick

  onClick: (tab)=>
    # if tab.url is "chrome://extensions/" or 
    # tab.url is "chrome://newtab/"
    # then return
    
    return if tab.url.indexOf('chrome') is 0

    # console.log tab, @
    # noteId = MD5 tab.url
    # console.log noteId
    # note = Note.exists noteId
    # console.log note

    @injectContentScripts tab.id

  injectContentScripts: (tabId)->
    ChromeTabs.injectStyle tabId, 'content-scripts/css/page-note-scale.css'
    # ChromeTabs.injectScript tabId, 'content-scripts/js/jquery.js'
    # ChromeTabs.injectScript tabId, 'content-scripts/js/mousetrap.js'
    # ChromeTabs.injectScript tabId, 'content-scripts/js/page-note.js'
    ChromeTabs.injectScript tabId, 'application.js'
    ChromeTabs.injectScript tabId, 'js/web-app.js'

  onTabUpdate: (tabId, changeInfo, tab)=>
    # @log changeInfo, tab
    PageAction.show tabId if MD5(tab.url) is 'd09057f8a646d24ef7287f02359deb9c'



module.exports = Background