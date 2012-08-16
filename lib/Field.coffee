Composed = require('./Composed')
Component = require('./Component')

class Field extends Composed
  constructor: (@raw) ->
    @length = @raw.length
    @assign(Component)
    return
  delimiter: '^'
  getComponent: (index) ->
    @getPart(index)
  setVal: (values) ->
    @raw = _.map(values, (value) ->
      [value]
    )

module.exports = Field
