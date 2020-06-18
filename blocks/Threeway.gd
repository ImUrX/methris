extends "res://blocks/Block.gd"

func _init():
	size = 3
	matrix[2][1] = true
	matrix[1][1] = true
	matrix[0][1] = true # ##
	matrix[1][0] = true # ##


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
