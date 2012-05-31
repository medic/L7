Composed = require('./Composed')

class Subcomponent extends Composed
  constructor: (@raw) ->
    return
  getValue: ->
    @raw

module.exports = Subcomponent
