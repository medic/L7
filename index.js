var cs = require('coffee-script'),
    _ = require('underscore'),
    _s = require('underscore.string'),
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
  },
  formatDate: function(date) {
    if (date == null) {
      date = new Date();
    }
    date = new Date(date);
    function num(d) {
      return _s.lpad(d, 2, '0');
    }
    return '' + (date.getFullYear()) + (num(date.getMonth() + 1)) + (num(date.getDate())) + (num(date.getHours())) + (num(date.getMinutes())) + (num(date.getSeconds()));
  }
};
