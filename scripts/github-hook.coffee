# Description:
#   Process github hooks
#
# Configuration
#   HUBOT_GITHUB_HOOK_SECRET - required, the secret used to validate the authenticity of the request
#
# Author:
#   Christopher De Cairos

crypto = require('crypto')

secretKey = process.env.HUBOT_GITHUB_HOOK_SECRET

module.exports = (robot) ->

  calculateSignature = (data) ->
    signature = "sha1=" + crypto.createHmac('sha1', secretKey)
      .update(JSON.stringify data)
      .digest('hex')

  verifySignature = (event, signature) -> 
    event.signature is signature

  robot.router.post '/mozbot/github-events/:room', (req, res) ->
    channel = req.params.room
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
        [#{userName}](https://github.com/#{userName}) #{action} Issue ##{issue.number} on [#{repository.full_name}](https://github.com/#{repository.full_name})

        [#{issue.title}](#{issue.html_url})
        """
      else null

  formatPulls = (event) ->
    data = event.data
    switch data.action
      when 'opened', 'closed', 'reopened'
        {pull_request, base, sender, repository} = data
        return null unless base?.ref in ["master", "develop"]
        verb = if pull_request.merged? then pull_request.merged else data.action

        """
        [#{sender.login}](https://github.com/#{sender.login}) #{verb} Pull Request ##{pull_request.number} on [#{repository.full_name}##{base.ref}](https://github.com/#{repository.full_name}/tree/#{base.ref})
        
        [#{pullRequest.title}](#{pullRequest.html_url})

        
        """
      else null

  ordinal = (size, singularNoun) ->
    noun = if size is 1 then singularNoun else singularNoun + "s"
    "#{size} #{noun}"

  # limit push notifications to master and develop branches
  refRegex = /// ^                # match from beginning
    \/ refs                       # string should lead with /refs
    \/ head                       # then /head
    \/ (?:                        # non capturing group
      master | develop            # Then it should show the branch name this pull happened on, we want master or develop
    )
  ///

  formatPushes = (event) ->

    {ref, commits, pusher, repository, compare} = event.data
    return null unless refRegex.match(ref)
    return null unless commits?.length > 0

    branchName = refs.split('/')[2]

    """
    [#{pusher.name}](https://github.com/#{pusher.name}) pushed #{ordinal(commits.length, 'commit')} to [#{repository.full_name}##{branchName}](https://github.com/#{repository.full_name}/tree/#{branchName})

    #{('*' + commit.message.split("\n")[0]) for commit in commits}

    #{compare}
    """

  formatDeployment = (event) ->
    {creator, sha, name, environment, description} = data.deployment

    """
    [#{creator.login}](https://github.com/{creator.login}) started a deployment of #{sha[0..8]} in [#{name}](https://github.com/#{name}) to #{environment}
    Description: #{description}
    """

  formatDeploymentStatus = (event) ->
    {repository, deployment, state, creator, state, description } = event.deployment_status

    """
    Deployment of [#{repository.name}](https://github.com/#{repository.name}) to #{deployment.environment} by [#{creator.login}](https://github.com/#{creator.login}) has ended in #{state}
    Description: #{description}
    """