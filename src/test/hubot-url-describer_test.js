process.env.EXPRESS_PORT = (process.env.PORT = 0);

const Helper = require('hubot-test-helper');
const Url = require('url');
require('should');
const nock = require('nock');
const helper = new Helper('../scripts/hubot-url-describer.js');

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));


const urls = [
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
  // Description could be good here
  [
    'http://www.mypebblefaces.com/apps/1219/1597/',
    'mypebblefaces.html',
    'Mac System 3 | My Pebble Faces'
  ],
  // this should be ignored
  [
    'https://lh6.googleusercontent.com/-hddEYyXVeZM/AAAAAAAAAAI/AAAAAAAAAAA/ghwEL1-FHdE/s48-c-k-no/photo.jpg',
    'gravatar.png',
    false
  ],
  // This one has an mdash in it
  [
    'http://www.kickstarter.com/projects/modrobotics/moss-the-dynamic-robot-construction-kit?ref=category',
    'mdash.html',
    'MOSS - The Dynamic Robot Construction Kit by Modular Robotics -- Kickstarter'
  ],
  // issue #3 - Reports multiline
  [
    'https://plus.google.com/110558071969009568835/posts/CyaYM9qXmM1',
    'gplus.html',
    'Koushik Dutta - Google+ - How Software Companies Die'
  ],
  // issue #4 - Page has no title
  [
    'http://www.thinkgeek.com/edm/20131206.shtml?cpg=gplus',
    'thinkgeek.html',
    'No title found'
  ],
  [
    'https://dev.twitter.com/docs/cards/types/summary-card',
    'twitter-card.html',
    'Summary Card | Twitter Developers' // title should not be overridden by twitter:title
  ]
];

// mock up the requests
urls.forEach(function(url) {
  const data = Url.parse(url[0]);
  nock(data.protocol + '//' + data.hostname)
    .defaultReplyHeaders({'Content-Type': 'text/html'})
    .get(data.path)
    .replyWithFile(200, __dirname + '/replies/'+ url[1]);
});

describe('hubot_url_describer', function () {
  let room;
  beforeEach(() => { room = helper.createRoom(); });
  afterEach(() => { room.destroy(); });
  for (const url of urls) {
    it(url[0] + ' outputs title', async () => {
      await room.user.say('halkeye', url[0])
      await sleep(25)
      if (url[2] === false) {
        room.messages.should.eql([
          ['halkeye', url[0]],
        ])
      } else {
        room.messages.should.eql([
          ['halkeye', url[0]],
          ['hubot', url[2]]
        ])
      }
    });
  }
})
