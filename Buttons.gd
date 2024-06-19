extends Spatial

#maps input actions to meshes
onready var button_dict = {
	"backspace" : $right_button,
	"spacebar" : $spacebar
}

#maps buttons to their low and high values
onready var high_lo_dict = {
	$right_button : Vector2(0.035, 0.025),
	$spacebar : Vector2(-3, 0)
}

func animate(action, pressed):
	var button = button_dict[action]
	var dest = high_lo_dict[button].x if pressed else high_lo_dict[button].y
	if action == "backspace":
		owner.get_node("Tween").interpolate_property(button, "translation:z", button.translation.z, dest, owner.keystroke_duration*2, Tween.TRANS_BACK, Tween.EASE_OUT)
		owner.get_node("Tween").start()
	elif action == "spacebar":
		owner.get_node("Tween").interpolate_property(button, "rotation_degrees:x", button.rotation_degrees.x, dest, owner.keystroke_duration*2, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		owner.get_node("Tween").start()
