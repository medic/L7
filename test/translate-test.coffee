vows = require('vows')
should = require('should')

parser = require('..')

vows.describe('translating messages').addBatch(
  'error handling for translate':
    topic: ->
      parser.parse(hl7)
    'bad selector throws an error': (msg) ->
      (->
        msg.translate(fake: 'MOONBAT|MOONBAT')
      ).should.throw()
      try
        msg.translate(fake: 'MOONBAT*MOONBAT')
      catch e
        e.message.should.eql("Bad selector 'MOONBAT*MOONBAT'")
      try
        msg.translate(fake: 'MOONBAT|MOONBAT')
      catch e
        e.message.should.eql("Bad selector 'MOONBAT|MOONBAT'")
  'translate':
    topic: ->
      parser.parse(hl7)
    'translate': (msg) ->
      msg.translate(
        familyName: 'PID|5^0'
        firstName: 'PID|5^1'
      ).should.eql(familyName: 'SMITH', firstName: 'JOHN')

  'translate with overrides':
    topic: ->
      parser.parse(hl7)
    'translate': (msg) ->
      date = new Date()
      msg.translate(
        familyName: 'PID|5^0'
        firstName: 'PID|5^1'
      ,
        date: date
      ).should.eql(familyName: 'SMITH', firstName: 'JOHN', date: date)
).export(module)

hl7 = """
MSH|^~\\&|REG^REG^|XYZ||XYZ|20050912110538|SI&U|SIU^S12|4676115|P|2.3
PID|||353966||SMITH^JOHN^^^^||19820707|F||C|108 MAIN STREET ^^ANYTOWN^TX^77777^^|HARV|(512)555-0170|||||00362103|123-45-6789||||||||||||
SCH|1||||||NEW||||20050912110230^20050912110430||||||||||||||||||^^^^^^||3|
PV1||O|SEROT|3|||1284^JOHNSON^MIKE^S.^^MD~|||SEROT||||1|||1284^JOHNSON^MIKE^S.^^ MD|SERIES|787672|B|||||||||N||||||||||||A|||20050912110230|||||| PV2|||HAND BRACE NEEDS REPAIRED|||||||||||20050912||||||||||A||20050725|||||O||||||
NK1|0001|HULK^INCREDIBLE|M|123 FAKE ST^^OUTLAND^^00000|123456789||
"""
