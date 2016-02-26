
_height = window.window.innerHeight - 5
_width = window.window.innerWidth - 5

if _height > _width
  width = _width
  width = 600 if width > 600
  height = width*1.8 
  if height > _height
    height = _height
    width = height*.6
  canvasSize = width

else 
  height = _height
  height = 600 if height > 600
  width = height*1.8
  if width > _width
    width = _width
    height = width*.6
  canvasSize = height

preload = ->
  _.load.tilemap "mapData", "js/minimap.json", null, Phaser.Tilemap.TILED_JSON
  _.load.spritesheet "tile", "img/tiles.png", 300, 300
  _.load.spritesheet "door", "img/door.png", 200, 200
  _.load.spritesheet "bg-tiles", "img/bg-tiles.png", 200, 200
  _.load.image "mapImage", "img/minimap.png"
  _.load.image "top", "img/top.png"
  _.load.image "side", "img/side2.png"
  _.load.image "fs", "img/fullscreen.png"
  _.load.image "player", "img/hero.png"
  for n in [1..15]
    _.load.audio "pop"+n, "snd/pop"+n+".mp3"
  _.load.audio "new", "snd/next_level.mp3"

create = ->
  initVars()
  setRoomSize();
  initBG();
  initTileGrid();
  initUI();
  newRoom();

update = ->

render = ->
  # debugTiles()

initVars = ->
  # init global game vars
  _.tilesToPop  = []
  _.path        = []
  _.arrows      = []
  _.pathMatches = []
  _.quads       = []
  _.rooms       = []
  _.halls       = []
  _.tiles       = []
  _.doors       = []
  _.score       = 0
  _.numMatched  = 0
  _.combo       = 0
  _.level       = 0
  _.numTypes    = 5
  _.maxPopTime  = 150
  _.popTime     = _.maxPopTime
  _.floorSize   = 70

_ = new Phaser.Game(
  width
  height
  Phaser.CANVAS, "super-candy-adventure-saga",
    preload: preload
    create: create
    update: update
    render: render
)
