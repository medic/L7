Field = require('./Field')
Segment = require('./Segment')

class HeadSegment extends Segment
  constructor: (segment) ->
    super(segment)
    @fields.splice(1, 0, new Field([['|']]))

module.exports = HeadSegment
