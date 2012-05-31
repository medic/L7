Composed = require('./Composed')
Subcomponent = require('./Subcomponent')

class Component extends Composed
  constructor: (@raw) ->
    @assign(Subcomponent)
    return
  delimiter: '&'
  getSubcomponent: (index) ->
    @getPart(index)

module.exports = Component
