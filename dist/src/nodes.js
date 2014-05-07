var Abstract, Expression, Literal, Variable, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ = require('lodash');

Abstract = (function() {
  function Abstract(token) {
    this.token = token;
  }

  Abstract.prototype.expand = function() {
    return this.token;
  };

  Abstract.prototype.extract = function() {
    return [];
  };

  Abstract.prototype.match = function(parser, input, params) {
    if (input.substr(0, this.token.length) === this.token) {
      input = input.substr(this.token.length);
    }
    return [input, params];
  };

  Abstract.prototype.toRegex = function(parser) {
    return parser.escapeRegex(this.token);
  };

  return Abstract;

})();

Expression = (function(_super) {
  __extends(Expression, _super);

  function Expression(token, operator, vars) {
    this.token = token;
    this.operator = operator;
    this.vars = vars;
  }

  Expression.prototype.expand = function(parser, params) {
    var data, op;
    op = this.operator;
    data = _(this.vars).reduce(function(data, variable) {
      var val;
      val = op.expand(parser, variable, params);
      if (val != null) {
        data.push(val);
      }
      return data;
    }, []);
    if (data.length) {
      return op.first + data.join(op.sep);
    }
  };

  Expression.prototype.toRegex = function(parser) {
    var op, regex;
    op = this.operator;
    regex = _(this.vars).reduce(function(data, variable) {
      if (data.push('(' + op.toRegex(parser, variable) + ')')) {
        return data;
      }
    }, []);

    /*
    Structure of regex (Note that we only capture vars, not the expression itself)
       
    (?:
      {operator}(var){sep}(var)
    )?
     */
    return '(?:' + parser.escapeRegex(op.id) + regex.join(parser.escapeRegex(op.sep)) + ')?';
  };

  Expression.prototype.match = function(parser, input, params) {
    var op;
    op = this.operator;
    if (op.id && input[0] !== op.id) {
      return [input, params];
    }
    if (op.id) {
      input = input.substr(1);
    }
    input = _(parser.sortVariables(this.vars)).reduce(function(uri, variable) {
      var m, regex, val;
      regex = new RegExp(op.toRegex(parser, variable));
      val = null;
      if (m = uri.match(regex)) {
        uri = uri.replace(regex, '');
        val = op.extract(parser, variable, m[0]);
      }
      params[variable.token] = val;
      return uri;
    }, input);
    return [input, params];
  };

  Expression.prototype.extract = function(parser, vars, params) {
    var data, i, op, val, variable, _i, _len, _ref;
    op = this.operator;
    _ref = this.vars;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      variable = _ref[i];
      val = vars[i];
      if (val != null) {
        data = op.extract(parser, variable, val);
      }
      params[variable.token] = data === '' ? null : data;
    }
    return params;
  };

  return Expression;

})(Abstract);

Literal = (function(_super) {
  __extends(Literal, _super);

  function Literal() {
    return Literal.__super__.constructor.apply(this, arguments);
  }

  return Literal;

})(Abstract);

Variable = (function(_super) {
  __extends(Variable, _super);

  Variable.prototype.name = null;

  Variable.prototype.options = {
    modifier: null,
    value: null
  };

  function Variable(token, name, options) {
    this.token = token;
    this.name = name;
    this.options = options;
  }

  return Variable;

})(Abstract);

module.exports = {
  Expression: Expression,
  Literal: Literal,
  Variable: Variable
};
