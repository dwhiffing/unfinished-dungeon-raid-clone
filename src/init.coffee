createGame = -> setRoomSize(); initBG(); initGrid(); initUI(); newRoom();

setRoomSize = ->
  # scale the tiles based on the size of the canvas and number of tiles
  # _.rSize      = _.rnd.integerInRange(4,7)
  _.rSize      = 7

  _.cSize      = _.rSize
  _.tSize      = _.width//_.rSize
  _.tSize      = 5 if _.tSize <5
  # place grid in the center of the screen
  _.startX     = _.tSize/2 + (_.width-_.tSize*_.rSize)/2
  _.startY     = _.tSize/2 + (_.height-_.tSize*_.cSize)/2

initBG = ->
  _.bgGroup  = _.add.group()
  _.tileGrid = _.add.graphics(0, 0)
  _.bgGroup.add _.tileGrid
  _.stage.backgroundColor = "#343435"
  initLine(_.tileGrid,1,0x000000,0,0)
  xPos = _.startX-_.tSize/2; yPos = _.startY-_.tSize/2
  # draw background grid
  for row in [0.._.rSize+1]
    _.tileGrid.moveTo xPos, yPos + row*_.tSize
    _.tileGrid.lineTo xPos + _.rSize*_.tSize, yPos + row*_.tSize
  for col in [0.._.cSize]
    _.tileGrid.moveTo xPos + col*_.tSize, yPos
    _.tileGrid.lineTo xPos + col*_.tSize, yPos + _.cSize*_.tSize

initGrid = ->
  _.gridMoving = false
  _.lTile      = null
  _.tiles      = _.add.group()
  _.tileArray  = new jMatch3.Grid(width: _.rSize, height: _.cSize)
  for row in [0..._.rSize]
    for col in [0..._.cSize]
      initTile _.tileArray.getPiece({x:row,y:col})

initTile = (_t)->
  xPos       = _.startX + _.tSize * _t.x
  yPos       = _.startY + _.tSize * _t.y
  _t.o       = _.add.sprite(xPos, yPos, "tile") 
  _t.o.t     = _t; 
  setSize _t.o, _.tSize*0.7
  _t.o.angle = Math.random() * (3 - (-3))
  pulseTile _t.o; _.tiles.add _t.o
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

initUI = ->
  _.fgGroup = _.add.group();

  _.input.onDown.add startPath, this
  _.input.onUp.add walkPath, this

  _.hero   = _.add.sprite(-20, -20, "player");
  setSize _.hero, _.tSize/2
  _.fgGroup.add _.hero

  _.uiFade = _.add.graphics(0, 0);
  _.uiFade.beginFill 0x000000; _.uiFade.alpha = 1
  _.uiFade.drawRect 0, 0, _.width, _.height
  _.fgGroup.add _.uiFade

  _.miniMap  = _.add.graphics(0, 0)
  _.fgGroup.add _.miniMap
