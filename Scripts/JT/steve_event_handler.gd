extends Control

@onready var steve_manager = %SteveManager
@onready var steve_email = %SteveMailHandler
@onready var steve = %Steve

# Randomize the events for each day
func randomize_event():
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
		steve.afternoonEvents.append(shuffledAfternoon)
		steve.eveningEvents.append(shuffledEvening)
		steve.nightEvents.append(shuffledNight)
		
		var randomEvent = steve_manager.steve_weekly_events[0]
		var afternoonOrEvening = randi_range(1,2)
		if randomEvent == "Hate Mail":
			steve_email.steve_hate_mails.shuffle()
			steve.mail.append(steve_email.steve_hate_mails[0])
		
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

func find_options(choices):
	var options = []
	for choice in choices:
		options.append(choice["text"])
	return options


# Show the current period's event dialogue
func _show_current_period_dialogue():
	var current_period = DayManager.get_period()
	print(current_period)
#	Play Breakfast event if morning
# Note: We will grab the breakfast info from steve_profile
# Look at how freddie did it in his script.
	if current_period == "Morning":
		var eventData = EventManager.create_shared_event("breakfast", 
		steve_manager.steve_profile )
		print(eventData)
		steve.currentEvent = "breakfast"
		var speaker = steve_manager.steve_profile["name"]
		var message = eventData["message"]
		
		var options = find_options(eventData["choices"])
		#for choice in eventData["choices"]:
			#options.append(choice["text"])
		
		#var option1 = eventData["choices"][0]["text"]
		#var option2 = eventData["choices"][1]["text"]
		#var option3 = eventData["choices"][2]["text"]
		steve.available_choices_info = eventData["choices"]
		
		steve.show_dialogue(speaker, message, options)
		while steve.ongoingDialogue:
			await get_tree().process_frame
		#print("No more dialogue occuring")
		await get_tree().create_timer(3.0).timeout
#		If it is the weekday, the player will always have lunch
		if not DayManager.isWeekend:
			var chosenMorningEvent = steve.morningEvents[0]
			steve.currentEvent = chosenMorningEvent.capitalize()
			eventData = steve_manager.normal_morning_events_info[chosenMorningEvent]
			print(eventData)
			message = eventData["message"]
			options = find_options(eventData["choices"])
			steve.available_choices_info = eventData["choices"]
			
			steve.show_dialogue(speaker, message, options)
			while steve.ongoingDialogue:
				await get_tree().process_frame
			steve.set_task_label()
#			Handle weekend dialogue
		else:
			if len(steve.morningEvents) >= 1:
				var chosenMorningEvent = steve.morningEvents[0]
				steve.currentEvent = chosenMorningEvent.capitalize()
				if (not chosenMorningEvent == "Nothing"):
					eventData = steve_manager.steve_special_events_info[chosenMorningEvent]
					print(eventData)
					message = eventData["message"]
					options = find_options(eventData["choices"])
					steve.available_choices_info = eventData["choices"]
					
					steve.show_dialogue(speaker, message, options)
					while steve.ongoingDialogue:
						await get_tree().process_frame
				steve.set_task_label()
	elif current_period == "Afternoon":
		print("Current period is now afternoon!")
		print("Afternoon: ", steve.afternoonEvents)
		for event in steve.afternoonEvents:
			print("event: ", event)
			if(event == "Nothing"): continue
			var eventData = ""
			if event == "Hate Mail":
				eventData = steve_manager.steve_weekly_events_info[event]
				
#				Load in the mail
				steve_manager.steve_hate_mails.shuffle()
				steve.mail.append(steve_manager.steve_hate_mails[0])
			else:
				eventData = steve_manager.normal_afternoon_events_info[event]
			var speaker = steve_manager.steve_profile["name"]
			var message = eventData["message"]
			
			var options = find_options(eventData["choices"])
			#for choice in eventData["choices"]:
				#options.append(choice["text"])
			
			#var option1 = eventData["choices"][0]["text"]
			#var option2 = eventData["choices"][1]["text"]
			#var option3 = eventData["choices"][2]["text"]
			steve.available_choices_info = eventData["choices"]
			
			steve.show_dialogue(speaker, message, options)
			while steve.ongoingDialogue:
				await get_tree().process_frame
			#print("No more dialogue occuring")
			await get_tree().create_timer(3.0).timeout
		steve.set_task_label()
	elif current_period == "Evening":
		print("Current period is now Evening!")
		print("Evening: ", steve.eveningEvents)
		for event in steve.eveningEvents:
			print("event: ", event)
			if(event == "Nothing"): continue
			var eventData = ""
			if (event == "Buy New Computer" or event == "Buy New Socks" 
			or event == "Pay Bonus"):
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
					steve_email.steve_emails.shuffle()
					steve.email.append(steve_email.steve_emails[0])
					print(steve.email)
					steve.load_necessary_data("Computer", steve.email[0])
					
			
			var speaker = steve_manager.steve_profile["name"]
			var message = eventData["message"]
			
			var options = find_options(eventData["choices"])
			steve.available_choices_info = eventData["choices"]
			
			steve.show_dialogue(speaker, message, options)
			while steve.ongoingDialogue:
				await get_tree().process_frame
			#print("No more dialogue occuring")
			await get_tree().create_timer(3.0).timeout
		steve.set_task_label()
			
