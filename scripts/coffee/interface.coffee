class Interface
  constructor: ->
    @doors        = []
    @group        = _.add.group()
    @doors        = []
    @leafGraphics = _.add.graphics(150,20)
    @hallGraphics = _.add.graphics(150,20)
    @roomGraphics = _.add.graphics(150,20)
    @group.add @leafGraphics
    @group.add @hallGraphics
    @group.add @roomGraphics
    # create doors
    for i in [1..4]
      door = new Door(i)
      @group.add door.sprite
      @doors.push door
    # fullscreen button
    fullscreen = @group.create(20,100, "fs")
    setSize(fullscreen,50)
    fullscreen.inputEnabled = true
    fullscreen.events.onInputDown.add goFull, this
    # _.stage.fullScreenScaleMode = Phaser.StageScaleMode.SHOW_ALL
    # create overlay to fade between levels
    @overlay = _.add.graphics(0, 0);
    @overlay.beginFill 0x000000; @overlay.alpha = 1
    @overlay.drawRect 0, 0, _.width,_.height
    @group.add @overlay
    @pointer = _.add.graphics(-10,0)
    @pointer.beginFill 0xff0000
    @pointer.drawRect(0,0,5,5)

  create: ->
    @leafGraphics.clear()
    @roomGraphics.clear()
    @hallGraphics.clear()
    @leafGraphics.lineStyle 1, 0x000000
    @hallGraphics.beginFill 0xaaaaaa
    @roomGraphics.beginFill 0xffffff

  unlockDoors: ->
    for door in _.Interface.doors
      door.frame = 0

  lockDoors: ->
    for door in _.Interface.doors
      door.frame = 1

  newDoors: ->
    doorCoords = [ { x:_.Room.grid.midX,  y:_.Room.grid.top-_.tSize/2, dir: "top" }, 
                   { x:-_.Room.grid.left-5,  y:_.Room.grid.midY, dir: "left" }, 
                   { x:_.Room.grid.right+_.tSize/2, y:_.Room.grid.midY, dir: "right" }, 
                   { x:_.Room.grid.midX,  y:_.Room.grid.bottom-_.tSize/2, dir: "bottom" } ]

    for door in @doors
      door.sprite.x = 10
      door.sprite.y = 10
      door.sprite.width = _.tSize; door.sprite.height = _.tSize

    @lockDoors()

  drawMinimap: ->
    @leafGraphics.clear()
    @roomGraphics.clear()
    @hallGraphics.clear()
    #minimap shouldnt be fully revealed straight away, it should only show tiles the player has been to and corridors the player has taken
    scl = _.tSize/40
    for hall in _.Dungeon.halls
      for line in hall
        @hallGraphics.drawRect line.x*scl,line.y*scl,line.w*scl,line.h*scl
    for room in _.Dungeon.rooms
      @roomGraphics.beginFill 0xFFFFFF
      @roomGraphics.beginFill 0x00ff00 if room.player
      @roomGraphics.drawRect room.x*scl,room.y*scl,room.w*scl,room.h*scl
    
    for quad in _.Dungeon.sections
      @leafGraphics.drawRect quad.x*scl,quad.y*scl,quad.width*scl,quad.height*scl
    # @leafGraphics.drawRect _.Dungeon.sections[0].x*scl,_.Dungeon.sections[0].y*scl,_.Dungeon.sections[0].width*scl,_.Dungeon.sections[0].height*scl

    # placement/scale of minimap
    @leafGraphics.width = _.Dungeon.sections[0].width*scl
    @leafGraphics.height = _.Dungeon.sections[0].height*scl
    if _.width > _.height # landscape
      for o in [@leafGraphics,@roomGraphics,@hallGraphics]
        o.x = _.tSize*.1
        o.y = _.height-@leafGraphics.height-_.tSize*.1
    else #portrait
      for o in [@leafGraphics,@roomGraphics,@hallGraphics]
        o.x = _.width-@leafGraphics.width-_.tSize*.1
        o.y = _.tSize*.1