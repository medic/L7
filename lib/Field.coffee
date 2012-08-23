_ = require('underscore')
Composed = require('./Composed')
Component = require('./Component')

class Field extends Composed
  constructor: (@raw, @control) ->
    @length = @raw.length
    @assign(Component)
    @delimiter = @control.components
    return
  getComponent: (index) ->
    @getPart(index)
  setVal: (values) ->
    @raw = _.map(values, (value) ->
      [value]
    )

module.exports = Field
