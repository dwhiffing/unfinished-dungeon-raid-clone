doNextAction = ->
  if _.tilesToPop and _.tilesToPop.length > 0
    popTile()
    _.time.events.add _.popTime, doNextAction
  else
    if _.pathMatches.length > 0
      checkMatches()
      resetPath()
    if _.tileArray.getMatches()
      _.gridMoving = false
    # _.time.events.add _.popTime, doNextAction
    else
      unlockDoors()

checkCollisions = (tile) ->
  if _.uiFade.alpha is 0.4
    if !_.lTile or tile.t isnt _.lTile.t
      unless tile.selected
        checkAdjacent tile
        checkMatches()
      else
        deselectBefore tile

checkAdjacent = (nTile) ->
  if _.lTile? # if at least one tile has been selected, store its coords.
    neighbours = _.lTile.t.neighbours()
    for dir of neighbours # check neighbours to see if tile is present
      if nTile.t isnt _.hero.t
        if nTile.t is neighbours[dir]
          if match(nTile, _.lTile) or (_.pathMatches.length>0 && _.lTile.isMatched)
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
  checkMatches()

checkMatches = ->
  # get all the current matches and reset the tile booleans
  matchesOnBoard = _.tileArray.getMatches()
  _.tiles.setAll("hasMatch", false)
  _.tiles.setAll("isMatched", false)
  # set a boolean if a tile has a possible match or:
  for match in matchesOnBoard
    for tile in match
      tile.o.hasMatch = true
  # that match is selected in the path
  for match in _.pathMatches
    if match.length < 3
      match = []
      _.pathMatches.pop()
    for tile in match
      tile.isMatched = true
  drawArrow()
  _.tiles.callAll("destroyIfLone")

doMatch = (tile) ->
  # if tile is the same type as our last matched piece, add it to that match
  if _.pathMatches[0] and tile.type is last(last(_.pathMatches)).type
      last(_.pathMatches).push(tile)
      tile.isMatched = true
  else # else attempt to create a new match
    match = []
    matchType = _.lTile.type
    for tile in _.path
      if tile.type is matchType and not tile.isMatched
        match.push tile
        tile.isMatched = true
    # add it if it is large enough then check the current state of matches
    _.pathMatches.push(match) if match.length >= 3

unlockDoors = ->
  for door in _.doors
    door.frame = 0

lockDoors = ->
  for door in _.doors
    door.frame = 1

checkDoor = (door) ->
  unless !_.tileArray.getMatches()
    _.time.events.add 500, ->
      _.tiles.callAll("destroy")
      # _.sound.play "new"
      fadeOut()
      _.time.events.add 2000, newRoom
  else
    # dont switch rooms
