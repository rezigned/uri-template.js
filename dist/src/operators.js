var Abstract, Named, TYPES, UnNamed, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ = require('lodash');

TYPES = {
  "null": {
    'sep': ',',
    'named': false,
    'empty': '',
    'reserved': false,
    'start': 0,
    'first': ''
  },
  '+': {
    'sep': ',',
    'named': false,
    'empty': '',
    'reserved': true,
    'start': 1,
    'first': ''
  },
  '.': {
    'sep': '.',
    'named': false,
    'empty': '',
    'reserved': false,
    'start': 1,
    'first': '.'
  },
  '/': {
    'sep': '/',
    'named': false,
    'empty': '',
    'reserved': false,
    'start': 1,
    'first': '/'
  },
  ';': {
    'sep': ';',
    'named': true,
    'empty': '',
    'reserved': false,
    'start': 1,
    'first': ';'
  },
  '?': {
    'sep': '&',
    'named': true,
    'empty': '=',
    'reserved': false,
    'start': 1,
    'first': '?'
  },
  '&': {
    'sep': '&',
    'named': true,
    'empty': '=',
    'reserved': false,
    'start': 1,
    'first': '&'
  },
  '#': {
    'sep': ',',
    'named': false,
    'empty': '',
    'reserved': true,
    'start': 1,
    'first': '#'
  }
};


/*
 * .------------------------------------------------------------------.
 * |          NUL     +      .       /       ;      ?      &      #   |
 * |------------------------------------------------------------------|
 * | first |  ""     ""     "."     "/"     ";"    "?"    "&"    "#"  |
 * | sep   |  ","    ","    "."     "/"     ";"    "&"    "&"    ","  |
 * | named | false  false  false   false   true   true   true   false |
 * | ifemp |  ""     ""     ""      ""      ""     "="    "="    ""   |
 * | allow |   U     U+R     U       U       U      U      U     U+R  |
 * `------------------------------------------------------------------'
 *
 * U:         : - . _ ~
 * encodeURIC : - . _ ~ ! * ' ( )
 * R:         : / ? # @ ! $ & ' ( ) * + , ; = [ ] 
 * encodeURI: : / ? # @ ! $ & ' ( ) * + , ; = - _ . ~    
 *
 * named = false
 * | 1   |    {/list}    /red,green,blue                  | {$value}*(?:,{$value}+)*
 * | 2   |    {/list*}   /red/green/blue                  | {$value}+(?:{$sep}{$value}+)*
 * | 3   |    {/keys}    /semi,%3B,dot,.,comma,%2C        | /(\w+,?)+
 * | 4   |    {/keys*}   /semi=%3B/dot=./comma=%2C        | /(?:\w+=\w+/?)*
 * named = true
 * | 1   |    {?list}    ?list=red,green,blue             | {name}=(?:\w+(?:,\w+?)*)*
 * | 2   |    {?list*}   ?list=red&list=green&list=blue   | {name}+=(?:{$value}+(?:{sep}{name}+={$value}*))*
 * | 3   |    {?keys}    ?keys=semi,%3B,dot,.,comma,%2C   | (same as 1)
 * | 4   |    {?keys*}   ?semi=%3B&dot=.&comma=%2C        | (same as 2)
 */

Abstract = (function() {
  function Abstract(id, named, sep, empty, reserved, start, first) {
    this.id = id;
    this.named = named;
    this.sep = sep;
    this.empty = empty;
    this.reserved = reserved;
    this.start = start;
    this.first = first;
  }

  Abstract.prototype.expand = function(parser, variable, params) {
    var isExplode, name, val;
    name = variable.name;
    isExplode = variable.options['modifier'] === '*';
    val = params[name];
    if (val == null) {
      return;
    }
    if (!_.isArray(val) && !(val.constructor === Object)) {
      return this.expandString(parser, variable, val);
    } else if (!isExplode) {
      return this.expandNonExplode(parser, variable, val);
    } else {
      return this.expandExplode(parser, variable, val);
    }
  };

  Abstract.prototype.expandString = function(parser, variable, val) {
    var options;
    val = val.toString();
    options = variable.options;
    if (options['modifier'] === ':') {
      val = val.substr(0, 1 * options['value']);
    }
    return this.encode(parser, variable, val);
  };

  Abstract.prototype.expandNonExplode = function(parser, variable, val) {
    if (_.isEmpty(val)) {
      return;
    }
    return this.encode(parser, variable, val);
  };

  Abstract.prototype.expandExplode = function(parser, variable, val) {
    if (_.isEmpty(val)) {
      return;
    }
    return this.encode(parser, variable, val);
  };

  Abstract.prototype.extract = function(parser, variable, data) {
    var vals;
    vals = data.split(this.sep);
    switch (variable.options['modifier']) {
      case '*':
        return _(vals).reduce(function(data, val) {
          var k, v, _ref;
          if (val.indexOf('=') > -1) {
            if (data == null) {
              data = {};
            }
            _ref = val.split('='), k = _ref[0], v = _ref[1];
            data[k] = parser.toNumber(v);
          } else {
            if (data == null) {
              data = [];
            }
            data.push(parser.toNumber(val));
          }
          return data;
        }, null);
      case ':':
        return parser.toNumber(data);
      default:
        return parser.toNumber(data.indexOf(this.sep) > -1 ? vals : data);
    }
  };

  Abstract.prototype.toRegex = function(parser, variable) {
    var options, regex, value;
    regex = null;
    value = parser.REGEX.value;
    options = variable.options;
    if (options['modifier']) {
      switch (options['modifier']) {
        case '*':
          regex = "" + value + "+(?:" + this.sep + value + "+)*";
          break;
        case ':':
          regex = ("" + value + "{0,") + options['value'] + '}';
      }
    } else {
      regex = "" + value + "*(?:," + value + "+)*";
    }
    return regex;
  };

  Abstract.prototype.encode = function(parser, variable, values) {
    var assocSep, encode, isObject, sep;
    isObject = values.constructor === Object;
    assocSep = '=';
    encode = this.reserved ? this.encodeReserved : this.encodeUnReserved;
    sep = this.sep;
    if (!isObject && !_.isArray(values)) {
      values = [values];
    }
    if (variable.options['modifier'] !== '*') {
      assocSep = sep = ',';
    }
    return _(values).map(function(val, key) {
      var encoded;
      encoded = encode(val);
      if (isObject) {
        encoded = encode(key) + assocSep + encoded;
      }
      return encoded;
    }).join(sep);
  };

  Abstract.prototype.encodeUnReserved = function(data) {
    return encodeURIComponent(data).replace(/[!*'()]/g, escape);
  };

  Abstract.prototype.encodeReserved = function(data) {
    return encodeURI(data).replace(/%(5B|5D)/g, unescape);
  };

  return Abstract;

})();

UnNamed = (function(_super) {
  __extends(UnNamed, _super);

  function UnNamed() {
    return UnNamed.__super__.constructor.apply(this, arguments);
  }

  return UnNamed;

})(Abstract);

Named = (function(_super) {
  __extends(Named, _super);

  function Named() {
    return Named.__super__.constructor.apply(this, arguments);
  }

  Named.prototype.expandString = function(parser, variable, val) {
    var result;
    val = val.toString();
    result = variable.name;
    if (!val.length) {
      return result + this.empty;
    }
    result += '=';
    if (variable.options['modifier'] === ':') {
      val = val.substr(0, variable.options.value);
    }
    return result + this.encode(parser, variable, val);
  };

  Named.prototype.expandNonExplode = function(parser, variable, val) {
    var result;
    if (_.isEmpty(val)) {
      return;
    }
    result = this.encode(parser, variable, variable.name);
    return result + '=' + this.encode(parser, variable, val);
  };

  Named.prototype.expandExplode = function(parser, variable, val) {
    var list;
    if (_.isEmpty(val)) {
      return;
    }
    list = _.isArray(val);
    return _(val).reduce((function(_this) {
      return function(data, v, k) {
        var name;
        name = _this.encode(parser, variable, list ? variable.name : k);
        v = _this.encode(parser, variable, v);
        if (data.push("" + name + "=" + v)) {
          return data;
        }
      };
    })(this), []).join(this.sep);
  };

  Named.prototype.toRegex = function(parser, variable) {
    var name, options, regex, value;
    regex = null;
    name = variable.name;
    value = parser.REGEX.value;
    options = variable.options;
    if (options['modifier']) {
      switch (options['modifier']) {
        case '*':
          regex = "" + name + "+=(?:" + value + "+(?:" + this.sep + name + "+=" + value + "*)*)";
          regex += "|" + value + "+=(?:" + value + "+(?:" + this.sep + value + "+=" + value + "*)*)";
          break;
        case ':':
          regex = ("" + value + "{0,") + options['value'] + '}';
      }
    } else {
      regex = "" + name + "=(?:" + value + "+(?:," + value + "+)*)*";
    }
    return regex;
  };

  Named.prototype.extract = function(parser, variable, data) {
    var vals;
    vals = data.split(this.sep);
    switch (variable.options['modifier']) {
      case '*':
        return _(vals).reduce(function(data, val) {
          var k, v, _ref;
          _ref = val.split('='), k = _ref[0], v = _ref[1];
          v = parser.toNumber(v);
          if (k === variable.token) {
            if (data == null) {
              data = [];
            }
            data.push(v);
          } else {
            if (data == null) {
              data = {};
            }
            data[k] = v;
          }
          return data;
        }, null);
      case ':':
        return parser.toNumber(vals);
      default:
        data = data.replace(variable.token + '=', '').split(',');
        if (data.length === 1) {
          data = data.pop();
        }
        return parser.toNumber(data);
    }
  };

  return Named;

})(Abstract);

module.exports = {
  TYPES: TYPES,
  createById: function(id) {
    var cls, op;
    if (!(id in TYPES)) {
      throw new Error("Invalid operator " + id);
    }
    op = TYPES[id];
    cls = op['named'] ? Named : UnNamed;
    return new cls(id, op['named'], op['sep'], op['empty'], op['reserved'], op['start'], op['first']);
  }
};
