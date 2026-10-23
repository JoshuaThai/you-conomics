
extends Node

# ==========================================================
# YOU-CONOMICS - SHARED EVENT MANAGER
# ==========================================================

#region Event Settings

const RANDOM_EVENT_CHANCE: float = 0.35

const SHARED_RULES = {
	"breakfast": {
		"periods": ["Morning"],
		"max_uses": 2,
		"cooldown": 5
	},
	"wishlist_sale": {
		"periods": ["Afternoon"],
		"max_uses": 2,
		"cooldown": 6
	},
	"small_refund": {
		"periods": ["Evening"],
		"max_uses": 2,
		"cooldown": 5
	}
}

var rng := RandomNumberGenerator.new()

var event_uses: Dictionary = {}
var last_event_day: Dictionary = {}
var delayed_effects: Array[Dictionary] = []

#endregion


#region Initialization

func _ready() -> void:
	rng.randomize()


func reset_run() -> void:
	event_uses.clear()
	last_event_day.clear()
	delayed_effects.clear()

#endregion


#region Shared Event Definitions

func create_shared_event(
	event_id: String,
	profile: Dictionary
) -> Dictionary:

	var speaker := str(profile.get("name", "PLAYER")).to_upper()

	match event_id:

		"breakfast":
			var delivery_cost := int(profile.get("breakfast_cost", 29))
			var home_cost := int(profile.get("home_breakfast_cost", 4))

			return {
				"id": "breakfast",
				"speaker": speaker,
				"message": str(profile.get(
					"breakfast_dialogue",
					"I'm hungry. Should I order breakfast or make something?"
				)),
				"choices": [
					{
						"text": "Order breakfast - $%d" % delivery_cost,
						"money": -delivery_cost,
						"mood": 8,
						"energy": 5,
						"reaction": str(profile.get(
							"breakfast_order_reaction",
							"That was good, but delivery really adds up."
						))
					},
					{
						"text": "Make breakfast - $%d" % home_cost,
						"money": -home_cost,
						"mood": 1,
						"energy": -2,
						"reaction": str(profile.get(
							"breakfast_cook_reaction",
							"Not bad. That saved some money."
						))
					},
					{
						"text": "Skip breakfast - $0",
						"money": 0,
						"mood": -4,
						"energy": -10,
						"reaction": str(profile.get(
							"breakfast_skip_reaction",
							"I'll eat later. I'm already feeling tired."
						))
					}
				]
			}

		"wishlist_sale":
			return {
				"id": "wishlist_sale",
				"speaker": speaker,
				"message": "Something on my wishlist is on sale for $18. Do I get it?",
				"choices": [
					{
						"text": "Buy it - $18",
						"money": -18,
						"mood": 3,
						"reaction": "Well, it's finally on sale!",
						"delayed": {
							"days_later": 2,
							"period": "Evening",
							"mood": 2,
							"text": "The package arrived. Still pretty happy with that purchase."
						}
					},
					{
						"text": "Leave it - $0",
						"money": 0,
						"mood": -1,
						"reaction": "Maybe another time."
					}
				]
			}

		"small_refund":
			return {
				"id": "small_refund",
				"speaker": speaker,
				"message": "A $24 refund just arrived. Nice! What should I do with it?",
				"choices": [
					{
						"text": "Keep the $24",
						"money": 24,
						"mood": 1,
						"reaction": "A little extra money never hurts."
					},
					{
						"text": "Spend $20 of it",
						"money": 4,
						"mood": 6,
						"reaction": "A little treat, and I still have $4 left."
					}
				]
			}

	return {}

#endregion


#region Random Event Selection

func roll_random_event(
	day: int,
	period: String,
	profile: Dictionary
) -> Dictionary:

	if rng.randf() >= RANDOM_EVENT_CHANCE:
		return {}

	var available: Array[String] = []

	for event_id in SHARED_RULES.keys():
		var rule: Dictionary = SHARED_RULES[event_id]

		if not rule["periods"].has(period):
			continue

		var uses := int(event_uses.get(event_id, 0))
		var last_day := int(last_event_day.get(event_id, -1000))

		if uses >= int(rule["max_uses"]):
			continue

		if day - last_day < int(rule["cooldown"]):
			continue

		available.append(event_id)

	if available.is_empty():
		return {}

	var index := rng.randi_range(0, available.size() - 1)

	return create_shared_event(available[index], profile)


func record_event_shown(event_id: String, day: int) -> void:
	if not SHARED_RULES.has(event_id):
		return

	event_uses[event_id] = int(event_uses.get(event_id, 0)) + 1
	last_event_day[event_id] = day

#endregion


#region Delayed Consequences

func schedule_delayed(
	start_day: int,
	effect: Dictionary
) -> void:

	var target_day := start_day + maxi(
		1,
		int(effect.get("days_later", 1))
	)

	if target_day > DayManager.TOTAL_DAYS:
		return

	var saved_effect: Dictionary = effect.duplicate(true)
	saved_effect["day"] = target_day

	if not saved_effect.has("period"):
		saved_effect["period"] = "Morning"

	delayed_effects.append(saved_effect)


func take_due_effects(
	day: int,
	period: String
) -> Array[Dictionary]:

	var due: Array[Dictionary] = []

	for i in range(delayed_effects.size() - 1, -1, -1):
		var effect: Dictionary = delayed_effects[i]

		if int(effect["day"]) == day and str(effect["period"]) == period:
			due.push_front(effect)
			delayed_effects.remove_at(i)

	return due

#endregion
