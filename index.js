require('coffee-script');
_ = require('underscore');
parser = require('./lib/parser');

module.exports = {
  parse: function(s) {
    if (_.isString(s) && s) {
      return parser.parse(s);
    } else {
      return {
        error: "Expected an HL7 message but got '" + s + "'"
      }
    }
  }
}
