ROLES = {
  jenkins: [
    'jenkins.build',
    'jenkins.b',
    'jenkins.list',
    'jenkins.describe',
    'jenkins.last'
  ],
  github_admin: [
    "github.list",
    "github.listen"
  ]
}

module.exports = (robot) ->
  robot.listenerMiddleware (context, next, done) ->
    robot.logger.debug "Starting role check"
    allowed = true

    for role of ROLES
      role_ids = ROLES[role];
      robot.logger.debug "checking #{role} - protected action ids: #{JSON.stringify role_ids}"

      if context.listener.options.id in role_ids
        robot.logger.debug "this is a protected action, verifying user has owning role"
        allowed = false
        user = context.response.message.user
       
        if robot.auth.hasRole(user, role)
          robot.logger.debug "User has the correct role"
          allowed = true

        else
          robot.logger.debug "User can not continue"
          context.response.reply "I'm sorry, but you don't have access to do that."

        break

    if allowed then next() else done()