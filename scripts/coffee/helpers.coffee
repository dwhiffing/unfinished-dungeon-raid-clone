debugTiles = ->
  # debug info about each tile's index and type
  if _.Interface.overlay.alpha is 0.4 or _.Interface.overlay.alpha is 0 or true
    for x in _.Room.grid 
      for tile in x
        tX = (_.Room.left + tile.x * _.tSize)-_.tSize/2.2
        tY = (_.Room.top + tile.y * _.tSize)-_.tSize/3
        tS = ( canvasSize / 20)/2

        color = "#fff"
        color = "#ff0000" if tile.type is -1
        color = "#00ff00" if tile.type is 0
        color = "#ff00ff" if tile.hasMatch && !tile.isMatched
        color = "#0000ff" if tile.isMatched

        _.debug.renderText tile.x+","+tile.y, tX, tY-tS, color, tS+"px Courier"
        _.debug.renderText tile.type, tX, tY, color, tS+"px Courier"

doNextAction = ->
  if _.Path.toPop and _.Path.toPop.length > 0
    _.Path.popTile()
    _.time.events.add _.popTime, doNextAction
  else
    if _.Path.matches.length > 0
      _.Room.checkMatches()
      resetPath()
    if _.Room.getMatches()
      _.gridMoving = false
    # _.time.events.add _.popTime, doNextAction
    else
      _.Interface.unlockDoors()

setPlayerCoords = ->
  _.Player.tile.reset()
  _.Room.spriteGroup.callAll "updateType"
  _.lTile.type = -1 if _.lTile
  _.Player.tile.type = 0

checkCollisions = (sprite) ->
  if _.Interface.overlay.alpha is 0.4
    tile = sprite.tile
    if !_.lTile or tile isnt _.lTile
      unless tile.selected
        _.Path.checkAdjacent tile
        _.Room.checkMatches()
      else
        _.Path.deselectBefore tile

increaseCombo = ->
  _.combo++
  _.time.events.remove _.comboTimer if _.comboTimer? and _.comboTimer.timer.length > 0
  _.comboTimer = _.time.events.add(_.comboTime, resetCombo)

resetCombo = ->
  _.combo = 1

checkForFalling = ->
  _.fallTiles = _.room.grid.applyGravity()

increaseScore = ->
  basePoints = 10; _.score += basePoints * _.combo

setSize = (o,s) ->
  o.anchor.setTo 0.5, 0.5; o.width = s; o.height = s;

match = (_a,_b) ->
  _a.type is _b.type or _b.type is 0 or _b.type is -1

last = (arr) -> 
  arr[arr.length-1]

getRandom = (low, high) ->
  ~~(Math.random() * (high - low)) + low

goFull = ->
  _.stage.scale.startFullScreen()
