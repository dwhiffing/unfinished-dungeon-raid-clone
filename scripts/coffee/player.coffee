class Player extends Tile
  constructor: ->
    @sprite   = _.add.sprite(-20, -20, "player");
    _.Interface.group.add @sprite

  spawn: ->
    tX = _.rnd.integerInRange(0,_.Room.width)
    tY = _.rnd.integerInRange(0,_.Room.height)
    @tile = _.Room.getTile x: tX, y: tY
    @sprite.x = @tile.sprite.x
    @sprite.y = @tile.sprite.y
    setSize @sprite, _.tSize/2
    _.Interface.overlay.alpha=1
    setPlayerCoords()