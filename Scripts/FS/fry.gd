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

# Set this when the project's actual main menu scene is ready.
const MAIN_MENU_SCENE_PATH: String = ""

#endregion

#region Fry - Mood Icons

# Five 64x64 mood sprites (kept in Fry's own folder).
const MOOD_VERY_HAPPY: Texture2D = preload("res://Images/Icons/Fry/fry_very_happy.png")
const MOOD_HAPPY: Texture2D = preload("res://Images/Icons/Fry/fry_happy.png")
const MOOD_NEUTRAL: Texture2D = preload("res://Images/Icons/Fry/fry_neutral.png")
const MOOD_SAD: Texture2D = preload("res://Images/Icons/Fry/fry_sad.png")
const MOOD_VERY_SAD: Texture2D = preload("res://Images/Icons/Fry/fry_very_sad.png")

#endregion

#region Fry - Personal Finances

# Tracks all money entering and leaving Fry's account.
var finance_history: Array[Dictionary] = []

var total_income: float = 0.0
var total_spending: float = 0.0


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

# Personal story flags stay with Fry
var story_flags: Dictionary = {
	"attend_campus": false,
	"packed_lunch": false,

	# Student club storyline.
	"club_helped": false,
	"club_ready": false,
	"club_supported": false,
	
	"caught_up_with_dulce": false
}


# Fry's textbook decisions and their consequences.
var textbook_choice: String = ""
var has_textbook: bool = false
var textbook_returned: bool = false

# Fry's first college exam.
var exam_completed: bool = false
var exam_passed: bool = false
var exam_pass_chance: int = 0

# The result appears after the exam period ends.
var pending_exam_result: Dictionary = {}

var campus_lines: Array[Dictionary] = []
var after_campus_lines: String = ""
var current_location: String = "bedroom"
var transitioning: bool = false

# Original two-character campus positions.
const FRY_CAMPUS_POSITION: Vector2 = Vector2(650, 690)
const DULCE_CAMPUS_POSITION: Vector2 = Vector2(1220, 690)

# Group positions for scenes featuring all three friends.
const FRY_GROUP_POSITION: Vector2 = Vector2(430, 690)
const STEVE_GROUP_POSITION: Vector2 = Vector2(950, 720)
const DULCE_GROUP_POSITION: Vector2 = Vector2(1470, 690)

# Speaker presentation.
const SPEAKER_SIZE_MULTIPLIER: float = 1.08
const INACTIVE_CHARACTER_COLOR: Color = Color(0.50, 0.50, 0.50, 1.0)

# Original sizes and positions.
var fry_bedroom_position: Vector2
var fry_normal_scale: Vector2
var dulce_normal_scale: Vector2
var steve_normal_scale: Vector2

var speaker_tween: Tween


#endregion


#region Fry - Free Time State

const STUDY_ENERGY_COST: int = 18

# These values persist throughout Fry's 30-day playthrough.
var study_sessions: int = 0
var activity_history: Array[Dictionary] = []
var active_room_activity: String = ""

const NAP_ENERGY_GAIN: int = 15
const SLEEP_ENERGY_GAIN: int = 25
const OVERNIGHT_ENERGY_GAIN: int = 10

# Prevent multiple study sessions in one day.
var last_study_day: int = -1

# True when a scheduled event uses up the period.
var event_consumes_period: bool = false

var pending_after_period_reaction: String = ""

# Multi-page end-of-month recap.
var month_recap_pages: Array[Dictionary] = []
var month_recap_page_index: int = 0


#endregion

#region Fry - Character Profile

var fry_profile: Dictionary = {
	"name": "Fry",

	"breakfast_cost": 29,
	"home_breakfast_cost": 0,

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
			"consumes_period": true,
			"reaction": "Alright, I'd better get going. Hopefully this shift goes by quickly.",
			"after_period_reaction": "Whew, that was exhausting. At least I'll have some extra money coming in.",

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


func add_late_month_events() -> void:

	# Day 16 - College project expenses.
	scheduled_events["16_Afternoon"] = {
		"id": "fry_project_printing",
		"speaker": "FRY",
		"message": "Our class presentation is coming up. I still need to prepare the handouts. How should I do it?",
		"choices": [
			{
				"text": "Color handouts - $18",
				"money": -18,
				"energy": -2,
				"mood": 5,
				"finance_label": "Color project handouts",
				"finance_category": "Education",
				"reaction": "They turned out pretty nice! Hopefully the group likes them."
			},
			{
				"text": "Black-and-white handouts - $6",
				"money": -6,
				"energy": -5,
				"mood": 2,
				"finance_label": "Basic project handouts",
				"finance_category": "Education",
				"reaction": "Nothing fancy, but they're readable. That's what matters."
			},
			{
				"text": "Create digital handouts - $0",
				"energy": -10,
				"mood": 1,
				"reaction": "That took longer than expected, but at least I didn't spend anything."
			}
		]
	}

	# Day 19 - Extra money before tuition.
	scheduled_events["19_Evening"] = {
		"id": "fry_quick_money",
		"speaker": "FRY",
		"message": "My school payment is due tomorrow. I could really use some extra cash tonight.",
		"choices": [
			{
				"text": "Take a rush editing job (+$35)",
				"money": 35,
				"energy": -18,
				"mood": -2,
				"consumes_period": true,
				"finance_label": "Rush editing job",
				"finance_category": "Income",
				"reaction": "Looks like someone needs this finished tonight. Better get started.",
				"after_period_reaction": "Finally finished! I'm exhausted, but the $35 payment came through."
			},
			{
				"text": "Sell an old video game (+$22)",
				"money": 22,
				"mood": -5,
				"finance_label": "Used video game sale",
				"finance_category": "Income",
				"reaction": "Kinda sad to let it go, but I needed the money more."
			},
			{
				"text": "Take the evening off",
				"energy": 8,
				"mood": 3,
				"reaction": "I'll deal with tomorrow when it comes. I really need a break."
			}
		]
	}

	# Day 22 - Bookstore shift with delayed payment.
	scheduled_events["22_Afternoon"] = {
		"id": "fry_inventory_shift",
		"speaker": "FRY",
		"message": "The bookstore needs help counting inventory. They're offering extra hours, but I'll have to give up my afternoon.",
		"choices": [
			{
				"text": "Work the full shift (+$52 later)",
				"energy": -14,
				"mood": -3,
				"consumes_period": true,
				"reaction": "Alright, a full shift it is. Time to get to work.",
				"after_period_reaction": "That was a long afternoon. At least I've got some extra pay coming.",
				"delayed": {
					"days_later": 2,
					"period": "Evening",
					"money": 52,
					"finance_label": "Inventory shift pay",
					"finance_category": "Income",
					"text": "The bookstore paid me for that inventory shift. +$52!"
				}
			},
			{
				"text": "Work a shorter shift (+$26 later)",
				"energy": -8,
				"mood": -1,
				"consumes_period": true,
				"reaction": "A shorter shift should be manageable.",
				"after_period_reaction": "Not too bad. A little extra money is better than nothing.",
				"delayed": {
					"days_later": 2,
					"period": "Evening",
					"money": 26,
					"finance_label": "Short inventory shift pay",
					"finance_category": "Income",
					"text": "The bookstore paid me for the short inventory shift. +$26!"
				}
			},
			{
				"text": "Keep my afternoon free",
				"energy": 5,
				"mood": 4,
				"reaction": "I'll pass this time. I've been working enough lately."
			}
		]
	}

	# Day 24 - Reliable versus cheap equipment.
	scheduled_events["24_Morning"] = {
		"id": "fry_broken_charger",
		"speaker": "FRY",
		"message": "Seriously? My laptop charger is acting up. I need this thing for school.",
		"choices": [
			{
				"text": "Buy a cheap charger - $14",
				"money": -14,
				"mood": 1,
				"finance_label": "Budget laptop charger",
				"finance_category": "Electronics",
				"reaction": "Fourteen bucks isn't bad. Hopefully it lasts.",
				"delayed": {
					"days_later": 4,
					"period": "Evening",
					"mood": -5,
					"energy": -3,
					"text": "Ugh, that cheap charger stopped working already. So much for saving money."
				}
			},
			{
				"text": "Buy a reliable charger - $38",
				"money": -38,
				"mood": 4,
				"finance_label": "Reliable laptop charger",
				"finance_category": "Electronics",
				"reaction": "That hurt my wallet, but this one should last a lot longer."
			},
			{
				"text": "Borrow a spare charger - $0",
				"energy": -6,
				"mood": -2,
				"reaction": "Found someone willing to lend me one. I'll have to figure something out later."
			}
		]
	}

	# Day 26 - Dinner and pantry inventory.
	scheduled_events["26_Evening"] = {
		"id": "fry_friday_dinner",
		"speaker": "FRY",
		"message": "Finally Friday. I'm pretty hungry, but I don't really feel like cooking tonight.",
		"choices": [
			{
				"text": "Cook dinner (1 grocery portion)",
				"money": 0,
				"pantry_cost": 1,
				"energy": 7,
				"mood": 3,
				"reaction": "Not bad! Glad I had something left in the kitchen."
			},
			{
				"text": "Order takeout - $17",
				"money": -17,
				"energy": 9,
				"mood": 6,
				"finance_label": "Friday night takeout",
				"finance_category": "Food",
				"reaction": "Okay, that was worth it. I just hope I don't regret the cost later."
			},
			{
				"text": "Skip dinner - $0",
				"energy": -10,
				"mood": -3,
				"reaction": "I'll just go to bed. Probably wasn't my best idea."
			}
		]
	}

	# Day 29 - Catching up with Dulce.
	scheduled_events["29_Evening"] = {
		"id": "fry_dulce_checkin",
		"speaker": "DULCE",
		"message": "Hey Fry! This month's been pretty chaotic, huh? Want to catch up tonight?",
		"choices": [
			{
				"text": "Meet for coffee - $9",
				"money": -9,
				"energy": -3,
				"mood": 8,
				"consumes_period": true,
				"set_flag": "caught_up_with_dulce",
				"flag_value": true,
				"finance_label": "Coffee with Dulce",
				"finance_category": "Social",
				"reaction": "That was nice. I really needed to get out and talk for a while."
			},
			{
				"text": "Call and catch up - $0",
				"energy": -2,
				"mood": 5,
				"set_flag": "caught_up_with_dulce",
				"flag_value": true,
				"reaction": "We ended up talking longer than I expected. That was fun."
			},
			{
				"text": "Stay home and rest",
				"energy": 10,
				"mood": 1,
				"reaction": "I'll catch up with her another day. Tonight I just need some sleep."
			}
		]
	}


#endregion


#region Fry - Node References

@onready var day_label: Label = $UI/HUD/DayLabel
@onready var weekday_label: Label = $UI/HUD/TimeRow/WeekdayLabel
@onready var period_label: Label = $UI/HUD/TimeRow/PeriodLabel

@onready var money_label: Label = $UI/HUD/TopRightStats/MoneyLabel
@onready var mood_label: Label = $UI/HUD/TopRightStats/MoodRow/MoodLabel
@onready var mood_icon: TextureRect = $UI/HUD/TopRightStats/MoodRow/MoodIcon
@onready var energy_label: Label = $UI/HUD/TopRightStats/EnergyLabel

@onready var next_day_button: Button = $UI/HUD/NextDayButton

@onready var dialogue_manager: DialogueManager = $UI/HUD/DialoguePanel
@onready var campus_backdrop: ColorRect = $CampusBackdrop
@onready var dulce_campus: Sprite2D = $DulceCampus
@onready var fry_sprite: Sprite2D = $Fry
@onready var steve_campus: Sprite2D = $SteveCampus

@onready var screen_fade: ColorRect = $UI/ScreenFade

# These areas are invisible click targets placed over the bedroom artwork.
@onready var bed_area: Area2D = $BedArea
@onready var desk_area: Area2D = $DeskArea

@onready var phone_ui: Control = $UI/PhoneUI

@onready var month_recap_overlay: ColorRect = $UI/HUD/MonthRecapOverlay
@onready var recap_title_label: Label = $UI/HUD/MonthRecapOverlay/RecapPanel/MarginContainer/VBoxContainer/RecapTitleLabel
@onready var recap_body_label: Label = $UI/HUD/MonthRecapOverlay/RecapPanel/MarginContainer/VBoxContainer/RecapBodyLabel
@onready var recap_continue_button: Button = $UI/HUD/MonthRecapOverlay/RecapPanel/MarginContainer/VBoxContainer/RecapContinueButton

@onready var recap_rows: VBoxContainer = $UI/HUD/MonthRecapOverlay/RecapPanel/MarginContainer/VBoxContainer/RecapRows
@onready var recap_page_label: Label = $UI/HUD/MonthRecapOverlay/RecapPanel/MarginContainer/VBoxContainer/RecapPageLabel


@onready var month_complete_overlay: ColorRect = $UI/HUD/MonthCompleteOverlay
@onready var complete_body_label: Label = $UI/HUD/MonthCompleteOverlay/CompletePanel/MarginContainer/VBoxContainer/CompleteBodyLabel
@onready var play_again_button: Button = $UI/HUD/MonthCompleteOverlay/CompletePanel/MarginContainer/VBoxContainer/PlayAgainButton
@onready var main_menu_button: Button = $UI/HUD/MonthCompleteOverlay/CompletePanel/MarginContainer/VBoxContainer/MainMenuButton


#endregion


#region Fry - Initialization

func _ready() -> void:
	# Remember how the characters look normally.
	fry_bedroom_position = fry_sprite.position
	fry_normal_scale = fry_sprite.scale
	dulce_normal_scale = dulce_campus.scale
	steve_normal_scale = steve_campus.scale
	
	campus_backdrop.hide()
	dulce_campus.hide()
	steve_campus.hide()
	screen_fade.color = Color.BLACK
	screen_fade.modulate.a = 0.0
	screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The full-screen HUD must not swallow clicks meant for bedroom objects.
	# Child buttons and the visible dialogue panel keep their own input filters.
	$UI/HUD.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	DayManager.reset_calendar()
	
	# DAY DEBUG: Choose which day and period to start on. DEVELOPER DELETE
	#DayManager.current_day = 30
	#DayManager.period_index = 2
	#
	## DEBUG: Simulate previous decisions. DEVELOPER DELETE
	#exam_completed = true
	#exam_passed = true
	#study_sessions = 3
	#story_flags["club_helped"] = true
	#story_flags["club_ready"] = true
	#story_flags["caught_up_with_dulce"] = true
	
	DayManager.isWeekend = DayManager.is_weekend_day(DayManager.current_day)
	
	add_late_month_events()
	
	# Connect Fry's financial information to the phone.
	phone_ui.call("set_finance_source", self)
	
	DayManager.schedule_night_for_day(5)
	EventManager.reset_run()

	next_day_button.pressed.connect(
		_on_next_day_button_pressed
	)

	dialogue_manager.choice_selected.connect(
		_on_dialogue_choice_selected
	)

	dialogue_manager.speaker_changed.connect(
		_on_dialogue_speaker_changed
	)

	dialogue_manager.dialogue_closed.connect(
		_on_dialogue_closed
	)

	DayManager.month_completed.connect(
		_on_month_completed
	)

	month_recap_overlay.hide()
	recap_continue_button.pressed.connect(_on_recap_continue_pressed)

	# Final month-completion screen.
	month_complete_overlay.hide()

	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Optional bedroom interactions. Does not interfere with the dialogue signals.
	bed_area.input_event.connect(_on_bed_input_event)
	desk_area.input_event.connect(_on_desk_input_event)

	update_ui()
	start_current_period()

#endregion


#region Fry - UI

func update_ui() -> void:

	day_label.text = "DAY %d / %d" % [
		DayManager.current_day,
		DayManager.TOTAL_DAYS
	]

	weekday_label.text = DayManager.get_weekday_name().to_upper() + " •"
	period_label.text = DayManager.get_period().to_upper()
	update_period_color()

	money_label.text = "$%.2f" % money
	mood_label.text = "Mood: %d" % mood
	update_mood_icon()
	energy_label.text = "Energy: %d" % energy

	next_day_button.disabled = DayManager.finished

	if DayManager.finished:
		next_day_button.text = "MONTH COMPLETE"
		return

	var next_time: Dictionary = DayManager.get_next_time()

	if next_time.is_empty():
		next_day_button.text = "FINISH MONTH"
	elif int(next_time["day"]) != DayManager.current_day:
		next_day_button.text = "NEXT DAY"
	else:
		next_day_button.text = "TO " + str(next_time["period"]).to_upper()


func update_period_color() -> void:
	var period_color: Color

	match DayManager.get_period():
		"Morning":
			period_color = Color("#EBC477")
		"Afternoon":
			period_color = Color("#A9D2DE")
		"Evening":
			period_color = Color("#E6A078")
		"Night":
			period_color = Color("#B9A7E6")
		_:
			period_color = Color("#F0E5D8")

	period_label.add_theme_color_override("font_color", period_color)

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


func change_money(
	amount: float,
	reason: String = "Other transaction",
	category: String = "Other"
) -> void:
	if is_zero_approx(amount):
		return
	
	money += amount
	
	if amount > 0.0:
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
	
	update_ui()



func change_mood(amount: int) -> void:
	mood = clampi(mood + amount, 0, 100)
	update_ui()


func change_energy(amount: int) -> void:
	energy = clampi(energy + amount, 0, 100)
	update_ui()



func apply_stat_changes(changes: Dictionary) -> void:
	var amount: float = float(changes.get("money", 0))

	if not is_zero_approx(amount):
		var reason: String = str(
			changes.get(
				"finance_label",
				changes.get("text", "Event decision")
			)
		)

		var category: String = str(
			changes.get(
				"finance_category",
				"Income" if amount > 0.0 else "Other"
			)
		)
	
		change_money(amount, reason, category)
	
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
		
		change_money(paycheck, "Bookstore paycheck", "Income")
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
		change_money(-amount, str(bill["name"]), "Bills")
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

#endregion



#region Fry - Grocery System

# Four meal portions per grocery purchase.
const GROCERY_BUNDLE_SIZE: int = 4
const GROCERY_STORE_PRICE: float = 24.0
const FOODDASH_DELIVERY_FEE: float = 7.0

# Fry starts with two portions already in his kitchen.
var grocery_meals: int = 2

# Only one FoodDash delivery can be pending at a time.
var pending_grocery_delivery: Dictionary = {}

# Groceries delivered while Fry was away or before he checked.
var pending_home_delivery_meals: int = 0

# Show the shopping trip reaction once Fry returns home.
var pending_store_trip_notice: String = ""


func customize_fry_breakfast_event() -> void:
	var choices: Array = active_event.get("choices", [])

	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var label: String = str(choice.get("text", "")).to_lower()

		if (
			label.contains("make breakfast")
			or label.contains("cook breakfast")
			or label.contains("cook at home")
			or label.contains("make at home")
		):
			choice["money"] = 0.0
			choice["pantry_cost"] = 1
			choice["is_home_cooked_breakfast"] = true

			if grocery_meals > 0:
				choice["text"] = "Make breakfast (1 grocery portion)"
			else:
				choice["text"] = "Make breakfast (NO GROCERIES)"

			choices[i] = choice
			active_event["choices"] = choices
			return

	push_warning("Could not identify Fry's breakfast cooking choice.")


func get_grocery_snapshot() -> Dictionary:
	var delivery_status: String = "No delivery scheduled."

	if not pending_grocery_delivery.is_empty():
		delivery_status = "Arriving Day %d, %s" % [
			int(pending_grocery_delivery["day"]),
			str(pending_grocery_delivery["period"])
		]

	return {
		"meals": grocery_meals,
		"balance": money,
		"bundle_size": GROCERY_BUNDLE_SIZE,
		"store_price": GROCERY_STORE_PRICE,
		"delivery_fee": FOODDASH_DELIVERY_FEE,
		"fooddash_price": GROCERY_STORE_PRICE + FOODDASH_DELIVERY_FEE,
		"delivery_status": delivery_status,
		"delivery_pending": not pending_grocery_delivery.is_empty()
	}


func purchase_groceries(delivery: bool) -> Dictionary:
	if DayManager.finished or transitioning:
		return {
			"success": false,
			"message": "Groceries aren't available right now."
		}

	var next_time: Dictionary = DayManager.get_next_time()

	if next_time.is_empty():
		return {
			"success": false,
			"message": "There isn't enough time left in the month."
		}

	var cost: float = GROCERY_STORE_PRICE

	if delivery:
		cost += FOODDASH_DELIVERY_FEE

		if not pending_grocery_delivery.is_empty():
			return {
				"success": false,
				"message": "You already have a FoodDash order on the way."
			}
	else:
		# In-person shopping is only available during free time at home.
		if (
			current_location != "bedroom"
			or event_state != ""
			or not period_queue.is_empty()
			or DayManager.get_period() not in ["Morning", "Afternoon"]
		):
			return {
				"success": false,
				"message": "Fry needs a free morning or afternoon at home to visit the store."
			}

	if money < cost:
		return {
			"success": false,
			"message": "Not enough money. You need $%.2f." % cost
		}

	if delivery:
		# Record groceries and the convenience fee separately.
		change_money(
			-GROCERY_STORE_PRICE,
			"FoodDash groceries",
			"Groceries"
		)

		change_money(
			-FOODDASH_DELIVERY_FEE,
			"FoodDash delivery fee",
			"Delivery Fees"
		)

		pending_grocery_delivery = {
			"day": int(next_time["day"]),
			"period": str(next_time["period"]),
			"meals": GROCERY_BUNDLE_SIZE
		}

		return {
			"success": true,
			"uses_period": false,
			"message": "Order placed! Your groceries will arrive next period."
		}

	# Shopping in person is cheaper, but takes time.
	change_money(
		-GROCERY_STORE_PRICE,
		"In-person groceries",
		"Groceries"
	)
	
	grocery_meals += GROCERY_BUNDLE_SIZE
	
	pending_store_trip_notice = (
		"Nice, I've got the groceries now. "
		+ "That's %d more meals covered."
	) % GROCERY_BUNDLE_SIZE
	
	return {
		"success": true,
		"uses_period": true,
		"message": "Shopping trip completed."
	}

#endregion



#region Fry - Free Time Activities

# Room interactions work only when Fry is home and no event is pending.
# The button remains available, so the player can skip their free time.
func can_use_room_activity() -> bool:
	return (
		current_location == "bedroom"
		and not transitioning
		and not DayManager.finished
		and event_state == ""
		and active_event.is_empty()
		and period_queue.is_empty()
	)


func _on_bed_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			show_room_activity("sleep")


func _on_desk_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			show_room_activity("study")


func show_room_activity(activity: String) -> void:
	if not can_use_room_activity():
		return

	var period: String = DayManager.get_period()

	# Check whether Fry can perform the activity.
	match activity:
		"sleep":
			if period == "Morning":
				show_room_activity_unavailable(
					"I just woke up. I should probably get on with my day."
				)
				return

			if period == "Afternoon" and energy > 40:
				show_room_activity_unavailable(
					"I'm not tired enough for a nap right now."
				)
				return

		"study":
			if period != "Afternoon" and period != "Evening":
				show_room_activity_unavailable(
					"This isn't a good time to study. I'll do it later."
				)
				return

			if last_study_day == DayManager.current_day:
				show_room_activity_unavailable(
					"I already studied today. I should give my brain a break."
				)
				return

			if energy < STUDY_ENERGY_COST:
				show_room_activity_unavailable(
					"I'm too exhausted to concentrate. I should rest first."
				)
				return

		_:
			return

	active_room_activity = activity
	event_state = "room_activity_choice"
	next_day_button.hide()

	match activity:
		"sleep":
			var gain: int = get_rest_energy_gain()
			var message: String = ""
			var option: String = ""

			if period == "Afternoon":
				message = "I'm pretty exhausted. A short nap might help."
				option = "Take a nap (+%d Energy)" % gain

			elif period == "Evening":
				var next_time: Dictionary = DayManager.get_next_time()

				if str(next_time.get("period", "")) == "Night":
					message = "I've still got tonight ahead of me. Maybe I should rest first."
					option = "Rest (+%d Energy)" % gain
				else:
					message = "It's getting late. Should I turn in early?"
					option = "Sleep early (+%d Energy)" % gain

			else:
				message = "It's getting pretty late. Time to sleep?"
				option = "Go to sleep (+%d Energy)" % gain

			dialogue_manager.show_dialogue(
				"FRY",
				message,
				[option, "Never mind"]
			)

		"study":
			dialogue_manager.show_dialogue(
				"FRY",
				"I have an exam to prepare for. I've studied %d time(s) so far." % study_sessions,
				[
					"Study (-%d Energy)" % STUDY_ENERGY_COST,
					"Never mind"
				]
			)



func show_room_activity_unavailable(message: String) -> void:
	active_room_activity = ""
	event_state = "room_activity_unavailable"
	next_day_button.hide()

	dialogue_manager.show_dialogue(
		"FRY",
		message,
		["Okay"]
	)


func get_rest_energy_gain() -> int:
	match DayManager.get_period():
		"Afternoon":
			return NAP_ENERGY_GAIN

		"Evening":
			var next_time: Dictionary = DayManager.get_next_time()

			# A special Night is coming, so this is only a rest.
			if str(next_time.get("period", "")) == "Night":
				return NAP_ENERGY_GAIN

			return SLEEP_ENERGY_GAIN

		"Night":
			return SLEEP_ENERGY_GAIN

	return 0



func resolve_room_activity_choice(index: int) -> void:
	if index == 1:
		cancel_room_activity()
		return

	if index != 0:
		return

	var reaction: String = ""

	match active_room_activity:
		"sleep":
			var gain: int = get_rest_energy_gain()

			if gain <= 0 or DayManager.get_period() == "Morning":
				show_room_activity_unavailable(
					"I can't sleep right now."
				)
				return

			if DayManager.get_period() == "Afternoon" and energy > 40:
				show_room_activity_unavailable(
					"I don't really need a nap right now."
				)
				return

			change_energy(gain)
			reaction = "That should help. Time to get some rest."

		"study":
			if last_study_day == DayManager.current_day:
				show_room_activity_unavailable(
					"I already studied today."
				)
				return

			if DayManager.get_period() != "Afternoon" and DayManager.get_period() != "Evening":
				show_room_activity_unavailable(
					"I'll study another time."
				)
				return

			if energy < STUDY_ENERGY_COST:
				show_room_activity_unavailable(
					"I'm too tired to study right now."
				)
				return

			change_energy(-STUDY_ENERGY_COST)

			study_sessions += 1
			last_study_day = DayManager.current_day

			reaction = "I managed to get some studying done. That's %d session(s) so far." % study_sessions

		_:
			cancel_room_activity()
			return

	activity_history.append({
		"day": DayManager.current_day,
		"period": DayManager.get_period(),
		"activity": active_room_activity
	})

	event_state = "room_activity_result"

	dialogue_manager.show_dialogue(
		"FRY",
		reaction,
		["Continue"]
	)



func cancel_room_activity() -> void:
	active_room_activity = ""
	event_state = ""
	dialogue_manager.close_dialogue()
	next_day_button.show()


func complete_room_activity() -> void:
	# An activity consumes this period. Reset the dialogue state first,
	# so Fry's existing advance_time() method is allowed to run.
	active_room_activity = ""
	event_state = ""
	dialogue_manager.close_dialogue()
	advance_time(true)

#endregion

#region Fry - Day Progression

func start_current_period() -> void:
	event_state = ""
	active_event.clear()
	event_consumes_period = false
	active_bill_id = ""
	active_room_activity = ""
	period_queue.clear()
	

	# Process deliveries when their scheduled period arrives.
	if not pending_grocery_delivery.is_empty():
		var delivery_day: int = int(pending_grocery_delivery["day"])
		var delivery_period: String = str(
			pending_grocery_delivery["period"]
		)

		if (
			DayManager.current_day == delivery_day
			and DayManager.get_period() == delivery_period
		):
			var delivered_meals: int = int(
				pending_grocery_delivery["meals"]
			)

			grocery_meals += delivered_meals
			pending_home_delivery_meals += delivered_meals
			pending_grocery_delivery.clear()


	# Fry only comments on FoodDash deliveries when he's home.
	if (
		current_location == "bedroom"
		and pending_home_delivery_meals > 0
	):
		period_queue.append({
			"type": "notice",
			"speaker": "FRY",
			"message": "Oh, my groceries arrived! I've got %d meal portion(s) in the kitchen now." % grocery_meals
		})

		# Clear the notification so it only appears once.
		pending_home_delivery_meals = 0

	# Don't interrupt campus events with grocery store dialogue.
	# Wait until Fry returns home.
	if (
		current_location == "bedroom"
		and not pending_store_trip_notice.is_empty()
	):
		period_queue.append({
			"type": "notice",
			"speaker": "FRY",
			"message": pending_store_trip_notice
		})

		# Clear the store notification separately.
		pending_store_trip_notice = ""
		pending_home_delivery_meals = 0

	# Show the exam result after the period changes.
	if not pending_exam_result.is_empty():
		apply_stat_changes(pending_exam_result)
		
		period_queue.append({
			"type": "notice",
			"speaker": "FRY",
			"message": str(pending_exam_result.get("text", ""))
		})
		
		pending_exam_result.clear()
	
	# Show the previous event's follow-up after time advances.
	if not pending_after_period_reaction.is_empty():
		period_queue.append({
			"type": "notice",
			"speaker": "FRY",
			"message": pending_after_period_reaction
		})
		
		pending_after_period_reaction = ""


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

	# Day 8: Dulce helps Fry compare textbook options.
	elif key == "8_Afternoon":
		start_textbook_story()
		return

	# Day 9: Free library copies require a pickup trip.
	elif key == "9_Afternoon" and textbook_choice == "library" and not has_textbook:
		scheduled = make_library_pickup_event()

	# Day 12: Fry takes his first college exam.
	elif key == "12_Afternoon":
		start_first_exam_story()
		return

	# Day 15: Borrowed and rented books must be returned.
	elif key == "15_Afternoon" and textbook_choice in ["library", "rent"] and has_textbook:
		scheduled = make_textbook_return_event()

	# Day 15: Fry may resell a used textbook.
	elif key == "15_Afternoon" and textbook_choice == "used" and has_textbook:
		scheduled = make_textbook_resale_event()

	# Student club storyline with Dulce and Steve.
	if key == "17_Evening":
		scheduled = make_club_invitation_event()

	elif key == "23_Evening":
		scheduled = make_club_preparation_event()

	elif key == "25_Evening":
		scheduled = make_club_result_event()

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

	# Customize Fry's breakfast regardless of how it was triggered.
	var is_breakfast: bool = (
		str(active_event.get("id", "")).to_lower().contains("breakfast")
		or (scheduled is String and scheduled == "breakfast")
	)

	if not is_breakfast:
		for option in active_event.get("choices", []):
			var label: String = str(option.get("text", "")).to_lower()

			if (
				label.contains("make breakfast")
				or label.contains("cook breakfast")
				or label.contains("cook at home")
			):
				is_breakfast = true
				break

	if is_breakfast:
		active_event["fry_pantry_breakfast"] = true
		customize_fry_breakfast_event()

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


func advance_time(force_fade: bool = false) -> void:
	if event_state != "" or transitioning:
		return

	var previous_day: int = DayManager.current_day
	DayManager.advance_period()

	if DayManager.finished:
		return
	
	# A new day means Fry got some sleep overnight.
	# Sleeping early gives additional Energy.
	# May or may not change it
	if DayManager.current_day > previous_day:
		change_energy(OVERNIGHT_ENERGY_GAIN)

	var day: int = DayManager.current_day
	var period: String = DayManager.get_period()

	var going_to_campus: bool = (
		(
			day == 4
			and period == "Afternoon"
			and bool(story_flags.get("attend_campus", false))
		)
		or (
			day == 8
			and period == "Afternoon"
		)
		or (
			day == 12
			and period == "Afternoon"
		)
	)



	var destination: String = "campus" if going_to_campus else "bedroom"
	var story_overnight: bool = (
		previous_day != day
		and day == 4
		and period == "Morning"
		and bool(story_flags.get("attend_campus", false))
	)

	# Fade overnight for the story, and whenever the place changes.
	if destination != current_location or story_overnight or force_fade:
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
	
	# Determine whether this choice requires groceries.
	var portions_needed: int = int(choice.get("pantry_cost", 0))
	var choice_label: String = str(choice.get("text", "")).to_lower()
	
	var is_home_cooked_breakfast: bool = (
		bool(choice.get("is_home_cooked_breakfast", false))
		or choice_label.contains("make breakfast")
		or choice_label.contains("cook breakfast")
		or choice_label.contains("cook at home")
	)
	
	if is_home_cooked_breakfast:
		portions_needed = 1
		choice["money"] = 0.0
	
	# Block cooking before applying any financial or stat changes.
	if portions_needed > grocery_meals:
		event_state = "insufficient_groceries"

		dialogue_manager.show_dialogue(
			"FRY",
			"I don't have enough groceries to make that. "
			+ "I'll need to get more food or choose something else.",
			["Choose again"]
		)
		return

	
	var cash_change: float = float(choice.get("money", 0))
	
	if cash_change < 0.0 and money + cash_change < 0.0:
		event_state = "insufficient_cash"
		
		dialogue_manager.show_dialogue(
			"FRY",
			"I don't have enough money for that. I'll have to choose something else.",
			["Choose again"]
		)
		return

	# Calculate Fry's first exam result.
	if str(active_event.get("id", "")) == "fry_first_exam":
		var effective_study: int = mini(study_sessions, 4)
		var textbook_bonus: int = 15 if has_textbook else 0

		exam_pass_chance = clampi(
			30 + (effective_study * 12) + textbook_bonus,
			5,
			90
		)

		# Roll a number from 1 to 100.
		var exam_roll: int = randi_range(1, 100)

		exam_passed = exam_roll <= exam_pass_chance
		exam_completed = true

		var result_message: String = ""
		var result_mood: int = 0
		
		if exam_passed:
			if study_sessions == 0:
				result_message = "Wait, I actually passed?! I barely studied. Guess I got lucky this time."
			else:
				result_message = "I passed! All that preparation really helped. Glad I made time for it."
			
			result_mood = 8
		
		else:
			result_message = "I didn't pass... I should've planned my studying better. I'll have to do better next time."
			result_mood = -10
		
		# Apply the result when Fry reaches the evening.
		pending_exam_result = {
			"mood": result_mood,
			"text": result_message
		}
		
	# Apply money, mood, and energy changes exactly once.
	apply_stat_changes(choice)
	
	# Consume groceries only after the choice succeeds.
	if portions_needed > 0:
		grocery_meals -= portions_needed
		
		if is_home_cooked_breakfast:
			choice["reaction"] = (
				"Not bad! Made breakfast with what I already had. "
				+ "I've got %d meal portion(s) left."
			) % grocery_meals
	
	# Remember Fry's textbook decision.
	if choice.has("textbook_choice"):
		textbook_choice = str(choice["textbook_choice"])
		has_textbook = textbook_choice != "library"
	
	# Used by later textbook events.
	if choice.has("has_textbook"):
		has_textbook = bool(choice["has_textbook"])
	
	if choice.has("textbook_returned"):
		textbook_returned = bool(choice["textbook_returned"])
	
	event_consumes_period = bool(choice.get("consumes_period", false))
	
	# Save any dialogue that should appear after
	# the event consumes the current period.
	if event_consumes_period:
		pending_after_period_reaction = str(
			choice.get("after_period_reaction", "")
		)
		
	
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
	var should_advance: bool = event_consumes_period

	event_consumes_period = false
	active_event.clear()


	if finished_id == "fry_textbook_choice":
		var dulce_reaction: String = ""

		match textbook_choice:
			"library":
				dulce_reaction = "That's a good way to save money. Just remember to pick it up tomorrow!"

			"rent":
				dulce_reaction = "Not bad! You saved some money compared to buying it. Don't forget the return date."

			"used":
				dulce_reaction = "At least you own it now. You might get some money back if you sell it later."

		campus_lines = [
			{
				"speaker": "DULCE",
				"message": dulce_reaction
			},
			{
				"speaker": "STEVE",
				"message": "Nice. If you ever need help finding a copy, just let us know."
			},
			{
				"speaker": "FRY",
				"message": "Thanks, guys. Now I just need to make sure I can afford my phone bill on Wednesday."
			}
		]


		after_campus_lines = "textbook_finish"
		show_next_campus_line()
		return


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

	if should_advance:
		advance_time(true)
	else:
		next_day_button.show()


#endregion


#region Fry - Dialogue Handling


func _on_dialogue_choice_selected(index: int) -> void:

	match event_state:

		"room_activity_choice":
			resolve_room_activity_choice(index)

		"room_activity_result":
			complete_room_activity()

		"room_activity_unavailable":
			cancel_room_activity()

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

		"insufficient_groceries":
			event_state = "event_choice"
			
			var option_texts: Array[String] = []
			
			for option in active_event.get("choices", []):
				option_texts.append(
					str(option.get("text", "Choose"))
				)
			
			dialogue_manager.show_dialogue(
				str(active_event.get("speaker", "FRY")),
				str(active_event.get("message", "")),
				option_texts
			)

		"month_end":
			pass

		
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
	var paid_count: int = 0

	for bill_id in bills.keys():
		if bool(bills[bill_id]["paid"]):
			paid_count += 1

	# Calculate grocery costs from recorded transactions.
	var grocery_spending: float = 0.0
	var delivery_spending: float = 0.0

	for transaction in finance_history:
		var amount: float = float(transaction.get("amount", 0.0))
		var category: String = str(transaction.get("category", ""))

		if amount >= 0.0:
			continue

		if category == "Groceries":
			grocery_spending += absf(amount)

		elif category == "Delivery Fees":
			delivery_spending += absf(amount)

	# Describe the exam outcome.
	var exam_summary: String = "Not completed"

	if exam_completed:
		if exam_passed:
			exam_summary = "Passed"
		else:
			exam_summary = "Failed"

	# Describe Fry's involvement in the club fundraiser.
	var club_summary: String = "Did not participate"

	if bool(story_flags.get("club_helped", false)):
		if bool(story_flags.get("club_ready", false)):
			club_summary = "Built and tested the website"
		else:
			club_summary = "Helped build the website"

	elif bool(story_flags.get("club_supported", false)):
		club_summary = "Helped promote the fundraiser"


	# ==================================================
	# Personalized final reflection
	# ==================================================

	# 1. Financial decisions.
	var money_reflection: String = ""

	if unpaid_total <= 0.01:
		if money >= 100.0:
			money_reflection = (
				"I paid my bills and kept some money aside. "
				+ "I want to keep that going."
			)
		else:
			money_reflection = (
				"I managed to pay my bills, but money is tight. "
				+ "I need a better cushion next month."
			)

	elif money >= unpaid_total:
		money_reflection = (
			"I still have unpaid bills, even though I could "
			+ "cover them. I shouldn't keep putting them off."
		)

	else:
		money_reflection = (
			"I still owe more than I have. Next month, "
			+ "I need to prioritize my bills."
		)

	if total_late_fees > 0.01:
		money_reflection += " Those late fees didn't help."

	# 2. College performance.
	var school_reflection: String = ""

	if exam_completed:
		if exam_passed:
			if study_sessions >= 2:
				school_reflection = (
					"I passed my exam, and all that studying paid off."
				)
			else:
				school_reflection = (
					"I passed my exam! Still, I should prepare "
					+ "more next time."
				)
		else:
			if study_sessions > 0:
				school_reflection = (
					"I studied, but the exam didn't go my way. "
					+ "I'll try a different approach."
				)
			else:
				school_reflection = (
					"I didn't pass the exam. I really should've "
					+ "made more time to study."
				)
	else:
		school_reflection = (
			"I don't have an exam result to look back on."
		)

	# 3. Friendships and the student club.
	var friends_reflection: String = ""

	var club_helped: bool = bool(
		story_flags.get("club_helped", false)
	)
	var club_ready: bool = bool(
		story_flags.get("club_ready", false)
	)
	var club_supported: bool = bool(
		story_flags.get("club_supported", false)
	)
	var caught_up: bool = bool(
		story_flags.get("caught_up_with_dulce", false)
	)

	if club_helped and club_ready:
		friends_reflection = (
			"Dulce and Steve trusted me with the fundraiser, "
			+ "and we pulled it off!"
		)

	elif club_helped:
		friends_reflection = (
			"Helping Dulce and Steve taught me to "
			+ "double-check my work."
		)

	elif club_supported:
		friends_reflection = (
			"I'm glad I could help Dulce and Steve "
			+ "promote the fundraiser."
		)

	elif bool(story_flags.get("attend_campus", false)):
		friends_reflection = (
			"I'm glad I made some time for Dulce "
			+ "and Steve at college."
		)

	else:
		friends_reflection = (
			"I should make more time for my friends next month."
		)

	if caught_up:
		if club_helped or club_supported:
			friends_reflection += (
				" Catching up with Dulce was worth it, too."
			)
		else:
			friends_reflection = (
				"I'm glad I made time to catch up with Dulce."
			)

	# Combine the three reflections.
	var conclusion: String = (
		money_reflection
		+ "\n\n"
		+ school_reflection
		+ "\n\n"
		+ friends_reflection
	)

	# Prepare the five recap screens.
	month_recap_pages = [
	{
		"title": "FINANCIAL SUMMARY",
		"body": (
			"Starting balance: $100.00\n"
			+ "Total earned: $%.2f\n"
			+ "Total spent: $%.2f\n"
			+ "Remaining cash: $%.2f"
		) % [
			total_income,
			total_spending,
			money
		]
	},
	{
		"title": "BILLS",
		"body": (
			"Bills paid: %d / %d\n"
			+ "Still owed: $%.2f\n"
			+ "Late fees: $%.2f"
		) % [
			paid_count,
			bills.size(),
			unpaid_total,
			total_late_fees
		]
	},
	{
		"title": "DAILY LIFE",
		"body": (
			"Groceries purchased: $%.2f\n"
			+ "Delivery fees: $%.2f\n"
			+ "Meals remaining: %d"
		) % [
			grocery_spending,
			delivery_spending,
			grocery_meals
		]
	},
	{
		"title": "COLLEGE & FRIENDS",
		"body": (
			"Study sessions: %d\n"
			+ "Exam result: %s\n"
			+ "Club: %s"
		) % [
			study_sessions,
			exam_summary,
			club_summary
		]
	},
	{
		"title": "FINAL REFLECTION",
		"body": conclusion
	}
]

	month_recap_page_index = 0
	show_month_recap_page()


func show_month_recap_page() -> void:
	if month_recap_pages.is_empty():
		return

	var page: Dictionary = month_recap_pages[month_recap_page_index]
	var is_last_page: bool = (
		month_recap_page_index == month_recap_pages.size() - 1
	)

	recap_title_label.text = str(page.get("title", "SUMMARY"))

	var body_text: String = str(page.get("body", ""))

	# The final reflection is regular paragraph text.
	# All other pages use neatly aligned rows.
	recap_body_label.visible = is_last_page
	recap_rows.visible = not is_last_page

	if is_last_page:
		recap_body_label.text = body_text
	else:
		populate_recap_rows(body_text)

	# Page navigation.
	recap_continue_button.text = (
		"Finish" if is_last_page else "Continue"
	)

	recap_page_label.text = "%d OF %d" % [
		month_recap_page_index + 1,
		month_recap_pages.size()
	]

	# Hide the normal dialogue.
	dialogue_manager.close_dialogue()
	month_recap_overlay.show()


func populate_recap_rows(body_text: String) -> void:
	# Remove the previous page's rows.
	for child in recap_rows.get_children():
		recap_rows.remove_child(child)
		child.queue_free()

	var lines: PackedStringArray = body_text.split("\n", false)

	for line in lines:
		var parts: PackedStringArray = line.split(": ", false, 1)

		if parts.size() != 2:
			continue

		var row_name: String = parts[0]
		var row_value: String = parts[1]

		var is_final_balance: bool = (
			month_recap_page_index == 0
			and row_name == "Remaining cash"
		)

		# Separate the remaining balance from other totals.
		if is_final_balance:
			var divider: HSeparator = HSeparator.new()
			divider.modulate = Color("#617181")
			divider.custom_minimum_size = Vector2(0, 12)
			recap_rows.add_child(divider)

		# One horizontal row with left and right columns.
		var row: HBoxContainer = HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 46)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		recap_rows.add_child(row)

		# Description on the left.
		var name_label: Label = Label.new()
		name_label.text = row_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override(
			"font_size", 25 if is_final_balance else 23
		)
		name_label.add_theme_color_override(
			"font_color",
			Color("#F3E8D7") if is_final_balance else Color("#C4CDD7")
		)
		row.add_child(name_label)

		# Value on the right.
		var value_label: Label = Label.new()
		value_label.text = row_value
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		value_label.add_theme_font_size_override(
			"font_size", 25 if is_final_balance else 23
		)

		# Use meaningful colors for financial outcomes.
		var value_color: Color = Color("#EAECEF")

		if row_name in [
			"Total earned",
			"Remaining cash",
			"Meals remaining"
		]:
			value_color = Color("#8BDDA9")

		elif row_name in [
			"Total spent",
			"Groceries purchased",
			"Delivery fees"
		]:
			value_color = Color("#F1A5A0")

		elif row_name == "Late fees":
			value_color = (
				Color("#8BDDA9") if total_late_fees <= 0.01
				else Color("#F1A5A0")
			)

		elif row_name == "Still owed":
			value_color = (
				Color("#8BDDA9") if row_value == "$0.00"
				else Color("#F1A5A0")
			)

		elif row_name == "Exam result":
			if row_value == "Passed":
				value_color = Color("#8BDDA9")
			elif row_value == "Failed":
				value_color = Color("#F1A5A0")

		elif row_name == "Club":
			if row_value != "Did not participate":
				value_color = Color("#8BDDA9")

		if row_name == "Remaining cash" and money < 0.0:
			value_color = Color("#F1A5A0")

		value_label.add_theme_color_override(
			"font_color", value_color
		)

		row.add_child(value_label)


func _on_recap_continue_pressed() -> void:
	month_recap_page_index += 1

	if month_recap_page_index < month_recap_pages.size():
		show_month_recap_page()
	else:
		show_month_complete_screen()


func show_month_complete_screen() -> void:
	event_state = "month_complete"

	# Close the recap and any remaining dialogue.
	month_recap_overlay.hide()
	dialogue_manager.close_dialogue()
	next_day_button.hide()

	complete_body_label.text = (
		"You made it through 30 days of college life!\n\n"
		+ "Every financial decision, every challenge, and every "
		+ "moment with your friends shaped Fry's month.\n\n"
		+ "What would you do differently next time?"
	)

	# Only enable Main Menu after its actual scene is connected.
	var menu_available: bool = (
		not MAIN_MENU_SCENE_PATH.is_empty()
		and ResourceLoader.exists(MAIN_MENU_SCENE_PATH)
	)

	main_menu_button.disabled = not menu_available

	if menu_available:
		main_menu_button.text = "Main Menu"
	else:
		main_menu_button.text = "Main Menu (Coming Soon)"

	month_complete_overlay.show()


func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	if MAIN_MENU_SCENE_PATH.is_empty():
		return

	if not ResourceLoader.exists(MAIN_MENU_SCENE_PATH):
		push_warning("Main menu scene could not be found.")
		return

	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


#endregion


#region Fry - Character-Specific Events


func make_club_invitation_event() -> Dictionary:
	var message: String = ""

	if bool(story_flags.get("attend_campus", false)):
		message = (
			"Dulce just texted me. That student club we saw at the fair "
			+ "is organizing a fundraiser. She and Steve asked if I could "
			+ "help build a signup page."
		)
	else:
		message = (
			"Dulce just texted me. She's helping Steve with a student "
			+ "club fundraiser, and they need someone to build a signup page."
		)

	return {
		"id": "fry_club_invitation",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Build it myself - $0",
				"energy": -12,
				"mood": 4,
				"set_flag": "club_helped",
				"flag_value": true,
				"reaction": "I can build something simple. It'll take some work, but I think I can do it."
			},
			{
				"text": "Use a website template - $12",
				"money": -12,
				"energy": -4,
				"mood": 3,
				"finance_label": "Club website template",
				"finance_category": "Education",
				"set_flag": "club_helped",
				"flag_value": true,
				"reaction": "That should save me some time. I'll customize it and send it over."
			},
			{
				"text": "Tell them I'm too busy",
				"energy": 5,
				"mood": -2,
				"set_flag": "club_helped",
				"flag_value": false,
				"reaction": "I told Dulce I couldn't take on another project. She said she understood."
			}
		]
	}


func make_club_preparation_event() -> Dictionary:
	if bool(story_flags.get("club_helped", false)):
		return {
			"id": "fry_club_preparation",
			"speaker": "FRY",
			"message": "Dulce says the signup page looks good. The fundraiser is coming up, though, and we should probably test everything first.",
			"choices": [
				{
					"text": "Test the page myself",
					"energy": -10,
					"mood": 3,
					"set_flag": "club_ready",
					"flag_value": true,
					"reaction": "Found a couple of broken links and fixed them. Glad I checked."
				},
				{
					"text": "Ask Steve to help test it",
					"energy": -4,
					"mood": 2,
					"set_flag": "club_ready",
					"flag_value": true,
					"reaction": "Steve caught a few things I missed. We make a pretty good team."
				},
				{
					"text": "Send it without checking",
					"energy": 4,
					"mood": -1,
					"set_flag": "club_ready",
					"flag_value": false,
					"reaction": "It looked fine last time I checked. Hopefully nothing goes wrong."
				}
			]
		}

	# Fry declined the website work but can still help.
	return {
		"id": "fry_club_preparation",
		"speaker": "FRY",
		"message": "Steve and Dulce finished the signup page themselves. They're looking for a little help promoting the fundraiser tonight.",
		"choices": [
			{
				"text": "Help write promotional posts",
				"energy": -8,
				"mood": 4,
				"set_flag": "club_supported",
				"flag_value": true,
				"reaction": "I put together a few posts for them. At least I could help with something."
			},
			{
				"text": "Share their fundraiser link",
				"energy": -2,
				"mood": 2,
				"set_flag": "club_supported",
				"flag_value": true,
				"reaction": "Shared! Hopefully a few more people see it."
			},
			{
				"text": "Sit this one out",
				"energy": 5,
				"set_flag": "club_supported",
				"flag_value": false,
				"reaction": "They've got things under control. I'll focus on my own stuff tonight."
			}
		]
	}


func make_club_result_event() -> Dictionary:
	var message: String = ""
	var choices: Array[Dictionary] = []

	var helped: bool = bool(story_flags.get("club_helped", false))
	var club_is_ready: bool = bool(story_flags.get("club_ready", false))
	var supported: bool = bool(story_flags.get("club_supported", false))

	if helped and club_is_ready:
		message = (
			"Dulce just texted! The fundraiser went really well, "
			+ "and our signup page worked perfectly. Steve says "
			+ "we should celebrate!"
		)

		choices = [
			{
				"text": "Go get snacks with them - $8",
				"money": -8,
				"energy": -3,
				"mood": 8,
				"finance_label": "Celebration with friends",
				"finance_category": "Social",
				"reaction": "That was a great night. I'm glad I helped them out."
			},
			{
				"text": "Celebrate over messages - $0",
				"mood": 5,
				"reaction": "I'm pretty proud of what we accomplished. And I didn't even have to go out."
			}
		]

	elif helped:
		message = (
			"Dulce said the fundraiser went alright, but a few "
			+ "links on our page weren't working. Some people had "
			+ "trouble signing up. I probably should've checked it."
		)

		choices = [
			{
				"text": "Fix the page for future events",
				"energy": -8,
				"mood": 4,
				"reaction": "Fixed the links and sent Dulce the updated page. Better late than never."
			},
			{
				"text": "Leave it for now",
				"energy": 3,
				"mood": -2,
				"reaction": "At least they still managed to hold the fundraiser. I'll be more careful next time."
			}
		]

	elif supported:
		message = (
			"Dulce said the fundraiser went pretty well! "
			+ "She thanked me for helping spread the word. "
			+ "It's nice knowing I still contributed something."
		)

		choices = [
			{
				"text": "Meet up with them - $9",
				"money": -9,
				"energy": -3,
				"mood": 6,
				"finance_label": "Meeting friends",
				"finance_category": "Social",
				"reaction": "It was nice catching up with everyone. Glad the event worked out."
			},
			{
				"text": "Send them congratulations",
				"mood": 3,
				"reaction": "Dulce sent a bunch of happy emojis. Sounds like everyone's in a good mood."
			}
		]

	else:
		message = (
			"I saw some pictures of the fundraiser Steve and "
			+ "Dulce worked on. Looks like they managed to pull it off."
		)

		choices = [
			{
				"text": "Congratulate them",
				"mood": 2,
				"reaction": "They seemed pretty happy. Maybe I'll join them for something next time."
			},
			{
				"text": "Focus on my own plans",
				"energy": 4,
				"reaction": "Glad things worked out for them. I've still got my own stuff to finish."
			}
		]

	return {
		"id": "fry_club_result",
		"speaker": "FRY",
		"message": message,
		"choices": choices
	}


func make_campus_morning_event() -> Dictionary:
	return {
		"id": "fry_campus_preparation",
		"speaker": "FRY",
		"message": "The club fair is this afternoon. Should I make lunch before heading out?",
		"choices": [
			{
				"text": "Pack lunch (1 grocery portion)",
				"money": 0,
				"pantry_cost": 1,
				"energy": -2,
				"set_flag": "packed_lunch",
				"flag_value": true,
				"reaction": "Sandwich packed. Good thing I already had groceries at home."
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
	campus_lines = [
		{
			"speaker": "DULCE",
			"message": "Fry! You made it! Come on, Steve's over by the student booths."
		},
		{
			"speaker": "STEVE",
			"message": "Hey! There are clubs, workshops, and food stalls everywhere."
		},
		{
			"speaker": "DULCE",
			"message": "Anyone hungry? We could grab something before looking around."
		}
	]

	after_campus_lines = "lunch_choice"
	show_next_campus_line()


func show_next_campus_line() -> void:
	if campus_lines.is_empty():
		var next_step: String = after_campus_lines
		after_campus_lines = ""

		match next_step:
			"lunch_choice":
				show_campus_lunch_choice()
				return

			"textbook_choice":
				show_textbook_choice()
				return

			"exam_choice":
				show_first_exam_choice()
				return

			"textbook_finish":
				event_state = ""
				dialogue_manager.close_dialogue()
				advance_time(true)
				return

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
		"message": (
			"Should I eat what I brought, or get something here?"
			if bool(story_flags.get("packed_lunch", false))
			else "Those food stalls look tempting. What should I eat?"
		),
		"choices": choices
	}

	event_state = "event_choice"
	next_day_button.hide()

	var labels: Array[String] = []
	for choice in choices:
		labels.append(str(choice.get("text", "Choose")))

	dialogue_manager.show_dialogue("FRY", str(active_event["message"]), labels)



func start_textbook_story() -> void:
	campus_lines = [
		{
			"speaker": "STEVE",
			"message": "Hey, Fry! Dulce and I were just talking about textbook prices. Some of them are ridiculous."
		},
		{
			"speaker": "DULCE",
			"message": "Speaking of which, have you gotten the textbook for class yet?"
		},
		{
			"speaker": "FRY",
			"message": "Not yet. I just got paid, but my phone bill is coming up too."
		},
		{
			"speaker": "STEVE",
			"message": "I looked at the campus bookstore earlier. Buying everything new would completely drain my wallet."
		},
		{
			"speaker": "DULCE",
			"message": "I found a few options. You can borrow it from the library, rent it, or buy a used copy. Each has its pros and cons."
		},
		{
			"speaker": "FRY",
			"message": "Alright, let me think. I don't want to spend more than I have to."
		}
	]

	after_campus_lines = "textbook_choice"
	show_next_campus_line()



func show_textbook_choice() -> void:
	active_event = {
		"id": "fry_textbook_choice",
		"speaker": "FRY",
		"message": "How should I get the textbook?",
		"choices": [
			{
				"text": "Borrow from library - $0",
				"money": 0,
				"textbook_choice": "library",
				"reaction": "Free sounds good. I'll just have to make time to pick it up tomorrow."
			},
			{
				"text": "Rent textbook - $18",
				"money": -18,
				"textbook_choice": "rent",
				"finance_label": "Textbook rental",
				"finance_category": "Education",
				"reaction": "Eighteen dollars isn't too bad. I'll need to return it next week, though."
			},
			{
				"text": "Buy used textbook - $40",
				"money": -40,
				"textbook_choice": "used",
				"finance_label": "Used textbook purchase",
				"finance_category": "Education",

				"reaction": "Forty dollars is a lot right now, but I might be able to sell it afterward."
			}
		]
	}

	event_state = "event_choice"
	next_day_button.hide()

	var labels: Array[String] = []

	for choice in active_event["choices"]:
		labels.append(str(choice["text"]))

	dialogue_manager.show_dialogue(
		"FRY",
		str(active_event["message"]),
		labels
	)


func make_library_pickup_event() -> Dictionary:
	return {
		"id": "fry_library_pickup",
		"speaker": "FRY",
		"message": "The library has my textbook ready. Picking it up will take most of my afternoon.",
		"choices": [
			{
				"text": "Pick it up - $0",
				"energy": -5,
				"has_textbook": true,
				"consumes_period": true,
				"reaction": "Alright, time to head to the library.",
				"after_period_reaction": "Got the textbook! Didn't cost anything, but that took a while."
			},
			{
				"text": "Skip the trip",
				"mood": -2,
				"reaction": "I'll manage without it for now. Hopefully I don't regret that."
			}
		]
	}


func make_textbook_return_event() -> Dictionary:
	var book_type: String = "library" if textbook_choice == "library" else "rental"

	return {
		"id": "fry_textbook_return",
		"speaker": "FRY",
		"message": "My %s textbook is due back today. I should return it before I get charged extra." % book_type,
		"choices": [
			{
				"text": "Return in person - $0",
				"energy": -4,
				"has_textbook": false,
				"textbook_returned": true,
				"consumes_period": true,
				"reaction": "I'll head over and return it now.",
				"after_period_reaction": "Book returned. At least I avoided any extra fees."
			},
			{
				"text": "Pay return shipping - $6",
				"money": -6,
				"has_textbook": false,
				"textbook_returned": true,
				"reaction": "Six dollars to save myself a trip. Convenience really does cost money."
			}
		]
	}


func make_textbook_resale_event() -> Dictionary:
	return {
		"id": "fry_textbook_resale",
		"speaker": "FRY",
		"message": "I'm finished with that textbook. Someone offered me $20 for it. Should I sell it?",
		"choices": [
			{
				"text": "Sell textbook - +$20",
				"money": 20,
				"has_textbook": false,
				"consumes_period": true,
				"finance_label": "Textbook resale",
				"finance_category": "Education",
				"reaction": "Found a buyer! I'll meet up with them this afternoon.",
				"after_period_reaction": "Sold the textbook for $20. Got some of my money back!"
			},
			{
				"text": "Keep the textbook",
				"mood": 1,
				"reaction": "I'll keep it around. It might be useful again."
			}
		]
	}



func start_first_exam_story() -> void:
	var preparation_line: String = ""

	if study_sessions >= 3:
		preparation_line = "I've actually studied quite a bit. Hopefully it pays off."
	elif study_sessions >= 1:
		preparation_line = "I got some studying done. I just hope it was enough."
	else:
		preparation_line = "I really should've studied more. This could be rough."

	var textbook_line: String = ""

	if has_textbook:
		textbook_line = "At least I managed to get the textbook."
	else:
		textbook_line = "Not having the textbook probably wasn't my smartest decision."

	campus_lines = [
		{
			"speaker": "DULCE",
			"message": "Hey, Fry! Ready for the exam? I swear this week went by so fast."
		},
		{
			"speaker": "FRY",
			"message": preparation_line
		},
		{
			"speaker": "FRY",
			"message": textbook_line
		},
		{
			"speaker": "DULCE",
			"message": "Well, good luck! I'll catch up with you afterward."
		}
	]

	after_campus_lines = "exam_choice"
	show_next_campus_line()


func show_first_exam_choice() -> void:
	active_event = {
		"id": "fry_first_exam",
		"speaker": "FRY",
		"message": "Alright, it's time. Let's see how prepared I really am.",
		"choices": [
			{
				"text": "Begin exam",
				"consumes_period": true,
				"reaction": "Here goes nothing..."
			}
		]
	}

	event_state = "event_choice"
	next_day_button.hide()

	dialogue_manager.show_dialogue(
		"FRY",
		str(active_event["message"]),
		["Begin exam"]
	)



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

	# Place and reveal only the characters needed here.
	update_location_characters(destination)


	var fade_in: Tween = create_tween()
	fade_in.tween_property(screen_fade, "modulate:a", 0.0, 0.45)
	await fade_in.finished

	transitioning = false

#endregion


#region Fry - Campus Character Presentation


func update_location_characters(destination: String) -> void:
	reset_speaker_effects()

	if destination == "campus":
		# Day 4 and Day 8 involve all three friends.
		var group_meeting: bool = (
			(
				DayManager.current_day == 4
				and bool(story_flags.get("attend_campus", false))
			)
			or DayManager.current_day == 8
		)

		# Use wider spacing when Steve joins.
		if group_meeting:
			fry_sprite.position = FRY_GROUP_POSITION
			steve_campus.position = STEVE_GROUP_POSITION
			dulce_campus.position = DULCE_GROUP_POSITION
		else:
			fry_sprite.position = FRY_CAMPUS_POSITION
			dulce_campus.position = DULCE_CAMPUS_POSITION

		# Dulce also appears on Day 12 for the exam.
		dulce_campus.visible = (
			group_meeting
			or DayManager.current_day == 12
		)

		steve_campus.visible = group_meeting

	else:
		# Return Fry to his bedroom.
		fry_sprite.position = fry_bedroom_position

		dulce_campus.hide()
		steve_campus.hide()



func _on_dialogue_speaker_changed(speaker: String) -> void:
	if current_location != "campus":
		return

	var speaker_name: String = speaker.to_upper()
	var speaking_character: Sprite2D = null

	match speaker_name:
		"FRY":
			speaking_character = fry_sprite

		"DULCE":
			if dulce_campus.visible:
				speaking_character = dulce_campus

		"STEVE":
			if steve_campus.visible:
				speaking_character = steve_campus

	if speaking_character == null:
		reset_speaker_effects()
		return

	if speaker_tween != null and speaker_tween.is_running():
		speaker_tween.kill()

	speaker_tween = create_tween()
	speaker_tween.set_parallel(true)
	speaker_tween.set_trans(Tween.TRANS_SINE)
	speaker_tween.set_ease(Tween.EASE_OUT)

	var characters: Array[Sprite2D] = [
		fry_sprite,
		dulce_campus,
		steve_campus
	]

	for character in characters:
		if not character.visible:
			continue

		var normal_scale: Vector2 = fry_normal_scale

		if character == dulce_campus:
			normal_scale = dulce_normal_scale
		elif character == steve_campus:
			normal_scale = steve_normal_scale

		var is_speaking: bool = character == speaking_character

		var target_scale: Vector2 = normal_scale * (
			SPEAKER_SIZE_MULTIPLIER if is_speaking else 1.0
		)

		var target_color: Color = (
			Color.WHITE if is_speaking
			else INACTIVE_CHARACTER_COLOR
		)

		speaker_tween.tween_property(
			character, "scale", target_scale, 0.18
		)

		speaker_tween.tween_property(
			character, "modulate", target_color, 0.18
		)



func reset_speaker_effects() -> void:
	if speaker_tween != null and speaker_tween.is_running():
		speaker_tween.kill()

	fry_sprite.scale = fry_normal_scale
	dulce_campus.scale = dulce_normal_scale
	steve_campus.scale = steve_normal_scale

	fry_sprite.modulate = Color.WHITE
	dulce_campus.modulate = Color.WHITE
	steve_campus.modulate = Color.WHITE



func _on_dialogue_closed() -> void:
	if current_location == "campus":
		reset_speaker_effects()

#endregion


#region Fry - Animations

# Animations will be implemented later.

#endregion
