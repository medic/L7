Segment = require('./Segment')
HeadSegment = require('./HeadSegment')
Ack = require('./Ack')

queryparser = require('../definitions/query')

class Message
  constructor: (raw, control) ->
    [msh, segments...] = raw
    @errors = []
    @segments = []

    # all messages have a head segment to start with; it's handled a bit differently
    @segments.push(new HeadSegment(msh, control))
    _.each(segments, (segment) ->
      @segments.push(new Segment(segment, control))
    , @)
    @validate()
    return
  getSegment: (name) ->
    _.find(@segments, (segment) ->
      segment.name is name
    )
  validate: ->
    @errors.push('Missing MSH segment') unless @segments[0]?.name is 'MSH'
    @valid = @errors.length is 0
  query: (query) ->
    try
      { component, field, segment, toDate } = queryparser.parse(query)

      fieldEl = @getSegment(segment)?.getField(field)
      if _.isNull(component)
        if _.isUndefined(fieldEl)
          val = null
        else
          val = fieldEl?.val()
      else
        componentEl = fieldEl?.getComponent(component)
        if _.isUndefined(componentEl)
          val = null
        else
          val = componentEl.val()
      if val and toDate
        match = val.match(/(\d{4})(\d{2})(\d{2})(\d{2})?(\d{2})?(\d{2})?/)
        if match
          [datestring, year, month, day, hours, minutes, seconds] = match
          hours ?= 0
          minutes ?= 0
          seconds ?= 0
          date = new Date(year, Number(month) - 1, day, hours, minutes, seconds, 0)
        else
          null
      else
        val
    catch e
      throw new Error("Bad selector '#{query}'")
  reject: (substitutions) ->
    @respond('AR', substitutions)
  error: (substitutions) ->
    @respond('AE', substitutions)
  acknowledge: (substitutions) ->
    @respond('AA', substitutions)
  respond: (code, substitutions) ->
    new Ack(@, code, substitutions).toString()
  translate: (map, override) ->
    result = _.reduce(map, (memo, val, key) =>
      memo[key] = @query(val)
      memo
    , {})
    _.extend(result, override)
  toString: ->
    _.map(@segments, (segment) ->
      segment.toString()
    ).join('\n')
  replace: (query, replacements...) ->
    try
      { component, field, segment, toDate } = queryparser.parse(query)

      fieldEl = @getSegment(segment)?.getField(field)
      if _.isNull(component)
        unless _.isUndefined(fieldEl)
          fieldEl.val(replacements)
      else
        componentEl = fieldEl?.getComponent(component)
        unless _.isUndefined(componentEl)
          componentEl.val(replacements)
    catch e
      throw new Error("Bad selector '#{query}'")
  remove: (names...) ->
    @segments = _.reject(@segments, (segment) ->
      _.find(names, (name) ->
        ///^#{name.replace('*', '.+')}$///.test(segment.name)
      )
    )
module.exports = Message
