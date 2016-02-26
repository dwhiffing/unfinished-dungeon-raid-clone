
_height = window.window.innerHeight 
_width = window.window.innerWidth 

# if _width > 1000 then _width = 1000


if _width > _height then width = _height*1.77 else height = _width*1.77 

if width > _width then width = _width; height = width*0.56

if height > _height then height = _height; width = height*0.56

if _height > _width then canvasSize = width else canvasSize = height



preload = ->
  _.load.spritesheet "tile", "img/tiles.png", 300, 300
  _.load.spritesheet "top", "img/top.png", 200, 200
  _.load.spritesheet "side", "img/side.png", 30, 230
  _.load.spritesheet "bg-tiles", "img/bg-tiles.png", 200, 200
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
  _.pathMatches= []
  _.score      = 0
  _.numMatched = 0
  _.combo      = 0
  _.level      = 0
  _.numTypes   = 5
  _.maxPopTime = 150
  _.popTime    = _.maxPopTime

_ = new Phaser.Game(
  width
  height
  Phaser.CANVAS, "super-candy-adventure-saga",
    preload: preload
    create: create
    update: update
    render: render
)
