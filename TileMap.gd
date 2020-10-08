extends TileMap

const xMax = [10,20]
const yMax = [0,20]
var blocks = [load("res://blocks/L.gd"), load("res://blocks/Square.gd"), load("res://blocks/Threeway.gd"), load("res://blocks/Stick.gd"), load("res://blocks/J.gd"), load("res://blocks/S.gd"), load("res://blocks/Z.gd")]

# Declare member variables here. Examples:
var time = 0
var rng = RandomNumberGenerator.new()
var controls = load("res://Controls.gd").new()
var instance
var score = 0
# var b = "text"

signal fullLineDone(y)
signal allFullLineDone
signal newBlock(instance)
signal graph(x, y)
signal flip

func _ready():
	rng.randomize()
	instance = randomBlock()
	emit_signal("newBlock", instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	controls._process(delta)
	if controls.getAction("flip"):
		if instance.flip(self): 
			emit_signal("flip")
	if controls.getAction("left"):
		instance.graph(self, -1)
		instance.x -= 1
		if instance.tryGraph(self, 0):
			instance.x += 1
			instance.graph(self, 0)
		else:
			instance.graph(self, 0)
			emit_signal("graph", -1, 0)
	if controls.getAction("right"):
		instance.graph(self, -1)
		instance.x += 1
		if instance.tryGraph(self, 0):
			instance.x -= 1
			instance.graph(self, 0)
		else:
			instance.graph(self, 0)
			emit_signal("graph", 1, 0)
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
		var success = false
		for i in range(1, instance.size + 1):
			var y = instance.y - i
			if(not fullLine(y)): continue
			instance.y += 1
			success = true
			emit_signal("fullLineDone", y)
			var ran = range(yMax[0], y)
			ran.invert()
			for j in range (xMax[0], xMax[1]):
				self.set_cell(j, y, -1)
			for j in range(xMax[0], xMax[1]):
				for k in ran:
					self.set_cell(j, k + 1, self.get_cell(j, k))
					self.set_cell(j, k, -1)
				#agregar puntitos
		if success: emit_signal("allFullLineDone")
		#Termina de checkear si las líneas estaban completas y si estaban, las borra y corrige acorde.
		#Antes de agregar un nuevo bloque, checkea si el jugador perdió:
		for i in range(xMax[0], xMax[1]):
			if(self.get_cell(i, yMax[0]-1) != -1):
				global.lastScore = score
				print("perdio")
				uploadScore()
				get_tree().change_scene("res://youlose.tscn")
		instance = randomBlock()
		emit_signal("newBlock", instance)
		return
	instance.graph(self, -1)
	instance.y += 1
	instance.graph(self, 0)
	emit_signal("graph", 0, 1)

func randomBlock():
	return blocks[rng.randi_range(0, blocks.size() - 1)].new()

func fullLine(y: int):
	for x in range(10, 20):
		if not (self.get_cell(x, y) >= 3): return false
	return true

var sentScore = false
func uploadScore():
	if sentScore: return
	sentScore = true
	var params
	if OS.has_feature("JavaScript"):
		params = JavaScript.eval("""
			let url = new URL(window.location.href);
			return [url.searchParams.get(\"user\"), url.searchParams.get(\"token\")];
		""")
	if params == null: return
	var data = JSON.print({
		"score": score,
		"time": OS.get_system_time_msecs()
	})
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request("https://paginatetris2.firebaseio.com/scores/%s.json?access_token=%s" % params, headers, true, HTTPClient.METHOD_POST, data)

func actualizarScore():
	$NumberMap/ScoreLabel.set_text("Score: %d" % score)
