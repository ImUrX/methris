extends "res://blocks/Block.gd"

func _init():
	defaultTile = 10
	size = 3
	matrix[1][0] = true
	matrix[0][1] = true
	matrix[1][1] = true # ##
	matrix[2][1] = true # ##


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
