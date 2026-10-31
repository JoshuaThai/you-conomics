extends Button

var debounce : bool = false
var hovering : bool = false

func _process(delta):
	if hovering:
		%Button.add_theme_stylebox_override('hover',
		load("res://Button Styles/on_hover_button_color.tres") )
		var tween = get_tree().create_tween()
		tween.tween_property(self.get_parent(), "position:y", 55, 2.0)
		await tween.finished
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self.get_parent(), "position:y", 95, 1.0)
		await tween.finished
	

func _on_mouse_entered():
	hovering = true
	#if debounce: return
	#debounce = true
	#debounce = false


func _on_mouse_exited():
	hovering = false
	#if debounce: return
	#debounce = true
#
	#debounce = false
