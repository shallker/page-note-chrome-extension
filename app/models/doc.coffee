Spine = require('spine')

class Doc extends Spine.Model
  @configure 'Doc', 'id', 'url', 'origin', 'time'

  @extend Spine.Model.Local
  
module.exports = Doc