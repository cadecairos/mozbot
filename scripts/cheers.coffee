# Description:
#   Happiness increaser
#
# Dependencies:
#   None
#
# Commands:
#   cheers - Display people celebrating
#
# Author:
#   dave

cheers = [
  "https://i.imgur.com/cRhfOgV.gif",
  "https://i.imgur.com/tnf1ruq.jpg",
  "https://www.reactiongifs.us/wp-content/uploads/2013/12/cheers_law_and_order.gif",
  "https://i.imgur.com/23oGmZK.gif",
  "https://media.tumblr.com/tumblr_mdn5c0qdmO1rsy0lf.gif",
  "https://i1145.photobucket.com/albums/o503/KimmieRocks/Marshall-Barney-how-i-met-your-mother-33452674-500-269_zps610b6d69.gif",
  "https://i.imgur.com/D0edloJ.jpg",
  "https://gifsec.com/wp-content/uploads/GIF/2014/10/Cheers-GIF.gif",
  "https://i.imgur.com/y3SK2Gy.jpg",
  "https://i.imgur.com/SBzzj.gif"
]

module.exports = (robot) ->

  robot.respond /cheers/i, (msg) ->
    msg.send msg.random cheers
