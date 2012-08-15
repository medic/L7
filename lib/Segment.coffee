Field = require('./Field')

class Segment
  constructor: (fields) ->
    @name = _.first(_.flatten(fields))
    @fields = _.reduce(fields, (memo, field) ->
      memo.push(new Field(field))
      memo
    , [])
  getValue: (index) ->
    @fields[index]?.val() || ''
  getField: (index) ->
    @fields[index]
  toString: ->
    _.map(@fields, (field) ->
      field.toString()
    ).join('|')

module.exports = Segment
