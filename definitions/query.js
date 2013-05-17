var fs = require('fs'),
    path = require('path'),
    definition,
    pegjs = require('pegjs');

definition = fs.readFileSync(path.join(__dirname, 'query.pegjs'), 'utf8');

module.exports = pegjs.buildParser(definition);
