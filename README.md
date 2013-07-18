L7
======

A simple HL7 query language and message manipulator.

Usage
----

Given HL7:

    MSH|^~\&|REG|XYZ||XYZ|20050912110538||SIU^S12|4676115|P|2.3
    PID|||353966||SMITH^JOHN^^^^||19820707|F||C|108 MAIN STREET ^^ANYTOWN^TX^77777^^|HARV|(512)555-0170|||||00362103|123-45-6789||||||||||||
    SCH|1||||||NEW||||20050912110230^20050912110430||||||||||||||||||^^^^^^||3|
    PV1||O|SEROT|3|||1284^JOHNSON^MIKE^S.^^MD~|||SEROT||||1|||1284^JOHNSON^MIKE^S.^^ MD|SERIES|787672|B|||||||||N||||||||||||A|||20050912110230|||||| PV2|||HAND BRACE NEEDS REPAIRED|||||||||||20050912||||||||||A||20050725|||||O||||||
    NK1|0001|HULK^INCREDIBLE|M|123 FAKE ST^^OUTLAND^^00000|123456789||
    NK1|0002|HULK^DEBATEABLE|M|122 FAKE ST^^OUTLAND^^00000|123456789||

And the javascript:

    parser = require('L7')

    message = parser.parse(hl7)
    version = message.query('MSH|12') // 2.3
    kinAddresses = message.query('NK1[4]') // ['123 FAKE ST^^OUTLAND^^00000', '122 FAKE ST^^OUTLAND^^00000']
    kinStreets = message.query('NK1|4[0]') // ['123 FAKE ST', '122 FAKE ST']

    name = message.translate({
      familyName: 'PID|5^0'
      firstName: 'PID|5^1'
    }) // { "familyName": "McTest", "firstName": "Test" }

    message.toString() // returns original message
    message.replace('PID|5', 'McFake', 'Firstname'); // replaces the values in the message with the supplied ones
    message.replace('PID|11^0', '123 Fake Street'); // can replace just one element

    message.remove('PV1'); // removes the PV1 segment if it exists
    message.remove('IN1', 'IN2'); // removes the IN1 and IN2 segments if they exists
    message.remove('Z*'); // remove all "Z" segements

Installation
------------

    $ npm install L7

Development
-----------

  * [Twitter](http://twitter.com/wombleton)

Caveat
------

This package is in its infancy, use with caution.
