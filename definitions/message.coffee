pegjs = require('pegjs')
definition = """
message
  = segments
segments
  = head:msh tail:(newline segment:segment { return segment; })* {
    tail.unshift(head);
    return tail;
  }
msh
  = "MSH|^~\\\\" "&" tail:(field_separator field:field { return field; })* {
    tail.unshift([['MSH']], [['^~\\\\&']]);
    return tail;
  }
segment
  = head:field tail:(field_separator field:field { return field; })* {
    tail.unshift(head);
    return tail;
  }
field
  = head:component tail:(component_separator component:component { return component;} )* {
    tail.unshift(head);
    return tail;
  }
component
  = head:subcomponent tail:(subcomponent_separator subcomponent:subcomponent { return subcomponent; })* {
    tail.unshift(head);
    return tail;
  }
subcomponent
  = content:(!(subcomponent_separator / component_separator / field_separator / newline) char:char { return char;} )* {
    return content.join('');
  }
char =
  .
field_separator
  = "|"
component_separator
  = "^"
newline
  = [\\r\\n]
subcomponent_separator
  = "&"
"""
module.exports = pegjs.buildParser(definition)
