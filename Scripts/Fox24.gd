extends Spatial

export var key_depth : float = 0.015
export var keystroke_duration : float = 0.07
export var cart_speed_per_keystroke : float = 0.04
export var cart_travel_per_keystroke : float = 0.005

export var min_cart_travel = -0.162
export var car_midpos = -0.028
export var max_cart_travel = 0.11
export var ding_threshold = 0.076

export var sound_profile : String = "portable"

onready var viewport = get_parent().owner.get_node("Viewport")

func _process(delta):
	var texture = viewport.get_texture()
	texture.flags = Texture.FLAGS_DEFAULT
	$Cart/cart/sheet.mesh.surface_get_material(0).albedo_texture = viewport.get_texture()
