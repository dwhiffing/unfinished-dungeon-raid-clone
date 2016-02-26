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
      color = "#ff00ff" if tile.isMatched && !tile.inMatch
      color = "#0000ff" if tile.inMatch
      
      _.debug.renderText tile.t.x+","+tile.t.y, tX, tY-tS, color, tS+"px Courier"
      
      _.debug.renderText tile.type, tX, tY, color, tS+"px Courier"

drawArrow = ->
  resetArrow()
  # console.log _.matches if _.matches.length >0
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
  _.lTile = null; _.uiFade.alpha = 0.4

walkPath = ->
  if _.lTile? && checkPath() && _.path.length > 1
    _.time.events.add 1000, setPlayerCoords
    _.tilesToPop.push _.path.shift().t  while _.path.length > 0
  resetPath()
  resetCombo()
  _.time.events.add _.popTime, doNextAction

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

initLine = (line,width,color,x,y) ->
  line.lineStyle width,color; 
  line.moveTo(x,y) if x? and y?

checkPath = ->
  _.path.length>3 || _.lTile.type is -1 && _.numMatched>2 || _.numMatched is 0

resetPath = ->
  _.tiles.callAll "deselect"; _.uiFade.alpha = 0; resetArrow();_.path = [_.hero]; _.numMatched = 0; _.matches = []

checkArrowColour = (tile) ->
  return "0xFFFFFF "if !tile.inMatch
  switch tile.type
    when -1 then "0xFFFFFF"
    when 1 then "0xFF0000"
    when 2 then "0x00FF00"
    when 3 then "0x0000FF"
    when 4 then "0xFFFF00"
    when 5 then "0xF0F000"
    else "0xFF00FF"