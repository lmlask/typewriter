extends Spatial

onready var tween = get_parent().get_node("Tween")

onready var DEPTH = owner.key_depth
onready var DURATION = owner.keystroke_duration

onready var high = translation.y
onready var low = translation.y - DEPTH

#maps each key to its default translation.y
onready var depth_dict : Dictionary

#maps each input action to a mesh
onready var mesh_map : Dictionary = {
	"0" : "0",
	"2" : "2",
	"3" : "3",
	"4" : "4",
	"5" : "5",
	"6" : "6",
	"7" : "7",
	"8" : "8",
	"9" : "9",
	"a" : "A",
	"b" : "B",
	"c" : "C",
	"d" : "D",
	"e" : "E",
	"f" : "F",
	"g" : "G",
	"h" : "H",
	"i" : "I",
	"j" : "J",
	"k" : "K",
	"l" : "L",
	"m" : "M",
	"n" : "N",
	"o" : "O",
	"p" : "P",
	"q" : "Q",
	"r" : "R",
	"s" : "S",
	"t" : "T",
	"u" : "U",
	"v" : "V",
	"w" : "W",
	"x" : "X",
	"y" : "Y",
	"z" : "Z",
	"comma" : "comma",
	"period" : "comma",
	"slash" : "slash"
}

var pose_tape_up = Transform(Vector3(1,0,0), Vector3(0,1.5,0), Vector3(0,0.988,0), Vector3(0,0,0))
var pose_tape_down = Transform(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,0))

func _ready():
	for i in get_children():
		depth_dict[i] = i.translation.y

#key is a string relating to the input action just performed.
func animate_press(key):
	var mesh = get_node(mesh_map[key])
	tween.interpolate_property(mesh, "translation:y", mesh.translation.y, depth_dict[mesh] - DEPTH, DURATION, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	owner.get_node("case/tape/skeleton").set_bone_custom_pose(0, pose_tape_up)
	owner.get_node("case/riser").translation.y = 0.02
	tween.start()

func animate_release(key):
	var mesh = get_node(mesh_map[key])
	owner.get_node("case/tape/skeleton").set_bone_custom_pose(0, pose_tape_down)
	owner.get_node("case/riser").translation.y = 0.00
	tween.interpolate_property(mesh, "translation:y", mesh.translation.y, depth_dict[mesh], DURATION*2, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
