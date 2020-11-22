extends AudioStreamPlayer

export(Array, AudioStreamSample) var block_sounds: Array
export(AudioStreamSample) var line_sound: AudioStreamSample

var block_index = 0
var dont_play = false

func _on_TileMap_placedBlock():
	if dont_play: 
		dont_play = false
		return
	self.stream = block_sounds[block_index]
	self.play()
	if block_sounds.size() > block_index + 1: block_index += 1

func _on_TileMap_allFullLineDone():
	block_index = 0
	dont_play = true
	self.stream = line_sound
	self.play()
