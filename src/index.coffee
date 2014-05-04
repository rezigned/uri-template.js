_      = require 'lodash'
parser = require './parser'

expand = (uri, params)->

  params ||= {}
  _(parser.parse uri)
    .reduce (data, node)->
      data if data.push node.expand parser, params

    , []

    .join ''

extract = (template, uri)->

  _(parser.parse template)
    .reduce (data, node)->
      [uri] = node.match parser, uri, data

      data

    , {}

class UriTemplate
  constructor: (@base, @params)->
  expand: (uri, params)->

    # user specifies params as 1st argument
    if arguments.length < 2
      params = uri || {}
      uri    = @base

    # user speicifies both uri, params
    # concat base uri with new uri and
    # merge default params
    else
      uri = @base + uri

    params = _.extend @params, params

    expand uri, params

  extract: extract

UriTemplate.expand  = expand
UriTemplate.extract = extract

module.exports = UriTemplate