pegjs = require('pegjs')

build = (fields, components, repeat, escape, subcomponents) ->
  definition = """
  message
    = segments
  segments
    = head:msh tail:(newline segment:segment { return segment; })* {
      tail.unshift(head);
      return tail;
    }
  msh
    = "MSH" fs:field_separator cs:component_separator fr:field_repeat_delimiter ec:escape_character ss:subcomponent_separator tail:(field_separator field:field { return field; })* {
      tail.unshift([['MSH']], [[ cs + fr + ec + ss ]]);
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
  escape_character
    = "\\#{escape}"
  field_repeat_delimiter
    = "#{repeat}"
  field_separator
    = "#{fields}"
  component_separator
    = "#{components}"
  newline
    = [\\r\\n]+
  subcomponent_separator
    = "#{subcomponents}"
  """
  pegjs.buildParser(definition)

cache = {}

module.exports =
  parse: (s) ->
    control_characters = s.substring(3, 8)
    [ fields, components, repeat, escape, subcomponents ] = control_characters.split('')
    unless cache[control_characters]
      cache[control_characters] = build(fields, components, repeat, escape, subcomponents)
    message = cache[control_characters].parse(s)
    return {
      control_characters:
        fields: fields
        components: components
        repeat: repeat
        escape: escape
        subcomponents: subcomponents
      message: message
    }
