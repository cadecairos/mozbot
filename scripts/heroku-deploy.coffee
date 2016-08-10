# Description:
#   Trigger production deployments to Heroku for Mozilla Foundation apps
#
# Dependencies:
#   None
#
# Configuration:
#   HEROKU_API_TOKEN
#
# Commands:#
#   mozbot deploy <appname> to staging
#   mozbot deploy <appname>@<ref> to staging
#   mozbot promote <appname> to production
#   mozbot which apps can you deploy
#
# Author:
#   Christopher De Cairos

VALID_APPS =
  chat:
    role: "deploy_chat",
    defaultBlobRef: "master"
    repo: "cadecairos/mattermost-heroku"
    staging:
      name: "chat-mozillafdn-org-staging"
    production:
      name: "chat-mozillafdn-org-production"
  donate:
    role: "deploy_donate"
    defaultBlobRef: "master"
    repo: "mozilla/donate.mozilla.org"
    staging:
      name: "donate-mozilla-org-us-staging"
    production:
      name: "donate-mozilla-org-us-prod"
  publish:
    role: "deploy_publish"
    defaultBlobRef: "master"
    repo: "mozilla/publish.webmaker.org"
    staging:
      name: "publish-webmaker-org-staging"
      id: "8cfb68e2-7423-477c-9ade-66c883ed662e"
    production:
      name: "publish-webmaker-org-prod"
      id: "0b70729c-ff45-497a-8dff-726a1dbe7385"
    pipelineId: "0b70729c-ff45-497a-8dff-726a1dbe7385"
  learning:
    role: "deploy_learning"
    defaultBlobRef: "master"
    repo: "mozilla/learning.mozilla.org"
    staging:
      name: "learning-mozilla-org-staging"
      id: "b3db69fd-3fc6-4b06-95fc-4d88d4497c5b"
    production:
      name: "learning-mozilla-org-prod"
      id: "d076d414-3ff2-4dc6-a61c-b318cc72b410"
    pipelineId: "a5e867f8-2101-41da-8c61-ba00bb30acbf"

AUTH_HEADER = "Bearer #{process.env.HEROKU_API_TOKEN}"

module.exports = (robot) ->
  robot.respond /deploy ([a-zA-Z\d\-]+)(?:@([a-zA-Z\d\-]+))? to staging$/i, { id: "heroku.deploy" }, (msg) ->
    appName = msg.match[1]
    blobRef = msg.match[2]

    appData = VALID_APPS[appName]

    unless appData?
      return msg.send "Invalid App name" 

    unless blobRef?
      blobRef = appData.defaultBlobRef

    unless robot.auth.hasRole msg.envelope.user, appData.role
      return msg.send "You need the '#{appData.role}'' role to deploy #{appName}"

    deploy { appName, appData, blobRef, msg }

  robot.respond /promote ([a-zA-Z\d\-]+) to production$/i, { id: "heroku.promote" }, (msg) ->
    appName = msg.match[1]

    appData = VALID_APPS[appName]

    unless appData?
      return msg.send "Invalid App name" 

    unless robot.auth.hasRole msg.envelope.user, appData.role
      return msg.send "You need the '#{appData.role}'' role to promote #{appName}"

    unless appData.pipelineId?
      return msg.send "This app doesn't allow pipeline promotions"

    promote { appName, appData, msg }

  robot.respond /which apps can you deploy\??$/i, {id: "heroku.list-apps"}, (msg) ->
    msg.send appList()

appList = () ->
  list = "I can deploy the following applications: \n\n"

  for appName, appData of VALID_APPS
    do (appName, appData) ->
      list += "* ** #{appName}** deploys #{appData.defaultBlobRef} to staging"
      list += " and supports promoting to production using pipelines" if appData.pipelineId?
      list += "\n"

  list

sendRequest = (msg, requestUrl, body, callback) ->
  msg.http(requestUrl)
    .header("Content-Type", "application/json")
    .header("Accept", "application/vnd.heroku+json; version=3")
    .header("Authorization", AUTH_HEADER)
    .post(body) (err, res, body) ->
      return msg.send "An error occurred #{err}" if err?
      return msg.send "The request was not successful" if res.statusCode isnt 201
      callback JSON.parse(body)

deploy = (options) ->
  { appName, appData, blobRef, msg } = options

  requestUrl = "https://kolkrabbi.herokuapp.com/apps/#{appData.staging.id}/github/push"

  body = JSON.stringify
    branch: blobRef

  sendRequest msg, requestUrl, body, (responseBody) ->
    msg.send "**Staging** deployment of **#{appName}** started - [Click here to watch](https://dashboard.heroku.com/apps/#{appData.staging.name}/activity/builds/#{responseBody.id})"

promote = (options) ->
  { appName, appData, msg } = options

  requestUrl = "https://api.heroku.com/pipeline-promotions"

  body = JSON.stringify({
    pipeline:
      id: appData.pipelineId
    source:
      app:
        id: appData.staging.id
    targets: [
      app:
        id: appData.production.id
    ]
  })

  sendRequest msg, requestUrl, body, (responseBody) ->
      msg.send "Promoting **#{appName}** staging to production"
