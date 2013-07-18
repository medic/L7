query =
  segment:segment '|' field:ref '[' component:ref ']' {
    return {
        repeat: true,
        selectors: [segment, field, component]
    };
  }
  /
  segment:segment '[' field:ref ']' {
    return {
        repeat: true,
        selectors: [segment, field]
    };
  }
  /
  segment:segment toDate:field_selector field:field {
    return {
      toDate: field.toDate || toDate,
      selectors: [segment].concat(field.selectors)
    };
  }

field =
  field:ref toDate:component_selector component:ref {
    return {
      toDate: toDate,
      selectors: [field, component]
    };
  }
  /
  field:ref {
    return {
      selectors: [field]
    };
  }

component_selector
  =
    '^' { return false; }
    /
    '@' { return true; }

field_selector
  =
    '|' { return false; }
    /
    '@' { return true; }

segment =
  chars:[a-z0-9]i+ {
    return chars.join('');
  }

ref =
  digits:[0-9]+ {
    return Number(digits.join(''));
  }
