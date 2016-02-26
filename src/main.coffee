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

render = -> debugTiles()

initVars = ->
  # init global game vars
  _.tilesToPop = []
  _.path       = []
  _.arrows     = []
  _.matches    = []
  _.score      = 0
  _.numMatched = 0
  _.combo      = 0
  _.level      = 0
  _.numTypes   = 4
  _.popTime    = 10

_ = new Phaser.Game(
  canvasSize
  canvasSize
  Phaser.CANVAS, "", 
    preload: preload
    create: create
    update: update
    render: render
)
