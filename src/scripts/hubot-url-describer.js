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
const cheerio = require('cheerio');
const unescapeHTML = require('unescape-html');

let ignore_extensions = ['.png','.jpg','.jpeg','.gif','.txt','.zip','.tar.bz','.js','.css'];
if (process.env.HUBOT_HTTP_INFO_IGNORE_EXTS) {
  ignore_extensions = process.env.HUBOT_HTTP_INFO_IGNORE_EXTS.split(',');
}
const regex = /(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?/i;
module.exports = function(robot) {
  robot.hear(regex, function(msg) {
    const url = msg.match[0];
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
      const $ = cheerio.load(body);
      let title = $('title').text() || $('[name="twitter:title"]').attr('content') || $('[name="og:title"]').attr('content') || '';
      title = title.split('\n').map(t => t.trim()).filter(Boolean)[0];
      if (title && title.length > 0) {
        return msg.send(unescapeHTML(
          title.replace(/&mdash;|\u2014/g, '--')
        ));
      } else {
        return msg.send('No title found');
      }
    });
  });
};

