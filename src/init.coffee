createGame = ->
  setRoomSize();
  Dungeon.Generate()
  initBG();
  initTileGrid();
  initUI();
  newRoom();

setRoomSize = ->
  # scale the tiles based on the size of the canvas and number of tiles
  # _.rSize      = _.rnd.integerInRange(4,7)
  _.rSize      = 6
  _.cSize      = _.rSize
  _.tSize      = (canvasSize//_.rSize)*.95
  # place grid in the center of the screen
  _.startX     = _.tSize/2 + (_.width-_.tSize*_.rSize)/2
  _.startY     = (_.tSize/2 + (_.height-_.tSize*_.cSize)/2)+100

initBG = ->
  _.bgGroup  = _.add.group()
  _.tileGrid = _.add.graphics(0, 0)
  _.stage.backgroundColor = "#343435"

  # draw background grid
  initLine(_.tileGrid,1,0x000000,0,0)
  xPos = _.startX-_.tSize/2; yPos = _.startY-_.tSize/2
  for row in [0.._.rSize]
    _.tileGrid.moveTo xPos, yPos + row*_.tSize
    _.tileGrid.lineTo xPos + _.rSize*_.tSize, yPos + row*_.tSize
  for col in [0.._.cSize]
    _.tileGrid.moveTo xPos + col*_.tSize, yPos
    _.tileGrid.lineTo xPos + col*_.tSize, yPos + _.cSize*_.tSize
  
  # draw side tiles
  for num in [0.._.rSize-1]
    side       = _.add.sprite(_.startX-35, _.startY+num*_.tSize, "side")
    side2       = _.add.sprite(_.startX+_.cSize*_.tSize-25, _.startY+num*_.tSize, "side")
    setSize(side,_.tSize)
    setSize(side2,_.tSize)
    side.width = _.tSize/4
    side2.width = _.tSize/4
    _.bgGroup.add(side)
    _.bgGroup.add(side2)
  
  # draw top tiles
  for num in [-1.._.cSize]
    top        = _.add.sprite(_.startX+num*_.tSize, _.startY-_.tSize, "top" )
    top2       = _.add.sprite(_.startX+num*_.tSize, _.startY+_.tSize*_.cSize, "top" )
    setSize(top,_.tSize)
    setSize(top2,_.tSize)
    _.bgGroup.add(top)
    _.bgGroup.add(top2)

initUI = ->
  _.fgGroup = _.add.group();
  _.mapGroup = _.add.group();

  # setup basic gameplay input events
  _.input.onDown.add startPath, this
  _.input.onUp.add walkPath, this

  # create player
  _.hero   = _.add.sprite(-20, -20, "player");
  setSize _.hero, _.tSize/2
  _.fgGroup.add _.hero

  # create overlay to fade between levels
  _.uiFade = _.add.graphics(0, 0);
  _.uiFade.beginFill 0x000000; _.uiFade.alpha = 1
  _.uiFade.drawRect 0, 0, _.width, _.height
  _.fgGroup.add _.uiFade

  # load generated map data and create tilemap for minimap of dungeon
  _.cache._tilemaps.mapData.data.layers[0].data = _.mapData
  _.tilemap    = _.add.tilemap("mapData")
  _.tilemap.addTilesetImage(0, "mapImage");
  layer = _.tilemap.createLayer(0,_.width,_.height,_.mapGroup);
  _.mapGroup.x=_.width/2-(_.tilemap.widthInPixels+30)/2
  _.mapGroup.y=20
  # layer.resizeWorld();
  # layer.y=100
  console.log _.tilemap

  # fullscreen button
  fullscreen = _.add.sprite(20,20, "minimap")
  fullscreen.inputEnabled = true
  fullscreen.events.onInputDown.add goFull, this
  _.stage.fullScreenScaleMode = Phaser.StageScaleMode.SHOW_ALL
