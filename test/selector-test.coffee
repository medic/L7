vows = require('vows')
should = require('should')

parser = require('..')

vows.describe('parser parsing').addBatch(
  'basic error handling':
    topic: -> parser
    'when parsing empty string return an error object': (topic) ->
      topic.parse('').should.have.property('error')
    'when parsing anything except a string throw an error': (topic) ->
      topic.parse(undefined).should.have.property('error')
      topic.parse(null).should.have.property('error')
      topic.parse(0).should.have.property('error')
      topic.parse(77).should.have.property('error')
    'when parsing expect an MSH header': (topic) ->
      result = topic.parse('qq')
      result.should.have.property('errors').with.lengthOf(1)
      result.errors[0].should.equal('Missing MSH segment')
      result.should.have.property('valid', false)
  'msh handling':
    topic: -> parser.parse(message)
    'special MSH handling': (message) ->
      should.exist(message)
      msh = message.getSegment('MSH')
      should.exist(msh)
      msh.name.should.eql('MSH')
      msh.should.have.property('getValue')
      msh.getValue(0).should.eql('MSH')
      msh.getValue(1).should.eql('|')
  'segments':
    topic: ->
      parser.parse(message).getSegment('MSH')
    'get value': (msh) ->
      msh.getValue(10).should.eql('4676115')
    'get field': (msh) ->
      msh.getField(3).should.have.lengthOf(3)
    'get value of field': (msh) ->
      msh.getField(3).val().should.eql('REG^REG^')
    'get component of field': (msh) ->
      msh.getField(3).getComponent(0).val().should.eql('REG')
    'get subcomponent of component': (msh) ->
      msh.getField(8).getComponent(0).getSubcomponent(1).val().should.eql('U')
      msh.getField(8).getComponent(0).val().should.eql('SI&U')
  'query definition':
    topic: ->
      parser.parse(message)
    'basic query': (msg) ->
      msg.query('PID|3').should.eql('353966')
    'component query': (msg) ->
      msg.query('PID|5^0').should.eql('SMITH')
    'querying segment with a number in it': (msg) ->
      msg.query('PV1|2').should.eql('O')
  'error handling for queries':
    topic: ->
      parser.parse(message)
    'bad selector throws an error': (msg) ->
      (->
        msg.query('MOONBAT|MOONBAT')
      ).should.throw()
      try
        msg.query('MOONBAT*MOONBAT')
      catch e
        e.message.should.eql("Bad selector 'MOONBAT*MOONBAT'")
      try
        msg.query('MOONBAT|MOONBAT')
      catch e
        e.message.should.eql("Bad selector 'MOONBAT|MOONBAT'")
  'querying for elements that are not there':
    topic: ->
      parser.parse(message)
    'selector with badly indexed component should return null': (msg) ->
      should.strictEqual(msg.query('PID|5^1000'), null)
    'selector going off the end of the segment should return null': (msg) ->
      should.strictEqual(msg.query('PID|1000'), null)
    'selector total miss should return null': (msg) ->
      should.strictEqual(msg.query('QQQ|0'), null)
    'selector total miss with component should return null': (msg) ->
      should.strictEqual(msg.query('QQQ|0^5'), null)
  'error handling for translate':
    topic: ->
      parser.parse(message)
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
  'date autoboxing':
    topic: ->
      parser.parse(message)
    'date selector should not throw an error': (msg) ->
      (->
        msg.query('MSH@7')
      ).should.not.throw()
    'date selector should return a date': (msg) ->
      result = msg.query('MSH@7')
      _.isDate(result).should.be.true
      result.getFullYear().should.eql(2005)
      result.getMonth().should.eql(8) # months offset by 1
      result.getDate().should.eql(12)
      result.getHours().should.eql(11)
      result.getMinutes().should.eql(5)
      result.getSeconds().should.eql(38)
      result.getMilliseconds().should.eql(0)
    'date selector which does not select date should return null': (msg) ->
      (->
        msg.query('MSH@8')
      ).should.not.throw()
      should.strictEqual(null, msg.query('MSH@8'))
    'date selector works for components': (msg) ->
      result = msg.query('SCH|11@1')
      _.isDate(result).should.be.true
      result.getFullYear().should.eql(2005)
      result.getMonth().should.eql(8) # months offset by 1
      result.getDate().should.eql(12)
      result.getHours().should.eql(11)
      result.getMinutes().should.eql(4)
      result.getSeconds().should.eql(30)
      result.getMilliseconds().should.eql(0)
    'date selector returns null for missing dates': (msg) ->
      should.strictEqual(msg.query('SCH|11@1000'), null)
    'date selector accepts partial dates': (msg) ->
      result = msg.query('PID@7')
      _.isDate(result).should.be.true
      result.getFullYear().should.eql(1982)
      result.getMonth().should.eql(6) # months offset by 1
      result.getDate().should.eql(7)
      result.getHours().should.eql(0)
      result.getMinutes().should.eql(0)
      result.getSeconds().should.eql(0)
      result.getMilliseconds().should.eql(0)
  'translate':
    topic: ->
      parser.parse(message)
    'translate': (msg) ->
      msg.translate(
        familyName: 'PID|5^0'
        firstName: 'PID|5^1'
      ).should.eql(familyName: 'SMITH', firstName: 'JOHN')
).export(module)

message = """
MSH|^~\&|REG^REG^|XYZ||XYZ|20050912110538|SI&U|SIU^S12|4676115|P|2.3
PID|||353966||SMITH^JOHN^^^^||19820707|F||C|108 MAIN STREET ^^ANYTOWN^TX^77777^^|HARV|(512)555-0170|||||00362103|123-45-6789||||||||||||
SCH|1||||||NEW||||20050912110230^20050912110430||||||||||||||||||^^^^^^||3|
PV1||O|SEROT|3|||1284^JOHNSON^MIKE^S.^^MD~|||SEROT||||1|||1284^JOHNSON^MIKE^S.^^ MD|SERIES|787672|B|||||||||N||||||||||||A|||20050912110230|||||| PV2|||HAND BRACE NEEDS REPAIRED|||||||||||20050912||||||||||A||20050725|||||O||||||
NK1|0001|HULK^INCREDIBLE|M|123 FAKE ST^^OUTLAND^^00000|123456789||
"""
