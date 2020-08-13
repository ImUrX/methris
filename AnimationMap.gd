extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var tetris
var animatedGlow: AnimatedTexture

# Called when the node enters the scene tree for the first time.
func _ready():
	tetris = get_parent()
	animatedGlow = self.tile_set.tile_get_texture(0)
	for i in range(4, 11):
		var color = tetris.tile_set.tile_get_modulate(i)
		self.tile_set.create_tile(i)
		self.tile_set.tile_set_texture(i, animatedGlow)
		self.tile_set.tile_set_modulate(i, color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TileMap_allFullLineDone():
	animatedGlow.oneshot = false
	for x in range(tetris.xMax[0], tetris.xMax[1]):
		for j in range(tetris.yMax[0], tetris.yMax[1]):
			var color = tetris.get_cell(x, j)
			if color < 4: continue
			self.set_cell(x, j, color)
			$Timer.start(1)


func _on_Timer_timeout():
	animatedGlow.oneshot = true;
	for x in range(tetris.xMax[0], tetris.xMax[1]):
		for j in range(tetris.yMax[0], tetris.yMax[1]):
			if self.get_cell(x, j) > -1: 
				self.set_cell(x, j, -1)
