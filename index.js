var _ = require('underscore'),
    parser = require('./lib/parser'),
    Ack = require('./lib/Ack');

module.exports = {
    parse: function(s) {
        if (s && _.isString(s)) {
            return parser.parse(s);
        } else {
            return {
                error: "Expected an HL7 message but got '" + s + "'"
            }
        }
    },
    ack: function(options) {
        return new Ack(options);
    }
};
