Field = require('./Field')
Segment = require('./Segment')

class HeadSegment extends Segment
  constructor: (segment) ->
    super(segment)
    @fields.splice(1, 0, new Field([['|']]))
  toString: ->
    _.reduce(@fields, (memo, field, index) ->
      if index is 0
        memo.push('MSH')
        memo.push('^~\\&')
      else if index > 2
        memo.push(field.toString())
      memo
    , []).join('|')

module.exports = HeadSegment
