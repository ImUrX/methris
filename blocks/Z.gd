extends "res://blocks/Block.gd"

func _init():
	defaultTile = 4
	size = 3
	matrix[0][1] = true
	matrix[1][1] = true # |
	matrix[1][2] = true # |
	matrix[2][2] = true # |_

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
