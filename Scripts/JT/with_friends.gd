extends Control

"""
This will handle the script where the friends are hanging out.
"""
var currentSpeaker = ""

#func _ready():
	#await highlight_speaker("Fry")
	#highlight_speaker("Dulce")

func highlight_speaker(name: String):
	currentSpeaker = name
	var orgScale = get_node(name).scale
	get_node(name).scale = Vector2(orgScale.x + 2, orgScale.y + 2)
	get_node(name).modulate = Color.from_rgba8(255, 255, 255, 255)
	#get_node(name).
	for child in get_children():
		if child.name == name: continue
		child.modulate = Color.from_rgba8(255, 255, 255, 200)
		
	#await get_tree().create_timer(3.0).timeout
	#remove_old_speaker()

func remove_old_speaker():
	var orgScale = get_node(currentSpeaker).scale
	get_node(currentSpeaker).scale = Vector2(orgScale.x - 2, 
	orgScale.y - 2)
