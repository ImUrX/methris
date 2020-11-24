extends TileMap

const FLIP_STATE = preload("res://blocks/Block.gd").FLIP_STATE
const TetrisMap = preload("res://scripts/TileMap.gd")

var rng = RandomNumberGenerator.new()

var tetris_map: TetrisMap
var originalMatrix
var pocketMatrix
var future_matrix := []
var future_size := 0
var matrix
var negatives := {}
var x := 16
var y := -1
var size := 4

func _init():
	for _x in range(size):
		future_matrix.append([])
		for _y in range(size):
			future_matrix[_x].append(false)

func _ready():
	tetris_map = get_parent()
	tetris_map.score_followers.append(funcref(self, "calc_multiplier"))
	rng.randomize()
	for i in range(10, 20):
		negatives[i] = (i - 10) * -1
		self.tile_set.create_tile(i)
		self.tile_set.tile_set_texture(i, self.tile_set.tile_get_texture(i - 10))
		self.tile_set.tile_set_region(i, self.tile_set.tile_get_region(i - 10))
		self.tile_set.tile_set_modulate(i, Color(0.7, 0, 0))

func _on_TileMap_newBlock(block, future_block):
	self.x = block.x
	self.y = block.y
	self.size = block.size
	if self.matrix == null:
		gen_future_num(block)
	else:
		graph_future(-1)
	self.matrix = self.future_matrix.duplicate(true)
	self.resetMatrix()
	gen_future_num(future_block)
	self.originalMatrix = matrix.duplicate(true)
	graph_future(null)
	
func gen_future_num(future_block):
	for toX in range(future_block.size):
		for toY in range(future_block.size):
			if(future_block.matrix[toX][toY] == false): continue
			self.future_matrix[toX][toY] = rng.randi_range(-9, 9)
	future_size = future_block.size

func _on_TileMap_graph(_x, _y):
	self.graph(-1)
	self.x += _x
	self.y += _y
	self.graph()

func _on_TileMap_flip(state: int):
	graph(-1)
	match state:
		FLIP_STATE.RIGHT: self.x += 1
		FLIP_STATE.LEFT: self.x -= 1
	flip()

func flip():
	var matrixT = matrix.duplicate(true)
	for toX in range(size):
		for toY in range(size):
			matrixT[toY][toX] = matrix[toX][toY] #transpose
	for toX in range(size/2):
		var arr_copy = matrixT[toX]
		var mirror = size - 1 - toX
		matrixT[toX] = matrixT[mirror]
		matrixT[mirror] = arr_copy
	matrix = matrixT
	graph()

func calc_multiplier(fakeY: int, _y: int) -> float:
	var ran = range(tetris_map.yMax[0], _y)
	ran.invert()
	var sum = 0
	var buffer = []
	for j in range (tetris_map.xMax[0], tetris_map.xMax[1]):
		var value = self.get_cell(j, _y)
		if value in negatives: value = negatives[value]
		buffer.append(value)
		sum += value
		self.set_cell(j, _y, -1) # aca estoy borrando la linea
	for j in range(tetris_map.xMax[0], tetris_map.xMax[1]):
		for k in ran:
			self.set_cell(j, k + 1, self.get_cell(j, k))
			self.set_cell(j, k, -1)
	show_calc(fakeY, buffer, sum)
	return abs(sum)

func show_calc(fakeY: int, buffer: Array, sum: int):
	var calc: Label = get_node("./Calculos/" + str(fakeY))
	var first = true
	for num in buffer:
		if first:
			calc.text = str(num)
			first = false
		else:
			calc.text += ("+" if num >= 0 else "") + str(num)
	calc.text += "=" + str(sum)
	var previous = calc.text
	calc.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	if calc.text == previous:
		calc.visible = false

func resetMatrix():
	for _x in range(4):
		for _y in range(4):
			self.future_matrix[_x][_y] = false

func graph(tile = null):
	for toX in range(self.size):
		for toY in range(self.size):
			if self.matrix[toX][toY] is bool: continue
			var modified = false
			if tile == null and self.matrix[toX][toY] < 0: 
				tile = (self.matrix[toX][toY] * -1) + 10
				modified = true
			self.set_cell(toX + self.x - self.size, toY + self.y - self.size, self.matrix[toX][toY] if tile == null else tile)
			if modified: tile = null


func _on_TileMap_saveBlock():
	self.graph(-1)
	self.pocketMatrix = self.originalMatrix.duplicate(true)
	self.matrix = self.originalMatrix
	self.x = 9
	self.y = 5
	self.graph()


func _on_TileMap_loadBlock(block):
	self.graph(-1)
	var backup = self.pocketMatrix
	var backupSize = self.size
	self.pocketMatrix = self.originalMatrix
	self.matrix = backup
	self.x = 9
	self.y = 5
	self.size = block.size
	self.graph(-1)
	self.size = backupSize
	self.matrix = self.pocketMatrix
	self.graph()
	self.matrix = backup
	self.x = block.x
	self.y = block.y
	self.size = block.size
	self.originalMatrix = backup.duplicate(true)
	
func graph_future(id):
	var backup = self.matrix
	var backupSize = self.size
	var backupCoord = [x, y]
	self.matrix = future_matrix
	self.x = 25
	self.y = 5
	self.size = future_size
	self.graph(id)
	self.size = backupSize
	self.matrix = backup
	self.x = backupCoord[0]
	self.y = backupCoord[1]
