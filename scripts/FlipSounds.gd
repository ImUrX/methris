extends AudioStreamPlayer


export(Array, AudioStreamSample) var flip_sounds: Array

var flip_index = 0

func _on_TileMap_flip(_type):
	self.stream = flip_sounds[flip_index]
	self.play()
	if flip_sounds.size() > flip_index + 1: flip_index += 1


func _on_TileMap_newBlock(_instance, _future):
	flip_index = 0
