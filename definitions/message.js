var build,
    cache,
    definition,
    fs = require('fs'),
    _ = require('underscore'),
    pegjs = require('pegjs');

definition = fs.readFileSync('./definitions/message.pegjs', 'utf8');

build = function(options) {
    return pegjs.buildParser(_.template(definition, options));
};

cache = {};

module.exports = {
    parse: function(s) {
        var components, control_characters, escape, fields, message, repeat, subcomponents, _ref;

        control_characters = s.substring(3, 8);
        _ref = control_characters.split(''), fields = _ref[0], components = _ref[1], repeat = _ref[2], escape = _ref[3], subcomponents = _ref[4];
        if (!cache[control_characters]) {
            cache[control_characters] = build({
                fields: fields,
                components: components,
                repeat: repeat,
                escape: escape,
                subcomponents: subcomponents
            });
        }
        message = cache[control_characters].parse(s);
        return {
            control_characters: {
                fields: fields,
                components: components,
                repeat: repeat,
                escape: escape,
                subcomponents: subcomponents
            },
            message: message
        };
    }
};
