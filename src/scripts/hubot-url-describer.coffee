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
HtmlParser = require 'htmlparser2'
_ = require 'underscore'
_S = require 'underscore.string'

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
                titles.push(child.data)
            title = title + _S.trim(titles.join(''))
          if ( elm.name == 'twitter:title' )
            console.log(elm)
            title = _S.trim(elm.value)

      if (title.length > 0)
        robot.send _S.unescapeHTML(title)
      else
        # err

    request.get url, {}, (err,res,body) ->
      if res.headers['content-type'].indexOf('text/html') != 0
        return
      new HtmlParser.Parser(handler).parseComplete(body)
    @

  @

