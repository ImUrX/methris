extends TileMap

var rng = RandomNumberGenerator.new()

var matrix = []
var x = 16
var y = -1
var size = 4

func _init():
	for _x in range(size):
		matrix.append([])
		for _y in range(size):
			matrix[_x].append(false)

func _ready():
	rng.randomize()

func _on_TileMap_newBlock(block):
	self.x = block.x
	self.y = block.y
	self.size = block.size
	self.resetMatrix()
	for toX in range(block.size):
		for toY in range(block.size):
			if(block.matrix[toX][toY] == false): continue
			self.matrix[toX][toY] = rng.randi_range(0, 9)

func _on_TileMap_graph(_x, _y):
	self.graph(-1)
	self.x += _x
	self.y += _y
	self.graph()

func _on_TileMap_flip():
	var copy = matrix.duplicate(true)
	var copy2
	for toX in range(size):
		for toY in range(size):
			matrix[toX][toY] = copy[size - toY - 1][toX]
	copy2 = matrix
	matrix = copy
	graph(-1)
	matrix = copy2
	graph()

func _on_TileMap_fullLineDone(_y: int):
	var ran = range(get_parent().yMax[0], _y)
	ran.invert()
	var suma = 0
	for j in range (get_parent().xMax[0], get_parent().xMax[1]):
		suma += self.get_cell(j, _y)
		self.set_cell(j, _y, -1) # aca estoy borrando la linea
	print("conseguiste %d puntos" % suma)
	for j in range(get_parent().xMax[0], get_parent().xMax[1]):
		for k in ran:
			self.set_cell(j, k + 1, self.get_cell(j, k))
			self.set_cell(j, k, -1)

func resetMatrix():
	for _x in range(4):
		for _y in range(4):
			self.matrix[_x][_y] = false

func graph(tile = null):
	for toX in range(self.size):
		for toY in range(self.size):
			if(self.matrix[toX][toY] is bool): continue
			self.set_cell(toX + self.x - self.size, toY + self.y - self.size, self.matrix[toX][toY] if tile == null else tile)
