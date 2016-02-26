# Set view port size
_height = 400
_width = 400
# portrait
if _height > _width
  if width > 600 then width = 600 else width = _width
  height = width*1.8
  if height > _height then height = _height; width = height*.6
  canvasSize = width
# landscape
else
  if height > 600 then height = 600 else height = _height
  width = height*1.8
  if width > _width then width = _width; height = width*.6
  canvasSize = height

preload = ->
  _.load.spritesheet "tile", "assets/images/tiles.png", 300, 300
  _.load.spritesheet "door", "assets/images/door.png", 200, 200
  _.load.spritesheet "bg-tiles", "assets/images/bg-tiles.png", 200, 200
  _.load.image "mapImage", "assets/images/minimap.png"
  _.load.image "top", "assets/images/top.png"
  _.load.image "side", "assets/images/side2.png"
  _.load.image "fs", "assets/images/fullscreen.png"
  _.load.image "player", "assets/images/hero.png"
  # for n in [1..15]
  #   _.load.audio "pop"+n, "snd/pop"+n+".mp3"
  # _.load.audio "new", "snd/next_level.mp3"

create = ->
  # init global game vars
  _.score       = 0
  _.numMatched  = 0
  _.combo       = 0
  _.numTypes    = 5
  _.maxPopTime  = 150
  _.popTime     = _.maxPopTime

  _.Background = new Background
  _.Interface  = new Interface
  _.Player     = new Player
  _.Path       = new Path
  _.Dungeon    = new Dungeon
  _.Room       = new Room

  _.Dungeon.create();
  _.Room.create(6,6);

update = ->

render = ->
  debugTiles()

_ = new Phaser.Game(
  400
  400
  Phaser.CANVAS, "super-candy-adventure-saga",
    preload: preload
    create: create
    update: update
    render: render
)
