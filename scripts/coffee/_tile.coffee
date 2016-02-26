class Tile
  constructor: (_x,_y, grid) ->
    # place tile according to start position and size of grid, reference data object
    @x            = _x
    @y            = _y
    @grid         = grid
    xPos          = _.Room.left + _.tSize * @x
    yPos          = _.Room.top + _.tSize * @y
    @sprite       = _.Room.spriteGroup.create(xPos, yPos, "tile")
    @sprite.tile  = this
    @type         = -1
    @hasMatch     = false
    @isMatched    = false
    @selected    = false
    # size tiles according to scale of window
    setSize @sprite, _.tSize*0.7
    # set up pulse animation
    @sprite.angle = Math.random() * (3 - (-3))
    pulseTile @sprite; 
    @sprite.inputEnabled = true
    @sprite.events.onInputOver.add checkCollisions, this
    @type = _.rnd.integerInRange(1,_.numTypes)
    @sprite.frame = @type-1
    @sprite.updateType = -> @tile.updateType()
    @sprite.deselect = -> @tile.deselect()
    @sprite.destroy = -> @tile.destroy()
    @sprite.destroyIfLone = -> @tile.destroyIfLone()
    @sprite.resetMatch = -> @tile.resetMatch()

  select: ->
    if not @selected
      if @type isnt -1
        # only effect non-empty tiles
        _.numMatched++; @alpha = 0.5
      # add this tile to the path
      _.Path.data.push this 
      _.lTile = this
      @selected = true

  deselect: ->
    if @selected
      @selected = false
      # only effect non-empty tiles
      if @type isnt -1
        _.numMatched--
        @alpha = 1
      # remove this tile from the path if its deselected
      if _.Path.matches.length > 0 && @isMatched
        last(_.Path.matches).pop()

  destroy: ->
    destroyTween(@sprite)
    _.combo++ if _.combo < 15
    @hasMatch = false
    @isMatched = false
    @type = -1

  relativeCoordinates: (direction, distance) ->
    x: @x + distance * direction.x
    y: @y + distance * direction.y

  destroyIfLone: (tile) ->
    @destroy() if !@hasMatch

  reset: -> 
    @sprite.alpha = 0; @type = -1

  resetMatch: -> 
    @hasMatch = false; @isMatched = false;

  updateType: ->
    @type = -1  if @sprite.alpha < 1

  clear: ->
    @reset()

  neighbour: (direction) ->
    @grid.neighbourOf this, direction

  neighbours: ->
    @grid.neighboursOf this

  matchingNeighbours: ->
    matches = []
    neighbours = @neighbours()
    for direction of neighbours
      neighbour = neighbours[direction]
      matches.push neighbour  if neighbour and neighbour.type is @type
    matches

  deepMatchingNeighbours: ->
    deepMatchingNeighbours = (tile) ->
      matchingNeighbours = tile.matchingNeighbours()
      for i of matchingNeighbours
        matchingNeighbour = matchingNeighbours[i]
        if deepMatches.indexOf(matchingNeighbour) is -1
          deepMatches.push matchingNeighbour
          deepMatchingNeighbours matchingNeighbour
      return
    deepMatches = []
    deepMatchingNeighbours this
    deepMatches

