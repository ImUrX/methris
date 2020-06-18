extends TileMap


const xMax = 10
const yMax = 16
var blocks = [load("res://blocks/L.gd")]

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
	if(time > 0.5):
		instance.graph(self, -1)
		instance.y += 1
		if(instance.graph(self, 0) or instance.y == yMax):
			instance = randomBlock()
			instance.x = 5
			pass
		time -= 0.5

func randomBlock():
	return blocks[rng.randi_range(0, blocks.size() - 1)].new()
