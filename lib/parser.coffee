fs = require('fs')
_ = require('underscore')

Message = require('./Message')

messageparser = require('../definitions/message')

module.exports =
  parse: (s) ->
    try
      new Message(messageparser.parse(s))
    catch e
      { column, line, message } = e
      return {
        column: column
        error: message
        line: line
      }
