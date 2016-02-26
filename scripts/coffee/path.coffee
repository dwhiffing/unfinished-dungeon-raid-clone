class Path
  constructor: (X,Y) ->
    @x       = X
    @y       = Y
    @data    = [_.Player]
    @sprites = []
    @matches = []
    @toPop   = []
    _.input.onDown.add @startPath, this
    _.input.onUp.add @walkPath, this

  checkAdjacent: (nTile) ->
    if _.Interface.overlay.alpha > 0 
      if _.lTile? # if at least one tile has been selected, store its coords.
        neighbours = _.lTile.neighbours()
        for dir of neighbours # check neighbours to see if tile is present
          if nTile isnt _.Player
            if nTile is neighbours[dir]
              if match(nTile, _.lTile) or (@matches.length>0 && _.lTile.isMatched)
                nTile.select()
                @doMatch(nTile) if _.numMatched >= 3
          else
            @deselectBefore _.Player.tile
      else # select player if path is empty
        nb = _.Player.tile.neighbours()
        for dir of nb
          nTile.select() if nb[dir] is nTile and @data.length is 1

  deselectBefore: (tile) ->
    p = @data.length - 1
    while p >= 0
      if tile is @data[p] or tile is _.Player.tile
        o = @data.length - 1
        while o > p
          @data[o].deselect(); @data.splice o, 1
          l = @data.length
          if l > 0 then _.lTile = @data[l-1] else _.lTile = null
          o--
      p--
    _.Room.checkMatches()

  doMatch: (tile) ->
    # if tile is the same type as our last matched tile, add it to that match
    if @matches[0] and tile.type is last(last(@matches)).type
        last(@matches).push(tile)
        tile.isMatched = true
    else # else attempt to create a new match
      match = []
      matchType = _.lTile.type
      for tile in @data
        if tile.type is matchType and not tile.isMatched
          match.push tile
          tile.isMatched = true
      # add it if it is large enough then check the current state of matches
      @matches.push(match) if match.length >= 3

  popTile: ->
    _.gridMoving = true
    if _.popTime>= 100 then _.popTime-=10 else _.popTime = 100
    # grab a tile from the beginning of the path
    tile = @toPop.shift()
    # if the tile is the player, get the next one
    if tile is _.Player
      _.lTile = tile.sprite
      tile = @toPop.shift()
    # play an animation/sound, move the player, and increase the score
    if tile? and tile.isMatched or tile.type is -1
      if tile.type isnt -1 
        tile.destroy()
        # _.time.events.add _.popTime/2, -> _.sound.play "pop"+_.combo
      moveHero(tile.sprite.x, tile.sprite.y)
      _.Player.tile.type = -1
      _.Player.tile = tile
      _.lTile = tile.sprite
      _.time.events.add _.popTime, setPlayerCoords
      # _.Player.tile.x = tile.sprite.x
      # _.Player.tile.y = tile.sprite.y
      increaseScore()

  checkPath: ->
    @data.length>3 || _.lTile.type is -1 && _.numMatched>2 || _.numMatched is 0

  resetArrow: ->
    for arrow in @sprites
      arrow.destroy()

  resetPath: ->
    _.Room.spriteGroup.callAll "deselect"
    _.Interface.overlay.alpha = 0
    @resetArrow()
    @data = [_.Player]
    _.numMatched = 0
    @matches = []

  startPath: ->
    _.lTile = null; _.Interface.overlay.alpha = 0.4;

  walkPath: ->
    _.popTime = _.maxPopTime
    if _.lTile? && @checkPath() && @data.length > 1
      _.time.events.add _.popTime, setPlayerCoords
      @toPop.push @data.shift()  while @data.length > 0
    resetCombo()
    @resetPath()
    _.time.events.add _.popTime, doNextAction

  drawArrow: ->
    @resetArrow()
    for tile of @data
      @lineToTile(tile) if tile > 0
      # drawMatchCircle if @data[tile]

  lineToTile: (index) ->
    tile = _.Path.data[index]
    tile2 = _.Path.data[index-1]
    arrow  = _.add.graphics(0, 0);
    _.Interface.group.add arrow
    arrow.lineStyle 2, @checkArrowColour(tile)
    arrow.moveTo tile2.sprite.x,tile2.sprite.y
    arrow.lineTo tile.sprite.x,tile.sprite.y
    _.Path.sprites.push arrow

  checkArrowColour: (tile) ->
    return "0xFFFFFF" if !tile.isMatched
    switch tile.type
      when -1 then "0xFFFFFF"
      when 1 then "0xFF0000"
      when 2 then "0x00FF00"
      when 3 then "0x0000FF"
      when 4 then "0xFFFF00"
      when 5 then "0xF0F000"
      else "0xFF00FF"