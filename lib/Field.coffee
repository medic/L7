Composed = require('./Composed')
Component = require('./Component')

class Field extends Composed
  constructor: (@raw) ->
    @length = @raw.length
    @assign(Component)
  delimiter: '^'
  getComponent: (index) ->
    @getPart(index)

module.exports = Field
