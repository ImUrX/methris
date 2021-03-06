extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause") && !get_node("../GameOver").visible:
		var paused_mode = !self.visible
		if paused_mode: $PausePlayer.play()
		self.visible = paused_mode
		get_tree().paused = paused_mode
