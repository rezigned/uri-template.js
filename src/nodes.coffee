_ = require 'lodash'

class Abstract
  constructor: (@token)->
  expand: ->
    @token

  extract: ->
    []

  toRegex: ->
    @token

class Expression extends Abstract
  constructor: (@token, @operator, @vars)->

  expand: (parser, params)->
    op   = @operator
    data = _(@vars).reduce (data, variable)->
      val = op.expand parser, variable, params

      data.push val if val?
      data

    , []

    op.first + data.join(op.sep) if data.length

class Literal extends Abstract

class Variable extends Abstract
  name: null
  options:
    modifier: null
    value: null

  constructor: (@token, @name, @options)->

module.exports =
  Expression: Expression
  Literal: Literal
  Variable: Variable