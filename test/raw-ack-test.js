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
        'returns correct code': function(parser) {
            var ack = parser.ack({
                code: 'AE'
            });
            return ack.toString().should.include('AE');
        }
    }
})["export"](module);
