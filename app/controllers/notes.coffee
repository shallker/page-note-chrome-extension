Spine = require('spine')

class Notes extends Spine.Controller
  
  className: 'page-note'

  constructor: ->
    super
    # @html @render()

  render: ->
    # @template = require('views/notes')()
    
module.exports = Notes
