extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_tryagainbutton_pressed():
	var ret = get_tree().reload_current_scene()
	print(ret)
	get_tree().paused = false


func _on_menubutton_pressed():
	get_tree().change_scene("res://Control.tscn")
	get_tree().paused = false
