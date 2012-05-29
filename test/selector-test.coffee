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
      msh.getValue(10).should.eql('1233A6')
    'get field': (msh) ->
      msh.getField(3).should.have.lengthOf(3)
    'get value of field': (msh) ->
      msh.getField(3).val().should.eql('PM^PM^')
    'get component of field': (msh) ->
      msh.getField(3).getComponent(0).val().should.eql('PM')
    'get subcomponent of component': (msh) ->
      msh.getField(9).getComponent(0).getSubcomponent(1).val().should.eql('U')
      msh.getField(9).getComponent(0).val().should.eql('SI&U')
  'query definition':
    topic: ->
      parser.parse(message)
    'basic query': (msg) ->
      msg.query('PID|2').should.eql('7779')
    'component query': (msg) ->
      msg.query('PID|5^0').should.eql('McTest')
    'querying segment with a number in it': (msg) ->
      msg.query('PV1|1').should.eql('1')
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
      result.getFullYear().should.eql(2006)
      result.getMonth().should.eql(11) # months offset by 1
      result.getDate().should.eql(6)
      result.getHours().should.eql(19)
      result.getMinutes().should.eql(22)
      result.getSeconds().should.eql(56)
      result.getMilliseconds().should.eql(0)
    'date selector which does not select date should return null': (msg) ->
      (->
        msg.query('MSH@8')
      ).should.not.throw()
      should.strictEqual(null, msg.query('MSH@8'))
    'date selector works for components': (msg) ->
      result = msg.query('SCH|11@3')
      _.isDate(result).should.be.true
      result.getFullYear().should.eql(2006)
      result.getMonth().should.eql(11) # months offset by 1
      result.getDate().should.eql(29)
      result.getHours().should.eql(11)
      result.getMinutes().should.eql(20)
      result.getSeconds().should.eql(0)
      result.getMilliseconds().should.eql(0)
    'date selector accepts partial dates': (msg) ->
      result = msg.query('PID@7')
      _.isDate(result).should.be.true
      result.getFullYear().should.eql(1967)
      result.getMonth().should.eql(4) # months offset by 1
      result.getDate().should.eql(2)
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
      ).should.eql(familyName: 'McTest', firstName: 'Test')
).export(module)

message = """
MSH|^~\&|PM^PM^||eClinicalWorks^eClinicalWorks^||20061206192256||SI&U^S12|1233A6|P|2.3||||NE
SCH|72919|72919|||||Cough and Cold |Annual Visit|20|m|^^1200^20061229112000^20061229114000||||||||||||||Arrived^Checked in
PID|1|7779|||McTest^Test^||19670502|F||White|123 HIGH WAY^^Westboro^MA^01581||5085085085|||Married||32801465|999999999
PV1|1||110011||||C9999^TEST^DOCTOR^L|G8888^REF^PHY|||||||||||38808
AIG|1||Dr Hparser Id^Test, Doctor S||||
AIL|1||Facility Hparser Id^Facility||||
AIP|1||ResourceId^Resource Last Name^Resource First Name|||20020108150000|||10|m||
"""
