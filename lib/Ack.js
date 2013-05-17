var _ = require('underscore'),
    moment = require('moment'),
    Ack;

Ack = (function() {
    function Ack(options) {
        options = _.defaults(options || {}, {
            code: 'AA',
            subs: {}
        });
        if (!options.message) {
            throw Error('No message supplied');
        }

        _.extend(this, options);
    }

    Ack.prototype.toString = function() {
        var date, messageControlId, receivingApplication, receivingFacility, sendingApplication, sendingFacility, textMessage, _ref;

        _ref = this.subs, sendingApplication = _ref.sendingApplication, sendingFacility = _ref.sendingFacility, receivingApplication = _ref.receivingApplication, receivingFacility = _ref.receivingFacility, textMessage = _ref.textMessage;
        if (sendingApplication == null) {
            sendingApplication = this.message.query('MSH|5');
        }
        if (sendingFacility == null) {
            sendingFacility = this.message.query('MSH|6');
        }
        if (receivingApplication == null) {
            receivingApplication = this.message.query('MSH|3');
        }
        if (receivingFacility == null) {
            receivingFacility = this.message.query('MSH|4');
        }
        messageControlId = this.message.query('MSH|10');

        date = moment(this.subs.dateTimeOfMessage).format('YYYYMMDDHHmmss');

        return "MSH|^~\\&|" + sendingApplication + "|" + sendingFacility + "|" + receivingApplication + "|" + receivingFacility + "|" + date + "||ACK^O01|" + messageControlId + "|P|2.3\nMSA|" + this.code + "|" + messageControlId + (textMessage ? "|" + textMessage : '');
    };

    return Ack;
})();

module.exports = Ack;
