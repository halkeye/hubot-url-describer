'use strict'

Hubot = require('hubot')
Path = require('path')
Url = require 'url'
sinon = require('sinon')
should = require('should')
nock = require('nock')

adapterPath = Path.join Path.dirname(require.resolve 'hubot'), "src", "adapters"
robot = Hubot.loadBot adapterPath, "shell", "true", "MochaHubot"
{TextMessage} = require Path.join(adapterPath,'../message')

hubot_url_describer = require('../scripts/hubot-url-describer')(robot)

user = {}
send_message = (msg) ->
  user = robot.brain.userForId '1', name: 'Shell', room: 'Shell'
  robot.adapter.receive new TextMessage user, msg, 'messageId'

urls = [
  [
    'https://google.com',
    'google.html',
    'Google'
  ],
  [
    'https://social.icims.com/job/Sr-Manager-Security-Job-US-TX-Austin-10268652.html?isd_source=linkedin&isd_pub=248215#',
    'job-posting.html',
    'Sr. Manager, Security | iCIMS Social Distribution'
  ],
  [
    'http://www.youtube.com/watch?v=jeMO9WseFck',
    'youtube.html',
    'Rooster Teeth Animated Adventures - Relaxed Gav & Lost Keys - YouTube'
  ],
  [
    'http://imgur.com/gallery/pqyzSW8',
    'imgur.html',
    'I owe you my life - Imgur',
  ],
  # Description could be good here
  [
    'http://www.mypebblefaces.com/apps/1219/1597/',
    'mypebblefaces.html',
    'Mac System 3 | My Pebble Faces'
  ]
]

# mock up the requests
urls.forEach (url) ->
  data = Url.parse(url[0])
  nock(data.protocol + '//' + data.hostname)
    .defaultReplyHeaders({'Content-Type': 'text/html'})
    .get(data.path)
    .replyWithFile(200, __dirname + '/replies/'+ url[1])

describe 'hubot_url_describer', ()->
  urls.forEach (url) ->
    describe url[0], ()->
      before (done) ->
        robot.adapter.send = sinon.spy()
        send_message url[0]
        # hack to wait for robot to finish fetching and returning
        a = setInterval ->
          if robot.adapter.send.args.length > 0
            clearInterval a
            done()
        , 100
      it 'output title', ()->
        robot.adapter.send.args[0][0].should.eql(url[2])
