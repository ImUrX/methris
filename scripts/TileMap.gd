extends TileMap

const xMax = [10,20]
const yMax = [0,20]
var blocks = [load("res://blocks/L.gd"), load("res://blocks/Square.gd"), load("res://blocks/Threeway.gd"), load("res://blocks/Stick.gd"), load("res://blocks/J.gd"), load("res://blocks/S.gd"), load("res://blocks/Z.gd")]

# Declare member variables here. Examples:
var time = 0
var rng = RandomNumberGenerator.new()
var start_round = OS.get_unix_time()
var controls = load("res://scripts/Controls.gd").new()
var instance
var score = 0
var saved = false
var pocket
var pocket_instance

signal fullLineDone(y, realY)
signal allFullLineDone
signal newBlock(instance)
signal graph(x, y)
signal flip
signal saveBlock
signal loadBlock(instance)

func _ready():
	rng.randomize()
	instance = randomBlock()
	emit_signal("newBlock", instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	controls._process(delta)
	var try
	if Input.is_action_just_pressed("instadown"):
		instance.graph(self, -1)
		var originalY = instance.y
		instance.get_lowest_collission(self)
		emit_signal("graph", 0, instance.y - originalY)
		instance.graph(self, 0)
		try = true
	elif Input.is_action_just_pressed("save") and !saved:
		instance.graph(self, -1)
		var block = get_block_type()
		if pocket == null:
			instance = randomBlock()
			emit_signal("saveBlock")
			emit_signal("newBlock", instance)
		else:
			pocket_instance.graph(self, -1)
			instance = pocket.new()
			emit_signal("loadBlock", instance)
		pocket = block
		pocket_instance = block.new()
		pocket_instance.x = 8
		pocket_instance.y = 5
		pocket_instance.graph(self, 0)
		saved = true
	else:
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
		try = instance.tryGraph(self, 0)
		instance.y -= 1
		instance.graph(self, 0)
	if(try):
		var success = false
		var lastY
		for i in range(1, instance.size + 1):
			var y = instance.y - i
			if(not fullLine(y)): continue
			if lastY == null:
				lastY = y
			else:
				lastY -= 1
			instance.y += 1
			success = true
			emit_signal("fullLineDone", lastY, y)
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
				uploadScore()
				get_tree().paused = true
				$GameOver.visible = true
		instance = randomBlock()
		emit_signal("newBlock", instance)
		saved = false
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

func uploadScore():
	var token
	var userId
	if OS.has_feature("JavaScript"):
		userId = JavaScript.eval("sessionStorage.getItem(\"userId\")")
		token = JavaScript.eval("sessionStorage.getItem(\"token\")")
	if token == null or userId == null: return
	var data = JSON.print({
		"score": score,
		"time": OS.get_system_time_msecs(),
		"duration": OS.get_unix_time() - start_round
	})
	var headers = ["Content-Type: application/json"]
	$ScoreUpdate.request("https://paginatetris2.firebaseio.com/scores/%s.json?auth=%s" % [userId, token], headers, true, HTTPClient.METHOD_POST, data)

func actualizarScore():
	$NumberMap/ScoreLabel.set_text("Score: %d" % score)

func get_block_type():
	for type in blocks:
		if instance is type:
			return type
