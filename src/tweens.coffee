destroyTween = (obj) ->
  tween = _.add.tween(obj)
  tween.to
    width: 0
    height: 0
    alpha: 0
    angle:100
  , _.popTime*3, Phaser.Easing.Quadratic.In, true, _.popTime
  tween.start()

moveHero = (newX, newY) ->
  tween = _.add.tween(_.hero)
  tween.to
    y: newY
    x: newX
  , _.popTime, Phaser.Easing.Quadratic.Linear, true, 0
  tween.start()

pulseTile = (obj) ->
  tween = _.add.tween(obj)
  tween.to
    width: obj.width * .95
    height: obj.height * .95
    angle: obj.angle * -1
  , 1000, Phaser.Easing.Linear.InOut, true, Math.random() * (200), 5000, true
  tween.start()
  tween.delay = 0

fadeOut = ->
  tween = _.add.tween(_.uiFade)
  tween.to
    alpha: 1
  , 1000, Phaser.Easing.Linear.Out, true
  tween.start()

fadeIn = ->
  tween = _.add.tween(_.uiFade)
  tween.to
    alpha: 0
  , 1000, Phaser.Easing.Linear.Out, true
  tween.start()
