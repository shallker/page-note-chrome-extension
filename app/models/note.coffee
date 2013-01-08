Spine = require('spine')

class Note extends Spine.Model
  @configure 'Note', 'id', 'title', 'content', 'url', 'time'

  @extend Spine.Model.Local
  
module.exports = Note