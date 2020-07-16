extends "res://blocks/Block.gd"

func _init():
	defaultTile = 8
	size = 2
	matrix[1][1] = true
	matrix[1][0] = true
	matrix[0][1] = true # ##
	matrix[0][0] = true # ##


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
