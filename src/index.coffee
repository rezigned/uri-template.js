_      = require 'lodash'
parser = require './parser'

module.exports =

  expand: (uri, params)->

    _(parser.parse uri)
      .reduce (data, node)->
        data if data.push node.expand parser, params

      , []

      .join ''

  extract: (template, uri)->

    _(parser.parse template)
      .reduce (data, node)->
        match = node.match parser, uri, data
        uri   = match[0]
        console.log uri, match, data
        data

      , {}

  UriTemplate: ->
    console.log 'hello world'
