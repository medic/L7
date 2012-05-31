class Composed
  assign: (ChildClass) ->
    @parts = _.reduce(@raw, (memo, component) ->
      memo.push(new ChildClass(component))
      memo
    , [])
  getPart: (index) ->
    @parts[index]
  val: ->
    if @parts
      _.map(_.flatten(@parts), (part) ->
        part.val()
      ).join(@delimiter)
    else
      @raw

module.exports = Composed
