extends Node

var matrix = []

var x = 16
var y = -1
var size = 4
var defaultTile = 3

enum FLIP_STATE { FAILED, NORMAL, RIGHT, LEFT }

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init():
	for _x in range(size):
		matrix.append([])
		for _y in range(size):
			matrix[_x].append(false)

func graph(tilemap: TileMap, tile: int):
	if tile == 0:
		tile = defaultTile
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

func flip(tilemap: TileMap, low_level: bool = false):
	var backup = matrix
	var matrixT = matrix.duplicate(true)
	for toX in range(size):
		for toY in range(size):
			matrixT[toY][toX] = matrix[toX][toY] #transpose
	for toX in range(size/2):
		var arr_copy = matrixT[toX]
		var mirror = size - 1 - toX
		matrixT[toX] = matrixT[mirror]
		matrixT[mirror] = arr_copy
		
	if !low_level: graph(tilemap, -1)
	matrix = matrixT
	if(tryGraph(tilemap, 0)):
		matrix = backup
		if !low_level: graph(tilemap, 0)
		return false
	graph(tilemap, 0)
	return true
	
func complex_flip(tilemap: TileMap) -> int:
	graph(tilemap, -1)
	if flip(tilemap, true): return FLIP_STATE.NORMAL
	x += 1
	if flip(tilemap, true): return FLIP_STATE.RIGHT
	x -= 2
	if flip(tilemap, true): return FLIP_STATE.LEFT
	x += 1
	graph(tilemap, 0)
	return FLIP_STATE.FAILED
	

func set_lowest_collission(tilemap: TileMap):
	while true:
		y += 1
		if tryGraph(tilemap, 0):
			y -= 1
			return
# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
