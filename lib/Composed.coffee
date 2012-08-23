_ = require('underscore')

class Composed
  assign: (@clazz) ->
    @rebuild()
  rebuild: ->
    @parts = _.reduce(@raw, (memo, component) ->
      memo.push(new @clazz(component))
      memo
    , [], @)
  getPart: (index) ->
    @parts[index]
  val: ->
    if arguments.length is 0
      if @parts
        _.map(_.flatten(@parts), (part) ->
          part.val()
        ).join(@delimiter)
      else
        @raw
    else
      @setVal(_.first(arguments))
      @rebuild()
  setVal: (values) ->
    @raw = values
  toString: ->
    if @parts
      _.map(@parts, (part) ->
        part.toString()
      ).join(@delimiter)
    else if _.isArray(@raw)
      @raw.join(@delimiter)
    else
      @raw

module.exports = Composed
