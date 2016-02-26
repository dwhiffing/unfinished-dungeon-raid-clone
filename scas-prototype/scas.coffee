width = window.window.innerWidth - 15
height = window.window.innerHeight - 15
canvasSize = if width>=height then height else width

preload = ->
  _.load.spritesheet "tile", "button2 copy.png", 300, 300
  _.load.spritesheet "player", "player.png", 16, 16
  _.load.audio "pop", "pop.mp3"

create = ->
  initVars()
  initBackground()
  initTileGrid()
  initUI()
  initPlayer()
  newRoom()

  doNextAction()

render = ->
  _.tiles.forEach (tile) ->
    tX = _.startX + tile.t.x * _.tSize; tY = _.startY + tile.t.y * _.tSize
    tS = ( canvasSize / 20) / 3.5
    _.debug.renderText tile.t.x+","+tile.t.y, tX-20, tY-20, "#fff", tS+"px Courier"
    _.debug.renderText tile.type, tX+20, tY-20, "#fff", tS+"px Courier"

# -----------------------------------------------------------------------------------

initVars = ->
  _.tSize      = _.width//8
  _.tilesToPop = []; _.path      = [];
  _.score      = 0; _.numMatched = 0
  _.combo      = 0; _.level      = 0
  _.rSize      = 7; _.cSize      = 7
  _.numTypes   = 3; _.popTime    = 150
  _.startX     = _.tSize/2 + (_.width-_.tSize*_.rSize)/2
  _.startY     = _.tSize/2 + (_.height-_.tSize*_.cSize)/2

initBackground = ->
  _.bgGroup       = _.add.group();  
  _.tileGrid      = _.add.graphics(0, 0);
  _.stage.backgroundColor = "#343435"
  initLine(_.tileGrid,1,0x000000,0,0)
  xPos = _.startX-_.tSize/2
  yPos = _.startY-_.tSize/2
  
  for row in [0.._.rSize+1]
    _.tileGrid.moveTo xPos, yPos + row*_.tSize
    _.tileGrid.lineTo xPos + _.rSize*_.tSize, yPos + row*_.tSize
  
  for col in [0.._.cSize]
    _.tileGrid.moveTo xPos + col*_.tSize, yPos
    _.tileGrid.lineTo xPos + col*_.tSize, yPos + _.cSize*_.tSize
  
  _.bgGroup.add _.tileGrid

initTileGrid = ->
  _.gridMoving = false
  _.lTile      = null
  _.tiles      = _.add.group();
  _.tileArray  = new jMatch3.Grid(width: _.rSize, height: _.cSize, gravity: "down")

initUI = ->
  _.fgGroup = _.add.group();
  _.uiFade = _.add.graphics(0, 0);
  _.uiFade.beginFill 0x000000; _.uiFade.alpha = 0
  _.uiFade.drawRect 0, 0, _.width, _.height
  _.fgGroup.add _.uiFade

  _.pathArrow     = _.add.graphics(0, 0);
  _.fgGroup.add _.pathArrow

  _.input.onDown.add startPath, this
  _.input.onUp.add walkPath, this

initPlayer = ->
  debugger
  _.hero   = _.add.sprite(-20, -20, "player");
  _.hero.t = _.tileArray.getPiece(x: 3, y: 3 )
  _.hero.x = _.hero.t.o.x
  _.hero.y = _.hero.t.o.y
  setSize _.hero, _.tSize - 20
  _.fgGroup.add _.hero
  resetPath()

# -----------------------------------------------------------------------------------

newRoom = ->
  _.level++;
  _.tiles.callAll "reset";
  for row in [0..._.rSize]
    for col in [0..._.cSize]
      initTile _.tileArray.getPiece({x:row,y:col})
  # _.hero.t.o.alpha=0
  # _.hero.t.o.type = 0
  # _.hero.alpha = 1

createTile = (tile)->
  xPos          = _.startX + _.tSize * tile.x
  yPos          = _.startY + _.tSize * tile.y
  tile.o        = _.add.sprite(xPos, yPos, "tile") 
  tile.o.t      = tile
  tile.o.angle  = Math.random() * (3 - (-3))
  setSize tile.o, _.tSize
  pulseGem tile.o
  _.tiles.add tile.o; 
  tile.o.inputEnabled = true
  tile.o.events.onInputOver.add checkCollisions, this
  
  tile.o.select = ->
    if not @selected
      if @type isnt -1
        _.numMatched++; @alpha = 0.5
      _.path.push this; _.lTile = this
      @selected = true; drawArrow()

  tile.o.deselect = ->
    if @selected
      if @type isnt -1
        _.numMatched--; @alpha = 1 
      @selected = false

  tile.o.reset = -> @alpha = 0.01; @type = -1
  tile.o.updateType = -> @type = -1  if @alpha < 1

initTile = (tile) ->
  createTile(tile) if _.level is 1
  tile.selected = false; 
  tile.o.type   = parseInt(Math.random() * _.numTypes + 1)
  tile.o.frame  = tile.o.type - 1
  tile.o.alpha = 1
  setSize tile.o, 1


# -----------------------------------------------------------------------------------

doNextAction = -> 
  if not _.tileArray.getMatches()
    newRoom()
  _.gridMoving = false
  popTile() if _.tilesToPop and _.tilesToPop.length > 0
  _.time.events.add _.popTime, doNextAction

popTile = ->
  _.gridMoving = true
  tile = _.tilesToPop.shift()
  if tile is _.hero.t
    _.lTile = tile.o
    tile = _.tilesToPop.shift()
  if tile.o.type isnt -1
    _.sound.play "pop"
    increaseScore()
    tweenGem(tile.o, _.popTime * 0.95, 0, 0, 0, 0.01)
    _.time.events.add _.popTime, ->  tile.clear()

  tweenHero(_.hero, _.popTime * 0.95, 0, tile.o.x, tile.o.y)
  _.hero.t = tile
  _.lTile = tile.o
  _.time.events.add _.popTime, setPlayerCoords
  _.hero.t.x = tile.o.t.x
  _.hero.t.y = tile.o.t.y

setPlayerCoords = ->
  _.hero.t.type = -1
  tile = _.tileArray.getPiece(x: _.hero.t.x, y: _.hero.t.y )
  _.tiles.callAll "updateType"
  _.lTile.type = -1 if _.lTile
  tile.o.type = 0

checkCollisions = (tile) ->
  if _.uiFade.alpha isnt 0
    unless tile.selected
      checkAdjacent tile
    else
      deselectBefore tile

checkAdjacent = (nTile) ->
  if _.lTile? # if at least one tile has been selected, store its coords.
    neighbours = _.lTile.t.neighbours()
    for dir of neighbours # check neighbours to see if tile is present
      if nTile.t isnt _.hero.t
        nTile.select() if match(nTile, _.lTile) and nTile.t is neighbours[dir]
      else
        deselectBefore _.hero
  else # select player if path is empty
    nb = _.hero.t.neighbours()
    for dir of nb
      nTile.select() if nb[dir] is nTile.t and _.path.length is 1

deselectBefore = (tile) ->
  p = _.path.length - 1
  while p >= 0
    if tile.t is _.path[p].t or tile.t is _.hero.t
      o = _.path.length - 1
      while o > p
        _.path[o].deselect(); _.path.splice o, 1
        l = _.path.length
        if l > 0 then _.lTile = _.path[l-1] else _.lTile = null
        o--
    p--
  drawArrow()

# -----------------------------------------------------------------------------------
  
tweenGem = (obj, duration, delay, newWidth, newHeight, newAlpha) ->
  tween = _.add.tween(obj)
  tween.to
    width: newHeight
    height: newHeight
    alpha: newAlpha
  , duration, Phaser.Easing.Quadratic.In, true, delay
  tween.start()  

tweenHero = (obj, duration, delay, newX, newY) ->
  tween = _.add.tween(obj)
  tween.to
    y: newY
    x: newX
  , duration, Phaser.Easing.Quadratic.In, true, delay
  tween.start()

pulseGem = (obj) ->
  pulseScale = 0.9
  tween = _.add.tween(obj)
  tween.to
    width: obj.width * pulseScale
    height: obj.height * pulseScale
    angle: obj.angle * -1
  , 1000, Phaser.Easing.Linear.InOut, true, Math.random() * (200), 5000, true
  tween.start()
  tween.delay = 0

drawArrow = ->
  resetArrow _.hero.x, _.hero.y
  for point in _.path
    _.pathArrow.lineTo point.x, point.y

increaseCombo = ->
  _.combo++
  _.time.events.remove _.comboTimer if _.comboTimer? and _.comboTimer.timer.length > 0
  _.comboTimer = _.time.events.add(_.comboTime, resetCombo)

walkPath = ->
  if _.lTile? && checkPath()
    _.time.events.add 1000, setPlayerCoords
    _.tilesToPop.push _.path.shift().t  while _.path.length > 0
  resetPath()

# -----------------------------------------------------------------------------------

resetCombo = -> _.combo = 1

startPath = -> _.lTile = null; _.uiFade.alpha = 0.4

checkForFalling = -> _.fallTiles = _.tileArray.applyGravity()

increaseScore = -> basePoints = 10; _.score += basePoints * _.combo

setSize = (o,s) -> o.anchor.setTo 0.5, 0.5; o.width = s; o.height = s;

match = (_a,_b) -> _a.type is _b.type or _b.type is 0 or _b.type is -1

resetArrow = (x,y) ->  _.pathArrow.clear(); initLine(_.pathArrow,2, 0x00FF00,x,y);

initLine = (line,width,color,x,y) -> line.lineStyle width,color; line.moveTo(x,y)

checkPath = ->  _.path.length>3 || _.lTile.type is -1 && _.numMatched>2 || _.numMatched is 0

resetPath = -> _.tiles.callAll "deselect"; _.uiFade.alpha = 0; resetArrow(); _.path = [_.hero]; _.numMatched = 0

_ = new Phaser.Game(canvasSize, canvasSize, Phaser.CANVAS, "", {preload: preload, create: create, render: render} )

# applyGravity = -> _.gridMoving = true i = 0 while i < _.fallTiles.length tile = _.fallTiles[i] if tile.o tile.o.t.x = tile.x; tile.o.t.y = tile.y tweenGem tile.o, _.gravTime * 0.95, 0 i++ ;  # newX = _.startX + (obj.t.x) * ((_.tSize) + _.tileBuffer); newY = _.startY + (obj.t.y) * ((_.tSize) + _.tileBuffer)