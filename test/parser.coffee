assert = require 'assert'
nodes  = require '../src/nodes'
parser = require '../src/parser'
ops    = require '../src/operators'

describe 'Parser', ->
  it 'should parse template and return AST', ->
    actual = parser.parse 'http://www.example.com/{term:1}/{term}/{test*}/foo{?query,number}'
    expect = [
        new nodes.Literal 'http://www.example.com/'
        new nodes.Expression 'term:1', ops.createById(null), [
            new nodes.Variable 'term:1', 'term',
              modifier: ':'
              value: 1
        ]
        new nodes.Literal '/'
        new nodes.Expression 'term', ops.createById(null), [
          new nodes.Variable 'term', 'term',
            modifier: null
            value: null
        ]
        new nodes.Literal '/'
        new nodes.Expression 'test*', ops.createById(null), [
          new nodes.Variable 'test', 'test',
            modifier: '*'
            value: null
        ]
        new nodes.Literal '/foo'
        new nodes.Expression 'query,number', ops.createById('?'), [
          new nodes.Variable 'query', 'query',
            modifier: null
            value: null
          new nodes.Variable 'number', 'number',
            modifier: null
            value: null
        ]
    ]

    for k, v of expect
      assert.deepEqual v, actual[k]

  it 'should sort variables by non-explode to explode order', ->

    ast = parser.parse '/search/{term:1}/{term}/{?q*,limit,extra*}'

    # we're only interested in the last expression i.e. {?q*,limit,extra*}
    actual = parser.sortVariables ast[ast.length - 1].vars
    expect = [
      new nodes.Variable 'limit', 'limit',
        modifier: null
        value: null
      new nodes.Variable 'q', 'q',
        modifier: '*'
        value: null
      new nodes.Variable 'extra', 'extra',
        modifier: '*'
        value: null
    ]

    assert.deepEqual expect, actual