extends Node

# ==========================================================
# FRY - YOU-CONOMICS
# ==========================================================

#region Fry - Starting Information

const TOTAL_DAYS: int = 30

var current_day: int = 1

var money: float = 100.00
var mood: int = 70
var energy: int = 80

#endregion

#region Fry - Node References

@onready var day_label: Label = $UI/HUD/DayLabel
@onready var money_label: Label = $UI/HUD/MoneyLabel
@onready var mood_label: Label = $UI/HUD/MoodLabel
@onready var energy_label: Label = $UI/HUD/EnergyLabel

@onready var next_day_button: Button = $UI/HUD/NextDayButton

#endregion

#region Fry - Initialization

func _ready() -> void:
	next_day_button.pressed.connect(_on_next_day_button_pressed)
	update_ui()
	
#endregion

#region Fry - UI

func update_ui() -> void:
	day_label.text = "DAY %d / %d" % [current_day, TOTAL_DAYS]
	
	money_label.text = "$%.2f" % money
	
	mood_label.text = "Mood: %d" % mood
	
	energy_label.text = "Energy: %d" % energy
	
	if current_day >= TOTAL_DAYS:
		next_day_button.text = "MONTH COMPLETE"
		next_day_button.disabled = true

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

#endregion

#region Fry - Day System

func next_day() -> void:
	if current_day < TOTAL_DAYS:
		current_day += 1
		update_ui()


func _on_next_day_button_pressed() -> void:
	next_day()

#endregion
