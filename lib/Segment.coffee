Field = require('./Field')

class Segment
  constructor: (fields, @control) ->
    @name = _.first(_.flatten(fields))
    @fields = _.reduce(fields, (memo, field) ->
      memo.push(new Field(field, @control))
      memo
    , [], @)
  getValue: (index) ->
    @fields[index]?.val() || ''
  getField: (index) ->
    @fields[index]
  toString: ->
    _.map(@fields, (field) ->
      field.toString()
    ).join(@control.fields)

module.exports = Segment
