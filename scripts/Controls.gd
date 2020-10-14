extends Node
var controls = {
	"flip": 0,
	"left": 0,
	"right": 0,
	"down": 0
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	for control in controls.keys():
		if Input.is_action_just_pressed(control):
			controls[control] += 0.2 + delta
		elif Input.is_action_pressed(control):
			controls[control] += delta
		elif controls[control] >= 0:
			controls[control] = 0
			
func getAction(action):
	if controls[action] >= 0.2:
		controls[action] -= 0.2
		return true
	return false
