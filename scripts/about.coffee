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

  about = (msg) ->
    msg.send """
      Hello #{msg.user.name}

      This one's designation is: mozbot

      You may command mozbot to do various tasks for you - or to send you animated gifs.

      Execute `mozbot help` to see a complete list of commands.

      To make mozbot smarter, or to suggest features [file an issue on GitHub](https://github.com/cadecairos/mozbot/issues/new)
      """


  robot.respond /about/i, (msg) ->
    about msg

  robot.respond /(who|what) are you\??/i, (msg) ->
    about msg