extends Node

# ==========================================================
# FRY - YOU-CONOMICS
# ==========================================================


#region Fry - Starting Information

var money: float = 100.00
var mood: int = 70
var energy: int = 80

var event_state: String = ""
var active_event: Dictionary = {}

#endregion

#region Fry - Mood Icons

const MOOD_VERY_HAPPY: Texture2D = preload("res://Images/Icons/Fry/fry_very_happy.png")
const MOOD_HAPPY: Texture2D = preload("res://Images/Icons/Fry/fry_happy.png")
const MOOD_NEUTRAL: Texture2D = preload("res://Images/Icons/Fry/fry_neutral.png")
const MOOD_SAD: Texture2D = preload("res://Images/Icons/Fry/fry_sad.png")
const MOOD_VERY_SAD: Texture2D = preload("res://Images/Icons/Fry/fry_very_sad.png")

#endregion

#region Fry - Personal Finances

# Fry gets paid every seven days.
const PAYDAYS = {
	7: 180.0,
	14: 180.0,
	21: 180.0,
	28: 180.0
}

# Bills belong to Fry. Other characters can have different
# bills, amounts, and payment schedules.

var bills: Dictionary = {
	"phone": {
		"name": "Phone bill",
		"amount": 45.0,
		"due_day": 10,
		"late_fee": 5.0,
		"paid": false,
		"fee_applied": false
	},
	
	"school": {
		"name": "School payment",
		"amount": 150.0,
		"due_day": 20,
		"late_fee": 10.0,
		"paid": false,
		"fee_applied": false
	}
}

# Items waiting to be shown during the current period.
var period_queue: Array[Dictionary] = []

# Tracks which bill the player is currently handling.
var active_bill_id: String = ""

# Used for the end-of-month recap.
var total_paycheck_income: float = 0.0
var total_late_fees: float = 0.0

#endregion

#region Fry - College Story State

# Personal story flags stay with Fry, not in a shared manager.
var story_flags: Dictionary = {
	"attend_campus": false,
	"packed_lunch": false
}

var campus_lines: Array[Dictionary] = []
var after_campus_lines: String = ""
var current_location: String = "bedroom"
var transitioning: bool = false

#endregion

#region Fry - Character Profile

var fry_profile: Dictionary = {
	"name": "Fry",

	"breakfast_cost": 29,
	"home_breakfast_cost": 4,

	"breakfast_dialogue":
		"I'm starving. Should I order breakfast or just make something at home?",

	"breakfast_order_reaction":
		"That hit the spot! ...Wait, did I really just spend $29 on breakfast?",

	"breakfast_cook_reaction":
		"Not bad. A little effort, but at least I saved some money.",

	"breakfast_skip_reaction":
		"I'll eat later... probably. Why am I already tired?"
}

#endregion


#region Fry - Scheduled Events

var scheduled_events: Dictionary = {

	"1_Morning": "breakfast",

	"2_Afternoon": {
		"id": "fry_extra_shift",
		"speaker": "FRY",
		"message": "The campus bookstore needs help with an extra shift. Should I take it?",
		"choices": [
			{
				"text": "Take the shift",
				"energy": -12,
				"mood": -3,
				"reaction": "Well, that was exhausting. At least I'll have some extra money coming in.",
				"delayed": {
					"days_later": 2,
					"period": "Afternoon",
					"money": 55,
					"text": "Payment from the extra shift arrived. +$55!"
				}
			},
			{
				"text": "Keep my afternoon free",
				"mood": 4,
				"reaction": "I could use a little time to myself."
			}
		]
	},

	"3_Evening": {
		"id": "fry_campus_invitation",
		"speaker": "DULCE",
		"message": "Hey, Fry! Steve and I are going to the campus club fair tomorrow. Want to meet us there?",
		"choices": [
			{
				"text": "Sure, I'll go",
				"mood": 2,
				"set_flag": "attend_campus",
				"flag_value": true,
				"reaction": "A day out with everyone sounds nice. I'd better get ready in the morning."
			},
			{
				"text": "Maybe next time",
				"set_flag": "attend_campus",
				"flag_value": false,
				"reaction": "I'll sit this one out. Hopefully they have fun."
			}
		]
	}

}

#endregion


#region Fry - Node References

@onready var day_label: Label = $UI/HUD/DayLabel
@onready var period_label: Label = $UI/HUD/PeriodLabel


@onready var money_label: Label = $UI/HUD/TopRightStats/MoneyLabel
@onready var mood_label: Label = $UI/HUD/TopRightStats/MoodRow/MoodLabel
@onready var mood_icon: TextureRect = $UI/HUD/TopRightStats/MoodRow/MoodIcon
@onready var energy_label: Label = $UI/HUD/TopRightStats/EnergyLabel


@onready var next_day_button: Button = $UI/HUD/NextDayButton

@onready var dialogue_manager: DialogueManager = $UI/HUD/DialoguePanel
@onready var campus_backdrop: ColorRect = $CampusBackdrop
@onready var screen_fade: ColorRect = $UI/ScreenFade

#endregion


#region Fry - Initialization

func _ready() -> void:

	campus_backdrop.hide()
	screen_fade.color = Color.BLACK
	screen_fade.modulate.a = 0.0
	screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

	DayManager.reset_calendar()
	EventManager.reset_run()

	next_day_button.pressed.connect(
		_on_next_day_button_pressed
	)

	dialogue_manager.choice_selected.connect(
		_on_dialogue_choice_selected
	)

	DayManager.month_completed.connect(
		_on_month_completed
	)

	update_ui()
	start_current_period()

#endregion


#region Fry - UI

func update_ui() -> void:

	day_label.text = "DAY %d / %d" % [
		DayManager.current_day,
		DayManager.TOTAL_DAYS
	]

	period_label.text = DayManager.get_period().to_upper()

	money_label.text = "$%.2f" % money
	# The icon identifies the stat, so the label only needs the number.
	mood_label.text = "Mood: %d" % mood
	update_mood_icon()
	energy_label.text = "Energy: %d" % energy

	next_day_button.disabled = DayManager.finished

	if DayManager.finished:
		next_day_button.text = "MONTH COMPLETE"
		return

	match DayManager.period_index:
		0:
			next_day_button.text = "TO AFTERNOON"
		1:
			next_day_button.text = "TO EVENING"
		2:
			if DayManager.current_day == DayManager.TOTAL_DAYS:
				next_day_button.text = "FINISH MONTH"
			else:
				next_day_button.text = "NEXT DAY"

#endregion

#region Fry - Mood Icon Display

func update_mood_icon() -> void:
	if mood >= 80:
		mood_icon.texture = MOOD_VERY_HAPPY
	elif mood >= 60:
		mood_icon.texture = MOOD_HAPPY
	elif mood >= 40:
		mood_icon.texture = MOOD_NEUTRAL
	elif mood >= 20:
		mood_icon.texture = MOOD_SAD
	else:
		mood_icon.texture = MOOD_VERY_SAD

#endregion


#region Fry - Stats

func change_money(amount: float) -> void:
	money += amount
	update_ui()


func change_mood(amount: int) -> void:
	mood = clampi(mood + amount, 0, 100)
	update_ui()


func change_energy(amount: int) -> void:
	energy = clampi(energy + amount, 0, 100)
	update_ui()


func apply_stat_changes(changes: Dictionary) -> void:

	money += float(changes.get("money", 0))
	mood = clampi(mood + int(changes.get("mood", 0)), 0, 100)
	energy = clampi(energy + int(changes.get("energy", 0)), 0, 100)

	update_ui()

#endregion

#region Fry - Financial System

func queue_financial_items() -> void:
	var day: int = DayManager.current_day
	
	# Paycheck arrives automatically on payday.
	if PAYDAYS.has(day):
		var paycheck: float = float(PAYDAYS[day])
		
		change_money(paycheck)
		total_paycheck_income += paycheck
		
		period_queue.append({
			"type": "notice",
			"speaker": "PAYDAY",
			"message": "My paycheck came in! +$%.2f from the bookstore." % paycheck
		})
		
	# Check bills that are due or overdue.
	for bill_id in bills.keys():
		var bill: Dictionary = bills[bill_id]
		
		if bool(bill["paid"]):
			continue
			
		var due_day: int = int(bill["due_day"])
		
		# Apply a late fee once after the due date.
		if day > due_day and not bool(bill["fee_applied"]):
			var fee: float = float(bill["late_fee"])
			
			bill["amount"] = float(bill["amount"]) + fee
			bill["fee_applied"] = true
			total_late_fees += fee
			
			period_queue.append({
				"type": "notice",
				"speaker": "BILL ALERT",
				"message": "%s is overdue. A $%.2f late fee was added." % [str(bill["name"]), fee]
			})
		
		# Offer payment on the due date, later paydayts, and the last day of the month.
		var offer_payment: bool = (
			day == due_day
			or (
				day > due_day
				and (
					PAYDAYS.has(day)
					or day == DayManager.TOTAL_DAYS
				)
			)
		)
		
		if offer_payment:
			period_queue.append({
				"type": "bill",
				"id": str(bill_id)
			})

func show_next_period_item() -> void:
	if period_queue.is_empty():
		active_bill_id = ""
		event_state = ""
		dialogue_manager.close_dialogue()
		load_period_event()
		return
	
	var item: Dictionary = period_queue.pop_front()
	
	match str(item.get("type", "")):
		"notice":
			event_state = "finance_notice"
			next_day_button.hide()
			
			dialogue_manager.show_dialogue(
				str(item.get("speaker", "UPDATE")),
				str(item.get("message", "")),
				["Continue"]
			)
		
		"bill":
			active_bill_id = str(item.get("id", ""))
			show_bill_prompt()

func show_bill_prompt() -> void:
	if not bills.has(active_bill_id):
		show_next_period_item()
		return
	
	var bill: Dictionary = bills[active_bill_id]
	var amount: float = float(bill["amount"])
	var due_day: int = int(bill["due_day"])
	
	var message: String = ""
	
	if DayManager.current_day == due_day:
		message = "My %s is due today. I owe $%.2f. If I miss it, there's a $%.2f late fee." % [
			str(bill["name"]).to_lower(),
			amount,
			float(bill["late_fee"])
		]
	else:
		message = "I still haven't paid my %s. The balance is now $%.2f." % [
			str(bill["name"]).to_lower(),
			amount
		]
	
	event_state = "bill_choice"
	next_day_button.hide()
	
	if money >= amount:
		dialogue_manager.show_dialogue(
			"FRY",
			message,
			[
				"Pay now - $%.2f" % amount,
				"Pay later"
			]
		)
	else:
		dialogue_manager.show_dialogue(
			"FRY",
			message + "\nI don't have enough cash to pay it.",
			["I'll have to wait"]
		)

func resolve_bill_choice(index: int) -> void:
	if not bills.has(active_bill_id):
		return
	
	var bill: Dictionary = bills[active_bill_id]
	var amount: float = float(bill["amount"])
	var reaction: String = ""
	
	if index == 0 and money >= amount:
		change_money(-amount)
		bill["paid"] = true
		
		reaction = "Alright, that's paid. One less thing to worry about."
	
	elif index == 1 or money < amount:
		reaction = "I'll deal with it later. I still owe $%.2f." % amount
	
	else:
		return
	
	event_state = "bill_reaction"
	
	dialogue_manager.show_dialogue(
		"FRY",
		reaction,
		["Continue"]
	)

func get_unpaid_total() -> float:
	var total: float = 0.0
	
	for bill_id in bills.keys():
		var bill: Dictionary = bills[bill_id]
		
		if not bool(bill["paid"]):
			total += float(bill["amount"])
	
	return total
	
#endregion

#region Fry - Day Progression

func start_current_period() -> void:
	event_state = ""
	active_event.clear()
	active_bill_id = ""
	period_queue.clear()

	dialogue_manager.close_dialogue()
	update_ui()

	# Financial events are checked once every morning.
	if DayManager.get_period() == "Morning":
		queue_financial_items()

	# Collect consequences from earlier decisions.
	var due_effects: Array[Dictionary] = EventManager.take_due_effects(
		DayManager.current_day,
		DayManager.get_period()
	)

	for effect in due_effects:
		apply_stat_changes(effect)

		period_queue.append({
			"type": "notice",
			"speaker": "UPDATE",
			"message": str(effect.get("text", "Something happened."))
		})

	# Display queued financial events first.
	# Afterward, the normal event system continues.
	show_next_period_item()


func load_period_event() -> void:

	var key := "%d_%s" % [
		DayManager.current_day,
		DayManager.get_period()
	]

	var scheduled = scheduled_events.get(key, null)

	# The invitation on Day 3 changes what happens on Day 4.
	if key == "4_Morning" and bool(story_flags.get("attend_campus", false)):
		scheduled = make_campus_morning_event()

	elif key == "4_Afternoon" and bool(story_flags.get("attend_campus", false)):
		start_campus_story()
		return

	if scheduled is String:
		active_event = EventManager.create_shared_event(
			scheduled,
			fry_profile
		)

	elif scheduled is Dictionary:
		active_event = scheduled.duplicate(true)

	else:
		active_event = EventManager.roll_random_event(
			DayManager.current_day,
			DayManager.get_period(),
			fry_profile
		)

	if active_event.is_empty():
		event_state = ""
		dialogue_manager.close_dialogue()
		next_day_button.show()
		return

	EventManager.record_event_shown(
		str(active_event.get("id", "")),
		DayManager.current_day
	)

	event_state = "event_choice"
	next_day_button.hide()

	var option_texts: Array[String] = []

	for choice in active_event.get("choices", []):
		option_texts.append(str(choice.get("text", "Choose")))

	dialogue_manager.show_dialogue(
		str(active_event.get("speaker", "FRY")),
		str(active_event.get("message", "")),
		option_texts
	)


func advance_time() -> void:
	if event_state != "" or transitioning:
		return

	var previous_day: int = DayManager.current_day
	DayManager.advance_period()

	if DayManager.finished:
		return

	var day: int = DayManager.current_day
	var period: String = DayManager.get_period()
	var going_to_campus: bool = (
		day == 4
		and period == "Afternoon"
		and bool(story_flags.get("attend_campus", false))
	)

	var destination: String = "campus" if going_to_campus else "bedroom"
	var story_overnight: bool = (
		previous_day != day
		and day == 4
		and period == "Morning"
		and bool(story_flags.get("attend_campus", false))
	)

	# Fade overnight for the story, and whenever the place changes.
	if destination != current_location or story_overnight:
		await fade_to_location(destination)

	start_current_period()


func _on_next_day_button_pressed() -> void:
	advance_time()

#endregion


#region Fry - Event Choices

func resolve_event_choice(index: int) -> void:

	var choices: Array = active_event.get("choices", [])

	if index < 0 or index >= choices.size():
		return

	var choice: Dictionary = choices[index]
	
	var cash_change: float = float(choice.get("money", 0))
	
	if cash_change < 0.0 and money + cash_change < 0.0:
		event_state = "insufficient_cash"
		
		dialogue_manager.show_dialogue(
			"FRY",
			"I don't have enough money for that. I'll have to choose something else.",
			["Choose again"]
		)
		return

	apply_stat_changes(choice)

	if choice.has("set_flag"):
		story_flags[str(choice["set_flag"])] = bool(choice.get("flag_value", false))

	if choice.has("delayed"):
		EventManager.schedule_delayed(
			DayManager.current_day,
			choice["delayed"]
		)

	event_state = "event_reaction"

	dialogue_manager.show_dialogue(
		"FRY",
		str(choice.get("reaction", "Alright, that's settled.")),
		["Continue"]
	)


func finish_event() -> void:
	var finished_id: String = str(active_event.get("id", ""))
	active_event.clear()

	if finished_id == "fry_campus_lunch":
		campus_lines = [
			{"speaker": "STEVE", "message": "We should do something like this again. It's a good break from classes."},
			{"speaker": "DULCE", "message": "Definitely! I'll message you both about the next one."},
			{"speaker": "FRY", "message": "I had a pretty good time. Now I should get home before it gets too late."}
		]
		after_campus_lines = "finish"
		show_next_campus_line()
		return

	event_state = ""
	dialogue_manager.close_dialogue()
	next_day_button.show()

#endregion


#region Fry - Dialogue Handling


func _on_dialogue_choice_selected(index: int) -> void:

	match event_state:

		"event_choice":
			resolve_event_choice(index)

		"event_reaction":
			finish_event()

		"campus_line":
			show_next_campus_line()

		"finance_notice":
			event_state = ""
			show_next_period_item()

		"bill_choice":
			resolve_bill_choice(index)

		"bill_reaction":
			event_state = ""
			active_bill_id = ""
			show_next_period_item()

		"month_end":
			event_state = ""
			dialogue_manager.close_dialogue()
			next_day_button.show()
		
		"insufficient_cash":
			event_state = "event_choice"
			
			var option_texts: Array[String] = []
			
			for choice in active_event.get("choices", []):
				option_texts.append(str(choice.get("text", "Choose")))
			
			dialogue_manager.show_dialogue(
				str(active_event.get("speaker", "FRY")),
				str(active_event.get("message", "")),
				option_texts
			)


#endregion


#region Fry - Month Ending


func _on_month_completed() -> void:
	event_state = "month_end"
	update_ui()

	next_day_button.hide()

	var unpaid_total: float = get_unpaid_total()

	var goal_met: bool = (
		unpaid_total < 0.01
		and money >= 0.0
	)

	var conclusion: String = ""

	if goal_met:
		conclusion = "I actually managed to cover everything. Nice!"
	else:
		conclusion = "Well, I've still got some catching up to do."

	var summary: String = (
		"Month over! Cash: $%.2f | Still owed: $%.2f\n"
		+ "Late fees: $%.2f\n%s"
	) % [
		money,
		unpaid_total,
		total_late_fees,
		conclusion
	]

	dialogue_manager.show_dialogue(
		"FRY",
		summary,
		["Close"]
	)


#endregion


#region Fry - Character-Specific Events

func make_campus_morning_event() -> Dictionary:
	return {
		"id": "fry_campus_preparation",
		"speaker": "FRY",
		"message": "The club fair is this afternoon. Should I make lunch before heading out?",
		"choices": [
			{
				"text": "Pack lunch - $4",
				"money": -4,
				"energy": -2,
				"set_flag": "packed_lunch",
				"flag_value": true,
				"reaction": "Sandwich packed. At least I won't need to buy lunch there."
			},
			{
				"text": "Leave without lunch - $0",
				"set_flag": "packed_lunch",
				"flag_value": false,
				"reaction": "I'll just see what's available at the event."
			}
		]
	}


func start_campus_story() -> void:
	var lunch_line: String = (
		"Good thing I packed lunch this morning."
		if bool(story_flags.get("packed_lunch", false))
		else "I came straight here without packing lunch."
	)

	campus_lines = [
		{"speaker": "DULCE", "message": "Fry! You made it! Come on, Steve's over by the student booths."},
		{"speaker": "STEVE", "message": "Hey! There are clubs, workshops, and food stalls everywhere."},
		{"speaker": "FRY", "message": lunch_line},
		{"speaker": "DULCE", "message": "Want to get something to eat before we look around?"}
	]
	after_campus_lines = "lunch_choice"
	show_next_campus_line()


func show_next_campus_line() -> void:
	if campus_lines.is_empty():
		if after_campus_lines == "lunch_choice":
			after_campus_lines = ""
			show_campus_lunch_choice()
			return

		after_campus_lines = ""
		event_state = ""
		dialogue_manager.close_dialogue()
		next_day_button.show()
		return

	var line: Dictionary = campus_lines.pop_front()
	event_state = "campus_line"
	next_day_button.hide()

	dialogue_manager.show_dialogue(
		str(line.get("speaker", "FRY")),
		str(line.get("message", "")),
		["Continue"]
	)


func show_campus_lunch_choice() -> void:
	var choices: Array[Dictionary] = []

	if bool(story_flags.get("packed_lunch", false)):
		choices.append({
			"text": "Eat packed lunch - $0",
			"energy": 7,
			"mood": 1,
			"reaction": "Not bad. Bringing my own lunch saved me some cash."
		})
	else:
		choices.append({
			"text": "Try the free snacks - $0",
			"energy": 2,
			"mood": 1,
			"reaction": "Free snacks! Not exactly a meal, but I'll take it."
		})

	choices.append({
		"text": "Buy lunch with friends - $12",
		"money": -12,
		"mood": 6,
		"energy": 7,
		"reaction": "That was fun, but I probably didn't need to spend another $12."
	})
	choices.append({
		"text": "Skip eating - $0",
		"energy": -8,
		"mood": -2,
		"reaction": "I'm getting hungry. Hopefully I can eat when I get home."
	})

	active_event = {
		"id": "fry_campus_lunch",
		"speaker": "FRY",
		"message": "We're all here together. What should I do for lunch?",
		"choices": choices
	}

	event_state = "event_choice"
	next_day_button.hide()

	var labels: Array[String] = []
	for choice in choices:
		labels.append(str(choice.get("text", "Choose")))

	dialogue_manager.show_dialogue("FRY", str(active_event["message"]), labels)

#endregion


#region Fry - Location Transitions

func fade_to_location(destination: String) -> void:
	transitioning = true
	next_day_button.hide()
	screen_fade.show()

	var fade_out: Tween = create_tween()
	fade_out.tween_property(screen_fade, "modulate:a", 1.0, 0.45)
	await fade_out.finished

	current_location = destination
	campus_backdrop.visible = (destination == "campus")

	var fade_in: Tween = create_tween()
	fade_in.tween_property(screen_fade, "modulate:a", 0.0, 0.45)
	await fade_in.finished

	transitioning = false

#endregion


#region Fry - Animations

# Animations will be implemented later.

#endregion
