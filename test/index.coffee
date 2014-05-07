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

  it 'should extract variables from uri', ->

    tests = [

      uri: '/no/{term:1}/random/{term}/{test*}/foo{?number,query}'
      expanded: '/no/j/random/john/a,b,c/foo?query=1,2,3&number=10'
      params:
        'term:1': 'j'
        term: 'john'
        test: ['a', 'b', 'c']
        query: [1, 2, 3]
        number: 10
     ,

      uri: 'http://www.example.com/foo{?query,number}'
      expanded: 'http://www.example.com/foo?query=5'
      params:
        query: 5
        number: null
     ,

      uri: '{count}|{count*}|{/count}|{/count*}|{;count}|{;count*}|{?count}|{?count*}|{&count*}'
      expanded: 'one,two,three|one,two,three|/one,two,three|/one/two/three|;count=one,two,three|;count=one;count=two;count=three|?count=one,two,three|?count=one&count=two&count=three|&count=one&count=two&count=three'
      params:
        count: ['one', 'two', 'three']
     ,

      uri: '/search/{term:1}/{term}/{?q*,limit}'
      expanded: '/search/j/john/?a=1&b=2&limit=10'
      params:
        'term:1': 'j'
        term: 'john'
        q:
          a: 1
          b: 2
        limit: 10
     ,
      uri: 'http://example.com/{term:1}/{term}/search{?q*,lang,test*}'
      expanded: 'http://example.com/j/john/search?q=mycelium&q=3&lang=th,jp,en&a=1&b=2'
      params:
        q: ['mycelium', 3]
        lang: ['th', 'jp', 'en']
        term: 'john'
        'term:1': 'j'
        test:
          a: 1
          b: 2
    ]

    for k, v of tests
      actual = URI.extract v.uri, v.expanded
      assert.deepEqual actual, v.params, v.uri 