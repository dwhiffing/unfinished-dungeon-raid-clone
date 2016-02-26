class Dungeon
  constructor: (X,Y) ->
    @x = X
    @y = Y
    @sections       = []
    @rooms       = []
    @halls       = []
    @floorSize   = 50
    _.Floor       = new Section(0,0,@floorSize,@floorSize)
    @sections.push(_.Floor)

  create: ->
    # create Dungeon Based Dungeon - refactor into helper function
    @mapGroup = _.add.group()
    @sections.withRooms = []

    did_split = true
    # we loop through every Dungeon in our Vector over and over again, until no more Leafs can be split.
    while (did_split)
      did_split = false
      for l in @sections
        if !l.leftChild? and !l.rightChild? # if this Dungeon is not already split...
          # if this Dungeon is too big, or 75% chance...
          if l.width > 10 or l.height > 10 or Math.random() > 0.25
            if l.split() # split the Dungeon!
              # if we did split, push the child leafs to the Vector so we can loop into them next
              @sections.push(l.leftChild)
              @sections.push(l.rightChild)
              did_split = true

    _.Floor.createRooms()
    for quad in @sections
      if quad.room?
        @sections.withRooms.push quad
    @sections.withRooms[0].room.player = true
    _.currentRoom = @sections.withRooms[0]

    for hall in _.currentRoom.halls
      if hall[0].x > _.currentRoom.room.x
        _.currentRoom.room.doors.right = true 
        break
      if hall[0].y < _.currentRoom.room.y
        _.currentRoom.room.doors.top = true 
        break
      if hall[0].x < _.currentRoom.room.x
        _.currentRoom.room.doors.left = true 
        break
      if hall[0].y > _.currentRoom.room.y
        _.currentRoom.room.doors.bottom = true 
        break

