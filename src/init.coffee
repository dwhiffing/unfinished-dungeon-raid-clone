createGame = ->
  setRoomSize()
  initBG()
  initGrid()
  initUI()
  newRoom()

initBG = ->
  _.bgGroup  = _.add.group();  
  _.tileGrid = _.add.graphics(0, 0);
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
  setSize _t.o, _.tSize-20
  _t.o.angle = Math.random() * (3 - (-3))
  pulseTile _t.o; _.tiles.add _t.o
  _t.o.inputEnabled = true
  _t.o.events.onInputOver.add checkCollisions, this
  
  _t.o.destroy = ->
    increaseScore()
    destroyTween(_t.o)
    _.combo++ if _.combo < 15
    @isMatched = false

  _t.o.select = ->
    if not @selected
      if @type isnt -1
        _.numMatched++; @alpha = 0.5
      _.path.push this; _.lTile = this; @selected = true;
      debugger
      checkMatches()


  _t.o.deselect = ->
    if @selected
      if @type isnt -1
        _.numMatched--; @alpha = 1 
      @selected = false
      if _.matches.length > 0
        if @inMatch
          _.matches[_.matches.length-1].pop() 


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
