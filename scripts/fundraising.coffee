# Description:
#   Display the total dollar amount of donations made
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   mozbot fundraising
#   mozbot show me the money
#
# Author:
#   Christopher De Cairos
module.exports = (robot) ->

  getTotal = (robot) ->
    robot.http("https://transaction-storage.mofoprod.net/eoy-2016-total")
      .get() (err, res, body) ->
        if err
          robot.send "I had trouble fetching the total, try again later?"
        else
          data = JSON.parse body
          robot.send "We've raised $#{data.sum} \o/"

  robot.respond /fundraising/i, getTotal
  robot.respond /show me the money/i, getTotal
