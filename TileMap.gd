extends TileMap


const xMax = 10
const yMax = 16
var L = load("res://blocks/L.gd")

# Declare member variables here. Examples:
var instance = L.new()
var time = 0
var rng = RandomNumberGenerator.new()
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	instance.x = 5
	instance.y = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if(time > 0.5):
		instance.graph(self, -1)
		instance.y += 1
		if(instance.graph(self, 0) or instance.y == yMax):
			instance = L.new()
			instance.x = 5
			pass
		time -= 0.5
		pass
	pass
