_ = require 'lodash'

types = 
  '':
    'sep'   : ','
    'named' : false
    'empty' : ''
    'reserved': false
    'start': 0
    'first': ''

  '+':
    'sep'  : ','
    'named': false
    'empty': ''
    'reserved': true
    'start': 1
    'first': ''

  '.':
    'sep'  : '.'
    'named': false
    'empty': ''
    'reserved': false
    'start': 1
    'first': '.'

  '/':
    'sep'  : '/'
    'named': false
    'empty': ''
    'reserved': false
    'start': 1
    'first': '/'

  ';':
    'sep'  : ';'
    'named': true
    'empty': ''
    'reserved': false
    'start': 1
    'first': ';'

  '?':
    'sep'  : '&'
    'named': true
    'empty': '='
    'reserved': false
    'start': 1
    'first': '?'

  '&':
    'sep'  : '&'
    'named': true
    'empty': '='
    'reserved': false
    'start': 1
    'first': '&'

  '#':
    'sep'  : ','
    'named': false
    'empty': ''
    'reserved': true
    'start': 1
    'first': '#'

###
 * .------------------------------------------------------------------.
 * |          NUL     +      .       /       ;      ?      &      #   |
 * |------------------------------------------------------------------|
 * | first |  ""     ""     "."     "/"     ";"    "?"    "&"    "#"  |
 * | sep   |  ","    ","    "."     "/"     ";"    "&"    "&"    ","  |
 * | named | false  false  false   false   true   true   true   false |
 * | ifemp |  ""     ""     ""      ""      ""     "="    "="    ""   |
 * | allow |   U     U+R     U       U       U      U      U     U+R  |
 * `------------------------------------------------------------------'
 *
 * U:         : - . _ ~
 * encodeURIC : - . _ ~ ! * ' ( )
 * R:         : / ? # @ ! $ & ' ( ) * + , ; = [ ] 
 * encodeURI: : / ? # @ ! $ & ' ( ) * + , ; = - _ . ~    
 *
 * named = false
 * | 1   |    {/list}    /red,green,blue                  | {$value}*(?:,{$value}+)*
 * | 2   |    {/list*}   /red/green/blue                  | {$value}+(?:{$sep}{$value}+)*
 * | 3   |    {/keys}    /semi,%3B,dot,.,comma,%2C        | /(\w+,?)+
 * | 4   |    {/keys*}   /semi=%3B/dot=./comma=%2C        | /(?:\w+=\w+/?)*
 * named = true
 * | 1   |    {?list}    ?list=red,green,blue             | {name}=(?:\w+(?:,\w+?)*)*
 * | 2   |    {?list*}   ?list=red&list=green&list=blue   | {name}+=(?:{$value}+(?:{sep}{name}+={$value}*))*
 * | 3   |    {?keys}    ?keys=semi,%3B,dot,.,comma,%2C   | (same as 1)
 * | 4   |    {?keys*}   ?semi=%3B&dot=.&comma=%2C        | (same as 2)
###

class Abstract
  constructor: (@id, @named, @sep, @empty, @reserved, @start, @first)->
  expand: (parser, variable, params)->
    name      = variable.name
    isExplode = variable.options['modifier'] is '*'

    # skip null
    val = params[name]
    return unless val?

    # This algorithm is based on RFC6570 http://tools.ietf.org/html/rfc6570
    # non-array, e.g. string
    if !_.isArray(val) and !(val.constructor is Object)
      @expandString parser, variable, val
    else if not isExplode
      @expandNonExplode parser, variable, val
    else
      @expandExplode parser, variable, val

  expandString: (parser, variable, val)->
    val     = val.toString()
    options = variable.options

    if options['modifier'] is ':'
      val = val.substr 0, 1 * options['value']

    @encode parser, variable, val

  expandNonExplode: (parser, variable, val)->

    return if _.isEmpty val
    @encode parser, variable, val

  expandExplode: (parser, variable, val)->

    return if _.isEmpty val
    @encode parser, variable, val

  encode: (parser, variable, values)->

    isObject = values.constructor is Object
    assocSep = '='
    encode   = if @reserved then @encodeReserved else @encodeUnReserved
    sep      = @sep

    # convert non-array to array
    if !isObject and not _.isArray values
      values = [values]

    # non-explode modifier always use ',' as a separator
    if variable.options['modifier'] isnt '*'
      assocSep = sep = ','

    _(values)
      .map (val, key)->

        encoded = encode val

        if isObject
          encoded = encode(key) + assocSep + encoded

        encoded

      .join sep

  encodeUnReserved: (data)->
    # Unreserved : - . _ ~
    # encodeURIC : - . _ ~ ! * ' ( )
    encodeURIComponent data
      .replace /[!*'()]/g, escape

  encodeReserved: (data)->
    # Reserved   : / ? # @ ! $ & ' ( ) * + , ; = [ ] | Unreserved
    # encodeURI: : / ? # @ ! $ & ' ( ) * + , ; = - _ . ~
    encodeURI data
      .replace /%(5B|5D)/g, unescape


class Named extends Abstract
  expandString: (parser, variable, val)->
    val    = val.toString()
    result = variable.name

    # handle empty value
    return result + @empty unless val.length

    result += '='

    if variable.options['modifier'] is ':'
      val = val.substr 0, variable.options.value

    result + @encode parser, variable, val

  expandNonExplode: (parser, variable, val)->

    return if _.isEmpty val

    result = @encode parser, variable, variable.name
    result + '=' + @encode parser, variable, val

  expandExplode: (parser, variable, val)->

    return if _.isEmpty val

    list   = _.isArray val

    _(val).reduce (data, v, k)=>
      name = @encode parser, variable, if list then variable.name else k
      v    = @encode parser, variable, v
      data if data.push "#{name}=#{v}"
    , []
    .join @sep

class UnNamed extends Abstract

module.exports =
  types: types
  validOperators: Object.keys types
  createById: (id)->

    # normalize null id to ''
    if id is null
      id = ''

    if id not in @validOperators
      throw new Error "Invalid operator #{id}"
    
    op  = types[id]
    cls = if op['named'] then Named else UnNamed

    new cls(id, op['named'], op['sep'], op['empty'], op['reserved'], op['start'], op['first'])