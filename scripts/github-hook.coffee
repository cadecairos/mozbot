# Description:
#   Process github hooks
#
# Configuration
#   HUBOT_GITHUB_HOOK_SECRET - required, the secret used to validate the authenticity of the request
#   HUBOT_GITHUB_CHANNEL_MAP - required, map channel name to id for hooks to send messages proplerly
#
# Author:
#   Christopher De Cairos

crypto = require('crypto')

secretKey = process.env.HUBOT_GITHUB_HOOK_SECRET
channelMap = process.env.HUBOT_GITHUB_CHANNEL_MAP

module.exports = (robot) ->

  unless channelMap
    return robot.logger.error "HUBOT_GITHUB_CHANNEL_MAP must be defined"

  channelMap = JSON.parse channelMap

  robot.logger.debug JSON.stringify channelMap, null, 2

  calculateSignature = (data) ->
    signature = "sha1=" + crypto.createHmac('sha1', secretKey)
      .update(JSON.stringify data)
      .digest('hex')

  verifySignature = (event, signature) -> 
    event.signature is signature

  robot.router.post '/mozbot/github-events/:room', (req, res) ->
    channel = channelMap[req.params.room]
    event = 
      data: req.body
      room: if channel then channel else req.params.room
      signature: req.get 'X-Hub-Signature'
      type: req.get 'X-Github-Event'

    robot.logger.debug "Event received: #{JSON.stringify event, null, 2}"

    res.end ""

    unless event.room?
      return robot.logger.error "#{event.room} not defined in HUBOT_GITHUB_CHANNEL_MAP"

    signature = calculateSignature event.data

    unless verifySignature event, signature
      return robot.logger.error "Invalid signature";

    unless formattedMessage = format event
      return robot.logger.info "#{event.type} Not supported"

    robot.logger.info "Messaging #{event.room} about #{event.type}:#{event.data.action}"
    robot.messageRoom event.room, formattedMessage
  
  format = (event) ->
    switch event.type
      when 'issues' then formatIssues event
      when 'pull_request' then formatPulls event
      when 'push' then formatPushes event
      when 'deployment' then formatDeployment event
      when 'deployment_status' then formatDeploymentStatus event 
      else null

  formatIssues = (event) ->
    data = event.data
    switch data.action
      when 'opened', 'closed', 'reopened'
        {action, issue, repository, sender} = data
        userName = sender?.login ? issue.user.login

        """
        #{userName} #{action} Issue ##{issue.number} on #{repository.full_name}

        [#{issue.title}](#{issue.html_url})
        """
      else null

  formatPulls = (event) ->
    data = event.data
    switch data.action
      when 'opened', 'closed', 'reopened'
        {pull_request, sender, repository} = data 
        verb = if pull_request.merged? then pull_request.merged else data.action

        """
        #{sender.login} #{verb} Pull Request ##{pull_request.number} on #{repository.full_name}

        [#{issue.title}](#{issue.html_url})
        """
      else null

  formatPushes = (event) ->
    ordinal = (size, singularNoun) ->
      noun = if size is 1 then singularNoun else singularNoun + "s"
      "#{size} #{noun}"

    data = event.data
    return unless data.commits and data.commits.length > 0

    message = "#{data.pusher.name} pushed #{ordinal(data.commits.length, 'commit')} to #{data.repository.full_name}"
    message += "\n * #{commit.message.split("\n")[0]}" for commit in data.commits
    message += "\n\n#{data.compare}"
    message

  formatDeployment = (event) ->
    deployment = data.deployment

    """
    #{deployment.creator.login} started a deployment of #{deployment.sha[0..8]} in #{deployment.name} to #{deployment.environment}
    Description: #{deployment.description}
    """

  formatDeploymentStatus = (event) ->
    deployment_status = event.deployment_status

    """
    Deployment of #{deployment_status.repository.name} to #{deployment_status.deployment.environment} by #{deployment_status.creator.login} has ended in #{deployment_status.state}
    Description: #{deployment_status.description}
    """