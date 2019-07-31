/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Description:
//   The best project ever.
//
// Dependencies:
//   None
//
// Configuration:
//   None
//
// Commands:
//   None
//
// Notes:
//   Copyright (c) 2013 Gavin Mogan
//   Licensed under the MIT license.
//
// Author:
//   halkeye

'use strict';
const request = require('request');
const Url = require('url');
const Querystring = require('querystring');
const Path = require('path');
const HtmlParser = require('htmlparser2');
const unescapeHTML = require('unescape-html');

let ignore_extensions = ['.png','.jpg','.jpeg','.gif','.txt','.zip','.tar.bz','.js','.css'];
if (process.env.HUBOT_HTTP_INFO_IGNORE_EXTS) {
  ignore_extensions = process.env.HUBOT_HTTP_INFO_IGNORE_EXTS.split(',');
}
const regex = /(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?/i;
module.exports = function(robot) {
  robot.hear(regex, function(msg) {
    const url = msg.match[0];

    let title = "";
    const tagstack = [];

    const parser  = new HtmlParser.Parser({
      onopentag(name, attribs) {
        tagstack.push(name);
        if ( (title !== "") && (name === 'twitter:title') ) {
          return title = attribs['content'].trim().split("\n")[0];
        }
      },
      ontext(text) {
        const tagname = tagstack[tagstack.length - 1];
        if (tagname === "title") {
          return title = text.trim().split("\n")[0];
        }
      },
        //else if ( title != "" and tagname == 'twitter:title' )
      onclosetag(tagname) {
        return tagstack.pop();
      },
      onend() {
        if (title.length > 0) {
          return msg.send(unescapeHTML(title.replace('&mdash;', '--')));
        } else {
          return msg.send('No title found');
        }
      }
    });

    const urldata = Url.parse(url);
    const path = urldata.path.split('?')[0];
    const ext = Path.extname(path);
    if (ext && (ignore_extensions.indexOf(ext) !== -1)) {
      return;
    }

    request.get(url, {}, function(err,res,body) {
      if (err) {
        msg.send(`Error getting ${url}: ${err}`);
        return;
      }
      if (res.headers['content-type'].indexOf('text/html') !== 0) {
        return;
      }
      parser.write(body);
      return parser.end();
    });
    return this;
  });
  return this;
};

