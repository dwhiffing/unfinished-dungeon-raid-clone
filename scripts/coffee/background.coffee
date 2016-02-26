class Background
  constructor: ->
    @group     = _.add.group()
    @grid = _.add.graphics(0,0)
    _.stage.backgroundColor = '#22211f';

  create: ->
    # draw background grid
    @grid.clear()
    @grid.lineStyle 1,0x000000
    xPos = _.Room.left-_.tSize/2; yPos = _.Room.top-_.tSize/2
    for row in [0.._.Room.width]
      @grid.moveTo xPos, yPos + row*_.tSize
      @grid.lineTo xPos + _.Room.width*_.tSize, yPos + row*_.tSize
    for col in [0.._.Room.height]
      @grid.moveTo xPos + col*_.tSize, yPos
      @grid.lineTo xPos + col*_.tSize, yPos + _.Room.height*_.tSize
    
    # draw side tiles
    for num in [-1.._.Room.height]
      side       = _.add.sprite(_.Room.left-_.tSize, _.Room.top+num*_.tSize, "side")
      side2      = _.add.sprite(_.Room.left+_.Room.height*_.tSize, _.Room.top+num*_.tSize, "side")
      setSize(side,_.tSize)
      setSize(side2,_.tSize)
      @group.add(side)
      @group.add(side2)
    
    # draw top tiles
    for num in [-1.._.Room.width]
      top        = _.add.sprite(_.Room.left+num*_.tSize, _.Room.top-_.tSize, "top" )
      top2       = _.add.sprite(_.Room.left+num*_.tSize, _.Room.top+_.tSize*_.Room.height, "top" )
      setSize(top,_.tSize)
      setSize(top2,_.tSize)
      @group.add(top)
      @group.add(top2)
      
    # draw Room tiles
    for row in [0.._.Room.width-1]
      for tile in [0.._.Room.height-1]
        bg       = _.add.sprite(_.Room.left+row*_.tSize, _.Room.top+tile*_.tSize, "bg-tiles")
        bg.frame = _.rnd.integerInRange(0,3)
        setSize(bg,_.tSize)
        @group.add bg

