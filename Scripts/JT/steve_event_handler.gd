extends Control

@onready var steve_manager = %SteveManager
@onready var steve_email = %SteveMailHandler
@onready var steve_dialogue = %SteveEventDialogue
@onready var steve = %Steve

func load_tutorial():
#		Load the events
		var selectedMorning = steve_manager.normal_morning_events[0]
		var shuffledAfternoon = "Work a extra shift"
		var shuffledEvening = "Scam Email"
		
		steve_email.steve_scam_emails.shuffle()
		steve.email.append(steve_email.steve_scam_emails[0])
		
		steve.morningEvents.append(selectedMorning)
		steve.afternoonEvents.append(shuffledAfternoon)
		steve.eveningEvents.append(shuffledEvening)
		
		steve.print_all_events()

		

# Randomize the events for each day
func randomize_event():
	if steve_manager.normal_evening_events_info["Sleep"]["cooldown"]:
		steve_manager.normal_evening_events_info["Sleep"]["duration"] -= 1
		if steve_manager.normal_evening_events_info["Sleep"]["duration"] == 0:
			print("Sleep is available again!")
			steve_manager.normal_evening_events_info["Sleep"]["cooldown"] = false
			steve_manager.normal_evening_events_info["Sleep"]["duration"] = 5
	if DayManager.isWeekend:
		steve_manager.steve_special_events.shuffle()
		var selectedSpecial = steve_manager.steve_special_events[0]
		steve_manager.normal_evening_events.shuffle()
		var shuffledEvening = steve_manager.normal_evening_events[0]
		
		steve.morningEvents.append(selectedSpecial)
		steve.eveningEvents.append(shuffledEvening)
		steve.print_all_events()
	else:
#		Player always have lunch on a weekday
#		Load the events
		var selectedMorning = steve_manager.normal_morning_events[0]
		steve_manager.normal_afternoon_events.shuffle()
		var shuffledAfternoon = steve_manager.normal_afternoon_events[0]
		var randomSharedEvents = ["wishlist_sale","small_refund", "nothing"]
		randomSharedEvents.shuffle()
		steve_manager.normal_evening_events.shuffle()
		var shuffledEvening = steve_manager.normal_evening_events[0]
		steve_manager.normal_night_events.shuffle()
		var shuffledNight = steve_manager.normal_night_events[0]
		steve_manager.steve_weekly_events.shuffle()
		
		steve.morningEvents.append(selectedMorning)
#		Determine if payday is needed
		for day in steve.paydays["days"]:
			if day == DayManager.current_day:
				steve.morningEvents.append("Payday")
				break
				
		if steve.money <= 30:
			steve_manager.steve_low_money_events.shuffle()
			var lowMoneyEvent = steve_manager.steve_low_money_events[0]
			print(lowMoneyEvent)
			if lowMoneyEvent == "Ask for Promotion":
				var luck = randi_range(1,2)
				if luck == 2:
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["money"] = 10
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["mood"] = 20
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["reaction"] = "Yes! I got the promotion!"
					steve.paydays["amount"] += 35
					print("You got promoted!")
				else:
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["money"] = 0
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["mood"] = -20
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["reaction"] = "Ugh! No promotion!"
					print("You did not get promoted!")
			else:
				var luck = randi_range(1,2)
				if luck == 2:
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["money"] = 75
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["mood"] = 20
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["reaction"] = "Phew!"
				else:
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["money"] = -75
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["mood"] = -30
					steve_manager.steve_low_money_events_info[lowMoneyEvent]["choices"][0]["reaction"] = "NOOOOOOOO! I made a bad bet!"
			lowMoneyEvent = steve_manager.steve_low_money_events[0]
			steve.morningEvents.append(lowMoneyEvent)
		steve.afternoonEvents.append(shuffledAfternoon)
		if shuffledAfternoon == "Nap" and shuffledAfternoon == "Sleep":
			steve.eveningEvents.append("Nothing")
		else:
			if shuffledEvening == "Sleep":
				if not steve_manager.normal_evening_events_info[shuffledEvening]["cooldown"]:
					steve_manager.normal_evening_events_info[shuffledEvening]["cooldown"] = true
					steve.eveningEvents.append(shuffledEvening)
			else:
				steve.eveningEvents.append(shuffledEvening)
			
		steve.nightEvents.append(shuffledNight)
		if randomSharedEvents[0] == "wishlist_sale":
			steve.afternoonEvents.append(randomSharedEvents[0])
		if randomSharedEvents[0] == "small_refund":
			steve.eveningEvents.append(randomSharedEvents[0])
		
		if steve.eveningEvents.is_empty():
			steve.eveningEvents.append("Nothing")
		
		var randomEvent = steve_manager.steve_weekly_events[0]
		#print("Random Event ", randomEvent)
		var afternoonOrEvening = randi_range(1,2)
		if randomEvent == "Hate Mail":
			steve_email.steve_hate_mails.shuffle()
			steve.mail.append(steve_email.steve_hate_mails[0])
			steve.morningEvents.append("Hate Mail")
			steve.load_necessary_data("HouseDoor", steve.mail[0])
		
#		Put random events based on their specified periods
		if(not randomEvent == "Nothing"):
			var randomEventData = steve_manager.steve_weekly_events_info[randomEvent]
			if afternoonOrEvening == 2:
				if randomEventData["period"] == "Afternoon":
					steve.afternoonEvents.append(randomEvent)
			else:
				if randomEventData["period"] == "Evening":
					steve.eveningEvents.append(randomEvent)
		
		#shuffledEvening = "Scam Email"
		if shuffledEvening == "Scam Email":
			steve_email.steve_scam_emails.shuffle()
			steve.email.append(steve_email.steve_scam_emails[0])
		if shuffledEvening == "Legit Email":
			steve_email.steve_emails.shuffle()
			steve.email.append(steve_email.steve_emails[0])
		steve.print_all_events()


# Wait for Steve's dialogue without continuing after
# Steve's scene has been unloaded.
func _wait_for_steve_dialogue() -> bool:
	while (
		is_inside_tree()
		and is_instance_valid(steve)
		and steve.ongoingDialogue
	):
		await get_tree().process_frame

	return is_inside_tree() and is_instance_valid(steve)


func find_options(choices):
	var options = []
	for choice in choices:
		options.append(choice["text"])
	return options

# Determine if checking fridge is necessary
func check_fridge():
	if steve.grocery_meals <= 0 and not TutorialManager.inTutorial:
		steve.clickAllObjects["Fridge"] = false
	else:
		steve.clickAllObjects["Fridge"] = true

func check_calendar():
	if (not steve.todayEvents.is_empty() 
	or not steve.upcomingEvents.is_empty()):
		steve.clickAllObjects["Calendar"] = false
	else:
		steve.clickAllObjects["Calendar"] = true
	
func check_computer(currentPeriod):
	if (currentPeriod == "Evening" 
	and (steve.eveningEvents.has("Legit Email") 
	or steve.eveningEvents.has("Scam Email")) ):
		steve.clickAllObjects["Computer"] = false
	else:
		steve.clickAllObjects["Computer"] = true
	
func check_mail(currentPeriod):
	
	if (currentPeriod == "Morning" 
	and steve.morningEvents.has("Hate Mail")):
		steve.clickAllObjects["HouseDoor"] = false
	else:
		steve.clickAllObjects["HouseDoor"] = true

# Check all house objects before each period to prevent
# unnecessary clicking!	
func check_house_objects(currentPeriod):
	check_fridge()
	check_calendar()
	check_computer(currentPeriod)
	check_mail(currentPeriod)

# Show the current period's event dialogue

func _show_current_period_dialogue():
	var current_period = DayManager.get_period()
	print(current_period)
	check_house_objects(current_period)
	steve.reload_calendar()
	for event in steve.get_today_events():
		print("Today event: ", event)
		if event["title"].contains("Hanging out with friends"):
			steve.morningEvents.append("Hanging out with friends")
#	Play Breakfast event if morning
# Note: We will grab the breakfast info from steve_profile
# Look at how freddie did it in his script.
	if current_period == "Morning":
		steve.nappingOrSleep = false
		var eventData = EventManager.create_shared_event("breakfast", 
		steve_manager.steve_profile )
		print(eventData)
		steve.currentEvent = "breakfast"
		var speaker = steve_manager.steve_profile["name"]
		var message = eventData["message"]
		
		var options = find_options(eventData["choices"])
		steve.available_choices_info = eventData["choices"]
		steve.load_necessary_data("Fridge", {})
		
		steve.show_dialogue(speaker, message, options)
		if not (await _wait_for_steve_dialogue()):
			return
		#print("No more dialogue occuring")
		await get_tree().create_timer(3.0).timeout
		if not is_inside_tree():
			return
#		If it is the weekday, the player will always have lunch
		if not DayManager.isWeekend:
			for event in steve.morningEvents:
				if TutorialManager.inTutorial:
					steve.get_node("%TutorialHUD").visible = true
					print("Tutorial HUD should come back!")
				var chosenMorningEvent = event
				steve.currentEvent = chosenMorningEvent.capitalize()
				if(steve_manager.normal_morning_events_info.has(event)):
					eventData = steve_manager.normal_morning_events_info[chosenMorningEvent]
				elif(steve_manager.steve_special_events_info.has(event)):
					eventData = steve_manager.steve_special_events_info[chosenMorningEvent]
					if chosenMorningEvent == "Hanging out with friends":
						await %SteveHome.halfway_transition()
						if not is_inside_tree():
							return
						%Steve.get_node("%WithFriends").visible = true
						var dialogues = steve_dialogue.steve_hang_out_with_friends["dialogues"]
						for dialogue in dialogues:
							print(dialogue)
							%Steve.get_node("%WithFriends").remove_old_speaker()
							%Steve.get_node("%WithFriends").highlight_speaker(dialogue["speaker"])
							#print(dialogue["choices"])
							#print("Choices Data Type: ",
								#type_string(typeof(dialogue["choices"])))
							options = find_options(dialogue["choices"])
							steve.available_choices_info = dialogue["choices"]
							
							steve.show_dialogue(dialogue["speaker"], 
							dialogue["text"], options)
							if not (await _wait_for_steve_dialogue()):
								return
						
						%Steve.get_node("%WithFriends").visible = false
						steve.go_to_next_period()
						return
				elif(steve_manager.steve_low_money_events_info.has(event)):
					eventData = steve_manager.steve_low_money_events_info[chosenMorningEvent]
				else:
					eventData = steve_manager.steve_weekly_events_info[chosenMorningEvent]
				print(eventData)
				#		Determine if random bill is going to happen
				message = eventData["message"]
				if event == "Random Bill":
					steve.random_bills.shuffle()
					var randomBill = steve.random_bills[0]
					message = message + randomBill["from"] + "!"
					eventData["choices"][0]["money"] = randomBill["amount"]
					steve.random_bills[0]["last_day"] = DayManager.current_day
					
				options = find_options(eventData["choices"])
				steve.available_choices_info = eventData["choices"]
				
				steve.show_dialogue(speaker, message, options)
				if not (await _wait_for_steve_dialogue()):
					return
			if TutorialManager.inTutorial:
				steve.get_node("%TutorialHUD").visible = true
			steve.set_task_label()
#			Handle weekend dialogue
		else:
			for event in steve.morningEvents:
				print("Morning event: ", event)
				var chosenMorningEvent = event
				steve.currentEvent = chosenMorningEvent.capitalize()
				if (not chosenMorningEvent == "Nothing"):
					eventData = steve_manager.steve_special_events_info[chosenMorningEvent]
					print(eventData)
					message = eventData["message"]
					options = find_options(eventData["choices"])
					steve.available_choices_info = eventData["choices"]
					
					steve.show_dialogue(speaker, message, options)
					if not (await _wait_for_steve_dialogue()):
						return
			
			steve.set_task_label()
	elif current_period == "Afternoon":
		steve.nappingOrSleep = false
		print("Current period is now afternoon!")
		print("Afternoon: ", steve.afternoonEvents)
		for event in steve.afternoonEvents:
			print("event: ", event)
			if TutorialManager.inTutorial:
				steve.get_node("%TutorialHUD").visible = true
			if(event == "Nothing"): continue
			var eventData = ""
			steve.currentEvent = event.capitalize()
			if event == "wishlist_sale":
				eventData = EventManager.create_shared_event(event, 
		steve_manager.steve_profile )
			else:
				eventData = steve_manager.normal_afternoon_events_info[event]
			var speaker = steve_manager.steve_profile["name"]
			var message = eventData["message"]
			
			var options = find_options(eventData["choices"])
			steve.available_choices_info = eventData["choices"]
			
			steve.show_dialogue(speaker, message, options)
			if not (await _wait_for_steve_dialogue()):
				return
			#print("No more dialogue occuring")
			await get_tree().create_timer(3.0).timeout
			if not is_inside_tree():
				return
		if (TutorialManager.inTutorial 
		and not steve.get_node("%TutorialLabel").text == "Sometimes, you will have to interact with objects in the house to get to next period."):
			steve.get_node("%TutorialHUD").visible = true
		steve.set_task_label()
	elif current_period == "Evening":
		steve.nappingOrSleep = false
		print("Current period is now Evening!")
		print("Evening: ", steve.eveningEvents)
		for event in steve.eveningEvents:
			print("event: ", event)
			if TutorialManager.inTutorial:
				steve.get_node("%TutorialHUD").visible = true
			if(event == "Nothing"): continue
			var eventData = ""
			steve.currentEvent = event.capitalize()
			
			if (event == "Buy New Computer" or event == "Buy New Socks" 
			or event == "Pay Bonus" or event == "small_refund"):
				if event == "small_refund":
					eventData = EventManager.create_shared_event(event, 
		steve_manager.steve_profile )
				else:	
					eventData = steve_manager.steve_weekly_events_info[event]
			else:
				eventData = steve_manager.normal_evening_events_info[event]
#				Store email in steve if that is the event name
				if event == "Scam Email":
					steve_email.steve_scam_emails.shuffle()
					steve.email.append(steve_email.steve_scam_emails[0])
					print(steve.email)
					steve.load_necessary_data("Computer", steve.email[0])
				if event == "Legit Email":
					if steve_email.steve_emails[0]["used"]:
						print("It is being erased")
						steve.eveningEvents.erase(event)
					else:
						steve_email.steve_emails.shuffle()
						steve.email.append(steve_email.steve_emails[0])
						steve_email.steve_emails[0]["used"] = true
						print(steve.email)
						steve.load_necessary_data("Computer", steve.email[0])
					
			
			var speaker = steve_manager.steve_profile["name"]
			var message = eventData["message"]
			
			var options = find_options(eventData["choices"])
			steve.available_choices_info = eventData["choices"]
			
			steve.show_dialogue(speaker, message, options)
			if not (await _wait_for_steve_dialogue()):
				return
			#print("No more dialogue occuring")
			await get_tree().create_timer(3.0).timeout
			if not is_inside_tree():
				return
		if TutorialManager.inTutorial:
			steve.get_node("%TutorialHUD").visible = true
		steve.set_task_label()
