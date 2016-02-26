initTile = (_t) ->
  # place tile according to start position and size of grid, reference data object
  xPos        = _.startX + _.tSize * _t.x
  yPos        = _.startY + _.tSize * _t.y
  _t.o        = _.add.sprite(xPos, yPos, "tile")
  _t.o.t      = _t;
  # size tiles according to scale of window
  setSize _t.o, _.tSize*0.7
  # set up pulse animation
  _t.o.angle = Math.random() * (3 - (-3))
  pulseTile _t.o; 
  # add to display group
  _.tiles.add _t.o
  # add touch event for path drawing
  _t.o.inputEnabled = true
  _t.o.events.onInputOver.add checkCollisions, this

  _t.o.destroy = ->
    destroyTween(_t.o)
    _.combo++ if _.combo < 15
    @hasMatch = false
    @isMatched = false

  _t.o.select = ->
    if not @selected
      if @type isnt -1
      # only effect non-empty tiles
        _.numMatched++; @alpha = 0.5
      # add this tile to the path
      _.path.push this; _.lTile = this; @selected = true;
  _t.o.deselect = ->
    if @selected
      @selected = false
      # only effect non-empty tiles
      if @type isnt -1
        _.numMatched--
        @alpha = 1
      # remove this tile from the path if its deselected
      if _.pathMatches.length > 0 && @isMatched
        last(_.pathMatches).pop()

  _t.o.destroyIfLone = (tile) ->
    if !@hasMatch
      @destroy() 

  _t.o.reset = -> @alpha = 0; @type = -1

  _t.o.updateType = -> @type = -1  if @alpha < 1
  
popTile = ->
  _.gridMoving = true
  if _.popTime>= 100 then _.popTime-=10 else _.popTime = 100
  # grab a tile from the beginning of the path
  tile = _.tilesToPop.shift()
  # if the tile is the player, get the next one
  if tile is _.hero.t
    _.lTile = tile.o
    tile = _.tilesToPop.shift()
  # play an animation/sound, move the player, and increase the score
  if tile? and tile.o.isMatched or tile.o.type is -1
    if tile.o.type isnt -1 
      tile.o.destroy()
      # _.time.events.add _.popTime/2, -> _.sound.play "pop"+_.combo
    moveHero(tile.o.x, tile.o.y)
    _.hero.t = tile
    _.lTile = tile.o
    _.time.events.add _.popTime, setPlayerCoords
    _.hero.t.x = tile.o.t.x
    _.hero.t.y = tile.o.t.y
    increaseScore()
    