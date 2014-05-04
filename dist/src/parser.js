var createNode, nodes, ops, parseExpression, parseVariable, _;

_ = require('lodash');

nodes = require('./nodes');

ops = require('./operators');

createNode = function(part) {
  if (part[0] !== '{') {
    return new nodes.Literal(part);
  } else {
    return parseExpression(part.substr(1, part.length - 2));
  }
};

parseExpression = function(expression) {
  var prefix, token, vars;
  token = expression;
  prefix = expression[0];
  if (!(prefix in ops.TYPES)) {
    prefix = null;
  }
  if (prefix) {
    token = token.substr(1);
  }
  vars = _(token.split(',')).map(parseVariable).value();
  return new nodes.Expression(token, ops.createById(prefix), vars);
};

parseVariable = function(v) {
  var modifier, name, val, _ref;
  name = v;
  val = null;
  modifier = null;
  if ((v.indexOf(':')) > -1) {
    modifier = ':';
    _ref = v.split(':'), name = _ref[0], val = _ref[1];
    if (isNaN(parseInt(val))) {
      throw new Error("Prefix modifier's value must be a numeric value " + v);
    }
  }
  if ((v.substr(-1)) === '*') {
    if (modifier != null) {
      throw new Error("Multiple modifiers per variable are not allowed " + v);
    }
    modifier = '*';
    name = v = v.substr(0, v.length - 1);
  }
  return new nodes.Variable(v, name, {
    modifier: modifier,
    value: val
  });
};

module.exports = {
  REGEX: {
    value: '(?:[\\w\\.\\-]|%[\\da-fA-F]{2})'
  },
  parse: function(template) {
    return _(template.split(/(\{[^\}]+\})/)).filter(function(part) {
      return part.length;
    }).reduce(function(acc, el) {
      if (acc.push(createNode(el))) {
        return acc;
      }
    }, []);
  },
  escapeRegex: function(str) {
    return str.replace(/[.*+?^=!:${}()|\[\]\/\\]/g, '\\$&');
  },
  toNumber: function(v) {
    if (v instanceof Array) {
      return _.map(v, function(v) {
        if (isNaN(v)) {
          return v;
        } else {
          return Number(v);
        }
      });
    } else {
      if (isNaN(v)) {
        return v;
      } else {
        return Number(v);
      }
    }
  }
};
