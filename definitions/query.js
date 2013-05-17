var fs = require('fs'),
    definition,
    pegjs = require('pegjs');

definition = fs.readFileSync('./definitions/query.pegjs', 'utf8');

module.exports = pegjs.buildParser(definition);
