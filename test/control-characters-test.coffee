vows = require('vows')
should = require('should')

parser = require('..')

vows.describe('control chars').addBatch(
  'basic':
    topic: ->
      hl7
    'querying regular fields works': (hl7) ->
      msg = parser.parse(hl7)
      msg.query('PID|3').should.eql('353966')
      msg.query('PID|5^0').should.eql('SMITH')
    'querying MSH special fields works': (hl7) ->
      msg = parser.parse(hl7)
      msg.query('MSH|1').should.eql('+')
      msg.query('MSH|2').should.eql('@~\\&')
).export(module)

hl7 = """
MSH+@~\\&+REG@REG@+XYZ+GOBLET+ZYX+20050912110538+SI&U+SIU@S12+4676115+P+2.3
PID+++353966++SMITH@JOHN@@@@++19820707+F++C+108 MAIN STREET @@ANYTOWN@TX@77777@@+HARV+(512)555-0170+++++00362103+123-45-6789++++++++++++
"""
