fs = require('fs')
_ = require('underscore')

Message = require('./Message')

messageparser = require('../definitions/message')

module.exports =
  parse: (s) ->
    try
      { message, control_characters } = messageparser.parse(s)
      new Message(message, control_characters)
    catch e
      { column, line, message } = e
      return {
        column: column
        error: message
        line: line
      }
