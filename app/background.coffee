require('lib/setup')

Spine = require('spine')
CouchDB = require 'lib/couchDB'
PageAction = require 'lib/PageAction'
ChromeTabs = require 'lib/ChromeTabs'
MD5 = require 'lib/md5-min'

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

  onTabUpdate: (tabId, changeInfo, tab)=>
    # @log changeInfo, tab
    PageAction.show tabId if MD5(tab.url) is 'd09057f8a646d24ef7287f02359deb9c'

module.exports = Background