var vows = require('vows'),
    should = require('should'),
    _ = require('underscore'),
    parser = require('..'),
    message;

vows.describe('list selectors').addBatch({
    'querying for missing element': {
        topic: function() {
            return parser.parse(message);
        },
        'bad selector should return empty list': function(msg) {
            return msg.query('OBT[1]').should.eql([]);
        },
    },
    'querying existing elements': {
        topic: function() {
            return parser.parse(message);
        },
        'selector with invalid index should return 1x null': function(msg) {
            return msg.query('PID[10000]').should.eql([null]);
        },
        'selector with valid index and 1x result should return 1x value': function(msg) {
            return msg.query('PID[3]').should.eql(['353966']);
        },
        'selector with valid index and 4x result should return 4x values': function(msg) {
            return msg.query('OBX[1]').should.eql(['A^1', 'B^2', 'C^3', 'C^3']);
        },
        'selector with valid component index and 4x result should return 4x values': function(msg) {
            return msg.query('OBX|1[1]').should.eql(['1', '2', '3', '3']);
        },
        'selector with one valid component index should return value and three nulls': function(msg) {
            return msg.query('OBX|2[0]').should.eql([null, 'Q', null, null]);
        }

    }
}).export(module);

message = "MSH|^~\\&|REG^REG^|XYZ||XYZ|20050912110538|SI&U|SIU^S12|4676115|P|2.3\r" +
    "PID|||353966||SMITH^JOHN^^^^||19820707|F||C|108 MAIN STREET ^^ANYTOWN^TX^77777^^|HARV|(512)555-0170|||||00362103|123-45-6789||||||||||||\r" +
    "SCH|1||||||NEW||||20050912110230^20050912110430||||||||||||||||||^^^^^^||3|\r" +
    "OBX|A^1\r" +
    "PV1||O|SEROT|3|||1284^JOHNSON^MIKE^S.^^MD~|||SEROT||||1|||1284^JOHNSON^MIKE^S.^^ MD|SERIES|787672|B|||||||||N||||||||||||A|||20050912110230|||||| PV2|||HAND BRACE NEEDS REPAIRED|||||||||||20050912||||||||||A||20050725|||||O||||||\r" +
    "OBX|B^2|Q\r" +
    "OBX|C^3\r" +
    "NK1|0001|HULK^INCREDIBLE|M|123 FAKE ST^^OUTLAND^^00000|123456789||\r" +
    "OBX|C^3\r";
