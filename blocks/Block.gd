extends Node

var matrix = []

var y = 0
var x = 0
var size = 4

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init():
	for x in range(size):
		matrix.append([])
		for _y in range(size):
			matrix[x].append(false)

func graph(tilemap: TileMap, tile: int):
	for toX in range(size):
		for toY in range(size):
			if(not matrix[toX][toY]): continue
			tilemap.set_cell(toX + x - size, toY + y - size, tile)

func tryGraph(tilemap: TileMap, tile: int):
	for toX in range(size):
		for toY in range(size):
			if(not matrix[toX][toY]): continue
			var cell = tilemap.get_cell(toX + x - size, toY + y - size)
			if(cell > -1 and tile > -1):
				return true
	return false

func flip(tilemap: TileMap):
	var copy = matrix.duplicate(true)
	var copy2
	for toX in range(size):
		for toY in range(size):
			matrix[toX][toY] = copy[size - toY - 1][toX]
	copy2 = matrix
	matrix = copy
	graph(tilemap, -1)
	matrix = copy2
	if(tryGraph(tilemap, 0)):
		matrix = copy
		graph(tilemap, 0)
		return true
	graph(tilemap, 0)
	return false

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
