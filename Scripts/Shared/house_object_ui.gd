extends Control

var currentRelevantEmailData = {}
var emailInteractedWith = false


@onready var steve = %steve
@onready var food_availability = %FoodAvailability

# Close the panel
func _on_close_button_pressed():
	hide()

func close_all_other_panels(panelName: String):
	if not panelName == "Calendar":
		$CalendarPanel.hide()
	if not panelName == "Computer":
		$ComputerPanel.hide()
	if not panelName == "Fridge":
		$FridgePanel.hide()
	if not panelName == "HouseDoor":
		$HouseDoorPanel.hide()
	$MailPanel.hide()
	

func open_panel(panelName: String):
	if panelName == "Calendar":
		$CalendarPanel.show()
	if panelName == "Computer":
		$ComputerPanel.show()
	if panelName == "Fridge":
		$FridgePanel.show()
	if panelName == "HouseDoor":
		$HouseDoorPanel.show()
	close_all_other_panels(panelName)
	
func load_necessary_data(objectName: String, relevantData: Dictionary):
	if objectName == "Computer":
		currentRelevantEmailData = relevantData
		%subjectName.text = relevantData["subject"]
		%FromName.text = relevantData["from"]
		%emailContent.text = relevantData["email"]
	if objectName == "HouseDoor":
		%MailLabel.text = relevantData["content"]
	if objectName == "Fridge":
		food_availability.text = "Food Items Available: " + str(owner.grocery_meals)
		if owner.grocery_meals <= 2:
			%SuggestionLabel.text = "Suggestion: You may need to consider buying additional food items! \n
			Buy more food by going to your phone or your house's door."
		else:
			%SuggestionLabel.text = "Keep up the great work with keeping the food in stock"
func clear_email():
	owner.email.clear()
	%subjectName.text = ""
	%FromName.text = ""
	%emailContent.text = ""
	_on_close_button_pressed()

func _on_report_button_pressed():
	if (currentRelevantEmailData.is_empty() 
	or emailInteractedWith): return
	
	if (currentRelevantEmailData["type"] == "scam"):
		owner.mood += randi_range(2,4)
	else:
		owner.mood += randi_range(-15, -10)
	emailInteractedWith = true
	clear_email()

func add_new_items_to_calendar():
	var eventContainer = load("res://Scenes/UI/House Objects/event_container.tscn").instantiate()
	var title = owner.upcomingEvents[len(owner.upcomingEvents) - 1]["title"]
	eventContainer.set_event(title)
	%UpcomingEvents.add_child(eventContainer)

## Reload the calendar upon the start of a new day
func reload_calendar():
	var upcomingEvents = %UpcomingEvents.get_children()
	var todayEvents = %TodayEvents.get_children()
	print("Calendar is reloading")
	
	for event in upcomingEvents:
		event.queue_free()
	for event in todayEvents:
		event.queue_free()
	for event in owner.upcomingEvents:
		if(event["time"] == DayManager.current_day):
			owner.todayEvents.append(event)
			owner.upcomingEvents.erase(event)
			continue
		var eventContainer = load(
			"res://Scenes/UI/House Objects/event_container.tscn"
			).instantiate()
		var title = event["title"]
		eventContainer.set_event(title)
		%UpcomingEvents.add_child(eventContainer)
	for event in owner.todayEvents:
		if(event["time"] < DayManager.current_day):
			owner.todayEvents.erase(event)
			continue
		var eventContainer = load(
			"res://Scenes/UI/House Objects/event_container.tscn"
			).instantiate()
		var title = event["title"]
		eventContainer.set_event(title)
		%TodayEvents.add_child(eventContainer)

func _on_respond_button_pressed():
	if (currentRelevantEmailData.is_empty() 
	or emailInteractedWith): return
	
	if (currentRelevantEmailData["type"] == "legit"):
		if currentRelevantEmailData["subject"] == "Hang out Saturday?":
#			We will need people to append it as a dictionary with
#			the event name and the day it will happen,
#			So we know when to move the event to the todayEvent
			owner.upcomingEvents.append(
				{"title": "Hanging out with friends on Saturday",
				"time": DayManager.find_next_day_number("Tuesday")
				})
			add_new_items_to_calendar()
			
		owner.mood += randi_range(5,10)
	else:
		owner.mood += randi_range(-5, -2)
		owner.change_money(-40, "Scam LOL", "Entertainment")
	emailInteractedWith = true
	clear_email()


func _on_mail_button_pressed():
	$HouseDoorPanel.hide()
	$MailPanel.show()
	
