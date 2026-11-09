extends CharacterBody2D

const WALKSPEED : int = 2
var debounce : bool = false
var movement_Tween : Tween
var ongoingDialogue = false

# Player State
var moving_Forward : bool = true

# Available Choices Info
# Store the current event that player is going through
var available_choices_info= {}

#region Steve - Starting Information
var money: int = 100
var mood: int = 70
var energy: int = 80

var total_income: int = 200

var total_spending: int = 0

var finance_history: Array[Dictionary] = []

var steve_profile = {
	"name": "Steve",
	"debt_amount": 1000,
	"workplace": "You-ville IT Solutions" 
}

var bills: Dictionary = {
	"phone": {
		"name": "Phone bill",
		"amount": 45,
		"due_day": 10,
		"late_fee": 5,
		"paid": false,
		"fee_applied": false
	},
	
	"student debt": {
		"name": "Student Loans",
		"amount": 250,
		"due_day": 20,
		"late_fee": 50,
		"paid": false,
		"fee_applied": false
	}
}

var random_bills = {
	"mechanic": {
		"name": "Mechanic Bill",
		"amount": 50,
	},
	"forgotten_debt" :{
		"name": "Money owed to Fry",
		"amount": 20
	}
}

# Player won't be able to move to next period until they interact with all items in house
var clickAllObjects = {
	"Calendar": true,
	"Computer": true,
	"Fridge": true,
	"HouseDoor": true
}

var objectsLeft = []
# After interacting with all items, the player will have to decide on lunch.
var decideLunch = false

# Keep track of all the events for the day
var morningEvents = []
var afternoonEvents = []
var eveningEvents = []
var nightEvents = []

var email = []

var calendar = []

var mail = []

var currentEvent = ""



# Variables
@onready var button_Label : Label = %ButtonLabel
@onready var front_Ray : RayCast2D = %FrontRay
@onready var back_Ray : RayCast2D = %BackRay
@onready var steve_Home = %SteveHome
@onready var dialogue_panel = %DialoguePanel
@onready var house_object = %HouseObjectUI

func print_all_events():
	print("morning events: ", morningEvents)
	print("afternoon events: ", afternoonEvents)
	print("evening events: ", eveningEvents)
	print("night events: ", nightEvents)
	
	
func interact_with_object(objectName):
	clickAllObjects[objectName] = true
	#var objectFound = false
	#for object in clickAllObjects:
		#if not clickAllObjects[object]:
			#objectFound = true
	#if not objectFound:
		#%NextPeriodButton.show()
	#else:
	set_task_label()

func load_next_period():
	for object in clickAllObjects:
		clickAllObjects[object] = false
	return true

func set_task_label():
	%TaskLabel.text = "Check: "
	var iterateOnce = false
	var anyObjectLeft = false
	for object in clickAllObjects:
		#if iterateOnce:
			#%TaskLabel.text = %TaskLabel.text + ", "
		#print(object)
		#iterateOnce = true
		if not clickAllObjects[object]:
			anyObjectLeft = true
			if object == "HouseDoor":
				%TaskLabel.text = %TaskLabel.text + "House's Door" + ","
			else:
				%TaskLabel.text = %TaskLabel.text + object + ", "
			%NextPeriodButton.hide()
	if anyObjectLeft:
		%TaskLabel.text[-1] = "."
		%NextPeriodButton.hide()
	else:
		%TaskLabel.text = ""
		%NextPeriodButton.show()

func change_money(
	amount: int,
	reason: String = "Other transaction",
	category: String = "Other"
) -> void:
	if is_zero_approx(amount):
		return
	
	money += amount
	
	if amount > 0:
		total_income += amount
	else:
		total_spending += absf(amount)
	
	finance_history.append({
		"day": DayManager.current_day,
		"period": DayManager.get_period(),
		"amount": amount,
		"reason": reason,
		"category": category,
		"balance_after": money
	})
	
func get_unpaid_total() -> float:
	var total: float = 0.0
	
	for bill_id in bills.keys():
		var bill: Dictionary = bills[bill_id]
		
		if not bool(bill["paid"]):
			total += float(bill["amount"])
	
	return total

func get_finance_snapshot() -> Dictionary:
	var unpaid: float = get_unpaid_total()
	
	return {
		"balance": money,
		"income": total_income,
		"spending": total_spending,
		"unpaid_bills": unpaid,
		"after_bills": money - unpaid,
		"transactions": finance_history.duplicate(true)
	}

func _ready():
	#print("Steve is ready!")
	#set_task_label()
	%NextPeriodButton.hide()
	steve_profile["debt_amount"] = randi() % 1000 + 800
	total_income = randi_range(150, 200)
	# Connect Fry's financial information to the phone.
	%PhoneUI.call("set_finance_source", self)
	%UI.visible = false
	await steve_Home._trigger_transition_on_start()
	%UI.visible = true

func _process(delta):
	#set_task_label()
	var nextTime = DayManager.get_next_time()
	if nextTime["period"] == "Afternoon":
		%NextPeriodButton.text = "To Work"
	else:
		%NextPeriodButton.text = "To " + nextTime["period"]
		
	%DayLabel.text = "DAY %s/ 30" % DayManager.current_day
	%PeriodLabel.text = DayManager.get_period().to_upper()
	
func pause_movement():
	debounce = true
	
func unpause_movement():
	debounce = false
	#print("Unpaused Steve ID: ", get_instance_id(), " debounce: ", debounce)

# Display Dialogue
func show_dialogue(speaker: String, message: String, options: Array):
	#print("Show dialogue?")
	pause_movement()
	ongoingDialogue = true
	dialogue_panel.show_dialogue(speaker, message, options)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Clicked"):
		if debounce: return
		print("Click detected!")
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
					
		#print("Walking Distance: ", walkDistance)
		#print("Walk Duration: ", WALKSPEED + (walkDistance / 100))
		#print("Player Position: ", position.x)
		#print("Mouse Position: ", mousePos.x)
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
			
	#if Input.is_action_pressed("Clicked"):
		
	else:
		if debounce: return
		%AnimatedSprite2D.animation = "Idle"
			


func _on_next_period_button_pressed():
	%NextPeriodButton.hide()
	%MoneyLabel.hide()
	%MoodLabel.hide()
	%EnergyLabel.hide()
	%PhoneUI.hide()
	%DayLabel.hide()
	%PeriodLabel.hide()
	await steve_Home.trigger_transition()
	DayManager.advance_period()
	
	%MoneyLabel.show()
	%MoodLabel.show()
	%EnergyLabel.show()
	%PhoneUI.show()
	%DayLabel.show()
	%PeriodLabel.show()
	%SteveEventHandler._show_current_period_dialogue()
	
func open_panel(panelName: String):
	house_object.show()
	house_object.open_panel(panelName)
