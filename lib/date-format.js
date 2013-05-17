var moment = require('moment');

module.exports = function(d) {
    return moment(d).format('YYYYMMDDHHmmss');
};
