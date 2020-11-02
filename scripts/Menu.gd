extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -15)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
