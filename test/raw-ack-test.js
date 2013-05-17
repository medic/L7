var _ = require('underscore'),
    parser = require('..'),
    Ack = require('../lib/Ack'),
    should = require('should'),
    vows = require('vows');

vows.describe('raw acks').addBatch({
    'basic': {
        topic: function() {
            return parser;
        },
        'has an ack function': function(parser) {
            return should.ok(_.isFunction(parser.ack));
        },
        'returns instanceof Ack': function(parser) {
            return parser.ack().should.be.an.instanceof(Ack);
        },
        'code defaults to AA': function(parser) {
            var ack = parser.ack({});
            return ack.toString().should.include('AA');
        },
        'returns correct code': function(parser) {
            var ack = parser.ack({
                code: 'AE'
            });
            return ack.toString().should.include('AE');
        }
    },
    'substitutions': {
        topic: function() {
            return parser;
        },
        'values done correctly': function(parser) {
            var ack,
                parsed;
            ack = parser.ack({
                values: {
                    sendingApplication: 'SA',
                    sendingFacility: 'SF',
                    receivingApplication: 'RA',
                    receivingFacility: 'RF',
                    messageControlId: 'MCI',
                    textMessage: 'TM'
                }
            });

            parsed = parser.parse(ack.toString());

            parsed.query('MSH|3').should.equal('RA');
            parsed.query('MSH|4').should.equal('RF');
            parsed.query('MSH|5').should.equal('SA');
            parsed.query('MSH|6').should.equal('SF');
            parsed.query('MSH|10').should.equal('MCI');
            parsed.query('MSA|1').should.equal('AA');
            parsed.query('MSA|2').should.equal('MCI');
            parsed.query('MSA|3').should.equal('TM');
            return;
        },
        'no LF found': function(parser) {
            parser.ack().toString().should.not.include('\n');
        }
    }
})["export"](module);
