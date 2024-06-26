extends Spatial

export (NodePath) var target

# mouse properties

export (float, 0.001, 0.1) var mouse_sensitivity = 0.005
export (float, 0.001, 0.1) var mouse_smoothing = 0.15
export (float) var max_zoom = 1.3
export (float) var min_zoom = 0.3
export (float, 0.05, 1.0) var zoom_speed = 0.09

# focus mode

export (Vector2) var focused_camera_rotation = Vector2(-0.011,-0.22)
export (Vector3) var focused_camera_location = Vector3(0, 0.491,0.668)
export (float) var reset_duration = 1.2

# movement properties

export (Vector2) var max_movement = Vector2(0.6, 0.6)


var zoom = 1
var default_transform
var target_offset = Vector2(0,0)
var true_offset = Vector2(0, 0)
var target_rotation = Vector2(0,0)

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

#camera
onready var camera = $OuterGimbal/InnerGimbal/ClippedCamera

#raycast
onready var ray = $OuterGimbal/InnerGimbal/ClippedCamera/RayCast
onready var music_change_area = owner.get_node("MusicChangeArea")
var aimedObject = null
var interact_areas = [music_change_area]

#modes
onready var tween = owner.get_node("Tween")

#default camera position
var default_camera = Vector3(0, 1.015, 0.822)


func _ready():
	default_transform = global_transform

func _process(delta):
	#Show crosshair only if is active camera
	if camera.current:
		$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer.visible = true
	else:
		$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer.visible = false
	
	#clamp rotation and target rotation
	$OuterGimbal/InnerGimbal.rotation.x = clamp($OuterGimbal/InnerGimbal.rotation.x, -1, 1.4)
	target_rotation.y = clamp(target_rotation.y, -1, 1.4)
	
	#apply rotation
	$OuterGimbal.rotation.y = lerp($OuterGimbal.rotation.y, target_rotation.x, delta/mouse_smoothing)
	$OuterGimbal/InnerGimbal.rotation.x = lerp($OuterGimbal/InnerGimbal.rotation.x, target_rotation.y, delta/mouse_smoothing)
	
	#Apply offset
	applyOffset(target_offset)
	target_offset=Vector2(0,0)
	
	#Apply zoom and sensivity
	camera.fov = lerp(camera.fov, 70 * zoom, delta/mouse_smoothing)
	lookatHandler()

func _input(event):
	# Mouse stuff.
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if $OuterGimbal/InnerGimbal/ClippedCamera.current:
		#Capture/release mouse
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			return
		#Camera reset
		if event.is_action_pressed("reset_camera"):
			resetCamera(focused_camera_rotation)
		#Zoom input
		if event.is_action_pressed("cam_zoom_in"):
			zoom -= zoom_speed
		if event.is_action_pressed("cam_zoom_out"):
			zoom += zoom_speed
		#Zoom clamping
		zoom = clamp(zoom, min_zoom, max_zoom)
			
		if event is InputEventMouseMotion:
			#camera movement
			if Input.is_action_pressed("cam_move"):
				if event.relative.x != 0:
					var dir = -1
					target_offset.x = dir * -event.relative.x * mouse_sensitivity * 0.1
				if event.relative.y != 0:
					var dir = -1
					target_offset.y = dir * event.relative.y * mouse_sensitivity * 0.1
			#camera rotation
			else:
				if event.relative.x != 0:
					var dir = -1
					target_rotation.x = target_rotation.x + (dir*event.relative.x*mouse_sensitivity)

				if event.relative.y != 0:
					var dir = -1
					target_rotation.y = target_rotation.y + (dir*event.relative.y*mouse_sensitivity)

func applyOffset(target_offset):
	if (true_offset.x + target_offset.x) >= max_movement.x or (true_offset.x + target_offset.x) <= -max_movement.x:
		target_offset.x = 0
	if (true_offset.y + target_offset.y) >= max_movement.y or (true_offset.y + target_offset.y) <= -max_movement.y:
		target_offset.y = 0
	#translate camera
	translate(Vector3(target_offset.x, target_offset.y, 0))
	#update offset amount
	true_offset = Vector2(true_offset.x + target_offset.x, true_offset.y + target_offset.y)
	#reset target offset
	target_offset = Vector2(0,0)
	print(true_offset)

func resetCamera(camera_rotation):
	true_offset = Vector2(0, 0)
	target = null
	target_rotation = focused_camera_rotation
	tween.interpolate_property(self, "zoom", zoom, 0.55, reset_duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "translation", translation, focused_camera_location, reset_duration, Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
	tween.start()
	#translation = focused_camera_location
	$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer/Crosshair.visible = true

func lookatHandler():
	if $OuterGimbal/InnerGimbal/ClippedCamera.current and interact_areas.has(ray.get_collider()):
		aimedObject = ray.get_collider()
		$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer/Crosshair.texture = crosshairs[aimedObject.indicator]
	else:
		aimedObject = null
		$OuterGimbal/InnerGimbal/ClippedCamera/CrosshairContainer/Crosshair.texture = dot_img
