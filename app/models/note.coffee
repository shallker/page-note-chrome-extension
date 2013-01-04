Spine = require('spine')

class Note extends Spine.Model
  @configure 'Note', 'docid', 'name', 'time'

  @extend Spine.Model.Local
  
module.exports = Note