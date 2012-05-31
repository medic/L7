_ = require('underscore')
_s = require('underscore.string')

class Ack
  constructor: (@message = '', @code = 'AA', @subs = {}) ->
    throw Error('No message supplied') unless @message
    @code = code
  formatDate: (date = new Date()) ->
    num = (d) ->
      _s.lpad(d, 2, '0')
    "#{date.getFullYear()}#{num(date.getMonth() + 1)}#{num(date.getDate())}#{num(date.getHours())}#{num(date.getMinutes())}#{num(date.getSeconds())}"
  toString: ->
    messageControlId = @message.query('MSH|10')
    date = @formatDate(@subs.dateTimeOfMessage)
    """
    MSH|^~\&|CATH|StJohn|AcmeHIS|StJohn|#{date}||ACK^O01|#{messageControlId}|P|2.3
    MSA|#{@code}|#{messageControlId}
    """

module.exports = Ack
