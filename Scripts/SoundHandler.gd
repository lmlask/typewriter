extends Node

export var keysound1 : AudioStream

onready var key_sounds = []
onready var shift_sounds = []
onready var sound_profile = owner.sound_profile

#0 = key
#1 = spacebar
#2 = shift

func _ready():
	if sound_profile == "portable":
		for i in range (0, 15):
			key_sounds.append(load("res://Sfx/Typewriters/Portable/key" + String(i+1) + ".mp3"))
		for i in range (0, 5):
			pass
			
	print(key_sounds)
	print(shift_sounds)
	
func play(profile):
	if profile == 0:
		owner.get_parent().get_node("Keys").stream = key_sounds[int(rand_range(0, 15))]
		owner.get_parent().get_node("Keys").play()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
