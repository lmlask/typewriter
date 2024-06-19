extends Node

export var label_scene : PackedScene
onready var label : Array = [owner.owner.get_node("Viewport/Label")]

var index = 0
var line = 0
var max_label = 0

func write(tex):
	index += 1
	#before sheet end
	if index < 58:
		label[max_label].text = label[max_label].text + tex
	#on sheet end
	else:
		overtype(58, tex)
		index = 58
	print (index)
		
func overtype(ind, tex):
	var new_label = label_scene.instance()
	label[max_label].get_parent().add_child(new_label)
	label.append(new_label)
	max_label += 1
	for i in range(0, index):
		label[max_label].text += (' ')
		print(i)
	label[max_label].text += tex
	print(index)

func backspace():
	overtype(index, '')
	index -= 1
	print(index)
