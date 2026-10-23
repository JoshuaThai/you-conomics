
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
	}

}

#endregion


#region Fry - Node References

@onready var day_label: Label = $UI/HUD/DayLabel
@onready var period_label: Label = $UI/HUD/PeriodLabel

@onready var money_label: Label = $UI/HUD/MoneyLabel
@onready var mood_label: Label = $UI/HUD/MoodLabel
@onready var energy_label: Label = $UI/HUD/EnergyLabel

@onready var next_day_button: Button = $UI/HUD/NextDayButton

@onready var dialogue_manager: DialogueManager = $UI/HUD/DialoguePanel

#endregion


#region Fry - Initialization

func _ready() -> void:

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
	mood_label.text = "Mood: %d" % mood
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


#region Fry - Day Progression

func start_current_period() -> void:

	event_state = ""
	active_event.clear()

	dialogue_manager.close_dialogue()
	update_ui()

	# Check whether an earlier choice has a consequence today.
	var due_effects: Array[Dictionary] = EventManager.take_due_effects(
		DayManager.current_day,
		DayManager.get_period()
	)

	if not due_effects.is_empty():

		var messages: Array[String] = []

		for effect in due_effects:
			apply_stat_changes(effect)
			messages.append(str(effect.get("text", "Something happened.")))

		event_state = "delayed_notice"
		next_day_button.hide()

		dialogue_manager.show_dialogue(
			"UPDATE",
			"\n".join(messages),
			["Continue"]
		)

		return

	load_period_event()


func load_period_event() -> void:

	var key := "%d_%s" % [
		DayManager.current_day,
		DayManager.get_period()
	]

	var scheduled = scheduled_events.get(key, null)

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

	if event_state != "":
		return

	DayManager.advance_period()

	if not DayManager.finished:
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

	apply_stat_changes(choice)

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

	event_state = ""
	active_event.clear()

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

		"delayed_notice":
			event_state = ""
			dialogue_manager.close_dialogue()
			load_period_event()

		"month_end":
			event_state = ""
			dialogue_manager.close_dialogue()
			next_day_button.show()

#endregion


#region Fry - Month Ending

func _on_month_completed() -> void:

	event_state = "month_end"
	update_ui()

	next_day_button.hide()

	var summary := "The month is over. I have $%.2f left, with %d mood and %d energy." % [
		money,
		mood,
		energy
	]

	dialogue_manager.show_dialogue(
		"FRY",
		summary,
		["Close"]
	)

#endregion


#region Fry - Character-Specific Events

# Additional Fry events will be added here or to scheduled_events.

#endregion


#region Fry - Animations

# Animations will be implemented later.

#endregion
