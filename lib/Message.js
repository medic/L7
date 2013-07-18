var Ack = require('./Ack'),
    HeadSegment = require('./HeadSegment'),
    Message,
    Segment = require('./Segment'),
    queryparser = require('../definitions/query'),
    _ = require('underscore'),
    __slice = [].slice,
    moment = require('moment');

function getParts(message, query) {
    var selectors = [].concat(query.selectors),
        selector = selectors.shift(),
        parts = message.getParts(selector),
        val;

    while (!_.isEmpty(selectors)) {
        selector = selectors.shift();
        parts = _.map(parts, function(part) {
            if (part) {
                return part.getPart(selector);
            } else {
                return null;
            }
        });
    }

    return parts;
}

function getValues(message, query) {
    var parts = getParts(message, query);

    return _.map(parts, function(part) {
        if (part) {
            val = part.val();

            return query.toDate ? toDate(val) : val;
        } else {
            return null;
        }
    });
}

function getValue(message, query) {
    var val = _.first(getValues(message, query));

    return val === undefined ? null : val;
}

function toDate(val) {
    var date;

    if (/^\d{8,14}$/.test(val)) {
        date = moment(val, 'YYYYMMDDHHmmss');
        if (_.isNaN(date.valueOf())) {
            return null;
        } else {
            return date.toDate();
        }
    } else {
        return null;
    }
}

Message = (function() {
    function Message(raw, control) {
        var msh, segments;

        msh = raw[0], segments = 2 <= raw.length ? __slice.call(raw, 1) : [];
        this.errors = [];
        this.segments = [];
        this.segments.push(new HeadSegment(msh, control));
        _.each(segments, function(segment) {
            return this.segments.push(new Segment(segment, control));
        }, this);
        this.validate();
        return;
    }

    Message.prototype.getParts = function(name) {
        return _.filter(this.segments, function(segment) {
            return segment.name === name;
        });
    };

    Message.prototype.getPart = function(name) {
        return _.first(this.getParts(name));
    };

    Message.prototype.validate = function() {
        var _ref;

        if (((_ref = this.segments[0]) != null ? _ref.name : void 0) !== 'MSH') {
            this.errors.push('Missing MSH segment');
        }
        return this.valid = this.errors.length === 0;
    };

    Message.prototype.query = function(q) {
        var query;

        try {
            query = queryparser.parse(q);

            if (query.repeat) {
                return getValues(this, query);
            } else {
                return getValue(this, query);
            }
        } catch (e) {
            throw new Error("Bad selector '" + q + "': " + e.message);
        }
    };

    Message.prototype.reject = function(substitutions) {
        return this.respond('AR', substitutions);
    };

    Message.prototype.error = function(substitutions) {
        return this.respond('AE', substitutions);
    };

    Message.prototype.acknowledge = function(substitutions) {
        return this.respond('AA', substitutions);
    };

    Message.prototype.respond = function(code, substitutions) {
        return new Ack({
            message: this,
            code: code,
            subs: substitutions
        }).toString();
    };

    Message.prototype.translate = function(map, override) {
        var result;

        result = _.reduce(map, function(memo, val, key) {
            memo[key] = this.query(val);
            return memo;
        }, {}, this);
        return _.extend(result, override);
    };

    Message.prototype.toString = function() {
        return _.map(this.segments, function(segment) {
            return segment.toString();
        }).join('\r');
    };

    Message.prototype.replace = function(q) {
        var query = queryparser.parse(q),
            parts = getParts(this, query),
            replacements = _.toArray(arguments).slice(1);

        _.each(parts, function(part) {
            if (part) {
                return part.val(replacements);
            } else {
                return null;
            }
        });
    };

    Message.prototype.remove = function() {
        var names;

        names = _.map(_.toArray(arguments), function(name) {
            return new RegExp('^' + name.replace(/\*$/, '.+') + '$');
        });

        this.segments = _.reject(this.segments, function(segment) {
            return _.any(names, function(name) {
                return name.test(segment.name);
            });
        });
    };

    return Message;

})();

module.exports = Message;
