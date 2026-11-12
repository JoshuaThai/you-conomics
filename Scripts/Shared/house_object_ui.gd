extends Control

var currentRelevantData = {}

@onready var steve = %steve

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
		currentRelevantData = relevantData
		%subjectName.text = relevantData["subject"]
		%FromName.text = relevantData["from"]
		%emailContent.text = relevantData["email"]
	if objectName == "HouseDoor":
		%MailLabel.text = relevantData["content"]

func clear_email():
	owner.email.clear()
	%subjectName.text = ""
	%FromName.text = ""
	%emailContent.text = ""
	_on_close_button_pressed()

func _on_report_button_pressed():
	if currentRelevantData.is_empty(): return
	
	if (currentRelevantData["type"] == "scam"):
		owner.mood += randi_range(2,4)
	else:
		owner.mood += randi_range(-15, -10)
	clear_email()


func _on_respond_button_pressed():
	if currentRelevantData.is_empty(): return
	
	if (currentRelevantData["type"] == "legit"):
		if currentRelevantData["subject"] == "Hang out Saturday?":
#			We will need people to append it as a dictionary with
#			the event name and the day it will happen,
#			So we know when to move the event to the todayEvent
			owner.upcomingEvents.append("Hang out with friends")
			
		owner.mood += randi_range(5,10)
	else:
		owner.mood += randi_range(-5, -2)
		owner.change_money(-40, "Scam LOL", "Entertainment")
	clear_email()


func _on_mail_button_pressed():
	$HouseDoorPanel.hide()
	$MailPanel.show()
	
