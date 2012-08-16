vows = require('vows')
should = require('should')

parser = require('..')

vows.describe('replacing').addBatch(
  'basic':
    topic: ->
      parser.parse(hl7)
    'replacing a field works': (msg) ->
      msg.replace('NK1|1', 'abcd')
      msg.toString().should.eql(hl7.replace(/NK1\|0001/, 'NK1|abcd'))
    'replacing two parts works': (msg) ->
      msg.replace('NK1|1', 'abcd', 'efgh')
      msg.toString().should.eql(hl7.replace(/NK1\|0001/, 'NK1|abcd^efgh'))
  'component':
    topic: ->
      parser.parse(hl7)
    'replacing component works': (msg) ->
      msg.replace('NK1|2^0', 'smulk')
      msg.toString().should.eql(hl7.replace(/0001\|HULK/, '0001|smulk'))
).export(module)

hl7 = """
MSH|^~\\&|REG^REG^|XYZ|GOBLET|ZYX|20050912110538|SI&U|SIU^S12|4676115|P|2.3
PID|||353966||SMITH^JOHN^^^^||19820707|F||C|108 MAIN STREET ^^ANYTOWN^TX^77777^^|HARV|(512)555-0170|||||00362103|123-45-6789||||||||||||
SCH|1||||||NEW||||20050912110230^20050912110430||||||||||||||||||^^^^^^||3|
PV1||O|SEROT|3|||1284^JOHNSON^MIKE^S.^^MD~|||SEROT||||1|||1284^JOHNSON^MIKE^S.^^ MD|SERIES|787672|B|||||||||N||||||||||||A|||20050912110230|||||| PV2|||HAND BRACE NEEDS REPAIRED|||||||||||20050912||||||||||A||20050725|||||O||||||
NK1|0001|HULK^INCREDIBLE|M|123 FAKE ST^^OUTLAND^^00000|123456789||
"""

