var _ = require('underscore'),
    moment = require('moment'),
    parser = require('./lib/parser');

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
    formatDate: function(d) {
        return moment(d).format('YYYYMMDDHHmmss');
    }
};
