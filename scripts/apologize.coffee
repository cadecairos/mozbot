# Description:
#   Make mozbot apologize for being a derp
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   mozbot apologize
#   mozbot aplologize to <name>
#   mozbot that's not nice
#
# Author:
#   Christopher De Cairos
module.exports = (robot) ->

  apologize = (robot) ->
    robot.send "I'm sorry :( I'll try better next time!"

  apologizeTo = (robot) ->
    robot.send "I'm sorry @${robot.match[1]}"

  robot.respond /apologize to (@?.+)/i, apologizeTo
  robot.respond /apologize/i, apologize
  robot.respond /that's not nice/i, apologize
