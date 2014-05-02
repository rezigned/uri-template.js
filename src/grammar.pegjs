template   = (literal / expression)*
literal    = literal:[^{]+ { return literal.join(''); }
expression = "{" op:operator? vars:variable_list "}" {
  return {
    operator: op,
    variables: vars
  }
}
operator   = [+#./;?&]
variable_list =  var1:varspec rest:( "," varspec )* {
  var vars = [var1];

  for (var i = 0, l=rest.length; i<l; i++) {
    vars.push(rest[i][1]);
  }

  return vars
}
varspec       =  name:varname modifier:modifier_level4? { 
    return {
        name: name, 
        modifier: modifier
    };
}

varname       =  name:varchar rest:( "."? varchar)* {

    var temp = [];
    for (var i = 0, item; item=rest[i++];) {
        temp.push(item[1]);
    }
    
    return name + temp.join('');
}
varchar       =  ALPHA / DIGIT / "_" / pct_encoded

modifier_level4 = ":" digits:[0-9]+ { 
    return {
        type: ':',
        value: parseInt(digits.join(''))
    }; 
} / "*" {
    return {
        type: '*',
        value: null
    }
}
pct_encoded = "%" HEXDIGIT HEXDIGIT
ALPHA = [a-zA-Z]
DIGIT = [0-9]
HEXDIGIT = DIGIT / [a-fA-F]