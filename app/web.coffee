require('lib/setup')

Spine = require('spine')
Notes = require 'controllers/notes'

class Web extends Spine.Controller

  el: document.body
  html: document.documentElement
  
  constructor: ->
    super
    url = window.location.origin + window.location.pathname
    url = url.replace(/\/$/g, "")  # trim last backslash /
    @notes = new Notes(url)
    @append @notes

module.exports = Web