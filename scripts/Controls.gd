var controls = {
	"flip": {
		"time": 0,
		"req": 0.15,
		"slowStart": null
	},
	"left": {
		"time": 0,
		"req": 0.05,
		"slowStart": false
	},
	"right": {
		"time": 0,
		"req": 0.05,
		"slowStart": false
	},
	"down": {
		"time": 0,
		"req": 0.05,
		"slowStart": null
	}
}

var touch_info := {
	"start_pos": null
}

func time_equal_req(control: String, delta: float = 0):
	controls[control]["time"] = controls[control]["req"] + delta

func input(ev: InputEventScreenTouch):
	if ev.index == 0:
		if touch_info["start_pos"] == null: 
			touch_info["start_pos"] = ev.position
		elif !ev.pressed:
			var dis: float = touch_info["start_pos"].distance_to(ev.position)
			if abs(dis) >= 0.5:
				var dir: Vector2 = touch_info["start_pos"].direction_to(ev.position)
				if dir.is_equal_approx(Vector2.UP):
					var event = InputEventAction.new()
					event.pressed = true
					event.action = "instadown"
					Input.parse_input_event(event)
				elif dir.is_equal_approx(Vector2.LEFT):
					time_equal_req("left")
				elif dir.is_equal_approx(Vector2.RIGHT):
					time_equal_req("right")
				elif dir.is_equal_approx(Vector2.DOWN):
					time_equal_req("down")
			else:
				time_equal_req("flip")
			touch_info["start_pos"] = null

func process(delta):
	for control in controls.keys():
		if Input.is_action_just_pressed(control):
			time_equal_req(control, delta)
			if control == "right":
				controls["left"]["time"] = 0
			elif control == "left":
				controls["right"]["time"] = 0
			if controls[control]["slowStart"] == false:
				controls[control]["slowStart"] = true
		elif Input.is_action_pressed(control):
			controls[control]["time"] += delta
		elif controls[control]["req"] >= 0:
			controls[control]["time"] = 0
			
func getAction(action):
	var mult = 1
	if controls[action]["slowStart"]:
		mult = 5
		controls[action]["slowStart"] = false
	if controls[action]["time"] >= controls[action]["req"]:
		controls[action]["time"] -= controls[action]["req"] * mult
		return true
	return false
