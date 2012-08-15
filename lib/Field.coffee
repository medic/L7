Composed = require('./Composed')
Component = require('./Component')

class Field extends Composed
  constructor: (@raw) ->
    @length = @raw.length
    @assign(Component)
  delimiter: '^'
  getComponent: (index) ->
    @getPart(index)
  toString: ->
    _.map(@raw, (component) ->
      component.join('&')
    ).join('^')

module.exports = Field
