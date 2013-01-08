Spine = require('spine')
require 'lib/spine/ajax'

class Note extends Spine.Model
  @configure 'Note', 'id', 'title', 'content', 'url', 'time', '_id', '_rev'

  @host: "http://shallker.iriscouch.com"

  @extend Spine.Model.Ajax
  
module.exports = Note