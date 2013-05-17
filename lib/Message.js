var Ack, HeadSegment, Message, Segment, queryparser, _,
__slice = [].slice;

Segment = require('./Segment');

HeadSegment = require('./HeadSegment');

Ack = require('./Ack');

_ = require('underscore');

queryparser = require('../definitions/query');

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

    Message.prototype.getSegment = function(name) {
        return _.find(this.segments, function(segment) {
            return segment.name === name;
        });
    };

    Message.prototype.validate = function() {
        var _ref;

        if (((_ref = this.segments[0]) != null ? _ref.name : void 0) !== 'MSH') {
            this.errors.push('Missing MSH segment');
        }
        return this.valid = this.errors.length === 0;
    };

    Message.prototype.query = function(query) {
        var component, componentEl, date, datestring, day, e, field, fieldEl, hours, match, minutes, month, seconds, segment, toDate, val, year, _ref, _ref1;

        try {
            _ref = queryparser.parse(query), component = _ref.component, field = _ref.field, segment = _ref.segment, toDate = _ref.toDate;
            fieldEl = (_ref1 = this.getSegment(segment)) != null ? _ref1.getField(field) : void 0;
            if (_.isNull(component)) {
                if (_.isUndefined(fieldEl)) {
                    val = null;
                } else {
                    val = fieldEl != null ? fieldEl.val() : void 0;
                }
            } else {
                componentEl = fieldEl != null ? fieldEl.getComponent(component) : void 0;
                if (_.isUndefined(componentEl)) {
                    val = null;
                } else {
                    val = componentEl.val();
                }
            }
            if (val && toDate) {
                match = val.match(/(\d{4})(\d{2})(\d{2})(\d{2})?(\d{2})?(\d{2})?/);
                if (match) {
                    datestring = match[0], year = match[1], month = match[2], day = match[3], hours = match[4], minutes = match[5], seconds = match[6];
                    if (hours == null) {
                        hours = 0;
                    }
                    if (minutes == null) {
                        minutes = 0;
                    }
                    if (seconds == null) {
                        seconds = 0;
                    }
                    return date = new Date(year, Number(month) - 1, day, hours, minutes, seconds, 0);
                } else {
                    return null;
                }
            } else {
                return val;
            }
        } catch (_error) {
            e = _error;
            throw new Error("Bad selector '" + query + "'");
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
        return new Ack(this, code, substitutions).toString();
    };

    Message.prototype.translate = function(map, override) {
        var result,
        _this = this;

        result = _.reduce(map, function(memo, val, key) {
            memo[key] = _this.query(val);
            return memo;
        }, {});
        return _.extend(result, override);
    };

    Message.prototype.toString = function() {
        return _.map(this.segments, function(segment) {
            return segment.toString();
        }).join('\n');
    };

    Message.prototype.replace = function() {
        var component, componentEl, e, field, fieldEl, query, replacements, segment, toDate, _ref, _ref1;

        query = arguments[0], replacements = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        try {
            _ref = queryparser.parse(query), component = _ref.component, field = _ref.field, segment = _ref.segment, toDate = _ref.toDate;
            fieldEl = (_ref1 = this.getSegment(segment)) != null ? _ref1.getField(field) : void 0;
            if (_.isNull(component)) {
                if (!_.isUndefined(fieldEl)) {
                    return fieldEl.val(replacements);
                }
            } else {
                componentEl = fieldEl != null ? fieldEl.getComponent(component) : void 0;
                if (!_.isUndefined(componentEl)) {
                    return componentEl.val(replacements);
                }
            }
        } catch (_error) {
            e = _error;
            throw new Error("Bad selector '" + query + "'");
        }
    };

    Message.prototype.remove = function() {
        var names;

        names = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.segments = _.reject(this.segments, function(segment) {
            return _.find(names, function(name) {
                return RegExp("^" + (name.replace('*', '.+')) + "$").test(segment.name);
            });
        });
    };

    return Message;

})();

module.exports = Message;
