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
  ],
  # this should be ignored
  [
    'https://lh6.googleusercontent.com/-hddEYyXVeZM/AAAAAAAAAAI/AAAAAAAAAAA/ghwEL1-FHdE/s48-c-k-no/photo.jpg',
    'gravatar.png',
    false
  ],
  # This one has an mdash in it
  [
    'http://www.kickstarter.com/projects/modrobotics/moss-the-dynamic-robot-construction-kit?ref=category',
    'mdash.html',
    'MOSS - The Dynamic Robot Construction Kit by Modular Robotics -- Kickstarter'
  ],
  # issue #3 - Reports multiline
  [
    'https://plus.google.com/110558071969009568835/posts/CyaYM9qXmM1',
    'gplus.html',
    'Koushik Dutta - Google+ - How Software Companies Die'
  ],
  # issue #4 - Page has no title
  [
    'http://www.thinkgeek.com/edm/20131206.shtml?cpg=gplus',
    'thinkgeek.html',
    'No title found'
  ],
  [
    'https://dev.twitter.com/docs/cards/types/summary-card',
    'twitter-card.html',
    'Summary Card | Twitter Developers' # title should not be overridden by twitter:title
  ]
]

# mock up the requests
urls.forEach (url) ->
  data = Url.parse(url[0])
  n = nock(data.protocol + '//' + data.hostname)
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
        setTimeout ->
          done()
        , 100

      it 'output title', ()->
        if (url[2] == false)
          robot.adapter.send.args.should.be.empty
        else
          robot.adapter.send.args.should.not.be.empty
          if (!robot.adapter.send.args[0])
            return
          robot.adapter.send.args[0][1].should.eql(url[2])
