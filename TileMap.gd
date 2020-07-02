extends TileMap


const xMax = [10,20]
const yMax = [0,20]
var blocks = [load("res://blocks/L.gd"), load("res://blocks/Square.gd"), load("res://blocks/Threeway.gd"), load("res://blocks/Stick.gd"), load("res://blocks/J.gd")]

# Declare member variables here. Examples:
var time = 0
var rng = RandomNumberGenerator.new()
var instance = randomBlock()
# var b = "text"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if Input.is_action_just_pressed("flip"):
		instance.flip(self)
	if Input.is_action_just_pressed("left"):
		instance.graph(self, -1)
		instance.x -= 1
		if instance.tryGraph(self, 0):
			instance.x += 1
			instance.graph(self, 0)
		else:
			instance.graph(self, 0)
	if Input.is_action_just_pressed("right"):
		instance.graph(self, -1)
		instance.x += 1
		if instance.tryGraph(self, 0):
			instance.x -= 1
			instance.graph(self, 0)
		else:
			instance.graph(self, 0)
	if(time > 0.5):
		instance.graph(self, -1)
		instance.y += 1
		var try = instance.tryGraph(self, 0)
		instance.y -= 1
		instance.graph(self, 0)
		if(try):
			var lastY = -1
			for i in range(instance.size):
				if(fullLine(instance.y - i)):
					lastY = instance.y - i
					for j in range (xMax[0], xMax[1]):
						self.set_cell(j, instance.y - i, -1)
					#agregar puntitos
			var ran = range(yMax[0], lastY - 1)
			ran.invert()
			if lastY >= yMax[0]:
				for i in range(xMax[0], xMax[1]):
					print("x" + str(i))
					for j in ran:
						print(j)
						self.set_cell(i, j + 1, self.get_cell(i, j))
						self.set_cell(i, j, -1)
					

			instance = randomBlock()
			time -= 0.5
			return
		instance.graph(self, -1)
		instance.y += 1
		instance.graph(self, 0)
		time -= 0.5

func randomBlock():
	return blocks[rng.randi_range(0, blocks.size() - 1)].new()

func fullLine(y: int):
	for x in range(10, 20):
		if(self.get_cell(x, y) != 0): return false
	return true
	
func addScore(num: int):
	sum = 0
	for(int i = 0, i < num, i++):
		sum = (sum + 100) + (sum + 100) * 0.2 * num
	return sum
