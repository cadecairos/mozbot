POWER_COMMANDS = [
  'jenkins.build',
  'jenkins.b',
  'jenkins.list',
  'jenkins.describe',
  'jenkins.last'
]

module.exports = (robot) ->
  robot.listenerMiddleware (context, next, done) ->
    if context.listener.options.id in POWER_COMMANDS
      user = context.response.message.user
      unless robot.auth.hasRole(user, "jenkins")
        context.response.reply "I'm sorry, but you don't have access to do that."
        done()
      else
        next()
    else
      next()