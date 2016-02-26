width = window.window.innerWidth - 15
height = window.window.innerHeight - 15
canvasSize = if width>=height then height else width

preload = ->
  _.load.spritesheet "tile", "img/tiles.png", 300, 300
  _.load.spritesheet "player", "img/hero.png", 16, 16
  for n in [1..15]
    _.load.audio "pop"+n, "snd/pop"+n+".mp3"
  _.load.audio "new", "snd/next_level.mp3"

create = ->
  initVars()
  createGame()

update = ->

render = ->
  # debugTiles()

initVars = ->
  # init global game vars
  _.tilesToPop = []
  _.path       = []
  _.arrows     = []
  _.pathMatches    = []
  _.score      = 0
  _.numMatched = 0
  _.combo      = 0
  _.level      = 0
  _.numTypes   = 5
  _.maxPopTime = 150
  _.popTime    = _.maxPopTime

_ = new Phaser.Game(
  canvasSize
  canvasSize+canvasSize
  Phaser.CANVAS, "super-candy-adventure-saga",
    preload: preload
    create: create
    update: update
    render: render
)
