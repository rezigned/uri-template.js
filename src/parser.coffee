_     = require 'lodash'
nodes = require './nodes'  
ops   = require './operators'

createNode = (part)->

  # literal string
  if part[0] isnt '{'
    node = new nodes.Literal part

  # expression (remove '{' and '}')
  else
    node = parseExpression part.substr(1, part.length - 2)

  node

parseExpression = (expression)->
  token  = expression
  prefix = expression[0]
  
  if prefix not in ops.validOperators
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
    name     = v.substr 0, v.length-1 # remove '*'

  new nodes.Variable v, name,
    modifier: modifier
    value: val
  
# Public APIs
module.exports =
  parse: (template)->
    parts = template

              # split template by '{}' expression 
              .split(/(\{[^\}]+\})/)

              # remove empty string
              .filter (part)->
                part.length

    parts.reduce (acc, el)->
      acc.push createNode el
      acc
    , []
