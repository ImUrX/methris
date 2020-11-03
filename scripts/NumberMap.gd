extends TileMap

var rng = RandomNumberGenerator.new()

var originalMatrix
var pocketMatrix
var matrix = []
var negatives = {}
var x = 16
var y = -1
var size = 4
export(DynamicFont) var calc_font

func _init():
	for _x in range(size):
		matrix.append([])
		for _y in range(size):
			matrix[_x].append(false)

func _ready():
	rng.randomize()
	get_parent().actualizarScore()
	for i in range(10, 20):
		negatives[i] = (i - 10) * -1
		self.tile_set.create_tile(i)
		self.tile_set.tile_set_texture(i, self.tile_set.tile_get_texture(i - 10))
		self.tile_set.tile_set_region(i, self.tile_set.tile_get_region(i - 10))
		self.tile_set.tile_set_modulate(i, Color(0.7, 0, 0))

func _on_TileMap_newBlock(block):
	self.x = block.x
	self.y = block.y
	self.size = block.size
	self.resetMatrix()
	for toX in range(block.size):
		for toY in range(block.size):
			if(block.matrix[toX][toY] == false): continue
			self.matrix[toX][toY] = rng.randi_range(-9, 9)
	self.originalMatrix = matrix.duplicate(true)

func _on_TileMap_graph(_x, _y):
	self.graph(-1)
	self.x += _x
	self.y += _y
	self.graph()

func _on_TileMap_flip():
	var matrixT = matrix.duplicate(true)
	for toX in range(size):
		for toY in range(size):
			matrixT[toY][toX] = matrix[toX][toY] #transpose
	for toX in range(size/2):
		var arr_copy = matrixT[toX]
		var mirror = size - 1 - toX
		matrixT[toX] = matrixT[mirror]
		matrixT[mirror] = arr_copy
	graph(-1)
	matrix = matrixT
	graph()

func _on_TileMap_fullLineDone(fakeY: int, _y: int):
	var ran = range(get_parent().yMax[0], _y)
	ran.invert()
	var sum = 0
	var buffer = []
	for j in range (get_parent().xMax[0], get_parent().xMax[1]):
		var value = self.get_cell(j, _y)
		if value in negatives: value = negatives[value]
		buffer.append(value)
		sum += value
		self.set_cell(j, _y, -1) # aca estoy borrando la linea
	get_parent().score += abs(sum)
	for j in range(get_parent().xMax[0], get_parent().xMax[1]):
		for k in ran:
			self.set_cell(j, k + 1, self.get_cell(j, k))
			self.set_cell(j, k, -1)
	var calc = get_node("./Calculos/" + str(fakeY))
	var first = true
	for num in buffer:
		if first:
			calc.text = str(num)
			first = false
		else:
			calc.text += ("+" if num >= 0 else "") + str(num)
	calc.text += "=" + str(sum)
	show_calc(calc)
	get_parent().actualizarScore()

func show_calc(node: Label):
	var previous = node.text
	node.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	if node.text == previous:
		node.visible = false

func resetMatrix():
	for _x in range(4):
		for _y in range(4):
			self.matrix[_x][_y] = false

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
	self.x = 8
	self.y = 5
	self.graph()


func _on_TileMap_loadBlock(block):
	self.graph(-1)
	var backup = self.pocketMatrix
	var backupSize = self.size
	self.pocketMatrix = self.originalMatrix
	self.matrix = backup
	self.x = 8
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
	
