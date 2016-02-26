class Room
  constructor: () ->
    options     = options or {}
    @gravity    = options.gravity or false # Could be "up", "down", "left", "right" or false
    @height     = options.height or 6
    @width      = options.width or 6
    @spriteGroup  = _.add.group()
    @grid       = []
    @directions =
      up:         { x: 0, y:-1 }
      upRight:    { x: 1, y: 1 }
      right:      { x: 1, y: 0 }
      downRight:  { x: 1, y:-1 }
      down:       { x: 0, y: 1 }
      downLeft:   { x:-1, y: 1 }
      left:       { x:-1, y: 0 }
      upLeft:     { x:-1, y:-1 }

  create: (sizeX=6, sizeY=6) ->
    # set size of room
    @setSize()
    @createTiles()
    _.Background.create()
    _.Player.spawn()
    @checkMatches()
    fadeIn()
    doNextAction()
    _.Interface.newDoors()
    _.Interface.drawMinimap()
    
  setSize: ->
    # scale the tiles based on the size of the canvas and number of tiles
    sizeX   = _.rnd.integerInRange(4,7)
    sizeY   = sizeX
    @width  = sizeX; @height = sizeY
    _.tSize = (canvasSize//@width)*.85
    @top    = _.tSize/2 + (_.height-_.tSize*@height)/2
    @left   = _.tSize/2 + (_.width-_.tSize*@width)/2
    # shift grid to bottom/right based on orientation
    if _.width > _.height
      @left += (_.width-_.tSize*(@width+1))/2
    else
      @top += (_.height-_.tSize*(@height+1))/2.4

    @right  = @left+(_.tSize*@width)
    @bottom = @top+(_.tSize*@height)
    @midX   = @left+(_.tSize*@width/2)
    @midY   = @top+(_.tSize*@height/2)

  createTiles: ->
    _.gridMoving = false
    _.lTile      = null
    # create tile array object to hold data for each tile
    for i in [0...@width]
      @grid[i]=[]
    for x in [0...@height]
      for y in [0...@width]
        @grid[x][y] = new Tile(x, y, @)

  coordsInWorld: (coords) ->
    coords.x >= 0 and coords.y >= 0 and coords.x < @width and coords.y < @height

  getTile: (coords) ->
    if @coordsInWorld(coords)
      @grid[coords.x][coords.y]
    else
      false

  neighbourOf: (tile, direction) ->
    targetCoords = tile.relativeCoordinates(direction, 1)
    @getTile targetCoords

  neighboursOf: (tile) ->
    result = {}
    for directionName of @directions
      result[directionName] = @neighbourOf(tile, @directions[directionName])
    result

  getMatches: ->
    checked = []
    matches = []
    for x in @grid
      for tile in x
        if checked.indexOf(tile) is -1
          match = tile.deepMatchingNeighbours()
          for j of match
            checked.push match[j]
          matches.push match  if tile.type isnt -1 if match.length >= 3
    return false  if matches.length is 0
    matches

  checkMatches: ->
    # get all the current matches and reset the tile booleans
    @spriteGroup.callAll("resetMatch")
    # set a boolean if a tile has a possible match or:
    for match in @getMatches()
      for tile in match
        tile.hasMatch = true
    # that match is selected in the path
    for match in _.Path.matches
      if match.length < 3
        match = []
        _.Path.matches.pop()
      for tile in match
        tile.isMatched = true
    _.Path.drawArrow()
    @spriteGroup.callAll("destroyIfLone")
