extends TileMap

const xMax = [10,20]
const yMax = [0,20]
var blocks = [load("res://blocks/L.gd"), load("res://blocks/Square.gd"), load("res://blocks/Threeway.gd"), load("res://blocks/Stick.gd"), load("res://blocks/J.gd"), load("res://blocks/S.gd"), load("res://blocks/Z.gd")]

# Declare member variables here. Examples:
var time = 0
var rng = RandomNumberGenerator.new()
var controls = load("res://Controls.gd").new()
var instance
# var b = "text"

func _ready():
	rng.randomize()
	instance = randomBlock()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	controls._process(delta)
	if controls.getAction("flip"):
		instance.flip(self)
	if controls.getAction("left"):
		instance.graph(self, -1)
		instance.x -= 1
		if instance.tryGraph(self, 0):
			instance.x += 1
			instance.graph(self, 0)
		else:
			instance.graph(self, 0)
	if controls.getAction("right"):
		instance.graph(self, -1)
		instance.x += 1
		if instance.tryGraph(self, 0):
			instance.x -= 1
			instance.graph(self, 0)
		else:
			instance.graph(self, 0)
	if controls.getAction("down"):
		time = 0
	elif time >= 0.5:
		time -= 0.5
	else:
		return
	instance.graph(self, -1)
	instance.y += 1
	var try = instance.tryGraph(self, 0)
	instance.y -= 1
	instance.graph(self, 0)
	if(try):
		for i in range(instance.size):
			if(not fullLine(instance.y - i)): continue
			var ran = range(yMax[0], instance.y - i)
			ran.invert()
			for j in range (xMax[0], xMax[1]):
				self.set_cell(j, instance.y - i, -1)
			for i in range(xMax[0], xMax[1]):
				for j in ran:
					self.set_cell(i, j + 1, self.get_cell(i, j))
					self.set_cell(i, j, -1)
				#agregar puntitos
		
		instance = randomBlock()
		return
	instance.graph(self, -1)
	instance.y += 1
	instance.graph(self, 0)
		

func randomBlock():
	return blocks[rng.randi_range(0, blocks.size() - 1)].new()

func fullLine(y: int):
	for x in range(10, 20):
		if not (self.get_cell(x, y) >= 3): return false
	return true
	
func addScore(num: int):
	var sum = 0
	for i in range(0, num):
		sum = (sum + 100) + (sum + 100) * 0.2 * num
	return sum
