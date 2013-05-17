var _ = require('underscore'),
    parser = require('./lib/parser'),
    dateFormat = require('./lib/date-format'),
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
    reject: function(options) {
        options = options || {};
        options.code = 'AR';

        return module.exports.ack(options);
    },
    error: function(options) {
        options = options || {};
        options.code = 'AE';

        return module.exports.ack(options);
    },
    ack: function(options) {
        return new Ack(options);
    },
    formatDate: function(d) {
        return dateFormat(d);
    }
};
