extends Node
var controls = {
	"flip": {
		"time": 0,
		"req": 0.25,
		"slowStart": null
	},
	"left": {
		"time": 0,
		"req": 0.15,
		"slowStart": false
	},
	"right": {
		"time": 0,
		"req": 0.15,
		"slowStart": false
	},
	"down": {
		"time": 0,
		"req": 0.1,
		"slowStart": null
	}
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	for control in controls.keys():
		if Input.is_action_just_pressed(control):
			controls[control]["time"] += controls[control]["req"] + delta
			if controls[control]["slowStart"] == false:
				controls[control]["slowStart"] = true
		elif Input.is_action_pressed(control):
			controls[control]["time"] += delta
		elif controls[control]["req"] >= 0:
			controls[control]["time"] = 0
			
func getAction(action):
	var mult = 1
	if controls[action]["slowStart"]:
		mult = 3
		controls[action]["slowStart"] = false
	if controls[action]["time"] >= controls[action]["req"] * mult:
		controls[action]["time"] -= controls[action]["req"] * mult
		return true
	return false
