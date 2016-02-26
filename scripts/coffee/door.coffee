class Door
  constructor: (dir) ->
    @sprite = _.add.sprite(0,0,"door")
    @sprite.anchor.setTo(.5,  1) if dir is 1
    @sprite.anchor.setTo(.5,  0) if dir is 2
    @sprite.anchor.setTo( 1, .5) if dir is 3
    @sprite.anchor.setTo( 0, .5) if dir is 4
    @sprite.inputEnabled = true
    @sprite.events.onInputDown.add @checkDoor, this

  checkDoor: (door) ->
    unless !_.Room.grid.getMatches()
      _.time.events.add 500, ->
        _.Room.spriteGroup.callAll("destroy")
        # _.sound.play "new"
        fadeOut()
        _.time.events.add 2000, newRoom, {6,6}
    else
      # dont switch rooms