extends TileMap


const xMax = 10
const yMax = 16
var blocks = [load("res://blocks/L.gd"), load("res://blocks/Square.gd")]

# Declare member variables here. Examples:
var time = 0
var rng = RandomNumberGenerator.new()
var instance = randomBlock()
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	instance.x = 5
	instance.y = 0

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
		if(try or instance.y >= yMax):
			instance = randomBlock()
			instance.x = 5
			time -= 0.5
			return
		instance.graph(self, -1)
		instance.y += 1
		instance.graph(self, 0)
		time -= 0.5

func randomBlock():
	return blocks[rng.randi_range(0, blocks.size() - 1)].new()
