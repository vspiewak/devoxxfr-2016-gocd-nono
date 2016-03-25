# Description:
#   "Accepts POST data and broadcasts it"
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
# URLs:
#   POST /hubot/say
#     message = <message>
#     room = <room>
#     type = <type>
#
#   curl -X POST http://localhost:8080/hubot/say -d message='my custom message' -d room='#dev-team'
#   curl -X POST http://localhost:8080/hubot/say -d message='my custom message' -d room='#dev-team' -d color='#87579B' -d author_name='GoCD' -d author_link='http://twitter.com/vspiewak' -d title='the title' -d title_link='http://github.com/vspiewak' -d thumb_url='https://raw.githubusercontent.com/vspiewak/nono/master/assets/gocd_thumb_url.gif'
#
# Author:
#   insom
#   luxflux

module.exports = (robot) ->
  robot.router.post "/hubot/say", (req, res) ->
    body = req.body
    room = body.room
    message = body.message

    # slack specific
    color = body.color
    author_name = body.author_name
    author_link = body.author_link
    title = body.title
    title_link = body.title_link
    thumb_url = body.thumb_url

    #robot.logger.info "Message '#{message}' received for room #{room}"

    envelope = robot.brain.userForId 'broadcast'
    envelope.user = {}
    envelope.user.room = envelope.room = room if room
    envelope.user.type = body.type or 'groupchat'


    slack = {}
    slack.text = message
    slack.fallback = message
    slack.color = color
    slack.channel = envelope.user.room
    slack.author_name = author_name
    slack.author_link = author_link
    slack.title = title
    slack.title_link = title_link
    slack.thumb_url = thumb_url


    if message
      if robot.adapterName != "slack"
        robot.send envelope, message
      else
        robot.emit 'slack-attachment',
          channel: "#{slack.channel}"
          content: slack

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'Thanks\n'
