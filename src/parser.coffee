_     = require 'lodash'
nodes = require './nodes'  
ops   = require './operators'

createNode = (part)->

  # literal string
  if part[0] isnt '{'
    new nodes.Literal part

  # expression (remove '{' and '}')
  else
    parseExpression part.substr(1, part.length - 2)

parseExpression = (expression)->
  token  = expression
  prefix = expression[0]
  
  if prefix not of ops.TYPES
    prefix = null

  # remove operator prefix if exists
  token = token.substr 1 if prefix

  # parse variables
  vars = _(token.split ',')
    .map(parseVariable)
    .value()

  new nodes.Expression token, ops.createById(prefix), vars
    
parseVariable = (v)->
  
  name     = v
  val      = null
  modifier = null

  # check ':' prefix modifier
  if (v.indexOf ':') > -1
    modifier = ':'
    [name, val] = v.split ':'

    if isNaN parseInt val
      throw new Error "Prefix modifier's value must be a numeric value #{v}"

  # check '*' explode modifier
  if (v.substr -1) is '*'

    if modifier?
      throw new Error "Multiple modifiers per variable are not allowed #{v}"

    modifier = '*'
    name     = v = v.substr 0, v.length-1 # remove '*'

  new nodes.Variable v, name,
    modifier: modifier
    value: val
  
# Public APIs
module.exports =
  REGEX:
    value: '(?:[\\w\\.\\-]|%[\\da-fA-F]{2})'

  parse: (template)->

    # split template by '{}' expression 
    _(template.split /(\{[^\}]+\})/)

      # remove empty string
      .filter (part)->
        part.length

      .reduce (acc, el)->
        acc if acc.push createNode el
      , []

  escapeRegex: (str)->

    # A modified version from https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
    str.replace /[.*+?^=!:${}()|\[\]\/\\]/g, '\\$&'

  # Only convert given value to numeric data if it's not a isNaN
  toNumber: (v)->
    if v instanceof Array 
      _.map v, (v)-> if isNaN v then v else Number v
    else
      if isNaN v then v else Number v