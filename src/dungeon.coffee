Dungeon =
  map: null
  map_size: 99
  rooms: []
  EMPTY: 1
  ROOM: 3
  WALL: 2
  Generate: ->
    # init map array
    @map = []
    for x in [0..@map_size]
      @map[x]=[]
      for y in [0..@map_size]
        @map[x][y]=@EMPTY

    # generate room data while ensuring that rooms don't overlap
    room_count = Helpers.GetRandom(10,20)
    min_size = 4
    max_size = 12
    for count in [0..room_count]
      room = {}
      [room.x, room.y] = Helpers.GetTwoRandom(1, @map_size - max_size - 1)
      [room.w, room.h] = Helpers.GetTwoRandom(min_size, max_size)

      continue if @DoesCollide(room)
      room.w--; room.h--
      @rooms.push room


    # force rooms to be closer so tunnels work better
    @SquashRooms()

    # draw tunnels
    for room in @rooms
      roomB = @FindClosestRoom(room)
      pointA =
        x: Helpers.GetRandom(room.x, room.x + room.w)
        y: Helpers.GetRandom(room.y, room.y + room.h)
      pointB =
        x: Helpers.GetRandom(roomB.x, roomB.x + roomB.w)
        y: Helpers.GetRandom(roomB.y, roomB.y + roomB.h)

      while (pointB.x isnt pointA.x) or (pointB.y isnt pointA.y)
        unless pointB.x is pointA.x
          if pointB.x > pointA.x then pointB.x-- else pointB.x++
        else unless pointB.y is pointA.y
          if pointB.y > pointA.y then pointB.y-- else pointB.y++
        @map[pointB.x][pointB.y] = @ROOM

    # draw rooms
    for room in @rooms
      x = room.x
      while x < room.x + room.w
        y = room.y
        while y < room.y + room.h
          @map[x][y] = @ROOM
          y++
        x++

    # stroke around all the rooms and corridors to form wall
    for x in [0..@map_size]
      for y in [0..@map_size]
        if @map[x][y] is @ROOM
          xx = x - 1
          while xx <= x + 1
            yy = y - 1
            while yy <= y + 1
              @map[xx][yy] = @WALL  if @map[xx][yy] is @EMPTY
              yy++
            xx++
        y++
      x++

    _.mapData = []
    for row in @map
      for tile in row
        _.mapData.push(tile)

    return

  FindClosestRoom: (_room) ->
    mid =
      x: _room.x + (_room.w / 2)
      y: _room.y + (_room.h / 2)

    closest = null
    closest_distance = 1000

    for room in @rooms
      continue  if room is _room
      room_mid =
        x: room.x + (room.w / 2)
        y: room.y + (room.h / 2)

      distance = Math.min(Math.abs(mid.x - room_mid.x) - (room.w / 2) - (room.w / 2), Math.abs(mid.y - room_mid.y) - (room.h / 2) - (room.h / 2))
      if distance < closest_distance
        closest_distance = distance
        closest = room
    closest

  SquashRooms: ->
    i = 0
    while i < 10
      for r of @rooms
        room = @rooms[r]
        loop
          old_position =
            x: room.x
            y: room.y

          room.x--  if room.x > 1
          room.y--  if room.y > 1
          break  if (room.x is 1) and (room.y is 1)
          if @DoesCollide(room, r)
            room.x = old_position.x
            room.y = old_position.y
            break
      i++
    return

  DoesCollide: (room, ignore) ->
    i = 0

    while i < @rooms.length
      continue  if i is ignore
      check = @rooms[i]
      return true  unless (room.x + room.w < check.x) or (room.x > check.x + check.w) or (room.y + room.h < check.y) or (room.y > check.y + check.h)
      i++
    false

Helpers =
  GetRandom: (low, high) ->
    Math.floor(~~(Math.random() * (high - low)) + low)

  GetTwoRandom: (low, high) ->
    x=@GetRandom(low,high)
    y=@GetRandom(low,high)
    [x,y]
