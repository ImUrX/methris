extends TileMap

const xMax = [10,20]
const yMax = [0,20]
const Block = preload("res://blocks/Block.gd")
const Controls = preload("res://scripts/Controls.gd")
var blocks = [load("res://blocks/L.gd"), load("res://blocks/Square.gd"), load("res://blocks/Threeway.gd"), load("res://blocks/Stick.gd"), load("res://blocks/J.gd"), load("res://blocks/S.gd"), load("res://blocks/Z.gd")]

var combo := -1
var level := 1 setget level_set
var time: float = 0
var start_round := OS.get_unix_time()
var controls := Controls.new()
var instance: Block
var score := 0
var score_followers := []
var saved := false
var pocket
var pocket_instance: Block

signal fullLineDone(y, realY)
signal allFullLineDone(n_lines)
signal newBlock(instance, future)
signal graph(x, y)
signal flip(type)
signal saveBlock
signal placedBlock
signal loadBlock(instance)

func _ready():
	score_followers.append(funcref(self, "base_mult"))
	
	for blockt in blocks:
		block_bag.append(blockt.new())
	block_bag.shuffle()
	instance = randomBlock()
	emit_signal("newBlock", instance, block_bag[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	controls.process(delta)
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
		var speed = get_speed()
		if controls.getAction("down"):
			time = 0
		elif time >= speed:
			time -= speed
		else:
			return
		instance.graph(self, -1)
		instance.y += 1
		try = instance.tryGraph(self, 0)
		instance.y -= 1
		instance.graph(self, 0)
	
	if(try):
		var base_score: float = 0
		var n_lines: int = 0
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
			n_lines += 1
			success = true
			base_score = calc_base_score(lastY, y)
			update_level()
			emit_signal("fullLineDone", lastY, y)
			
			var ran = range(yMax[0], y)
			ran.invert()
			for j in range (xMax[0], xMax[1]):
				self.set_cell(j, y, -1)
			for j in range(xMax[0], xMax[1]):
				for k in ran:
					self.set_cell(j, k + 1, self.get_cell(j, k))
					self.set_cell(j, k, -1)
		if success:
			combo += 1
			calc_score(base_score, n_lines)
			emit_signal("allFullLineDone", n_lines)
		#Termina de checkear si las líneas estaban completas y si estaban, las borra y corrige acorde.
		#Antes de agregar un nuevo bloque, checkea si el jugador perdió:
		for i in range(xMax[0], xMax[1]):
			if(self.get_cell(i, yMax[0]-1) != -1):
				global.lastScore = score
				upload_score()
				$GameOver/FailSound.play()
				$GameOver.visible = true
				get_tree().paused = true
		
		if combo > -1:
			score += combo * 50
			combo = -1
			$NumberMap/ScoreLabel.set_text("Score: %d" % self.score)
		
		emit_signal("placedBlock")
		instance = randomBlock()
		emit_signal("newBlock", instance, block_bag[0])
		saved = false
		return
	instance.graph(self, -1)
	instance.y += 1
	instance.graph(self, 0)
	emit_signal("graph", 0, 1)
	
func get_speed() -> float:
	return pow(0.8-((level-1)*0.007), level-1)

func level_set(new_level: int) -> void:
	level = new_level
	$LevelLabel.set_text("Level: %d" % new_level)

func update_level() -> void:
	var new_level = (score/100)/(level * 5) + 1
	if new_level <= level: return
	level_set(new_level)
	if level > 20:
		level = 20

var block_bag := []
func randomBlock() -> Block:
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

func showFuture() -> void:
	var block: Block = block_bag[0]
	block.x = 25
	block.y = 5
	block.graph(self, 0)
	

func fullLine(y: int) -> bool:
	for x in range(10, 20):
		if not (self.get_cell(x, y) >= 3): return false
	return true

func upload_score() -> void:
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

func base_mult(fakeY: int, _realY: int) -> float:
	return float(level + (fakeY * -1) + 20)

func calc_base_score(fakeY: int, realY: int) -> float:
	if self.score_followers.empty(): return .0
	var result: float = 1
	for follower in self.score_followers:
		result *= (follower as FuncRef).call_func(fakeY, realY)
	return result

func calc_score(base_score: float, n_lines: int) -> void:
	self.score += int(base_score * n_lines)
	$NumberMap/ScoreLabel.set_text("Score: %d" % self.score)

func get_block_type() -> Object:
	for type in blocks:
		if instance is type:
			return type
	return null
