query =
  segment:segment toDate:field_selector field:field {
    return {
      toDate: field.toDate || toDate,
      segment: segment,
      field: field.field,
      component: field.component
    };
  }

field =
  field:ref toDate:component_selector component:ref {
    return {
      toDate: toDate,
      field:field,
      component: component
    };
  }
  /
  field:ref {
    return {
      field: field,
      component: null
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
