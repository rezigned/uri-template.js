# uri-template.js

Node.js/Javascript [RFC 6570 URI Template](http://tools.ietf.org/html/rfc6570) implementation that supports both URI expansion and extraction.

[![Build Status](https://travis-ci.org/rezigned/uri-template.js.svg?branch=master)](https://travis-ci.org/rezigned/uri-template.js)

* [PHP](https://github.com/rize/UriTemplate) URI Template

## Usage
### Expansion

A very simple usage

```js
UriTemplate.expand('/{username}/profile', {'username': 'john'});

>> '/john/profile'
```

More examples (supports all expansion levels defined in RFC6570)
```js
UriTemplate.expand('/search/{term:1}/{term}/{?q*,limit}', {
    term: 'john',
    q: ['a', 'b'],
    limit: 10,
});

>> '/search/j/john/?q=a,b&limit=10'
```

### Extraction

Extract variables from URI.

```js
UriTemplate.extract('/search/{term:1}/{term}/{?q*,limit}', '/search/j/john/?q=a&q=b&limit=10');

>>
(
    'term:1': 'j',
    term: 'john',
    q: [
      'a',
      'b'
    ]
    limit: 10
)
```
### UriTemplate class

You can also instantiate `UriTemplate` instance via `new` keyword. Its constructor accepts 2 optional params `base uri` and `default params`. Which is very useful when working with API endpoint.

```js
var uri = new UriTemplate('https://api.twitter.com/{version}', {'version': 1.1});
uri.expand('/statuses/show/{id}.json', {'id': '210462857140252672'});

>> https://api.twitter.com/1.1/statuses/show/210462857140252672.json
```

## Installation

In browsers:

```bash
bower install uri-template.js
```

```html
<script src="dist/uri-template.js"></script>
UriTemplate.expand(...)
```

In Node.js

```bash
npm install uri-template.js

UriTemplate = require('uri-template.js');
```
