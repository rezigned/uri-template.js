_ = require 'lodash'

class Abstract
  constructor: (@token)->
  expand: ->
    @token

  extract: ->
    []

  match: (parser, input, params)->

    # match literal string from start to end
    if input.substr(0, @token.length) is @token
      input = input.substr @token.length

    [input, params]

  toRegex: (parser)->
    parser.escapeRegex @token

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

  toRegex: (parser)->
    op    = @operator
    regex = _(@vars).reduce (data, variable)->
      data if data.push '(' + op.toRegex(parser, variable) + ')'
    , []

    ###
    Structure of regex (Note that we only capture vars, not the expression itself)
   
    (?:
      {operator}(var){sep}(var)
    )?
    ###
    '(?:' + parser.escapeRegex(op.id) + regex.join(parser.escapeRegex op.sep) + ')?'

  match: (parser, input, params)->

    op   = @operator

    # check expression operator first
    if op.id and input[0] isnt op.id
      return [input, params]

    # remove operator from input
    input = input.substr 1 if op.id
    input = _(@vars).reduce (uri, variable)->

      regex = new RegExp(op.toRegex parser, variable)
      val   = null

      if m = uri.match regex
        
        # remove matched part from input
        uri = uri.replace regex, ''
        val = op.extract parser, variable, m[0]

      params[variable.token] = val
      uri
      
    , input

    [input, params]

  extract: (parser, vars, params)->

    op = @operator

    for variable, i in @vars
      val  = vars[i]

      if val?
        data = op.extract parser, variable, val

      params[variable.token] = if data is '' then null else data

    params

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