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

  Number::formatMoney = (t=',', d='.', c='$') ->
    n = this
    s = if n < 0 then "-#{c}" else c
    i = Math.abs(n).toFixed(2)
    j = (if (j = i.length) > 3 then j % 3 else 0)
    s += i.substr(0, j) + t if j
    return s + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t)

  getTotal = (robot) ->
    robot.http("https://transaction-storage.mofoprod.net/eoy-2016-total")
      .get() (err, res, body) ->
        if err
          robot.send "I had trouble fetching the total, try again later?"
        else
          data = JSON.parse body
          robot.send "## We've raised\n# #{data.sum.formatMoney()}\n:parrotbeer:"

  robot.respond /fundraising/i, getTotal
  robot.respond /show me the money/i, getTotal
