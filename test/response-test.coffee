vows = require('vows')
should = require('should')

parser = require('..')

vows.describe('responding').addBatch(
  'basic response handling':
    topic: -> parser.parse(hl7)
    'response returns something': (msg) ->
      should.exist(msg.respond('AA'))
    'response returns a string': (msg) ->
      _.isString(msg.respond('AA')).should.be.true
  'message subsitutions':
    topic: -> parser.parse(parser.parse(hl7).respond('AA'))
    'confirm message control id': (response) ->
      response.query('MSH|10').should.eql('4676115')
      response.query('MSA|2').should.eql('4676115')
    'confirm acknowledge code': (response) ->
      response.query('MSA|1').should.eql('AA')
  'message timestamp subsitutions':
    topic: ->
      response: parser.parse(parser.parse(hl7).respond('AA'))
      timestamp: new Date()
    'confirm timestamp of ACK': ({ response, timestamp }) ->
      result = response.query('MSH@7')
      _.isDate(result).should.be.true
      result.getFullYear().should.eql(timestamp.getFullYear())
      result.getMonth().should.eql(timestamp.getMonth())
      result.getDate().should.eql(timestamp.getDate())
      result.getHours().should.eql(timestamp.getHours())
      result.getMinutes().should.eql(timestamp.getMinutes())
      result.getSeconds().should.eql(timestamp.getSeconds())
      result.getMilliseconds().should.eql(0)
  'default response senders and receivers':
    topic: -> parser.parse(parser.parse(hl7).respond('AA'))
    'should reverse sending and receiving application by default': (response) ->
      response.query('MSH|3').should.eql('GOBLET')
      response.query('MSH|4').should.eql('ZYX')
      response.query('MSH|5').should.eql('REG^REG^')
      response.query('MSH|6').should.eql('XYZ')
  'overridden response senders and receivers':
    topic: ->
      parser.parse(parser.parse(hl7).respond('AA',
        sendingApplication: 'weasel'
        sendingFacility: 'town'
        receivingApplication: 'stoat'
        receivingFacility: 'village'
      ))
    'should apply overrides': (response) ->
      response.query('MSH|3').should.eql('weasel')
      response.query('MSH|4').should.eql('town')
      response.query('MSH|5').should.eql('stoat')
      response.query('MSH|6').should.eql('village')
  'error method':
    topic: -> parser.parse(hl7)
    'error is the same as responding with AE': (msg) ->
      msg.respond('AE').should.eql(msg.error())
  'reject method':
    topic: -> parser.parse(hl7)
    'reject is the same as responding with AR': (msg) ->
      msg.respond('AR').should.eql(msg.reject())
  'acknowledge method':
    topic: -> parser.parse(hl7)
    'acknowledge is the same as responding with AA': (msg) ->
      msg.respond('AA').should.eql(msg.acknowledge())
  'no text message':
    topic: -> parser.parse(parser.parse(hl7).acknowledge())
    'no text message means no MSA|3 field': (response) ->
      should.strictEqual(response.query('MSA|3'), null)
  'adding text message':
    topic: -> parser.parse(parser.parse(hl7).acknowledge(textMessage: 'Everything is fine.'))
    'text message received': (response) ->
      response.query('MSA|3').should.eql('Everything is fine.')
).export(module)

hl7 = """
MSH|^~\\&|REG^REG^|XYZ|GOBLET|ZYX|20050912110538|SI&U|SIU^S12|4676115|P|2.3
PID|||353966||SMITH^JOHN^^^^||19820707|F||C|108 MAIN STREET ^^ANYTOWN^TX^77777^^|HARV|(512)555-0170|||||00362103|123-45-6789||||||||||||
SCH|1||||||NEW||||20050912110230^20050912110430||||||||||||||||||^^^^^^||3|
PV1||O|SEROT|3|||1284^JOHNSON^MIKE^S.^^MD~|||SEROT||||1|||1284^JOHNSON^MIKE^S.^^ MD|SERIES|787672|B|||||||||N||||||||||||A|||20050912110230|||||| PV2|||HAND BRACE NEEDS REPAIRED|||||||||||20050912||||||||||A||20050725|||||O||||||
NK1|0001|HULK^INCREDIBLE|M|123 FAKE ST^^OUTLAND^^00000|123456789||
"""
