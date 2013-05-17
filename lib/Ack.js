var _ = require('underscore'),
    moment = require('moment'),
    Ack;

Ack = (function() {
    function Ack(options) {
        options = options || {};

        if (options.message) {
            options.values = options.message.translate({
                sendingApplication: 'MSH|5',
                sendingFacility: 'MSH|6',
                receivingApplication: 'MSH|3',
                receivingFacility: 'MSH|4',
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
            "MSH|^~\\&|<%=sendingApplication%>|<%=sendingFacility%>|<%=receivingApplication%>|<%=receivingFacility%>|<%=date%>||ACK^O01|<%=messageControlId%>|P|2.3",
            "MSA|<%=code%>|<%=messageControlId%>|<%=textMessage%>"
        ].join('\n'));

        _.extend(this, options);
    }

    Ack.prototype.toString = function() {
        var date = moment(this.subs.dateTimeOfMessage).format('YYYYMMDDHHmmss'),
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
