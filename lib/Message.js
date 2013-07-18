var Ack = require('./Ack'),
    HeadSegment = require('./HeadSegment'),
    Message,
    Segment = require('./Segment'),
    queryparser = require('../definitions/query'),
    _ = require('underscore'),
    __slice = [].slice,
    moment = require('moment');

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
        var componentEl = null,
            date,
            fieldEl = null,
            segmentEl = null,
            val,
            parsed;

        try {
            if (query.indexOf('1000') > 0) debugger;
            parsed = queryparser.parse(query);

            segmentEl = this.getSegment(parsed.segment);
            if (segmentEl) {
                fieldEl = segmentEl.getField(parsed.field);
            }
            if (parsed.component === null) {
                val = fieldEl ? fieldEl.val() : null;
            } else {
                if (fieldEl) {
                    componentEl = fieldEl.getComponent(parsed.component);
                }

                val = componentEl ? componentEl.val() : null;
            }

            if (val && parsed.toDate) {
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
            } else {
                return val;
            }
        } catch (e) {
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
        return new Ack({
            message: this,
            code: code,
            subs: substitutions
        }).toString();
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
        }).join('\r');
    };

    Message.prototype.replace = function() {
        var component, componentEl, e, field, fieldEl, query, replacements, segment, toDate, _ref, _ref1;

        query = arguments[0], replacements = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        try {
            _ref = queryparser.parse(query), component = _ref.component, field = _ref.field, segment = _ref.segment, toDate = _ref.toDate;
            fieldEl = (_ref1 = this.getSegment(segment)) != null ? _ref1.getField(field) : void 0;
            if (_.isNull(component)) {
                if (fieldEl !== undefined) {
                    return fieldEl.val(replacements);
                }
            } else {
                componentEl = fieldEl != null ? fieldEl.getComponent(component) : void 0;
                if (componentEl !== undefined) {
                    return componentEl.val(replacements);
                }
            }
        } catch (e) {
            throw new Error("Bad selector '" + query + "'");
        }
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
