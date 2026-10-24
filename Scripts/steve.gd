extends CharacterBody2D

const WALKSPEED : int = 2
var debounce : bool = false
	
func _physics_process(delta):
	if Input.is_action_pressed("Clicked"):
		if debounce: return
		var mousePos : Vector2 = get_global_mouse_position()
#		Prevent user from moving into negative coordinates and breaking stuff
		if mousePos.x <= 0: 
			print("Mouse Pos Blocked")
			return
		debounce = true
		var walkDistance : int
#		Dynamically Update Walk Duration based on how far the user is clicking.
#		Forward
		%AnimatedSprite2D.flip_h = not mousePos.x > position.x
		'''
		if mousePos.x > position.x:
			#walkDuration = mousePos.x / position.x
			%AnimatedSprite2D.flip_h = false
#		Backward
		else:
			%AnimatedSprite2D.flip_h = true
			#walkDuration = position.x / mousePos.x
		'''
		if mousePos.x > position.x:
			walkDistance = mousePos.x - position.x
		else:
			walkDistance = position.x - mousePos.x	
					
		print("Walking Distance: ", walkDistance)
		print("Walk Duration: ", WALKSPEED + (walkDistance / 100))
		print("Player Position: ", position.x)
		print("Mouse Position: ", mousePos.x)
#		Dyanamically speed up character walkspeed based on the distance they want to travel
		var final_Walkspeed : int = WALKSPEED + (walkDistance / 100)
		#if(walkDistance < 100):
			#final_Walkspeed = WALKSPEED
			
		%AnimatedSprite2D.animation = "Walking"
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:x", 
		mousePos.x, final_Walkspeed)
		await tween.finished
		%AnimatedSprite2D.animation = "Idle"
		await get_tree().create_timer(1.0).timeout
		print("Walking occuring")
		debounce = false
	else:
		if debounce: return
		%AnimatedSprite2D.animation = "Idle"
			
	
		
