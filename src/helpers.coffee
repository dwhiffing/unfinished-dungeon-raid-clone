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