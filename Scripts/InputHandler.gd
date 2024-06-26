extends Node

onready var cart = get_parent().get_node("Cart")
onready var cart_travel = get_parent().cart_travel_per_keystroke
onready var cart_speed = get_parent().cart_speed_per_keystroke
onready var output_handler = get_parent().get_node("OutputHandler")

var letters = "qwertyuiopasdfghjklzxcvbnm123456789"
var shifted = false

#Maps input action names to typeable characters. Populate it with this typewriters special characters,
#letters will be added by code.
var input_map : Dictionary = {
	"comma" : ",,",
	"period" : "..",
	"slash" : "/?",
}

var buttons = ["backspace", "spacebar"]

func _ready():
	#populate input map with letters
	for i in letters:
		input_map[i] = i + i.to_upper()
	print(input_map)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event):
#shift key
	if event.is_action("shift"):
		shifted = !shifted

#handles all keys that print things
	for i in input_map.keys():
		if event.is_action_pressed(i):
			get_parent().get_node("Keys").animate_press(i)
			get_parent().get_node("SoundHandler").play(0)
			cart.advance(cart_travel/2, cart_speed, false)
			output_handler.write(input_map[i][int(shifted)])
			return
		elif event.is_action_released(i):
			cart.advance(cart_travel/2, cart_speed, false)
			get_parent().get_node("Keys").animate_release(i)
			return

#handles keys that dont print things
	for i in buttons:
		if event.is_action_pressed(i):
			if i == "backspace" and cart.translation.x >= owner.min_cart_travel + owner.cart_travel_per_keystroke:
				cart.backspace(cart_travel, cart_speed, false)
				get_parent().get_node("Buttons").animate(i, true)
				output_handler.backspace()
				return
			elif i == "spacebar":
				cart.advance(cart_travel/2, cart_speed, false)
				output_handler.write(' ')
				get_parent().get_node("Buttons").animate(i, true)
				return
		elif event.is_action_released(i):
			if i =="spacebar":
				cart.advance(cart_travel/2, cart_speed, false)
				
#		elif event.is_action_released(i):
#			cart.advance(cart_travel/2, cart_speed, false)
#			get_parent().get_node("Buttons").animate(i, false)
