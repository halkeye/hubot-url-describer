# hubot-url-describer

[![Build Status](https://travis-ci.org/halkeye/hubot-url-describer.png)](https://travis-ci.org/halkeye/hubot-url-describer)

Simple hubot script that grabs a url and outputs the title

## Getting Started
1. Install the module: `npm install --save hubot-url-describer`
2. Add it `hubot-url-describer` to your external-scripts.json file in your hubot directory

## Configuration
_(Nothing yet)_

## Release History

0.1.2 - ???

 * Update node module version
 
0.1.1 - 2013-12-07 

 * Switched html parser to use a SAX design as it should be faster and code is a lot cleaner
 * Handled case with page with no title - #4
 * Handled case when page doesn't start with a html tag - #4
 * Added case to handle twitter:title if title doesn't exist (shouldn't happen, but why not)

## License
Copyright (c) 2013 Gavin Mogan
Licensed under the MIT license.
