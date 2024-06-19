extends Spatial

export (NodePath) var target

# mouse properties

export (float, 0.001, 0.1) var mouse_sensitivity = 0.005
export (float, 0.001, 0.1) var mouse_smoothing = 0.005

# zoom settings

export (float) var max_zoom = 1.3
export (float) var min_zoom = 0.3
export (float, 0.05, 1.0) var zoom_speed = 0.09

# movement properties

export (Vector2) var max_movement = Vector2(0.6, 0.6)

var zoom = 1
var default_sensivity = mouse_sensitivity
var default_transform
var target_offset_x = 0
var target_offset_y = 0
var true_offset = Vector2(0, 0)

#crosshair
onready var hand_img = preload("res://Textures/Icons/hand.png")
onready var eye_img = preload("res://Textures/Icons/eye.png")
onready var cross_img = preload("res://Textures/crosshair.png")
onready var dot_img = preload("res://Textures/Icons/dot.png")
onready var crosshairs = {
	"hand" : hand_img,
	"eye" : eye_img,
	"cross" : cross_img,
	"dot" : dot_img
}

#raycast
onready var ray = $OuterGimbal/InnerGimbal/ClippedCamera/RayCast
var aimedObject = null
var interact_areas = []

#modes
var mode = "pan"
onready var tween = owner.get_node("Tween")

#default camera position
var default_camera = Vector3(0, 1.015, 0.822)

func _ready():
	default_transform = global_transform

func _process(delta):
	#Show crosshair only if is active camera
	if $OuterGimbal/InnerGimbal/ClippedCamera.current:
		$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer.visible = true
	else:
		$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer.visible = false
	
	applyOffset(target_offset_x, target_offset_y)
	
	#clamp rotation
	if mode == "pan" or mode == "hatch":
		$OuterGimbal/InnerGimbal.rotation.x = clamp($OuterGimbal/InnerGimbal.rotation.x, -1, 1.4)

	#Apply zoom and sensivity
	get_node("OuterGimbal/InnerGimbal/ClippedCamera").fov = lerp(get_node("OuterGimbal/InnerGimbal/ClippedCamera").fov, 70 * zoom, 4*delta)
	mouse_sensitivity = default_sensivity * zoom * zoom

	#set target for portmode:
	if target:
		global_transform.origin = target.global_transform.origin
		
	lookatHandler()

func set_current():
	get_node("OuterGimbal/InnerGimbal/ClippedCamera").current = true

func _input(event):
	if $OuterGimbal/InnerGimbal/ClippedCamera.current:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			return
			
		if event.is_action_pressed("reset_camera"):
			resetCamera()
			
		#Zoom input
		if event.is_action_pressed("cam_zoom_in"):
			zoom -= zoom_speed
		if event.is_action_pressed("cam_zoom_out"):
			zoom += zoom_speed
			
		#Zoom clamping
		zoom = clamp(zoom, min_zoom, max_zoom)
			
		if event is InputEventMouseMotion:
			#camera movement
			if Input.is_action_pressed("cam_move") and (mode == "pan"):
				if event.relative.x != 0:
					var dir = -1
					target_offset_x = dir * -event.relative.x * default_sensivity * 0.1
				if event.relative.y != 0:
					var dir = -1
					target_offset_y = dir * event.relative.y * default_sensivity * 0.1
			else:
				if event.relative.x != 0:
					var dir = -1
					$OuterGimbal.rotate_object_local(Vector3.UP, dir * event.relative.x * mouse_sensitivity)

				if event.relative.y != 0:
					var dir = -1
					var y_rotation = clamp(event.relative.y, -30, 30)
					$OuterGimbal/InnerGimbal.rotate_object_local(Vector3.RIGHT, dir * y_rotation * mouse_sensitivity)

func applyOffset(x, y):
	if mode == "pan":
		if (true_offset.x + x) >= max_movement.x or (true_offset.x + x) <= -max_movement.x:
			x = 0
		if (true_offset.y + y) >= max_movement.y or (true_offset.y + y) <= -max_movement.y:
			y = 0
		#translate camera
		translate(Vector3(x, y, 0))
		#update offset amount
		true_offset = Vector2(true_offset.x + x, true_offset.y + y)
		#reset target offset
		target_offset_x = 0
		target_offset_y = 0

func resetCamera(y_rot=0):
	true_offset = Vector2(0, 0)
	target = null
	mode = "pan" 
	$OuterGimbal/InnerGimbal.rotation.x = 0
	$OuterGimbal.rotation.y = deg2rad(y_rot)
	rotation_degrees.y = 0
	transform.origin = default_camera
	$OuterGimbal/InnerGimbal/ClippedCamera.translation.z = 0
	#get_node("OuterGimbal/InnerGimbal/ClippedCamera").fov = 70
	zoom = 1
	$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer/Crosshair.visible = true

func tween_translation(pos, speed, easing):
	tween.interpolate_property(self, "translation", translation, pos, speed, easing, Tween.EASE_IN_OUT)
	tween.start()
	true_offset = Vector2(0, 0)

func lookatHandler():
	if $OuterGimbal/InnerGimbal/ClippedCamera.current and interact_areas.has(ray.get_collider()):
		aimedObject = ray.get_collider()
		if aimedObject.name.substr(0, 3) == "Bin":
			$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer/Crosshair.texture = aimedObject.get_crosshair_tex()
		else:
			$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer/Crosshair.texture = crosshairs[aimedObject.indicator]
	else:
		aimedObject = null
		$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer/Crosshair.texture = dot_img
