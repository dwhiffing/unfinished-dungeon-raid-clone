initTileGrid = ->
  _.gridMoving = false
  _.lTile      = null
  _.tiles      = _.add.group()
  
  # create grid of tiles
  _.tileArray  = new jMatch3.Grid(width: _.rSize, height: _.cSize)
  for row in [0..._.rSize]
    for col in [0..._.cSize]
      initTile _.tileArray.getPiece({x:row,y:col})
  _.bgGroup.add _.tileGrid

initTile = (_t) ->
  xPos       = _.startX + _.tSize * _t.x
  yPos       = _.startY + _.tSize * _t.y
  _t.bg       = _.add.sprite(xPos, yPos, "bg-tiles")
  _t.bg.frame = _.rnd.integerInRange(0,3)
  _.bgGroup.add _t.bg
  setSize(_t.bg,_.tSize)
  _t.o       = _.add.sprite(xPos, yPos, "tile")
  _t.o.t     = _t;
    
  setSize _t.o, _.tSize*0.7
  _t.o.angle = Math.random() * (3 - (-3))
  pulseTile _t.o; 
  _.tiles.add _t.o
  _t.o.inputEnabled = true
  _t.o.events.onInputOver.add checkCollisions, this

  _t.o.destroy = ->
    increaseScore()
    destroyTween(_t.o)
    _.combo++ if _.combo < 15
    @hasMatch = false
    @isMatched = false

  _t.o.select = ->
    if not @selected
      if @type isnt -1
        _.numMatched++; @alpha = 0.5
      _.path.push this; _.lTile = this; @selected = true;
  _t.o.deselect = ->
    if @selected
      @selected = false
      if @type isnt -1
        _.numMatched--
        @alpha = 1
      if _.pathMatches.length > 0 && @isMatched
        last(_.pathMatches).pop()

  _t.o.reset = ->
    @alpha = 0; @type = -1

  _t.o.updateType = ->
    @type = -1  if @alpha < 1
  
popTile = ->
  _.gridMoving = true
  if _.popTime>= 100 then _.popTime-=10 else _.popTime = 100
  tile = _.tilesToPop.shift()
  if tile is _.hero.t
    _.lTile = tile.o
    tile = _.tilesToPop.shift()
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