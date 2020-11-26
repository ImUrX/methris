extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var err = config.load("user://settings.cfg")
	if err == OK:
		var master_bus = config.get_value("audio", "master", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_bus)
		var music_bus = config.get_value("audio", "music", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_bus)
		var sfx_bus = config.get_value("audio", "sfx", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), sfx_bus)
	set_process_input(true)
	$Tutorial/tuto.texture = aux[tuto]
	$Options/TabContainer/Audio/Control/VolumeLabel/MasterSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	$Options/TabContainer/Audio/Control/MusicLabel/MusicSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	$Options/TabContainer/Audio/Control/EffectLabel/EffectSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects"))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
export(Array, Texture) var aux
var tuto = 0
var tutobool = false

func _input(event):
	if !tutobool: return
	var just_released = !event.is_pressed() and not event.is_echo()
	if just_released and (event is InputEventKey or event is InputEventMouseButton):
		tuto += 1
		if tuto >= aux.size():
			tutobool = false
			$Tutorial.visible = false
			$MainMenu.visible = true
			tuto = 0
		$Tutorial/tuto.texture = aux[tuto]
		

func _on_TextureButton_pressed():
	get_tree().change_scene("res://Game.tscn")


func _on_OptionsMenuButton_pressed():
	$MainMenu.visible = false
	$Options.visible = true


func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	config.set_value("audio", "master", value)

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
	config.set_value("audio", "music", value)
	
func _on_EffectSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), value)
	config.set_value("audio", "sfx", value)

func _on_BackButton_pressed():
	config.save("user://settings.cfg")
	$MainMenu.visible = true
	$Options.visible = false


func _on_TutorialMenuButton_pressed():
	$MainMenu.visible = false
	$Tutorial.visible = true
	tutobool = true


func _on_play_pressed():
	global.math = $PlaySettings/MathLabel/CheckButton.pressed
	global.normal = $PlaySettings/NormalLabel/CheckButton.pressed
	global.level = $PlaySettings/LevelLabel/SpinBox.value
	get_tree().change_scene("res://Game.tscn")
