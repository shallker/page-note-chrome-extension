Spine = require('spine')

class Doc extends Spine.Model
  @configure 'Doc', 'url', 'origin', 'time'

  @extend Spine.Model.Local
  
module.exports = Doc