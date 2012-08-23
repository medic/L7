Field = require('./Field')
Segment = require('./Segment')
_ = require('underscore')

class HeadSegment extends Segment
  constructor: (segment, @control) ->
    super(segment, @control)
    @fields.splice(1, 0, new Field([[@control.fields]], @control))
  toString: ->
    _.reduce(@fields, (memo, field, index) ->
      if index is 0
        memo.push('MSH')
        memo.push("#{@control.components}#{@control.repeat}#{@control.escape}#{@control.subcomponents}")
      else if index > 2
        memo.push(field.toString())
      memo
    , [], @).join(@control.fields)

module.exports = HeadSegment
