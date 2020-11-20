extends TileMap

const xMax = [10,20]
const yMax = [0,20]
const Block = preload("res://blocks/Block.gd")
var blocks = [load("res://blocks/L.gd"), load("res://blocks/Square.gd"), load("res://blocks/Threeway.gd"), load("res://blocks/Stick.gd"), load("res://blocks/J.gd"), load("res://blocks/S.gd"), load("res://blocks/Z.gd")]

# Declare member variables here. Examples:
var time = 0
var start_round = OS.get_unix_time()
var controls = load("res://scripts/Controls.gd").new()
var instance: Block
var score = 0
var saved = false
var pocket
var pocket_instance: Block

signal fullLineDone(y, realY)
signal allFullLineDone
signal newBlock(instance, future)
signal graph(x, y)
signal flip(type)
signal saveBlock
signal loadBlock(instance)

func _ready():
	for blockt in blocks:
		block_bag.append(blockt.new())
	block_bag.shuffle()
	instance = randomBlock()
	emit_signal("newBlock", instance, block_bag[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	controls._process(delta)
	var try
	if Input.is_action_just_pressed("instadown"):
		instance.graph(self, -1)
		var originalY = instance.y
		instance.set_lowest_collission(self)
		emit_signal("graph", 0, instance.y - originalY)
		instance.graph(self, 0)
		try = true
	elif Input.is_action_just_pressed("save") and !saved:
		instance.graph(self, -1)
		var block = get_block_type()
		if pocket == null:
			instance = randomBlock()
			emit_signal("saveBlock")
			emit_signal("newBlock", instance, block_bag[0])
		else:
			pocket_instance.graph(self, -1)
			instance = pocket.new()
			emit_signal("loadBlock", instance)
		pocket = block
		pocket_instance = block.new()
		pocket_instance.x = 9
		pocket_instance.y = 5
		pocket_instance.graph(self, 0)
		saved = true
	else:
		if Input.is_action_just_pressed("flip"):
			var state = instance.complex_flip(self)
			if state != Block.FLIP_STATE.FAILED: emit_signal("flip", state)
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
				$GameOver/FailSound.play()
				$GameOver.visible = true
				get_tree().paused = true
		instance = randomBlock()
		emit_signal("newBlock", instance, block_bag[0])
		saved = false
		return
	instance.graph(self, -1)
	instance.y += 1
	instance.graph(self, 0)
	emit_signal("graph", 0, 1)

var block_bag: Array = []
func randomBlock():
	var block: Block = block_bag.pop_front()
	if block_bag.size() == 0:
		for blockt in blocks:
			block_bag.append(blockt.new())
		block_bag.shuffle()
	block.graph(self, -1)
	block.x = 16
	block.y = -1
	showFuture()
	return block

func showFuture():
	var block: Block = block_bag[0]
	block.x = 25
	block.y = 5
	block.graph(self, 0)
	

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
