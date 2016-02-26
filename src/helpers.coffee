debugTiles = ->
  # debug info about each tile's index and type
  if _.uiFade.alpha is 0.4 or _.uiFade.alpha is 0
    _.tiles.forEach (tile) ->
      tX = (_.startX + tile.t.x * _.tSize)-_.tSize/2.2
      tY = (_.startY + tile.t.y * _.tSize)-_.tSize/3
      tS = ( canvasSize / 20) / 3

      color = "#fff"
      color = "#ff0000" if tile.type is -1
      color = "#00ff00" if tile.type is 0
      color = "#ff00ff" if tile.hasMatch && !tile.isMatched
      color = "#0000ff" if tile.isMatched

      _.debug.renderText tile.t.x+","+tile.t.y, tX, tY-tS, color, tS+"px Courier"

      _.debug.renderText tile.type, tX, tY, color, tS+"px Courier"

drawArrow = ->
  resetArrow()
  for tile of _.path
    lineToTile(tile) if tile > 0
    # drawMatchCircle if _.path[tile]

lineToTile = (index) ->
  tile = _.path[index]
  tile2 = _.path[index-1]
  arrow  = _.add.graphics(9, 0);
  _.fgGroup.add arrow
  arrow.lineStyle 2, checkArrowColour(tile)
  arrow.moveTo tile2.x,tile2.y
  arrow.lineTo tile.x,tile.y
  _.arrows.push arrow

increaseCombo = ->
  _.combo++
  _.time.events.remove _.comboTimer if _.comboTimer? and _.comboTimer.timer.length > 0
  _.comboTimer = _.time.events.add(_.comboTime, resetCombo)

startPath = ->
  _.lTile = null; _.uiFade.alpha = 0.4;

walkPath = ->
  _.popTime = _.maxPopTime
  if _.lTile? && checkPath() && _.path.length > 1
    _.time.events.add 1000, setPlayerCoords
    _.tilesToPop.push _.path.shift().t  while _.path.length > 0
  resetCombo()
  resetPath()
  _.time.events.add _.popTime, doNextAction

setPlayerCoords = ->
  _.hero.t.type = -1
  tile = _.tileArray.getPiece(x: _.hero.t.x, y: _.hero.t.y )
  tile.o.reset()
  _.tiles.callAll "updateType"
  # _.lTile.type = -1 if _.lTile
  tile.o.type = 0

newRoom = ->
  _.level++;
  _.tiles.callAll "reset";
  # _.tileArray  = new jMatch3.Grid(width: _.rSize, height: _.cSize)
  for row in [0..._.rSize]
    for col in [0..._.cSize]
      spawnTile _.tileArray.getPiece({x:row,y:col})
  spawnPlayer()
  checkMatches()
  setRoomSize()
  fadeIn()
  doNextAction()
  lockDoors()

spawnTile = (tile) ->
  tile.selected = false;
  tile.o.type   = _.rnd.integerInRange 1, _.numTypes
  tile.o.frame  = tile.o.type - 1
  tile.o.alpha  = 1
  setSize tile.o, 1
  tile.o.hasMatch=false

spawnPlayer = ->
  tX = _.rnd.integerInRange(0,_.rSize)
  tY = _.rnd.integerInRange(0,_.cSize)
  _.hero.t = _.tileArray.getPiece x: tX, y: tY
  _.hero.x = _.hero.t.o.x
  _.hero.y = _.hero.t.o.y
  resetPath()
  _.uiFade.alpha=1
  setPlayerCoords()

resetArrow = ->
  for arrow in _.arrows
    arrow.destroy()

resetCombo = ->
  _.combo = 1

checkForFalling = ->
  _.fallTiles = _.tileArray.applyGravity()

increaseScore = ->
  basePoints = 10; _.score += basePoints * _.combo

setSize = (o,s) ->
  o.anchor.setTo 0.5, 0.5; o.width = s; o.height = s;

match = (_a,_b) ->
  _a.type is _b.type or _b.type is 0 or _b.type is -1

last = (arr) -> arr[arr.length-1]

initLine = (line,width,color,x,y) ->
  line.lineStyle width,color;
  line.moveTo(x,y) if x? and y?

checkPath = ->
  _.path.length>3 || _.lTile.type is -1 && _.numMatched>2 || _.numMatched is 0

resetPath = ->
  _.tiles.callAll "deselect"; _.uiFade.alpha = 0; resetArrow();_.path = [_.hero]; _.numMatched = 0; _.pathMatches = []

getRandom = (low, high) ->
  ~~(Math.random() * (high - low)) + low

checkArrowColour = (tile) ->
  return "0xFFFFFF" if !tile.isMatched
  switch tile.type
    when -1 then "0xFFFFFF"
    when 1 then "0xFF0000"
    when 2 then "0x00FF00"
    when 3 then "0x0000FF"
    when 4 then "0xFFFF00"
    when 5 then "0xF0F000"
    else "0xFF00FF"


goFull = ->
  _.stage.scale.startFullScreen()

drawMinimap = ->
  scl = _.tSize/25
  for hall in _.halls
    for line in hall
      _.hallGraphics.drawRect line.x*scl,line.y*scl,line.w*scl,line.h*scl
  for room in _.rooms
    _.roomGraphics.beginFill 0xFFFFFF
    _.roomGraphics.beginFill 0x00ff00 if room.player
    _.roomGraphics.drawRect room.x*scl,room.y*scl,room.w*scl,room.h*scl
  # for quad in _.quads
  #   _.leafGraphics.drawRect quad.x*scl,quad.y*scl,quad.width*scl,quad.height*scl
  _.leafGraphics.drawRect _.quads[0].x*scl,_.quads[0].y*scl,_.quads[0].width*scl,_.quads[0].height*scl
  _.leafGraphics.width = _.quads[0].width*scl
  _.leafGraphics.height = _.quads[0].height*scl
  if _.width > _.height # landscape
    for o in [_.leafGraphics,_.roomGraphics,_.hallGraphics]
      o.x = _.tSize*.1
      o.y = _.height-_.leafGraphics.height-_.tSize*.1
  else #portrait
    for o in [_.leafGraphics,_.roomGraphics,_.hallGraphics]
      o.x = _.width-_.leafGraphics.width-_.tSize*.1
      o.y = _.tSize*.1

createOldDungeon = ->
  # load generated map data and create tilemap for minimap of dungeon
  Dungeon.Generate()
  
  _.cache._tilemaps.mapData.data.layers[0].data = _.mapData
  _.tilemap    = _.add.tilemap("mapData")
  _.tilemap.addTilesetImage(0, "mapImage");
  layer = _.tilemap.createLayer(0,_.width,_.height,_.mapGroup);
  _.mapGroup.x=_.width/2-(_.tilemap.widthInPixels+30)/2
  _.mapGroup.y=20
  layer.resizeWorld();
  layer.y=100

createDungeon = ->
  # create Leaf Based Dungeon - refactor into helper function
  _.mapGroup = _.add.group()
  _.floor = new Leaf(0,0,_.floorSize,_.floorSize)
  _.quads.push(_.floor)
  _.quads.withRooms = []

  did_split = true
  # we loop through every Leaf in our Vector over and over again, until no more Leafs can be split.
  while (did_split)
    did_split = false
    for l in _.quads
      if !l.leftChild? and !l.rightChild? # if this Leaf is not already split...
        # if this Leaf is too big, or 75% chance...
        if l.width > 10 or l.height > 10 or Math.random() > 0.25
          if l.split() # split the Leaf!
            # if we did split, push the child leafs to the Vector so we can loop into them next
            _.quads.push(l.leftChild)
            _.quads.push(l.rightChild)
            did_split = true

  _.floor.createRooms()
  for quad in _.quads
    if quad.room?
      _.quads.withRooms.push quad
  _.quads.withRooms[0].room.player = true
  _.currentRoom = _.quads.withRooms[0]

  for hall in _.currentRoom.halls
    if hall[0].x > _.currentRoom.room.x
      _.currentRoom.room.doors.right = true 
      break
    if hall[0].y < _.currentRoom.room.y
      _.currentRoom.room.doors.top = true 
      break
    if hall[0].x < _.currentRoom.room.x
      _.currentRoom.room.doors.left = true 
      break
    if hall[0].y > _.currentRoom.room.y
      _.currentRoom.room.doors.bottom = true 
      break