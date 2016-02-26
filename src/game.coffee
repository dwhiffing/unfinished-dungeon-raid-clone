doNextAction = -> 
  if _.tilesToPop and _.tilesToPop.length > 0
    popTile()
    _.time.events.add _.popTime, doNextAction
  else
    if _.tileArray.getMatches()
      _.gridMoving = false
    else
      _.time.events.add 500, -> 
        _.tiles.callAll("destroy")
        _.sound.play "new"
        fadeOut()
        _.time.events.add 2000, newRoom 

popTile = ->
  _.gridMoving = true
  
  tile = _.tilesToPop.shift()
  if tile is _.hero.t
    _.lTile = tile.o
    tile = _.tilesToPop.shift()
  if tile? and tile.o.inMatch or tile.o.type is -1
    if tile.o.type isnt -1
      tile.o.destroy() 
      _.time.events.add _.popTime/2, -> _.sound.play "pop"+_.combo
    moveHero(tile.o.x, tile.o.y)
    _.hero.t = tile
    _.lTile = tile.o
    _.time.events.add _.popTime, setPlayerCoords
    _.hero.t.x = tile.o.t.x
    _.hero.t.y = tile.o.t.y

setPlayerCoords = ->
  _.hero.t.type = -1
  tile = _.tileArray.getPiece(x: _.hero.t.x, y: _.hero.t.y )
  tile.o.reset()
  _.tiles.callAll "updateType"
  # _.lTile.type = -1 if _.lTile
  tile.o.type = 0

checkCollisions = (tile) ->
  if _.uiFade.alpha is 0.4
    if !_.lTile or tile.t isnt _.lTile.t
      unless tile.selected
        checkAdjacent tile
      else
        deselectBefore tile

checkAdjacent = (nTile) ->
  if _.lTile? # if at least one tile has been selected, store its coords.
    neighbours = _.lTile.t.neighbours()
    for dir of neighbours # check neighbours to see if tile is present
      if nTile.t isnt _.hero.t
        if nTile.t is neighbours[dir]
          if match(nTile, _.lTile) or (_.matches.length>0 && _.lTile.inMatch)
            nTile.select() 
            doMatch(nTile) if _.numMatched >= 3
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

spawnPlayer = ->
  tX = _.rnd.integerInRange(0,_.rSize)
  tY = _.rnd.integerInRange(0,_.cSize)
  _.hero.t = _.tileArray.getPiece(x: tX, y: tY )
  _.hero.x = _.hero.t.o.x
  _.hero.y = _.hero.t.o.y
  resetPath()
  _.uiFade.alpha=1
  setPlayerCoords()

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

setRoomSize = ->
  # scale the tiles based on the size of the canvas and number of tiles
  # _.rSize      = _.rnd.integerInRange(4,7)
  _.rSize      = 5
  _.cSize      = _.rSize
  _.tSize      = _.width//_.rSize
  # place grid in the center of the screen
  _.startX     = _.tSize/2 + (_.width-_.tSize*_.rSize)/2
  _.startY     = _.tSize/2 + (_.height-_.tSize*_.cSize)/2
  

spawnTile = (tile) ->
  tile.selected = false; 

  tile.o.type   = _.rnd.integerInRange 1, _.numTypes
  tile.o.frame  = tile.o.type - 1
  tile.o.alpha  = 1
  setSize tile.o, 1
  tile.o.isMatched=false

checkMatches = ->
  matches = _.tileArray.getMatches()
  _.tiles.setAll("isMatched", false)
  for match in matches
    for tile in match
      tile.o.isMatched = true

  _.tiles.setAll("inMatch", false)
  for match in _.matches
    if match.length < 3
      match = [] 
      _.matches.pop()
    for tile in match
      tile.inMatch = true
  drawArrow()  

doMatch = (tile) ->
  console.log "As"
  if _.matches[0] and tile.type is (_.matches[_.matches.length-1])[0].type
      _.matches[_.matches.length-1].push(tile)
      tile.inMatch = true
  else
    match = []
    matchType = _.lTile.type
    
    for tile in _.path
      if tile.type is matchType and not tile.inMatch
        match.push tile 
        tile.inMatch = true
    
    _.matches.push(match) if match.length >= 3
    checkMatches()
