# Description:
#   Grab XKCD comic image urls
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot xkcd [latest]- The latest XKCD comic
#   hubot xkcd <num> - XKCD comic <num>
#   hubot xkcd random - XKCD comic <num>
#
# Author:
#   twe4ked
#   Hemanth (fixed the max issue)
module.exports = (robot) ->
  robot.respond /xkcd(\s+latest)?$/i, (robot) ->
    robot.http("https://xkcd.com/info.0.json")
      .get() (err, res, body) ->
        if res.statusCode == 404
          robot.send 'Comic not found.'
        else
          object = JSON.parse(body)
          robot.send "#{object.title}\n![XKCD](#{object.img.replace("http", "https")})\n#{object.alt}"

  robot.respond /xkcd\s+(\d+)/i, (robot) ->
    num = "#{robot.match[1]}"

    robot.http("https://xkcd.com/#{num}/info.0.json")
      .get() (err, res, body) ->
        if res.statusCode == 404
          robot.send 'Comic #{num} not found.'
        else
          object = JSON.parse(body)
          robot.send "#{object.title}\n![XKCD](#{object.img.replace("http", "https")})\n#{object.alt}"

  robot.respond /xkcd\s+random/i, (robot) ->
    robot.http("https://xkcd.com/info.0.json")
          .get() (err,res,body) ->
            if res.statusCode == 404
               max = 0
            else
               max = JSON.parse(body).num 
               num = Math.floor((Math.random()*max)+1)
               robot.http("https://xkcd.com/#{num}/info.0.json")
               .get() (err, res, body) ->
                 object = JSON.parse(body)
                 robot.send "#{object.title}\n![XKCD](#{object.img.replace("http", "https")})\n#{object.alt}"
