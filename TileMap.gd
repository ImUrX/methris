extends TileMap


const xMax = [10,19]
const yMax = [0,19]
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
			var aux = false
			for i in range(instance.size):
				if(fullLine(instance.y - i)):
					aux = true
					for j in range (10, 20):
						self.set_cell(j, instance.y - i, -1)
					#agregar puntitos
						
					

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
