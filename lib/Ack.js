var _ = require('underscore'),
    dateFormat = require('./date-format'),
    Ack;

Ack = (function() {
    function Ack(options) {
        options = options || {};

        if (options.message) {
            options.values = options.message.translate({
                sendingApplication: 'MSH|3',
                sendingFacility: 'MSH|4',
                receivingApplication: 'MSH|5',
                receivingFacility: 'MSH|6',
                messageControlId: 'MSH|10'
            });
        }

        options = _.defaults(options, {
            code: 'AA',
            subs: {},
            values: {}
        });

        options.values = _.defaults(options.values, {
            sendingApplication: '',
            sendingFacility: '',
            receivingApplication: '',
            receivingFacility: '',
            messageControlId: '',
            textMessage: ''
        });

        this.template = _.template([
            "MSH|^~\\&|<%=receivingApplication%>|<%=receivingFacility%>|<%=sendingApplication%>|<%=sendingFacility%>|<%=date%>||ACK^O01|<%=messageControlId%>|P|2.3",
            "MSA|<%=code%>|<%=messageControlId%>|<%=textMessage%>"
        ].join('\r'));

        _.extend(this, options);
    }

    Ack.prototype.toString = function() {
        var date = dateFormat(this.subs.dateTimeOfMessage),
            textMessage = this.subs.textMessage,
            data;

        data = _.clone(this.subs);
        data = _.defaults(data, this.values, {
            code: this.code,
            date: date
        });

        return this.template(data);
    };

    return Ack;
})();

module.exports = Ack;
