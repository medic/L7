_ = require('underscore')

class Ack
  constructor: (@message = '', @code = 'AA', @subs = {}) ->
    throw Error('No message supplied') unless @message
    @code = code
  toString: ->
    { sendingApplication, sendingFacility, receivingApplication, receivingFacility, textMessage } = @subs
    # reversed -- is receiving application of original message
    sendingApplication ?= @message.query('MSH|5')
    sendingFacility ?= @message.query('MSH|6')
    receivingApplication ?= @message.query('MSH|3')
    receivingFacility ?= @message.query('MSH|4')

    messageControlId = @message.query('MSH|10')
    date = require('..').formatDate(@subs.dateTimeOfMessage)

    """
    MSH|^~\\&|#{sendingApplication}|#{sendingFacility}|#{receivingApplication}|#{receivingFacility}|#{date}||ACK^O01|#{messageControlId}|P|2.3
    MSA|#{@code}|#{messageControlId}#{if textMessage then "|#{textMessage}" else ''}
    """

module.exports = Ack
