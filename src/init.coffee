setRoomSize = ->
  # scale the tiles based on the size of the canvas and number of tiles
  # _.rSize      = _.rnd.integerInRange(4,7)
  _.rSize      = 6
  _.cSize      = _.rSize
  _.tSize      = (canvasSize//_.rSize)*.85
  # place grid in the center of the screen
  _.startX     = _.tSize/2 + (_.width-_.tSize*_.rSize)/2
  _.startY     = _.tSize/2 + (_.height-_.tSize*_.cSize)/2
  # shift grid to bottom/right based on orientation
  if _.width > _.height
    _.startX += (_.width-_.tSize*(_.rSize+1))/2
  else
    _.startY += (_.height-_.tSize*(_.cSize+1))/2.4

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
    side       = _.add.sprite(_.startX-_.tSize, _.startY+num*_.tSize, "side")
    side2       = _.add.sprite(_.startX+_.cSize*_.tSize, _.startY+num*_.tSize, "side")
    setSize(side,_.tSize)
    setSize(side2,_.tSize)
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
    
  # draw room tiles
  for row in [0.._.rSize-1]
    for tile in [0.._.cSize-1]
      bg       = _.add.sprite(_.startX+row*_.tSize, _.startY+tile*_.tSize, "bg-tiles")
      bg.frame = _.rnd.integerInRange(0,3)
      setSize(bg,_.tSize)
      _.bgGroup.add bg

initTileGrid = ->
  _.gridMoving = false
  _.lTile      = null
  _.tiles      = _.add.group()
  
  # create tile array object to hold data for each tile
  _.tileArray  = new jMatch3.Grid(width: _.rSize, height: _.cSize)
  for row in [0..._.rSize]
    for col in [0..._.cSize]
      initTile _.tileArray.getPiece({x:row,y:col})
  _.bgGroup.add _.tileGrid
  _.tileArray.top = _.startY
  _.tileArray.left = _.startX
  _.tileArray.right = _.startX+(_.tSize*_.rSize)
  _.tileArray.bottom = _.startY+(_.tSize*_.cSize)
  _.tileArray.midX = _.startX+(_.tSize*_.rSize/2)
  _.tileArray.midY = _.startY+(_.tSize*_.cSize/2)

initUI = ->
  _.fgGroup = _.add.group()

  # create first floor
  _.leafGraphics = _.add.graphics(150,20)
  _.leafGraphics.lineStyle 1, 0xff0000
  _.fgGroup.add _.leafGraphics

  _.roomGraphics = _.add.graphics(150,20)
  _.roomGraphics.beginFill 0xffffff
  _.fgGroup.add _.roomGraphics

  _.hallGraphics = _.add.graphics(150,20)
  _.hallGraphics.beginFill 0xaaaaaa
  _.fgGroup.add _.hallGraphics

  doorCoords = [ { x:_.tileArray.midX,  y:_.tileArray.top-_.tSize/2, dir: "top" }, 
                 { x:-_.tileArray.left-5,  y:_.tileArray.midY, dir: "left" }, 
                 { x:_.tileArray.right+_.tSize/2, y:_.tileArray.midY, dir: "right" }, 
                 { x:_.tileArray.midX,  y:_.tileArray.bottom-_.tSize/2, dir: "bottom" } ]

  for i in doorCoords
    door = _.add.sprite(i.x,i.y,"door")
    setSize(door,_.tSize)
    door.anchor.setTo(.5,  1) if i.dir is "top"
    door.anchor.setTo(.5,  0) if i.dir is "bottom"
    door.anchor.setTo( 1, .5) if i.dir is "right"
    door.anchor.setTo( 0, .5) if i.dir is "left"
    door.inputEnabled = true
    door.events.onInputDown.add checkDoor, this
    _.fgGroup.add door
    _.doors.push door

  createDungeon()
  drawMinimap()

  for quad in _.quads.withRooms
    console.log quad.halls

  # createOldDungeon()

  # setup basic gameplay input events
  _.input.onDown.add startPath, this
  _.input.onUp.add walkPath, this

  # create player
  _.hero   = _.add.sprite(-20, -20, "player");
  setSize _.hero, _.tSize/2
  _.fgGroup.add _.hero

  # fullscreen button
  fullscreen = _.add.sprite(20,20, "fs")
  setSize(fullscreen,_.tSize/2)
  fullscreen.inputEnabled = true
  fullscreen.events.onInputDown.add goFull, this
  _.stage.fullScreenScaleMode = Phaser.StageScaleMode.SHOW_ALL
  _.fgGroup.add fullscreen

  # create overlay to fade between levels
  _.uiFade = _.add.graphics(0, 0);
  _.uiFade.beginFill 0x000000; _.uiFade.alpha = 1
  _.uiFade.drawRect 0, 0, _.width,_.height
  _.fgGroup.add _.uiFade
