# Description:
#   About Mozbot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   mozbot about
#
# Author:
#   Christopher De Cairos

module.exports = (robot) ->
  robot.respond /about/i, (msg) ->
    msg.send "Hi, I'm mozbot, I do things! You can see what I do by running `mozbot help`. If you'd like to help make me smarter, [click here](https://github.com/cadecairos/mozbot)"