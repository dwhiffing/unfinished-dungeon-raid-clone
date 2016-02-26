Leaf = (X,Y,_width,_height,parent=null) -> 
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
  @split = ->
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
      @leftChild = new Leaf(_x, _y, _w, s, @)
      @rightChild = new Leaf(_x, _y+s, _w, _h-s,@)
    else
      @leftChild = new Leaf(_x, _y, s, _h,@)
      @rightChild = new Leaf(_x+s, _y, _w-s, _h,@)
    
    return true
  @createRooms = -> 
  # this function generates all the rooms and hallways for this Leaf and all of its children.
    if @leftChild? or @rightChild?
      # this leaf has been split, so go into the children leafs
      @leftChild.createRooms() if @leftChild?
      @rightChild.createRooms() if @rightChild?
      if @leftChild? and @rightChild?
        @createHall( @leftChild.getRoom(), @rightChild.getRoom() )
    else # this Leaf is the ready to make a room
      # the room can be between 3 x 3 tiles to the size of the leaf - 2.
      roomSizeX = _.rnd.integerInRange(5, 10)
      roomSizeY = _.rnd.integerInRange(5, 10)
      # place the room within the Leaf, but don't put it right 
      # against the side of the Leaf (that would merge rooms together)
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
      _.rooms.push @room

  @getRoom = ->
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
  @createHall = (l, r) ->
    # now we connect these two rooms together with hallways.
    # this looks pretty complicated, but it's just trying to figure out which point is where and then either draw a straight line, or a pair of lines to make a right-angle to connect them.
    # you could do some extra logic to make your halls more bendy, or do some more advanced things if you wanted.
    
    _t = 1

    p1X = _.rnd.integerInRange(l.x + 1, l.w+l.x - 2)
    p1Y = _.rnd.integerInRange(l.y + 1, l.h+l.y - 2)
    p2X = _.rnd.integerInRange(r.x + 1, r.w+r.x - 2) 
    p2Y = _.rnd.integerInRange(r.y + 1, r.h+r.y - 2)
 
    w = p2X - p1X
    h = p2Y - p1Y
 
    if (w < 0)
      if (h < 0)
        if (Math.random() * 0.5)
          @pushHall( "bottom", p2X, p1Y, Math.abs(w), _t, p2X, p2Y, _t, Math.abs(h) )
        else
          @pushHall( "bottom", p2X, p2Y, Math.abs(w), _t, p1X, p2Y, _t, Math.abs(h) )
      else if (h > 0)
        if (Math.random() * 0.5)
          @pushHall( "right", p2X, p1Y, Math.abs(w), _t, p2X, p1Y, _t, Math.abs(h) )
        else
          @pushHall( "right", p2X, p2Y, Math.abs(w), _t, p1X, p1Y, _t, Math.abs(h) )
      else # if (h == 0)
        @pushHall( "top", p2X, p2Y, Math.abs(w), _t )
    else if (w > 0)
      if (h < 0)
        if (Math.random() * 0.5)
          @pushHall( "left", p1X, p2Y, Math.abs(w), _t, p1X, p2Y, _t, Math.abs(h) )
        else
          @pushHall( "left", p1X, p1Y, Math.abs(w), _t, p2X, p2Y, _t, Math.abs(h) )
      else if (h > 0)
        if (Math.random() * 0.5)
          @pushHall( "asd", p1X, p1Y, Math.abs(w), _t, p2X, p1Y, _t, Math.abs(h) )
        else
          @pushHall( "asd", p1X, p2Y, Math.abs(w), _t, p1X, p1Y, _t, Math.abs(h) )
      else # if (h == 0)
        @pushHall( "bbasd", p1X, p1Y, Math.abs(w), _t )
    else # if (w == 0)
      if (h < 0)
        @pushHall( "dddd", p2X, p2Y, _t, Math.abs(h) )
      else if (h > 0)
        @pushHall( "eeee", p1X, p1Y, _t, Math.abs(h) )


  @pushHall = (type, X,Y,W,H,X2=null,Y2=null,W2=null,H2=null) ->
    # debugger
    hall = []
    if W > 1 or H > 1
      hall.push {x:X, y:Y, w:W, h:H,t:type}
      hall.push {x:X2, y:Y2, w:W2, h:H2,t:type} if X2? and (W2 > 1 or H2 > 1)

      _.halls.push hall
      @leftChild.halls.push hall
      @rightChild.halls.push hall


  return this
