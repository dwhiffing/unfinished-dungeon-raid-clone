compile: 
	coffee --join scas.js --watch --compile src/main.coffee src/init.coffee src/game.coffee src/tweens.coffee src/helpers.coffee src/dungeon.coffee

	open: 
	open http://localhost/scas/

run: 
	compile open
