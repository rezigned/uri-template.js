# uri-template.js

Node.js/Javascript [RFC 6570 URI Template](http://tools.ietf.org/html/rfc6570) implementation that supports both URI expansion and extraction.

## Usage

### Expansion

A very simple usage

```
UriTemplate.expand('/{username}/profile', {'username': 'john'});

>> '/john/profile'
```

More examples (supports all expansion levels defined in RFC6570)
```
UriTemplate.expand('/search/{term:1}/{term}/{?q*,limit}', {
    term: 'john',
    q: ['a', 'b'],
    limit: 10,
});

>> '/search/j/john/?q=a,b&limit=10'
```

### Extraction

Extract variables from URI.

```
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

```
bower install uri-template.js

<script src="dist/uri-template.js"></script>
UriTemplate.expand(...)
```

In Node.js

```
npm install uri-template.js

UriTemplate = require('uri-template.js');
```
