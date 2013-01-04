require('lib/setup')

Spine = require('spine')
CouchDB = require 'lib/couchDB'

class Background extends Spine.Controller
  constructor: ->
    super
    couch = new CouchDB 'https://shallker.iriscouch.com/', 'test'
    # has = => @log 'yes'
    # hasnt = => @log 'no'
    # couch.has 'new_id', has, hasnt
    
    get = (text)=> @log text
    getnt = => @log 'get not'
    couch.get 'my_id', get, getnt

    # insert = (text)=> @log text
    # insertnt = => @log 'insert failed'
    # couch.insert 'my_id', name: 'Jack', insert, insertnt

module.exports = Background