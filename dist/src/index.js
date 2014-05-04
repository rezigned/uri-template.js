var UriTemplate, expand, extract, parser, _;

_ = require('lodash');

parser = require('./parser');

expand = function(uri, params) {
  params || (params = {});
  return _(parser.parse(uri)).reduce(function(data, node) {
    if (data.push(node.expand(parser, params))) {
      return data;
    }
  }, []).join('');
};

extract = function(template, uri) {
  return _(parser.parse(template)).reduce(function(data, node) {
    uri = node.match(parser, uri, data)[0];
    return data;
  }, {});
};

UriTemplate = (function() {
  function UriTemplate(base, params) {
    this.base = base;
    this.params = params;
  }

  UriTemplate.prototype.expand = function(uri, params) {
    if (arguments.length < 2) {
      params = uri || {};
      uri = this.base;
    } else {
      uri = this.base + uri;
    }
    params = _.extend(this.params, params);
    return expand(uri, params);
  };

  UriTemplate.prototype.extract = extract;

  return UriTemplate;

})();

UriTemplate.expand = expand;

UriTemplate.extract = extract;

module.exports = UriTemplate;
