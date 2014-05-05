# uri-template.js

[![Build Status](https://travis-ci.org/rezigned/uri-template.js.svg?branch=0.1.1)](https://travis-ci.org/rezigned/uri-template.js)

Node.js/Javascript [RFC 6570 URI Template](http://tools.ietf.org/html/rfc6570) implementation that supports both URI expansion and extraction.

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
