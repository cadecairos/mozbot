# Description:
#   provides a link to help with commands
#
# Commands:
#   hubot help - Displays a link to the help page


module.exports = (robot) ->
    robot.respond /help/i, (msg) ->
         msg.message.done = true
         msg.reply "a list of commands can be found at https://hubot-mozbot.herokuapp.com/mozbot/help"