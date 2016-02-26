var width = window.window.innerWidth-15;
var height = window.window.innerHeight-15;
var canvasSize = width; if (width>=height) { canvasSize = height }
var textScale = canvasSize/20;
var game = new Phaser.Game(canvasSize, canvasSize, Phaser.CANVAS, '', { preload: preload, create: create, update: update, render: render });

// scope for all important vars
var numTypes, tileBuffer, tileScale, pulseRotation, pulseScale;
var gridSize, rSize, cSize, startX, startY;
var path, tilesToPop, matchesToPop, fallingPieces, lastSwapped, currentMatch, numMatched;
var popTime, gravTime, clearTime, swapTime, comboTime;
var lastTile, boardMoving, comboTimer;
var tileGroup, tileArray, select;
var score, combo, level, basePoints;
var grid,fade,foreground,background,arrow;

// Main interface ---------------------------------------

function preload() {
  game.load.spritesheet('tile', 'button2 copy.png', 300, 300);
  game.load.spritesheet('player', 'player.png', 16, 16);
  game.load.audio('pop', 'pop.mp3');
}

function create() {
  initVars();
  initBackground();
  initTileGrid();
  initUI();
  initPlayer();
  doNextAction();
  game.input.onDown.add(startPath,this);
  game.input.onUp.add(walkPath,this);
}

function update() {
}

function render() {
  // game.debug.renderText(
  //   parseInt(score), textScale, textScale*1.5, "#ffffff", textScale+"px Courier"
  // );
  // game.debug.renderText(
  //   "X"+combo, width-textScale*2.4, textScale*2, "#ffffff", textScale+"px Courier"
  // );
  tileGroup.forEach(function(tile) {
    var tX = startX+tile.gridX*gridSize;
    var tY = startY+tile.gridY*gridSize;
    game.debug.renderText(
      tile.gridX+","+tile.gridY, tX-20, tY-20, "#fff", textScale/3.5+"px Courier"
    );
    game.debug.renderText(
      tile.type, tX+20, tY-20, "#fff", textScale/3.5+"px Courier"
    );
  });
}

// Create Game -----------------------------------------------

function initVars() {
  
  numTypes      = 3;
  tileBuffer    = 0;
  tileScale     = Math.floor(game.width / 8);
  pulseScale    = 0.9;
  pulseRotation = 3;

  gridSize      = tileScale + tileBuffer;
  rSize         = 7;
  cSize         = 7;
  // center grid on screen
  startX        = tileScale/2+(game.width - gridSize * (rSize)) / 2;
  startY        = tileScale/2+(game.height - gridSize * (cSize)) / 2;
  
  path          = [];
  tilesToPop    = [];
  matchesToPop  = [];
  fallingPieces = [];
  lastSwapped   = [];
  currentMatch  = [];
  
  popTime       = 150;
  gravTime      = 200;
  clearTime     = 100;
  swapTime      = 300;
  comboTime     = 1500;

  lastTile  = null;
  boardMoving   = false;
  
  score         = 0;
  numMatched    = 0;
  combo         = 0;
  level         = 0;
  basePoints    = 10;

  background = game.add.group();
  tileGroup = game.add.group();
  foreground = game.add.group();
}

function initBackground() {
  game.stage.backgroundColor = '#282323';
  //draw grid
  grid = game.add.graphics(0, 0);
  grid.lineStyle(2, 0x000000, 1);
  grid.beginFill(0xFFFF0B, 0);
  // adjust for tile center
  var yPos = startY-tileScale/2;
  var xPos = startX-tileScale/2-5;
  for (var x = yPos; x < tileScale * (rSize + 1) + xPos; x += gridSize) {
    grid.moveTo(x, yPos);
    grid.lineTo(x, yPos + gridSize * cSize);
    for (var y = xPos; y < tileScale * (cSize + 1) + yPos; y += gridSize) {
      grid.moveTo(xPos, y);
      grid.lineTo(xPos + gridSize * rSize, y);
    }
  }
  background.add(grid);
}

function initTileGrid() {
  // create array to represent grid of tiles
  tileArray = new jMatch3.Grid({
    width: rSize, height: cSize, gravity: "down"
  });
  // set up sprite objects with grid data
  for (var x = startX; x < tileScale * rSize + startX; x += gridSize) {
    for (var y = startY; y < tileScale * cSize + startY; y += gridSize) {
      initTile(x, y);
    }
  }
}

function initPlayer() {
  player = game.add.sprite(-20,-20, 'player');
  setSize(player, tileScale-20);
  player.anchor.setTo(0.5,0.5);
  var tile = tileArray.getPiece({x:3,y:3});
  player.x = tile.object.x;
  player.y = tile.object.y;
  player.gridX = tile.x;
  player.gridY = tile.y;
  tile.clear();
  tile.object.type = 0;
  player.t = tile;
  foreground.add(player);
}

function initUI() {
  fade = game.add.graphics(0,0);
  fade.beginFill(0x000000);
  fade.lineStyle(2,0x000000,1);
  fade.drawRect(0,0,game.width,game.height);
  fade.alpha=0;

  arrow = game.add.graphics(0, 0);

  foreground.add(fade);
  foreground.add(arrow);
}

// Update ----------------------------------

function doNextAction() {
  // wait for input if no matches/pops to do
  boardMoving = false;
  if (tilesToPop && tilesToPop.length > 0) {
    // pop each tile from our last match with a delay between each
    popTile();
    game.time.events.add( popTime, doNextAction );
  } 
  else {
    // resolve gravity if all tiles have been popped
    // checkForFalling();
    // if (fallingPieces && fallingPieces.length > 0) {
    //   applyGravity();
    // } 
    game.time.events.add( gravTime, doNextAction );
  }
}

// Main Actions ----------------------------------

function popTile() {
  boardMoving = true;
  var tile = tilesToPop.shift();
  if (tile === player.t){
    lastTile = tile.object;
    tile = tilesToPop.shift();
  }
    
  if ( tile.object.type !== -1 ){
    var candyTween = game.add.tween(tile.object);
    candyTween.to({
      alpha: 0.01,
      width: 0,
      height: 0,
    }, popTime * 0.95, Phaser.Easing.Quadratic.In, true, 200);
    candyTween.start();
    game.sound.play("pop");
    increaseScore();
    game.time.events.add(popTime,function(){tile.clear();});
  }

  var playerTween = game.add.tween(player);
  playerTween.to({
    x: tile.object.x,
    y: tile.object.y
  }, popTime * 0.95);
  playerTween.start();
  player.t = tile;
  game.time.events.add( popTime, setPlayerCoords );
  player.gridX = tile.object.gridX;
  player.gridY = tile.object.gridY;
  lastTile = tile.object;
  
}

function setPlayerCoords(){
  var tile = tileArray.getPiece({x:player.gridX,y:player.gridY});
  tileGroup.callAll("updateType");
  if(lastTile){
    lastTile.type = -1;
  }
  tile.object.type = 0;
}

function applyGravity() {
  boardMoving = true;
  for (var i = 0; i < fallingPieces.length; i++) {
    var tile = fallingPieces[i];
    if (tile.object) {
      tile.object.gridX = tile.x;
      tile.object.gridY = tile.y;
      tweenGem(tile.object, gravTime * 0.95, 0);
    }
  }
}


// Secondary Actions ----------------------------------

function initTile(x, y) {
  // grab data object for tile to create
  var gridX = (x - startX) / (gridSize);
  var gridY = (y - startY) / (gridSize);
  var tile = tileArray.getPiece({x: gridX,y: gridY});
  // create sprite object at that coord
  tile.object = game.add.sprite(x, y, 'tile');
  tile.object.t = tile;
  tile.object.gridX = gridX;
  tile.object.gridY = gridY;
  tile.object.angle= Math.random()*(pulseRotation-(-pulseRotation));
  setSize(tile.object, tileScale);
  tile.object.type = parseInt(Math.random() * numTypes+1);
  tile.object.frame = tile.object.type-1;
  // attach input event
  tile.object.inputEnabled = true;
  tile.selected = false;
  tile.object.events.onInputOver.add(checkCollisions, this);
  // add tile to group
  tileGroup.add(tile.object);
  pulseGem(tile.object);

  tile.object.select = function() {
    if (!this.selected){
      if(this.type !== -1){
        numMatched++;
        this.alpha=0.5;
      }
      console.log(numMatched);
      this.selected=true;
      lastTile = this;
      path.push(this);
      drawArrow();
    }
  };
  
  tile.object.deselect = function(){
    if (this.selected){
      if(this.type!=-1){
        numMatched--;
        this.alpha=1;
      }
      console.log(numMatched);
      this.selected=false;
    }
  };
  tile.object.isEmpty = function(){
    return this.type === -1;
  };
  tile.object.isPlayer = function(){
    return this.type === 0;
  };
  tile.object.reset = function(){
    this.alpha=0.01;
    this.type = -1;
  };
  tile.object.updateType = function(){
    if (this.alpha < 1){
      this.type = -1;
    }
  };
}

function startPath() {
  lastTile=null;
  fade.alpha = 0.4;
  fade.z = 1;
  sel = 0;
  numMatched=0;
  path=[player];
}

function walkPath(){
  var tile = tileArray.getPiece({x:player.gridX, y:player.gridY}).object;
  if (path.length>1 && numMatched >= 3){
    if ( varExists(lastTile) && ( path.length>3 || lastTile.type === -1 )) {
    tile.type = -1;
      game.time.events.add(1000, setPlayerCoords);
      while (path.length > 0) { 
        tilesToPop.push(path.shift().t); }
      }
  }
  tileGroup.callAll("deselect");
  path = [];
  fade.alpha = 0;
  arrow.clear();
}

function checkCollisions(tile) {
  if (fade.alpha !== 0 ) {
    if (!tile.selected) {
    //if it hasnt been selected check if it is adjacent to the last tile
      checkAdjacent(tile);
    }
    //if it has been selected, deselect all tiles before it in the path
    else { 
      deselectBefore(tile);
    }
  }
}

function deselectBefore(tile){
  for (var p = path.length - 1; p >= 0; p--) {
    if (tile.t === path[p].t || tile.t === player.t ) {
      var o = path.length-1;
      while (o > p) { 
        path[o].deselect(); 
        path.splice(o,1);
        
        if( path.length > 0 ){ lastTile = path[path.length-1]; }
        else{ lastTile = null; }

        drawArrow();
        o--; 
      }
    }
  }
  // if(tile.t === player.t){
  //   path = [player]
  // }
}

function checkAdjacent(newTile) {
  //if at least one tile has been selected, store its coords. 
  if ( varExists(lastTile) ) { 
    neighbours = lastTile.t.neighbours();
    for (var direction in neighbours) {
      //check all 8 adjacent tiles to see if any are the new tile
      if ( newTile.t === neighbours[direction] ) {
        if((newTile.type === lastTile.type || lastTile.type === 0 || lastTile.type === -1) && newTile.t !== player.t){
          newTile.select();
        }
        if ( newTile.t === player.t){
          deselectBefore(player);
        }
      }
    }
  }
  //Else store the players coords.  
  else {
    var nb = player.t.neighbours();
    for (var dir in nb) {
      if(nb[dir] === newTile.t && path.length === 1){

        newTile.select();
      }
    }
  }
}

function drawArrow(){
  // arrow = game.add.graphics(0, 0);
  var lX, lY, mX = player.x, mY = player.y;
  resetArrow(mX,mY);
  for (var l = 0; l < path.length; l++) {
    lX = path[l].x; lY = path[l].y;
    arrow.lineTo(lX,lY);
  }
}

// Helpers

function tweenGem(obj, duration, delay) {
  var newX = startX + (obj.gridX) * ((tileScale) + tileBuffer);
  var newY = startY + (obj.gridY) * ((tileScale) + tileBuffer);
  var tween = game.add.tween(obj);
  tween.to({
    y: newY,
    x: newX
  }, duration, Phaser.Easing.Quadratic.In, true, delay);
  tween.start();
}

function pulseGem(obj) {
  var tween = game.add.tween(obj);
  tween.to({
    width:obj.width*pulseScale,
    height:obj.height*pulseScale,
    angle:obj.angle*-1
  }, 1000, Phaser.Easing.Linear.InOut, true, Math.random()*(200), 5000, true);
  tween.start();
  tween.delay=0;
}

function increaseCombo() {
  combo++;
  if(comboTimer && comboTimer.timer.length > 0){
    game.time.events.remove(comboTimer); 
  }
  comboTimer = game.time.events.add(comboTime,resetCombo); 
}

function setSize(object, size) {
  object.width = size;
  object.height = size;
  object.anchor.setTo(0.5,0.5);
}

function increaseScore() {
  score += basePoints*combo;
}


function resetCombo() {
  combo = 1;
}

function varExists(variable){
  return typeof(variable) !== 'undefined' && variable !== null;
}

function checkForFalling() {
  fallingPieces = tileArray.applyGravity();
}

function resetArrow(x,y){
    arrow.clear()
    arrow.lineStyle(2, 0x00FF00, 1);
    arrow.moveTo(x,y);
}