_      = require 'lodash'
parser = require './parser'

module.exports =

  expand: (uri, params)->

    _(parser.parse uri)
      .reduce (data, node)->
        data if data.push node.expand parser, params

      , []

      .join ''

  extract: ->
    console.log 'test, I am impress'

  UriTemplate: ->
    console.log 'hello world'
