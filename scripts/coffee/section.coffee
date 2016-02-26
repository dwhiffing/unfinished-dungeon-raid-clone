class Section
  constructor: (X,Y,_width,_height,parent=null) ->
    @x = X
    @y = Y
    @width = _width
    @height = _height
    @leftChild = null
    @rightChild = null
    @parent
    @room = null
    @min_size = 15
    @halls = []
    @parent = parent

  split: ->
    return false if @leftChild? or @rightChild?
    # begin splitting the leaf into two children
    # determine direction of split
    # if the width is >25% larger than height, we split vertically
    # if the height is >25% larger than the width, we split horizontally
    # otherwise we split randomly
    splitH = Math.random() > 0.5
    if @width > @height and @height / @width >= 0.05
      splitH = false
    else if @height > @width and @width / @height >= 0.05
      splitH = true

    max = if splitH then @height - @min_size else @width - @min_size # determine the maximum @height or @width
    
    return false if max <= @min_size

    s = _.rnd.integerInRange(@min_size, max); # determine where we're going to split

    # create our left and right children based on the direction of the split
    _w = @width
    _h = @height
    _x = @x
    _y = @y
    if splitH
      @leftChild = new Section(_x, _y, _w, s, @)
      @rightChild = new Section(_x, _y+s, _w, _h-s,@)
    else
      @leftChild = new Section(_x, _y, s, _h,@)
      @rightChild = new Section(_x+s, _y, _w-s, _h,@)
    
    return true

  createRooms: -> 
  # this function generates all the rooms and hallways for this Section and all of its children.
    if @leftChild? or @rightChild?
      # this leaf has been split, so go into the children leafs
      @leftChild.createRooms() if @leftChild?
      @rightChild.createRooms() if @rightChild?
      @createHall( @leftChild.getRoom(), @rightChild.getRoom() ) if @leftChild? and @rightChild?
    else # this Section is the ready to make a room
      # the room can be between 3 x 3 tiles to the size of the leaf - 2.
      roomSizeX = _.rnd.integerInRange(5, 10)
      roomSizeY = _.rnd.integerInRange(5, 10)
      # place the room within the Section, but don't put it right 
      # against the side of the Section (that would merge rooms together)
      roomPosX = _.rnd.integerInRange(1, @width - roomSizeX - 4)
      roomPosY = _.rnd.integerInRange(1, @height - roomSizeY - 4)
      @room = {
        x: @x + roomPosX
        y: @y + roomPosY
        w: roomSizeX
        h: roomSizeY
        player: false
        doors:{
          top:false
          bottom:false
          right:false
          left:false
        }
      }
      _.Dungeon.rooms.push @room

  getRoom: ->
    # iterate all the way through these leafs to find a room, if one exists.
    if @room?
      return @room
    else
      lRoom = @leftChild.getRoom() if @leftChild?
      rRoom = @rightChild.getRoom() if @rightChild?
      if !lRoom? and !rRoom?
        return null 
      else if !rRoom?
        return lRoom
      else if !lRoom?
        return rRoom
      else if (Math.random() > .5)
        return lRoom
      else
        return rRoom

  createHall: (l, r) ->
    
    # if hallway is above a certain length, it is a hidden shortcut, and isnt revealed until something happens
    # hallway is an array of 1 or 2 objects that make up an individual corridor.
    # properties: 
    # x, y, w, h
    # uncovered?
    # roomsConnected
    # startX, startY

    # # l is right of r
    # if l.x > r.x
    #   lX = l.x + l.w
    #   # lY = l.y + l.h/2
    #   rX = r.x
    #   # rY = r.y + r.h/2
    # # l is left of r
    # if l.x < r.x 
    #   lX = l.x
    #   # lY = l.y + l.h/2
    #   rX = r.x + r.w
    #   # rY = r.y + r.h/2
    # # l is below r
    # if l.y > r.y 
    #   # lX = l.x + l.w/2
    #   lY = l.y
    #   # rX = r.x + r.w/2
    #   rY = r.y + r.h
    # # l is above r
    # if l.y < r.y 
    #   # lX = l.x + l.w/2
    #   lY = l.y + l.h
    #   # rX = r.x + r.w/2
    #   rY = r.y

    lX = _.rnd.integerInRange(l.x + 1, l.w+l.x - 2)
    lY = _.rnd.integerInRange(l.y + 1, l.h+l.y - 2)
    rX = _.rnd.integerInRange(r.x + 1, r.w+r.x - 2)
    rY = _.rnd.integerInRange(r.y + 1, r.h+r.y - 2)

    w = rX - lX
    W = Math.abs(w)
    h = rY - lY
    H = Math.abs(h)
 
    T = 1 # thickness of path

    # l is right of r
    if (w < 0) 
      # l is below r
      if (h < 0) 
        if (Math.random()*.5)then @pushHall({ x:rX, y:lY, w:W, h:T },{ x:rX, y:rY, w:T, h:H })
        else                      @pushHall({ x:rX, y:rY, w:W, h:T },{ x:lX, y:rY, w:T, h:H })
      # l is above r
      else if (h > 0) 
        if (Math.random()*.5)then @pushHall({ x:rX, y:lY, w:W, h:T },{ x:rX, y:lY, w:T, h:H })
        else                      @pushHall({ x:rX, y:rY, w:W, h:T },{ x:lX, y:lY, w:T, h:H })
      # l is neither below or above r
      else @pushHall({ x:rX, y:rY, w:W, h:T })

    # l is left of r
    else if (w > 0) 
      # l is below r
      if (h < 0) 
        if (Math.random()*.5)then @pushHall({ x:lX, y:rY, w:W, h:T },{ x:lX, y:rY, w:T, h:H })
        else                      @pushHall({ x:lX, y:lY, w:W, h:T },{ x:rX, y:rY, w:T, h:H })
      # l is above r
      else if (h > 0) 
        if (Math.random()*.5)then @pushHall({ x:lX, y:lY, w:W, h:T },{ x:rX, y:lY, w:T, h:H })
        else                      @pushHall({ x:lX, y:rY, w:W, h:T },{ x:lX, y:lY, w:T, h:H })
      # l is neither below or above r
      else @pushHall({ x:lX, y:lY, w:W, h:T })
    else  # l is neither left or right of r
      if (h < 0) then @pushHall({ x:rX, y:rY, w:T, h:H })
      if (h > 0) then @pushHall({ x:lX, y:lY, w:T, h:H })


  pushHall: (hall1, hall2=null) ->
    if hall1.w > 1 or hall1.h > 1
      hall = [hall1]
      hall.push hall2 if hall2?
      
      _.Dungeon.halls.push hall
      @leftChild.halls.push hall
      @rightChild.halls.push hall
