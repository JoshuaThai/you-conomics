extends CharacterBody2D

const WALKSPEED : Vector2 = Vector2(20, 0)
var debounce : bool = false
	
func _physics_process(delta):
	if Input.is_action_pressed("Clicked"):
		if debounce: return
		debounce = true
		var mousePos : Vector2 = get_global_mouse_position()
		var walkDuration : float
#		Dynamically Update Walk Duration based on how far the user is clicking.
	# EDGE CASE I need to handle: Negative X units
#		Forward
		if mousePos.x > position.x:
			walkDuration = mousePos.x / position.x
			%AnimatedSprite2D.flip_h = false
#		Backward
		else:
			%AnimatedSprite2D.flip_h = true
			walkDuration = position.x / mousePos.x
		
		print("Walk Duration: ", walkDuration)
		#print(mousePos.x)
		%AnimatedSprite2D.animation = "Walking"
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:x", mousePos.x, walkDuration)
		await tween.finished
		%AnimatedSprite2D.animation = "Idle"
		await get_tree().create_timer(1.0).timeout
		debounce = false
	else:
		if debounce: return
		%AnimatedSprite2D.animation = "Idle"
			
	
		
