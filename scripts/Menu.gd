extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Tutorial/tuto.texture = aux[tuto]
	$Options/VolumeLabel/HSlider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
export(Array, Texture) var aux
var tuto = 0
var tutobool = false


func _input(event):
	if !tutobool: return
	var just_pressed = event.is_pressed() and not event.is_echo()
	if just_pressed and (event is InputEventKey or event is InputEventMouseButton):
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


func _on_BackButton_pressed():
	$MainMenu.visible = true
	$Options.visible = false


func _on_TutorialMenuButton_pressed():
	$MainMenu.visible = false
	$Tutorial.visible = true
	tutobool = true



