# Description:
#   The best project ever.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Notes:
#   Copyright (c) 2013 Gavin Mogan
#   Licensed under the MIT license.
#
# Author:
#   halkeye

'use strict'
request = require 'request'
Url = require 'url'
Querystring = require 'querystring'
Path = require 'path'
HtmlParser = require 'htmlparser2'
_ = require 'underscore'
_S = require 'underscore.string'

ignore_extensions = ['.png','.jpg','.jpeg','.gif','.txt','.zip','.tar.bz','.js','.css']
if process.env.HUBOT_HTTP_INFO_IGNORE_EXTS
  ignore_extensions = process.env.HUBOT_HTTP_INFO_IGNORE_EXTS.split(',')
regex = /(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?/i
module.exports = (robot) ->
  robot.hear regex, (msg) ->
    url = msg.match[0]

    title = ""

    handler = new HtmlParser.DomHandler (err,dom) ->
      # html tag
      dom = _.findWhere dom, { type: 'tag' }
      # Head Tag
      dom = _.findWhere dom.children, { name: 'head' }

      dom.children.forEach (elm) ->
        if ( title == "" )
          if ( elm.name == 'title' )
            titles = []
            elm.children.forEach (child) ->
              if (child.type == 'text')
                titles.push( _S.trim(child.data).split("\n")[0] )
            title = title + _S.trim(titles.join(''))
          #if ( elm.name == 'twitter:title' )
          #  console.log(elm)
          #  title = _S.trim(elm.value)

      if (title.length > 0)
        msg.send _S.unescapeHTML(title.replace('&mdash;', '--'))
      else
        # err

    urldata = Url.parse(url)
    path = urldata.path.split('?')[0]
    ext = Path.extname(path)
    if (ext && ignore_extensions.indexOf(ext) != -1)
      return

    request.get url, {}, (err,res,body) ->
      if err
        msg.send "Error getting " + url + ": " + err
        return
      if res.headers['content-type'].indexOf('text/html') != 0
        return
      new HtmlParser.Parser(handler).parseComplete(body)
    @
  @

