extends Spatial

var has_dinged = false
var sheet

onready var max_travel = owner.max_cart_travel
onready var min_travel = owner.min_cart_travel
onready var ding_threshold = owner.ding_threshold

func advance(amount, duration, animate=true):
	if animate and translation.x < owner.max_cart_travel:
		get_parent().get_node("Tween").interpolate_property(self, "translation:x", translation.x, translation.x + amount, duration, Tween.TRANS_CUBIC, Tween.EASE_IN)
		get_parent().get_node("Tween").start()
	elif translation.x < owner.max_cart_travel:
		translation.x += amount
	if translation.x > ding_threshold:
		if not has_dinged:
			print("DING, MOTHERFUCKER")
			has_dinged = true

func backspace(amount, duration, animate=true):
	if animate:
		get_parent().get_node("Tween").interpolate_property(self, "translation:x", translation.x, translation.x - amount, duration*3, Tween.TRANS_BACK, Tween.EASE_OUT)
		get_parent().get_node("Tween").start()
	else:
		translation.x -= amount

func _ready():
	sheet = get_node("cart/sheet")
	translation.x = owner.min_cart_travel

func _process(delta):
	pass
#	sheet.mesh.surface_get_material(0).uv1_offset.x -= 0.01 * delta *4
#	get_node("cart/roll").rotation_degrees.x += 15 * delta * 4
		
