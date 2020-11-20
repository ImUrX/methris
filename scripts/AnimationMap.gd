extends TileMap

const Block = preload("res://blocks/Block.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var tetris
var animatedGlow: AnimatedTexture

var block: Block = Block.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	tetris = get_parent()
	animatedGlow = self.tile_set.tile_get_texture(0)
	for i in range(4, 11):
		var color = tetris.tile_set.tile_get_modulate(i)
		self.tile_set.create_tile(i)
		self.tile_set.tile_set_texture(i, animatedGlow)
		self.tile_set.tile_set_modulate(i, color)
		
		var j = i + 7 #bloque transparente
		self.tile_set.create_tile(j)
		self.tile_set.tile_set_texture(j, tetris.tile_set.tile_get_texture(i))
		color.a = 0.2
		self.tile_set.tile_set_modulate(j, color)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TileMap_allFullLineDone():
	self.clear()
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
			var cell = self.get_cell(x, j)
			if cell > -1 and cell < 11 : 
				self.set_cell(x, j, -1)

var originalY
func _on_TileMap_newBlock(block, _future):
	self.block.graph(self, -1)
	self.block.x = block.x
	self.block.y = block.y
	originalY = block.y
	self.block.size = block.size
	self.block.defaultTile = block.defaultTile
	for toX in range(block.size):
		for toY in range(block.size):
			self.block.matrix[toX][toY] = block.matrix[toX][toY]
	set_lowest_collission()
	self.block.graph(self, self.block.defaultTile + 7)

func _on_TileMap_graph(x, y):
	self.block.graph(self, -1)
	self.block.x += x
	originalY += y
	set_lowest_collission()
	self.block.graph(self, self.block.defaultTile + 7)
	
func _on_TileMap_flip(state: int):
	self.block.graph(self, -1)
	self.block.y = originalY
	match state:
		Block.FLIP_STATE.RIGHT: self.block.x += 1
		Block.FLIP_STATE.LEFT: self.block.x -= 1
	self.block.flip(self, true)
	self.block.graph(self, -1)
	set_lowest_collission()
	self.block.graph(self, self.block.defaultTile + 7)

func set_lowest_collission():
	self.block.y = originalY
	self.block.graph(tetris, -1)
	self.block.set_lowest_collission(tetris)
	var y = self.block.y
	self.block.y = originalY
	self.block.graph(tetris, 0)
	self.block.y = y


func _on_TileMap_loadBlock(instance):
	_on_TileMap_newBlock(instance, null)
