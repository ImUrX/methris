extends Node

var matrix = []

var y = 0
var x = 0
var flipNum = 0
var touched = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init():
	for x in range(4):
		matrix.append([])
		for _y in range(4):
			matrix[x].append(false)
	matrix[0][2] = true # |
	matrix[0][1] = true # |
	matrix[0][0] = true # |_
	matrix[1][0] = true
	matrix[1][1] = true

func graph(tilemap: TileMap, tile: int):
	for toX in range(4):
		for toY in range(4):
			if(not matrix[toX][toY]): continue
			var cell = tilemap.get_cell(toX + x - 4, toY + y - 4)
			if(cell > -1 and tile > -1):
				touched = true
				return touched
			tilemap.set_cell(toX + x - 4, toY + y - 4, tile)

func flip():
	pass

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
