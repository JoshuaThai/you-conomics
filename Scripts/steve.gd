extends CharacterBody2D

const WALKSPEED : int = 2
var debounce : bool = false
var movement_Tween : Tween

# Player State
var moving_Forward : bool = true


# Variables
@onready var button_Label : Label = %ButtonLabel
@onready var front_Ray : RayCast2D = %FrontRay
@onready var back_Ray : RayCast2D = %BackRay

	
func _physics_process(delta):
	if front_Ray.is_colliding():
#		Only prevent user from walking forward
#		if there is a wall in front of them and they are walking
#		forward.
		if movement_Tween and moving_Forward:
			movement_Tween.kill()
			movement_Tween = null
			moving_Forward = false
			print("Blocked Forward Walking")
			%AnimatedSprite2D.animation = "Idle"
			await get_tree().create_timer(1.0).timeout
			debounce = false
			print("Ray Cast turns off debounce")
			
	if back_Ray.is_colliding():
#		Only prevent user from walking backward
#		if there is a wall in front of them and they are walking
#		backward.
		if movement_Tween and not moving_Forward:
			movement_Tween.kill()
			movement_Tween = null
			moving_Forward = true
			print("Blocked Backward Walking")
			%AnimatedSprite2D.animation = "Idle"
			await get_tree().create_timer(1.0).timeout
			debounce = false
			print("Ray Cast turns off debounce")
			
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
#		Player is clicking forward
		if mousePos.x > position.x:
			if front_Ray.is_colliding():
				debounce = false
				return
			moving_Forward = true
			walkDistance = mousePos.x - position.x
#		Player is clicking backward
		else:
			if back_Ray.is_colliding():
				debounce = false
				return
			moving_Forward = false
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
		movement_Tween = get_tree().create_tween()
		movement_Tween.tween_property(self, "position:x", 
		mousePos.x, final_Walkspeed)
		await movement_Tween.finished
		%AnimatedSprite2D.animation = "Idle"
		await get_tree().create_timer(1.0).timeout
		print("Walking occuring")
		debounce = false
	else:
		if debounce: return
		%AnimatedSprite2D.animation = "Idle"
			
	
		
