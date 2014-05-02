assert = require 'assert'
URI    = require '../src/index'

run = (cases)->

  for k, v of cases

    for test in v.testcases
      actual = URI.expand test[0], v.variables

      if test[1] instanceof Array
        assert.ok actual in test[1], test[0] + '=' + actual
      else
        assert.equal actual, test[1], test[0]

describe 'URITemplate', ->
  it 'should expand variables in uri', ->

    data = [
      uri: 'http://example.com/~{username}'
      params: 
        username: 'john'
      expected: 'http://example.com/~john'
     ,
      uri: 'http://example.com/dictionary/{term:1}/{term}'
      params:
        term: 'dog'
      expected: 'http://example.com/dictionary/d/dog'
    ]

    for item in data

      actual   = URI.expand item.uri, item.params
      assert.equal item.expected, actual

  it 'should expand all uris from spec-examples.json', ->

    run require './fixtures/spec-examples.json'

  it 'should expand all uris from spec-examples-by-section.json', ->

    run require './fixtures/spec-examples-by-section.json'

  it 'should expand all uris from extended-tests.json', ->

    run require './fixtures/extended-tests.json'