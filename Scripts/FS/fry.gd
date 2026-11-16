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
# First economy-balancing test: four $150 paychecks.
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
	},
	"water": {
		"name": "Water bill",
		"amount": 25.0,
		"due_day": 8,
		"late_fee": 5.0,
		"paid": false,
		"fee_applied": false
	},
	"electricity": {
		"name": "Electricity bill",
		"amount": 40.0,
		"due_day": 16,
		"late_fee": 8.0,
		"paid": false,
		"fee_applied": false
	},
	"rent": {
		"name": "Apartment rent",
		"amount": 250.0,
		"due_day": 25,
		"late_fee": 25.0,
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

# Personal story flags stay with Fry -- STORY FLAGS HERE
var story_flags: Dictionary = {
	"attend_campus": false,
	"packed_lunch": false,
	
	# Day 1 - The Start
	"day1_evening_seen": false,
	"day1_budget_planned": false,
	
	# Day 2 - Late-Night Assignment.
	"day2_evening_seen": false,
	"day2_assignment_finished": false,
	"day2_assignment_help": false,
	"day2_assignment_deferred": false,

	# Day 4 - After the Fair.
	"day4_evening_seen": false,
	"day4_club_links_saved": false,

	"day5_party_invited": false,

	# Day 6 - The Morning After.
	"day6_evening_seen": false,
	"day6_replied_to_friends": false,
	"day6_reviewed_budget": false,
	
	# Day 7 - Payday Temptation.
	"day7_evening_seen": false,
	"day7_bought_game": false,
	"day7_held_for_bills": false,
	"day7_small_treat": false,

	# Day 8 - Study Group.
	"day8_evening_seen": false,
	"day8_studied_with_friends": false,
	"day8_swapped_notes": false,

	# Day 9 - Campus Food Pantry.
	"day9_evening_seen": false,
	"day9_donated_food": false,
	"day9_volunteered": false,
	"day9_used_pantry": false,
	"day9_shared_info": false,

	# Day 11 - Last-Minute Studying.
	"day11_evening_seen": false,
	"day11_final_review": false,
	"day11_asked_dulce": false,

	# Day 12 - After the Exam.
	"day12_evening_seen": false,
	"day12_connected_with_friends": false,
	"day12_shared_good_news": false,
	"day12_reflected_on_exam": false,

	# Day 13 - Animal Shelter.
	"day13_evening_seen": false,
	"day13_donated": false,
	"day13_volunteered": false,
	"day13_adoption_posted": false,
	"day13_shared_wishlist": false,

	# Day 14 - Family Check-In.
	"day14_evening_seen": false,
	"day14_opened_up": false,
	"day14_budget_advice": false,
	"day14_family_visit": false,
	"day14_long_call": false,

	# Day 15 - New Assignment.
	"day15_evening_seen": false,
	"day15_project_budget": false,
	"day15_started_slides": false,
	"day15_split_tasks": false,

	# Day 16 - Unexpected Invitation.
	"day16_evening_seen": false,
	"day16_arcade": false,
	"day16_online_games": false,
	"day16_free_walk": false,
	"day16_stayed_home": false,
	
	# Day 17 - Student Club Fundraiser.
	"day17_evening_seen": false,
	
	# Day 18 - Homeless Shelter and kitten update.
	"day18_evening_seen": false,
	"day18_donated_supplies": false,
	"day18_collected_supplies": false,
	"day18_volunteered": false,
	"day18_shared_request": false,
	"day18_kitten_update_seen": false,

	# Day 19 - Financial Pressure.
	"day19_evening_seen": false,
	"day19_rush_job": false,
	"day19_sold_game": false,
	"day19_rest": false,

	# Day 21 - Kitten Adoption.
	"day21_kitten_decision_seen": false,
	"day21_kittens_adopted": false,
	"day21_saving_for_kittens": false,
	"day21_visited_kittens": false,
	"day21_helped_rehome": false,

	# Day 21 - A Friend Needs Help.
	"day21_friend_event_seen": false,
	"day21_practiced_interview": false,
	"day21_paid_transport": false,
	"day21_found_bus_route": false,
	"day21_encouraged_steve": false,

	# Day 22 - Bookstore and Professor's Office Hours.
	"day22_inventory_worked": false,
	"day22_evening_seen": false,
	"day22_office_hours": false,
	"day22_emailed_professor": false,
	"day22_rest": false,

	# Day 23 - Fundraiser Final Checks.
	"day23_evening_seen": false,

	# Day 24 - Internship Opportunity.
	"day24_afternoon_seen": false,
	"day24_portfolio_applied": false,
	"day24_quick_applied": false,
	"day24_saved_listing": false,

	# Day 25 - Fundraiser Results.
	"day25_evening_seen": false,

	# Day 26 - Friday Dinner.
	"day26_evening_seen": false,
	"day26_cooked_dinner": false,
	"day26_community_meal": false,
	"day26_ordered_takeout": false,
	"day26_skipped_dinner": false,

	# Day 27 - A Visit From Dulce and Steve.
	"day27_kitten_visit_seen": false,

	# Day 27 - Internship Follow-Up.
	"day27_internship_seen": false,
	"day27_screening_submitted": false,
	"day27_screening_started": false,
	"day27_sample_polished": false,
	"day27_sample_sent": false,
	"day27_requested_more_time": false,
	"day27_late_application": false,
	"day27_prepared_application": false,
	"day27_listing_deferred": false,

	# Day 27 - Kitten Supplies.
	"day27_pet_care_seen": false,
	"day27_pet_full_supplies": false,
	"day27_pet_essentials": false,
	"day27_pet_compared_prices": false,
	"day27_pet_used_starter": false,
	"day27_pet_budget_planned": false,

	# Day 28 - The Final Paycheck.
	"day28_evening_seen": false,
	"day28_budget_reviewed": false,
	"day28_extra_gig": false,
	"day28_small_treat": false,
	"day28_relaxed": false,

	# Day 29 - Internship and Dulce.
	"day29_internship_update_seen": false,
	"day29_evening_seen": false,

	# Day 30 - The End of the Month.
	"day30_evening_seen": false,
	"day30_planned_next_month": false,
	"day30_texted_friends": false,
	"day30_rest": false,

	# Student club storyline.
	"club_helped": false,
	"club_ready": false,
	"club_supported": false,
	
	"caught_up_with_dulce": false,

	# Day 10 movie-night memories, used again on Day 29.
	"movie_with_steve": false,
	"movie_with_dulce": false,
	"movie_with_both": false
	
}

# Remembers the actual Day 5 Night decision.
# 0, 1, or 2, based on the selected dialogue button.
var day5_night_choice: int = -1

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

# Classroom / campus positions.
const FRY_CAMPUS_POSITION: Vector2 = Vector2(650, 770)
const DULCE_CAMPUS_POSITION: Vector2 = Vector2(1220, 770)

# Group positions for scenes featuring all three friends.
const FRY_GROUP_POSITION: Vector2 = Vector2(430, 770)
const STEVE_GROUP_POSITION: Vector2 = Vector2(950, 800)
const DULCE_GROUP_POSITION: Vector2 = Vector2(1470, 770)

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
const SLEEP_ENERGY_GAIN: int = 40
const OVERNIGHT_ENERGY_GAIN: int = 20
# The passage of a period has a small cost even if Fry chooses to skip it.
const PERIOD_ENERGY_COST: int = 3

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
		"emotion": "excited",
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


func make_day1_first_night_event() -> Dictionary:
	return {
		"id": "fry_day1_first_night",
		"emotion": "nervous",
		"speaker": "FRY",
		"message": (
			"First night in my own place. I've only got "
			+ "a hundred bucks right now, and payday "
			+ "isn't until next week. I've got bills coming "
			+ "up too. How should I handle tonight?"
		),
		"choices": [
			{
				"text": "Make a spending plan - $0",
				"mood": 3,
				"energy": -3,
				"set_flag": "day1_budget_planned",
				"flag_value": true,
				"reaction": (
					"Alright, phone bill, utilities, rent... "
					+ "I should keep track of what's coming up "
					+ "before spending too much. "
					+ "At least now I have a plan."
				)
			},
			{
				"text": "Treat myself to takeout - $12",
				"reaction_emotion": "happy",
				"money": -12.0,
				"mood": 7,
				"energy": 4,
				"finance_label": "First-night takeout",
				"finance_category": "Food",
				"reaction": (
					"Okay, that was pretty good! "
					+ "My first dinner in my own apartment. "
					+ "I guess I should watch how often "
					+ "I do this, though."
				)
			},
			{
				"text": "Keep tonight simple - $0",
				"mood": 2,
				"energy": 3,
				"reaction": (
					"I've got enough things to worry about "
					+ "this month. No reason to spend money "
					+ "just because it's my first night here."
				)
			}
		]
	}


func make_day2_late_night_assignment_event() -> Dictionary:
	return {
		"id": "fry_day2_late_night_assignment",
		"emotion": "nervous",
		"speaker": "FRY",
		"message": (
			"[shake rate=14 level=3]Wait... I almost forgot![/shake] I have an assignment due "
			+ "tomorrow at noon. I was ready to relax tonight. "
			+ "What should I do?"
		),
		"choices": [
			{
				"text": "Finish it tonight - $0",
				"reaction_emotion": "excited",
				"energy": -11,
				"mood": 5,
				"set_flag": "day2_assignment_finished",
				"flag_value": true,
				"reaction": (
					"Finally, submitted! That took more effort "
					+ "than I expected. At least I won't have "
					+ "to worry about it tomorrow. "
					+ "Now, where was I?"
				)
			},
			{
				"text": "Ask Dulce for help - $0",
				"reaction_emotion": "soft",
				"energy": -4,
				"mood": 2,
				"set_flag": "day2_assignment_help",
				"flag_value": true,
				"reaction_speaker": "DULCE",
				"reaction": (
					"Hey! I can send you my notes. The last "
					+ "question is a little confusing, but "
					+ "I think you'll figure it out. Just "
					+ "make sure you finish before class!"
				),
				"delayed": {
					"days_later": 1,
					"period": "Morning",
					"energy": -7,
					"mood": 1,
					"text": (
						"Dulce's notes really helped. I managed "
						+ "to finish my assignment before class, "
						+ "although it took some morning energy."
					)
				}
			},
			{
				"text": "Leave it for tomorrow - $0",
				"reaction_emotion": "tired",
				"energy": 3,
				"mood": 1,
				"set_flag": "day2_assignment_deferred",
				"flag_value": true,
				"reaction": (
					"I'll deal with it tomorrow. It's not "
					+ "that long anyway, right? "
					+ "Besides, I could really use a break. "
					+ "Tomorrow-me can handle it."
				),
				"delayed": {
					"days_later": 1,
					"period": "Morning",
					"energy": -13,
					"mood": -5,
					"text": (
						"Oh no, the assignment! I completely "
						+ "forgot how much was left. I managed "
						+ "to submit it before the deadline, "
						+ "but that was way too stressful."
					)
				}
			}
		]
	}


func make_day4_after_fair_event() -> Dictionary:
	var message: String = ""

	if bool(story_flags.get("attend_campus", false)):
		message = (
			"Dulce sent our group photo from the fair. "
			+ "Steve blinked in every shot! Now the group "
			+ "chat won't stop buzzing. What should I do?"
		)
	else:
		message = (
			"Dulce sent pictures from the club fair. "
			+ "Looks like they had fun! Steve apparently "
			+ "found a very weird club. Should I reply?"
		)

	return {
		"id": "fry_day4_after_fair",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Browse free clubs - $0",
				"energy": -4,
				"mood": 2,
				"set_flag": "day4_club_links_saved",
				"flag_value": true,
				"reaction": (
					"Huh, some clubs offer free workshops. "
					+ "I saved a few links in case something "
					+ "interesting comes up later."
				)
			},
			{
				"text": "Joke in the group chat - $0",
				"reaction_emotion": "dramatic",
				"energy": -2,
				"mood": 5,
				"reaction_speaker": "STEVE",
				"reaction": (
					"For the record, I didn't blink. "
					+ "The camera was clearly trying "
					+ "to [wave amp=9 freq=4]sabotage me![/wave]"
				)
			},
			{
				"text": "Unplug and recharge - $0",
				"energy": 5,
				"mood": 1,
				"reaction": (
					"Phone on silent. I like those guys, "
					+ "but I've had enough notifications "
					+ "for one night. Time to relax."
				)
			}
		]
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
		"emotion": "nervous",
		"speaker": "FRY",
		"message": "My school payment is due tomorrow. I could really use some extra cash tonight.",
		"choices": [
			{
				"text": "Take a rush editing job (+$35)",
				"reaction_emotion": "tired",
				"money": 35,
				"energy": -18,
				"mood": -2,
				"set_flag": "day19_rush_job",
				"flag_value": true,
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
				"set_flag": "day19_sold_game",
				"flag_value": true,
				"finance_label": "Used video game sale",
				"finance_category": "Income",
				"reaction": "Kinda sad to let it go, but I needed the money more."
			},
			{
				"text": "Take the evening off",
				"energy": 8,
				"mood": 3,
				"set_flag": "day19_rest",
				"flag_value": true,
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
				"set_flag": "day22_inventory_worked",
				"flag_value": true,
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
		"emotion": "angry",
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
		"emotion": "tired",
		"speaker": "FRY",
		"message": "Finally Friday. What's for dinner?",
		"choices": [
			{
				"text": "Cook dinner (1 grocery portion)",
				"money": 0,
				"pantry_cost": 1,
				"energy": 7,
				"mood": 3,
				"consumes_period": true,
				"set_flag": "day26_cooked_dinner",
				"flag_value": true,
				"reaction": (
					"Not bad! Glad I had something "
					+ "left in the kitchen."
				),
				"after_period_reaction": (
					"Dinner at home saved me money. "
					+ "I should plan my next grocery trip."
				)
			},
			{
				"text": "Order takeout - $17",
				"reaction_emotion": "excited",
				"money": -17,
				"energy": 9,
				"mood": 6,
				"finance_label": "Friday night takeout",
				"finance_category": "Food",
				"set_flag": "day26_ordered_takeout",
				"flag_value": true,
				"reaction": (
					"Okay, that was good! "
					+ "Hopefully it was worth the $17."
				)
			},
			{
				"text": "Skip dinner - $0",
				"energy": -10,
				"mood": -3,
				"set_flag": "day26_skipped_dinner",
				"flag_value": true,
				"reaction": (
					"I'll just go to bed. "
					+ "Probably wasn't my best idea."
				)
			}
		]
	}


	# Day 29 - Catching up with Dulce.
	scheduled_events["29_Evening"] = {
		"id": "fry_dulce_checkin",
		"emotion": "soft",
		"speaker": "DULCE",
		"message": "Hey Fry! This month's been pretty chaotic, huh? Want to catch up tonight?",
		"choices": [
			{
				"text": "Meet for coffee - $9",
				"reaction_emotion": "soft",
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
				"reaction_emotion": "soft",
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


#region Fry - Random Encounters

# These encounters are Fry-only. Shared events still use EventManager.
# Each one can appear in a free Afternoon or Evening, never over a story event.
const FRY_RANDOM_EVENT_CHANCE: float = 0.52
const FRY_RANDOM_GLOBAL_COOLDOWN_DAYS: int = 2

const FRY_RANDOM_RULES: Dictionary = {
	"fry_rand_laptop": {"min_day": 5, "max_day": 24, "max_uses": 1, "cooldown": 6},
	"fry_rand_bike": {"min_day": 6, "max_day": 24, "max_uses": 1, "cooldown": 6},
	"fry_rand_utility": {"min_day": 9, "max_day": 25, "max_uses": 1, "cooldown": 6},
	"fry_rand_supplies": {"min_day": 3, "max_day": 25, "max_uses": 2, "cooldown": 10},
	"fry_rand_gig": {"min_day": 4, "max_day": 27, "max_uses": 2, "cooldown": 7},
	"fry_rand_refund": {"min_day": 4, "max_day": 27, "max_uses": 2, "cooldown": 9}
}

var fry_random_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var fry_random_uses: Dictionary = {}
var fry_random_last_day: Dictionary = {}
var fry_last_random_day: int = -100

# Remember the last dialogue used for Fry's smaller events.
var fry_last_small_event_line: Dictionary = {}


func fry_small_event_line(event_id: String, variants: Array) -> String:
	if variants.is_empty():
		return ""

	var previous_index: int = int(fry_last_small_event_line.get(event_id, -1))
	var next_index: int = fry_random_rng.randi_range(0, variants.size() - 1)

	# Avoid repeating the same variation twice in a row.
	if variants.size() > 1 and next_index == previous_index:
		next_index = (next_index + fry_random_rng.randi_range(1, variants.size() - 1)) % variants.size()

	fry_last_small_event_line[event_id] = next_index
	return str(variants[next_index])


func roll_fry_random_event(day: int, period: String) -> Dictionary:
	if period not in ["Afternoon", "Evening"]:
		return {}

	# At most one Fry-only encounter every two days.
	if day - fry_last_random_day < FRY_RANDOM_GLOBAL_COOLDOWN_DAYS:
		return {}

	if fry_random_rng.randf() >= FRY_RANDOM_EVENT_CHANCE:
		return {}

	var available: Array[String] = []

	for event_id in FRY_RANDOM_RULES.keys():
		var rule: Dictionary = FRY_RANDOM_RULES[event_id]
		if day < int(rule["min_day"]) or day > int(rule["max_day"]):
			continue
		if int(fry_random_uses.get(event_id, 0)) >= int(rule["max_uses"]):
			continue
		if day - int(fry_random_last_day.get(event_id, -100)) < int(rule["cooldown"]):
			continue
		available.append(event_id)

	if available.is_empty():
		return {}

	var chosen: String = available[fry_random_rng.randi_range(0, available.size() - 1)]
	return make_fry_random_event(chosen)


func record_fry_random_event(event_id: String, day: int) -> void:
	if not FRY_RANDOM_RULES.has(event_id):
		return
	fry_random_uses[event_id] = int(fry_random_uses.get(event_id, 0)) + 1
	fry_random_last_day[event_id] = day
	fry_last_random_day = day


func add_fry_unexpected_bill(details: Dictionary) -> void:
	# Deferred repair and utility invoices use the existing bill system.
	# They show up in Phone > Finances and in the Month Recap.
	var bill_id: String = str(details.get("id", "unexpected_bill"))
	if bills.has(bill_id):
		return

	var due_in: int = maxi(1, int(details.get("days_later", 3)))
	bills[bill_id] = {
		"name": str(details.get("name", "Unexpected invoice")),
		"amount": float(details.get("amount", 0.0)),
		"due_day": mini(DayManager.current_day + due_in, DayManager.TOTAL_DAYS),
		"late_fee": float(details.get("late_fee", 5.0)),
		"paid": false,
		"fee_applied": false
	}


func make_fry_random_event(event_id: String) -> Dictionary:
	match event_id:
		"fry_rand_laptop":
			return {
				"id": event_id, "speaker": "FRY",
				"message": "My laptop fan is making a terrible grinding sound. A repair shop says it needs attention. What should I do?",
				"choices": [
					{
						"text": "Professional repair - $70", "money": -70,
						"energy": -4, "mood": 3, "consumes_period": true,
						"finance_label": "Laptop repair", "finance_category": "Repairs",
						"reaction": "That's expensive, but at least I can use my laptop without worrying.",
						"after_period_reaction": "The shop finished fixing it. Everything sounds normal again."
					},
					{
						"text": "Try fixing it myself - $18", "money": -18,
						"energy": -20, "mood": 1, "consumes_period": true,
						"finance_label": "Laptop repair supplies", "finance_category": "Repairs",
						"risk_effect": {"chance": 0.40, "mood": -7, "energy": -5,
							"reaction": "Oof. I made the fan sound worse. That was stressful."},
						"reaction": "I looked up a repair guide. Hopefully my fix holds up."
					},
					{
						"text": "Repair now, pay the invoice later", "mood": -5,
						"energy": -4, "consumes_period": true,
						"create_bill": {"id": "laptop_invoice", "name": "Laptop repair invoice",
							"amount": 88.0, "days_later": 4, "late_fee": 12.0},
						"reaction": "They repaired it on a payment plan. I owe $88 in four days."
					}
				]
			}

		"fry_rand_bike":
			return {
				"id": event_id, "speaker": "FRY",
				"message": "My bike's tire went flat on the way home. Great timing... How am I getting it fixed?",
				"choices": [
					{
						"text": "Take it to a bike mechanic - $45", "money": -45,
						"energy": -3, "mood": 2, "finance_label": "Bike mechanic",
						"finance_category": "Transport",
						"reaction": "That cost more than I wanted, but the tire is fixed."
					},
					{
						"text": "Patch it myself - $12", "money": -12, "energy": -17,
						"finance_label": "Bike tire patch kit", "finance_category": "Transport",
						"risk_effect": {"chance": 0.35, "mood": -6, "energy": -4,
							"reaction": "The patch leaked. That took longer than I expected."},
						"reaction": "A patch kit and some effort should do the trick."
					},
					{
						"text": "Use the shop's pay-later option", "mood": -4, "energy": -4,
						"create_bill": {"id": "bike_invoice", "name": "Bike repair invoice",
							"amount": 58.0, "days_later": 3, "late_fee": 8.0},
						"reaction": "The shop fixed it, but now I owe $58 in three days."
					}
				]
			}

		"fry_rand_utility":
			return {
				"id": event_id, "speaker": "FRY",
				"message": "My apartment sent a separate $34 utility adjustment I wasn't expecting. That's not in my budget!",
				"choices": [
					{
						"text": "Pay the adjustment - $34", "money": -34, "mood": -3,
						"finance_label": "Utility adjustment", "finance_category": "Bills",
						"reaction": "I paid it, but I really need to leave room for surprises."
					},
					{
						"text": "Call to negotiate - $18", "money": -18,
						"energy": -13, "mood": -1,
						"finance_label": "Negotiated utility adjustment", "finance_category": "Bills",
						"reaction": "They reduced the charge. That phone call was worth the trouble."
					},
					{
						"text": "Request a deferred invoice", "mood": -5,
						"create_bill": {"id": "utility_adjustment", "name": "Utility adjustment",
							"amount": 34.0, "days_later": 3, "late_fee": 7.0},
						"reaction": "I can pay it in three days, but I can't ignore it."
					}
				]
			}

		"fry_rand_supplies":
			return {
				"id": event_id, "speaker": "FRY",
				"message": fry_small_event_line(event_id, [
					"A class project needs materials I didn't budget for. Should I buy everything new or find another way?",
					"Great, I need more supplies for class. Should I pay full price or try to save a little?",
					"Didn't see that coming. My project needs extra materials, and I'm trying not to spend too much."
				]),
				"choices": [
					{
						"text": "Buy new supplies - $36", "money": -36, "mood": 3,
						"finance_label": "Class project supplies", "finance_category": "Education",
						"reaction": "At least I got everything I need for class."
					},
					{
						"text": "Find used materials - $12", "money": -12, "energy": -10,
						"finance_label": "Used class supplies", "finance_category": "Education",
						"reaction": "It took some searching, but I kept the cost down."
					},
					{
						"text": "Borrow materials from Steve", "energy": -6, "mood": -3,
						"reaction": "Steve said I can borrow what he has. I owe him one."
					}
				]
			}

		"fry_rand_gig":
			var full_pay: int = fry_random_rng.randi_range(30, 45)
			var small_pay: int = fry_random_rng.randi_range(14, 22)
			return {
				"id": event_id, "speaker": "FRY",
				"message": fry_small_event_line(event_id, [
					"Someone on the campus job board needs a quick website update. I could earn some extra money today.",
					"Oh, there's a small web job posted on campus. A little extra cash wouldn't hurt.",
					"Someone needs help fixing a website. I could take the whole job or just do a quick task."
				]),
				"choices": [
					{
						"text": "Take the full job (+$%d)" % full_pay,
						"money": full_pay,
						"energy": -19,
						"mood": -3,
						"consumes_period": true,
						"finance_label": "Campus website gig",
						"finance_category": "Income",
						"reaction": "It's a lot of work, but that $%d will help with the bills." % full_pay
					},
					{
						"text": "Do a smaller task (+$%d)" % small_pay,
						"money": small_pay,
						"energy": -10,
						"consumes_period": true,
						"finance_label": "Small campus web task",
						"finance_category": "Income",
						"reaction": "Quick and manageable. An extra $%d isn't bad." % small_pay
					},
					{
						"text": "Pass and take a break", "energy": 6, "mood": 2,
						"reaction": "Money would be nice, but I need some time to myself."
					}
				]
			}

		"fry_rand_refund":
			var refund_amount: int = fry_random_rng.randi_range(10, 25)
			var treat_cost: int = mini(11, refund_amount - 1)
			var kept_amount: int = refund_amount - treat_cost

			return {
				"id": event_id,
				"speaker": "FRY",
				"message": fry_small_event_line(event_id, [
					"An old store order was overcharged. They approved a $%d refund I can claim today!",
					"Wait, the store owes me $%d from that old order? I should probably claim it.",
					"Hey, I got an email saying I can get $%d back for an overcharge. Nice."
				]) % refund_amount,
				"choices": [
					{
						"text": "Claim the full refund (+$%d)" % refund_amount,
						"money": refund_amount,
						"mood": 2,
						"finance_label": "Store overcharge refund",
						"finance_category": "Refund",
						"reaction": "Nice. I'm putting that $%d back into my budget." % refund_amount
					},
					{
						"text": "Claim it and spend $%d (+$%d net)" % [treat_cost, kept_amount],
						"money": kept_amount,
						"mood": 7,
						"finance_label": "Refund after treating myself",
						"finance_category": "Refund",
						"reaction": "A little treat felt good, and I still got $%d back." % kept_amount
					},
					{
						"text": "Ignore the refund",
						"mood": -1,
						"reaction": "I guess I'll let that one go... maybe not my smartest decision."
					}
				]
			}
	return {}

#endregion


#region Fry - Day 5 Party


func show_day5_party_guests() -> void:
	# Reuse the existing Steve and Dulce sprites.
	reset_speaker_effects()

	# Calculate the camera's visible horizontal area.
	var half_width: float = (
		get_viewport().get_visible_rect().size.x * 0.5
		/ bedroom_camera.zoom.x
	)

	var camera_x: float = clampf(
		bedroom_camera.position.x,
		float(bedroom_camera.limit_left) + half_width,
		float(bedroom_camera.limit_right) - half_width
	)

	var safe_left: float = camera_x - half_width + 170.0
	var safe_right: float = camera_x + half_width - 170.0

	var fry_x: float = fry_bedroom_position.x
	var steve_x: float = fry_x - 260.0
	var dulce_x: float = fry_x + 260.0

	# Keep guests visible even if Fry is near a room edge.
	if steve_x < safe_left:
		steve_x = fry_x + 200.0
		dulce_x = fry_x + 450.0

	elif dulce_x > safe_right:
		steve_x = fry_x - 450.0
		dulce_x = fry_x - 200.0

	steve_x = clampf(steve_x, safe_left, safe_right)
	dulce_x = clampf(dulce_x, safe_left, safe_right)

	# Match the bottom of each sprite to Fry's feet.
	var floor_y: float = (
		fry_sprite.position.y
		+ fry_sprite.get_rect().end.y * fry_sprite.scale.y
	)

	steve_campus.position = Vector2(
		steve_x,
		floor_y - steve_campus.get_rect().end.y * steve_campus.scale.y
	)

	dulce_campus.position = Vector2(
		dulce_x,
		floor_y - dulce_campus.get_rect().end.y * dulce_campus.scale.y
	)

	# Draw party guests above the bedroom background.
	steve_campus.z_index = fry_sprite.z_index + 10
	dulce_campus.z_index = fry_sprite.z_index + 10

	# Reset any transparency or tint.
	steve_campus.modulate = Color.WHITE
	dulce_campus.modulate = Color.WHITE
	steve_campus.self_modulate = Color.WHITE
	dulce_campus.self_modulate = Color.WHITE

	# Explicitly enable both sprites.
	steve_campus.visible = true
	dulce_campus.visible = true
	steve_campus.flip_h = not steve_default_flip_h


var day5_party_lines: Array[Dictionary] = []

func make_day5_party_invitation_event() -> Dictionary:
	return {
		"id": "fry_day5_party_invitation",
		"emotion": "excited",
		"speaker": "STEVE",
		"message": (
			"Hey Fry! Dulce and I were thinking of coming over "
			+ "tonight for games, music, and food. "
			+ "We could make it a little party. You in?"
		),
		"choices": [
			{
				"text": "Invite them over tonight",
				"mood": 3,
				"set_flag": "day5_party_invited",
				"flag_value": true,
				"reaction": (
					"Sounds fun! I'll figure out the food situation "
					+ "when they get here."
				)
			},
			{
				"text": "Have a quiet night instead",
				"energy": 3,
				"set_flag": "day5_party_invited",
				"flag_value": false,
				"reaction": (
					"I could use a quiet night. "
					+ "Maybe we'll hang out another time."
				)
			}
		]
	}



func start_day5_party_story() -> void:
	show_day5_party_guests()
	day5_party_lines = [
		{
			"speaker": "FRY",
			"emotion": "nervous",
			"message": (
				"Alright, everyone's here. "
				+ "Hopefully my apartment isn't too messy."
			)
		},
		{
			"speaker": "STEVE",
			"emotion": "excited",
			"message": (
				"I brought the games! "
				+ "And no, we are [shake rate=16 level=3]NOT[/shake] talking about what "
				+ "happened to my last controller."
			)
		},
		{
			"speaker": "DULCE",
			"emotion": "soft",
			"message": (
				"He's officially banned from choosing "
				+ "the first game tonight."
			)
		},
		{
			"speaker": "FRY",
			"message": (
				"Fair enough. So... what are we doing for food?"
			)
		}
	]

	event_state = "day5_party_line"
	next_day_button.hide()
	show_next_day5_party_line()


func show_next_day5_party_line() -> void:
	if not day5_party_lines.is_empty():
		var line: Dictionary = day5_party_lines.pop_front()

		dialogue_manager.show_dialogue(
			str(line.get("speaker", "FRY")),
			str(line.get("message", "")),
			["Continue"],
			str(line.get("emotion", "neutral"))
		)
		return

	# Once the conversation ends, show the spending decision.
	active_event = make_day5_party_main_event()
	event_state = "event_choice"

	var options: Array[String] = []

	for choice in active_event.get("choices", []):
		options.append(str(choice.get("text", "Choose")))

	dialogue_manager.show_dialogue(
		str(active_event.get("speaker", "FRY")),
		str(active_event.get("message", "")),
		options
	)


func make_day5_party_main_event() -> Dictionary:
	return {
		"id": "fry_day5_party",
		"speaker": "FRY",
		"message": (
			"Everyone's having fun, but we're getting hungry. "
			+ "I've still got bills coming up. "
			+ "What should I do about snacks?"
		),
		"choices": [
			{
				"text": "Order party food - $18",
				"money": -18,
				"mood": 10,
				"energy": -9,
				"consumes_period": true,
				"finance_label": "Party food",
				"finance_category": "Entertainment",
				"reaction_speaker": "STEVE",
				"reaction": (
					"Now THAT'S what I'm talking about! "
					+ "This food is incredible!"
				),

				"after_period_reaction": (
					"Last night was great! That $18 came out "
					+ "of my budget, though. Worth remembering "
					+ "with my bills coming up."
				)
			},
			{
				"text": "Share snacks from my groceries (1 portion)",
				"pantry_cost": 1,
				"mood": 8,
				"energy": -7,
				"consumes_period": true,
				"reaction_speaker": "DULCE",
				"reaction": (
					"These are actually pretty good! "
					+ "We didn't need to order anything."
				),
				"after_period_reaction": (
					"That was fun, and I didn't spend extra cash. "
					+ "I'll need to remember I used some of my groceries."
				)
			},
			{
				"text": "Keep it simple: games and music - $0",
				"mood": 7,
				"energy": -6,
				"consumes_period": true,
				"reaction_speaker": "STEVE",
				"reaction": (
					"No food? That's criminal. "
					+ "Fine, but I'm winning the next round!"
				),
				"after_period_reaction": (
					"We had a really good time without spending "
					+ "anything. Maybe we should do that more often."
				)
			}
		]
	}


func make_day5_quiet_night_event() -> Dictionary:
	return {
		"id": "fry_day5_quiet_night",
		"speaker": "FRY",
		"message": (
			"Steve and Dulce are probably having fun tonight. "
			+ "I've got the apartment to myself. "
			+ "How should I spend the evening?"
		),
		"choices": [
			{
				"text": "Finish a small editing gig (+$14)",
				"money": 14,
				"energy": -13,
				"mood": -2,
				"consumes_period": true,
				"finance_label": "Late-night editing gig",
				"finance_category": "Income",
				"reaction": (
					"That took a while, but I finished the job. "
					+ "Fourteen extra dollars isn't bad."
				),
				"after_period_reaction": (
					"At least I earned some money last night. "
					+ "I could use a little more sleep, though."
				)
			},
			{
				"text": "Make a simple dinner (1 grocery portion)",
				"pantry_cost": 1,
				"energy": 6,
				"mood": 4,
				"consumes_period": true,
				"reaction": (
					"Nothing fancy, but a homemade dinner "
					+ "really hit the spot."
				),
				"after_period_reaction": (
					"That was a nice, inexpensive evening at home."
				)
			},
			{
				"text": "Relax with a free movie - $0",
				"energy": 11,
				"mood": 4,
				"consumes_period": true,
				"reaction": (
					"Sometimes staying home and doing nothing "
					+ "is exactly what I need."
				),
				"after_period_reaction": (
					"I feel pretty refreshed after last night."
				)
			}
		]
	}

#endregion


#region Fry - Day 6 The Morning After

func make_day6_morning_after_event() -> Dictionary:
	var message: String = ""

	# The party actually happened.
	if bool(story_flags.get("day5_party_invited", false)):
		match day5_night_choice:
			0:
				# Fry bought party food.
				message = (
					"Steve sent a photo of last night's takeout. "
					+ "Great memories, but that $18 came from my "
					+ "budget. What's the move?"
				)

			1:
				# Fry shared groceries.
				message = (
					"Dulce loved the snacks we shared! "
					+ "My wallet survived, but my pantry "
					+ "took a hit. Steve wants a rematch!"
				)

			2:
				# Fry kept the party free.
				message = (
					"Steve says he won every game last night. "
					+ "That's funny. I remember him losing! "
					+ "At least we spent nothing."
				)

			_:
				message = (
					"Last night's party was a lot of fun. "
					+ "Dulce and Steve are already talking "
					+ "about getting together again."
				)

	# Fry declined the party invitation.
	else:
		match day5_night_choice:
			0:
				# Fry completed the editing gig.
				message = (
					"The client loved last night's editing "
					+ "work! That $14 helps, though I'm "
					+ "tired. Dulce texted to check in."
				)

			1:
				# Fry cooked dinner.
				message = (
					"Last night's dinner was simple, but "
					+ "nice. I used a meal portion and "
					+ "stayed in. Dulce sent a message."
				)

			2:
				# Fry watched a free movie.
				message = (
					"That free movie was just what I needed. "
					+ "Steve texted to ask how my Friday "
					+ "went. Should I answer?"
				)

			_:
				message = (
					"Dulce and Steve sent a weekend "
					+ "check-in. Friday's over, but "
					+ "I still have my Saturday evening."
				)

	return {
		"id": "fry_day6_morning_after",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Reply to friends - $0",
				"mood": 5,
				"energy": -2,
				"set_flag": "day6_replied_to_friends",
				"flag_value": true,
				"reaction": (
					"I sent a quick message. "
					+ "It's nice having people to talk to. "
					+ "Maybe we can hang out again soon."
				)
			},
			{
				"text": "Check my budget - $0",
				"mood": 2,
				"energy": -3,
				"set_flag": "day6_reviewed_budget",
				"flag_value": true,
				"reaction": (
					"Okay, I've still got bills coming up. "
					+ "I should check my Finances app "
					+ "before buying anything else."
				)
			},
			{
				"text": "Take it slow - $0",
				"mood": 1,
				"energy": 4,
				"reaction": (
					"It's Saturday. I can slow down "
					+ "a little. No need to rush "
					+ "into something else tonight."
				)
			}
		]
	}

#endregion


#region Fry - Day 7 Payday Temptation

func make_day7_payday_temptation_event() -> Dictionary:
	var message: String = ""

	var planned_budget: bool = bool(
		story_flags.get("day1_budget_planned", false)
	)

	var checked_budget: bool = bool(
		story_flags.get("day6_reviewed_budget", false)
	)

	# Remember Fry's earlier financial decisions.
	if planned_budget and checked_budget:
		message = (
			"My $150 paycheck came in! I made a plan "
			+ "and checked my bills yesterday. "
			+ "But that new game looks so tempting..."
		)

	elif planned_budget:
		message = (
			"Payday! $150 from the bookstore. "
			+ "I made a budget last week, but "
			+ "that new game is calling my name."
		)

	elif checked_budget:
		message = (
			"Payday! $150 in my account. "
			+ "I checked my bills yesterday... "
			+ "but I keep looking at that new game."
		)

	else:
		message = (
			"Payday! $150 from the bookstore. "
			+ "That new game looks amazing, "
			+ "but I've got bills coming up."
		)

	return {
		"id": "fry_day7_payday_temptation",
		"emotion": "excited",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Buy the new game - $24",
				"reaction_emotion": "excited",
				"money": -24.0,
				"mood": 9,
				"energy": 2,
				"finance_label": "New video game",
				"finance_category": "Entertainment",
				"set_flag": "day7_bought_game",
				"flag_value": true,
				"reaction": (
					"[wave amp=8 freq=4]Finally![/wave] I've wanted this for weeks. "
					+ "I can't wait to play it tonight. "
					+ "Hopefully I don't regret the $24."
				)
			},
			{
				"text": "Keep cash for bills - $0",
				"mood": 3,
				"energy": -2,
				"set_flag": "day7_held_for_bills",
				"flag_value": true,
				"reaction": (
					"The game can wait. My water and "
					+ "phone bills are coming up. "
					+ "Maybe I'll grab it another time."
				)
			},
			{
				"text": "Get a small treat - $9",
				"money": -9.0,
				"mood": 5,
				"energy": 3,
				"finance_label": "Payday snack and drink",
				"finance_category": "Food",
				"set_flag": "day7_small_treat",
				"flag_value": true,
				"reaction": (
					"A little snack and a cold drink "
					+ "hit the spot! I got to celebrate "
					+ "without spending too much."
				)
			}
		]
	}

#endregion


#region Fry - Day 8 Study Group

func make_day8_study_group_event() -> Dictionary:
	var message: String = ""

	# Reference the textbook decision from Day 8 Afternoon.
	match textbook_choice:
		"library":
			message = (
				"Dulce invited me to study for Friday's exam. "
				+ "My library book isn't ready yet. "
				+ "Steve says his flashcards are 'legendary.' Join?"
			)

		"rent":
			message = (
				"I rented a textbook today. Dulce and Steve "
				+ "are doing a review call. Steve's flashcards "
				+ "have some weird answers. Join?"
			)

		"used":
			message = (
				"I bought a used textbook today. Dulce and "
				+ "Steve are reviewing for Friday's exam. "
				+ "Steve's flashcards are mostly jokes. Join?"
			)

		_:
			message = (
				"Dulce and Steve are reviewing for Friday's "
				+ "exam. Steve made flashcards... and half "
				+ "are memes. Join them?"
			)

	# A full study session must obey the same basic limits
	# as Fry's bedroom desk.
	var can_study: bool = (
		not exam_completed
		and study_sessions < 4
		and last_study_day != DayManager.current_day
		and energy >= STUDY_ENERGY_COST
	)

	var first_choice: Dictionary = {}

	if can_study:
		first_choice = {
			"text": "Join study call (-18 Energy)",
			"reaction_emotion": "excited",
			"energy": -STUDY_ENERGY_COST,
			"mood": 4,
			"consumes_period": true,
			"day8_study_session": true,
			"set_flag": "day8_studied_with_friends",
			"flag_value": true,
			"reaction_speaker": "DULCE",
			"reaction": (
				"Nice work, Fry! That was a good review. "
				+ "Steve, please fix your flashcards "
				+ "before the next one."
			),
			"after_period_reaction": (
				"That study call took the whole evening, "
				+ "but I feel more prepared for the exam."
			)
		}
	else:
		# Don't offer an unusable full study session.
		first_choice = {
			"text": "Encourage the group - $0",
			"reaction_emotion": "dramatic",
			"energy": -1,
			"mood": 2,
			"reaction_speaker": "STEVE",
			"reaction": (
				"Thanks, Fry! My flashcards are "
				+ "[wave amp=8 freq=4]educational masterpieces.[/wave] "
				+ "Dulce just doesn't appreciate art."
			)
		}

	return {
		"id": "fry_day8_study_group",
		"speaker": "FRY",
		"message": message,
		"choices": [
			first_choice,
			{
				"text": "Swap notes and memes - $0",
				"reaction_emotion": "excited",
				"energy": -4,
				"mood": 4,
				"set_flag": "day8_swapped_notes",
				"flag_value": true,
				"reaction_speaker": "STEVE",
				"reaction": (
					"Sending my notes now! "
					+ "Ignore the memes in between. "
					+ "Actually, those might help."
				)
			},
			{
				"text": "Study another time - $0",
				"energy": 2,
				"mood": 1,
				"reaction": (
					"I'll catch the next one. "
					+ "I can always use my desk if "
					+ "I feel like studying later."
				)
			}
		]
	}

#endregion


#region Fry - Day 9 Campus Food Pantry

func make_day9_campus_pantry_event() -> Dictionary:
	var first_choice: Dictionary = {}

	# Fry can donate a portion only if he owns one.
	if grocery_meals > 0:
		first_choice = {
			"text": "Share 1 grocery portion - $0",
			"pantry_cost": 1,
			"energy": -3,
			"mood": 5,
			"set_flag": "day9_donated_food",
			"flag_value": true,
			"reaction_speaker": "DULCE",
			"reaction": (
				"Thanks, Fry! I'll add it to the pantry "
				+ "supplies. Steve's still explaining "
				+ "why he brought so much corn."
			)
		}
	else:
		# A zero-grocery player still has a way to help.
		first_choice = {
			"text": "Share the pantry's info - $0",
			"energy": -2,
			"mood": 2,
			"set_flag": "day9_shared_info",
			"flag_value": true,
			"reaction_speaker": "DULCE",
			"reaction": (
				"Thanks for spreading the word! "
				+ "There are students who don't "
				+ "even know this place exists."
			)
		}

	return {
		"id": "fry_day9_campus_pantry",
		"speaker": "FRY",
		"message": (
			"Dulce says the campus pantry has meal bags "
			+ "tonight. Steve donated twelve cans of corn. "
			+ "Should I go?"
		),
		"choices": [
			first_choice,
			{
				"text": "Volunteer to sort food - $0",
				"energy": -12,
				"mood": 6,
				"consumes_period": true,
				"set_flag": "day9_volunteered",
				"flag_value": true,
				"reaction_speaker": "STEVE",
				"reaction": (
					"Fry! Perfect timing. We have so "
					+ "many bags to pack. And no, "
					+ "not all of them are corn!"
				),
				"after_period_reaction": (
					"That took the whole evening, "
					+ "but we packed a lot of meal bags. "
					+ "Glad I came out to help."
				)
			},
			{
				"text": "Pick up a meal bag - $0",
				"energy": -4,
				"mood": 2,
				"day9_pantry_gain": 2,
				"set_flag": "day9_used_pantry",
				"flag_value": true,
				"reaction": (
					"I picked up two meal portions. "
					+ "That's a little less grocery "
					+ "money to worry about this week."
				)
			}
		]
	}

#endregion


#region Fry - Day 11 Last-Minute Studying

func make_day11_last_minute_studying_event() -> Dictionary:
	var message: String = ""

	# Respond to Fry's earlier exam preparation.
	if not has_textbook:
		message = (
			"My exam is tomorrow, and I still don't "
			+ "have the textbook. Dulce sent some tips. "
			+ "What should I do tonight?"
		)

	elif study_sessions >= 3:
		message = (
			"The exam is tomorrow. I've studied quite "
			+ "a bit, but I'm still nervous. "
			+ "Should I review one more time?"
		)

	elif bool(story_flags.get("day8_studied_with_friends", false)):
		message = (
			"Exam tomorrow! Dulce sent a review sheet. "
			+ "Steve says his flashcards are better. "
			+ "What's my plan tonight?"
		)

	elif bool(story_flags.get("day8_swapped_notes", false)):
		message = (
			"Exam tomorrow. Steve sent more memes "
			+ "with his notes. Dulce says I should "
			+ "actually review. What now?"
		)

	else:
		message = (
			"[shake rate=14 level=3]The exam is tomorrow already?![/shake] "
			+ "Dulce and Steve wished me luck. "
			+ "I should figure out my plan tonight."
		)

	# A full review counts as a real study session.
	var can_study: bool = (
		not exam_completed
		and study_sessions < 4
		and last_study_day != DayManager.current_day
		and energy >= STUDY_ENERGY_COST
	)

	var first_choice: Dictionary = {}

	if can_study:
		first_choice = {
			"text": "Do a final review (-18 Energy)",
			"reaction_emotion": "tired",
			"energy": -STUDY_ENERGY_COST,
			"mood": -2,
			"consumes_period": true,
			"day11_study_session": true,
			"set_flag": "day11_final_review",
			"flag_value": true,
			"reaction": (
				"Done. My brain feels like mashed potatoes, "
				+ "but I understand a few things better now. "
				+ "Hopefully that's enough."
			),
			"after_period_reaction": (
				"My exam is today. That last review "
				+ "was exhausting, but at least I tried."
			)
		}
	else:
		# Don't award an extra session when studying
		# is no longer available.
		first_choice = {
			"text": "Organize my notes - $0",
			"mood": 1,
			"reaction": (
				"At least everything is organized. "
				+ "I should give my brain a break "
				+ "instead of forcing another session."
			)
		}

	return {
		"id": "fry_day11_last_minute_studying",
		"emotion": "nervous",
		"speaker": "FRY",
		"message": message,
		"choices": [
			first_choice,
			{
				"text": "Ask Dulce for tips - $0",
				"reaction_emotion": "soft",
				"energy": -4,
				"mood": 4,
				"set_flag": "day11_asked_dulce",
				"flag_value": true,
				"reaction_speaker": "DULCE",
				"reaction": (
					"Hey! Focus on what you know first. "
					+ "And get some sleep, okay? "
					+ "You've got this, Fry!"
				)
			},
			{
				"text": "Give my brain a break - $0",
				"energy": 3,
				"mood": 2,
				"reaction": (
					"One evening won't decide everything. "
					+ "Maybe I'll unwind a little, "
					+ "then decide whether to sleep."
				)
			}
		]
	}

#endregion


#region Fry - Day 12 After the Exam

func make_day12_after_exam_event() -> Dictionary:
	var message: String = ""
	var choices: Array[Dictionary] = []

	# The exam result was already calculated in the Afternoon.
	# This event only reacts to that result.
	if exam_passed:
		message = (
			"Dulce texted after the exam. [wave amp=7 freq=4]I passed![/wave] "
			+ "Steve wants to celebrate, but I'm tired. "
			+ "What sounds good?"
		)

		choices = [
			{
				"text": "Celebrate with friends - $12",
				"reaction_emotion": "excited",
				"money": -12.0,
				"energy": -6,
				"mood": 8,
				"consumes_period": true,
				"finance_label": "After-exam celebration",
				"finance_category": "Social",
				"set_flag": "day12_connected_with_friends",
				"flag_value": true,
				"reaction_speaker": "STEVE",
				"reaction": (
					"That's what I'm talking about! "
					+ "You passed! Now, who's getting "
					+ "the biggest plate of fries?"
				)
			},
			{
				"text": "Share in group chat - $0",
				"energy": -2,
				"mood": 4,
				"set_flag": "day12_shared_good_news",
				"flag_value": true,
				"reaction_speaker": "STEVE",
				"reaction": (
					"See? My flashcards are legendary! "
					+ "What do you mean half of them "
					+ "were memes?"
				)
			},
			{
				"text": "Recharge at home - $0",
				"energy": 6,
				"mood": 2,
				"reaction": (
					"I passed! That's enough excitement "
					+ "for today. Maybe I'll relax "
					+ "and enjoy a quiet evening."
				)
			}
		]

	else:
		message = (
			"Dulce checked in after the exam. "
			+ "I didn't pass. Steve sent a terrible joke. "
			+ "What should I do tonight?"
		)

		choices = [
			{
				"text": "Talk with Dulce - $0",
				"reaction_emotion": "soft",
				"energy": -5,
				"mood": 6,
				"consumes_period": true,
				"set_flag": "day12_connected_with_friends",
				"flag_value": true,
				"reaction_speaker": "DULCE",
				"reaction": (
					"One exam isn't the whole semester. "
					+ "We can figure out what went wrong "
					+ "and try something different."
				)
			},
			{
				"text": "Make a better plan - $0",
				"energy": -4,
				"mood": 3,
				"set_flag": "day12_reflected_on_exam",
				"flag_value": true,
				"reaction": (
					"That didn't go how I wanted. "
					+ "Next time, I'll spread out "
					+ "my studying a little more."
				)
			},
			{
				"text": "Unwind at home - $0",
				"reaction_emotion": "tired",
				"energy": 6,
				"mood": 2,
				"reaction": (
					"Today was rough. I'll deal "
					+ "with school again tomorrow. "
					+ "I need some time for myself."
				)
			}
		]

	return {
		"id": "fry_day12_after_exam",
		"emotion": "excited" if exam_passed else "sad",
		"speaker": "FRY",
		"message": message,
		"choices": choices
	}

#endregion


#region Fry - Day 13 Animal Shelter

func make_day13_animal_shelter_event() -> Dictionary:
	var message: String = ""
	var first_choice: Dictionary = {}

	# Reference Fry's earlier community involvement.
	if bool(story_flags.get("day9_volunteered", false)):
		message = (
			"Dulce texted: 'Thanks for helping at the "
			+ "food pantry, Fry!' Now she says a local "
			+ "animal shelter needs help with cats too."
		)

	elif exam_completed and not exam_passed:
		message = (
			"That exam was rough. Dulce sent me a shelter "
			+ "appeal. Helping some animals might be "
			+ "a nice change of pace. What should I do?"
		)

	else:
		message = (
			"Dulce sent me a local animal shelter's post. "
			+ "They need pet food, volunteers, and help "
			+ "finding homes for animals. What can I do?"
		)

	# Offer a donation only if Fry can afford it.
	if money >= 15.0:
		first_choice = {
			"text": "Donate pet food - $15",
			"money": -15.0,
			"energy": -2,
			"mood": 5,
			"finance_label": "Animal shelter donation",
			"finance_category": "Charity",
			"set_flag": "day13_donated",
			"flag_value": true,
			"reaction": (
				"I sent $15 for pet food. "
				+ "Hopefully that helps keep "
				+ "a few furry bellies full."
			)
		}
	else:
		# Helping doesn't always require money.
		first_choice = {
			"text": "Share shelter wishlist - $0",
			"energy": -2,
			"mood": 2,
			"set_flag": "day13_shared_wishlist",
			"flag_value": true,
			"reaction": (
				"I can't donate right now, but I shared "
				+ "their supply wishlist. Maybe someone "
				+ "else can send what they need."
			)
		}

	return {
		"id": "fry_day13_animal_shelter",
		"emotion": "soft",
		"speaker": "FRY",
		"message": message,
		"choices": [
			first_choice,
			{
				"text": "Volunteer - Care for cats - $0",
				"reaction_emotion": "excited",
				"energy": -14,
				"mood": 7,
				"consumes_period": true,
				"set_flag": "day13_volunteered",
				"flag_value": true,
				"reaction": (
					"A tiny black Bombay kitten followed "
					+ "me everywhere! Her gray sister "
					+ "kept hiding behind my shoes."
				),
				"after_period_reaction": (
					"I can't stop thinking about those "
					+ "two kittens at the shelter. "
					+ "Maybe I could adopt them both..."
				)
			},
			{
				"text": "Create adoption posts - $0",
				"reaction_emotion": "excited",
				"energy": -6,
				"mood": 4,
				"set_flag": "day13_adoption_posted",
				"flag_value": true,
				"reaction": (
					"I made adoption posts for two "
					+ "kitten sisters. One black, one "
					+ "gray. [wave amp=7 freq=4]They're adorable together![/wave]"
				)
			}
		]
	}

#endregion


#region Fry - Day 14 Family Check-In

func make_day14_family_checkin_event() -> Dictionary:
	var message: String = ""
	var honest_reaction: String = ""
	var advice_reaction: String = ""
	var third_choice: Dictionary = {}

	# Fry has a personal connection to the two shelter kittens.
	var met_kittens: bool = (
		bool(story_flags.get("day13_volunteered", false))
		or bool(story_flags.get("day13_adoption_posted", false))
	)


	# Family conversation always addresses Fry's life first.
	if exam_completed and not exam_passed:
		message = (
			"Mom's calling. My exam didn't go well, "
			+ "and I'm still thinking about it. "
			+ "What should I tell her?"
		)

	elif money < 40.0:
		message = (
			"Mom called to check on me. Money's "
			+ "getting tight, and she wants to know "
			+ "if I'm managing okay."
		)

	elif exam_completed and exam_passed:
		message = (
			"Mom called to ask about school. "
			+ "I passed my first exam! She's also "
			+ "asking how my money's holding up."
		)

	else:
		message = (
			"Mom called to see how I'm doing. "
			+ "School, work, bills... there's a lot "
			+ "to catch her up on."
		)

	# Mention the kittens in addition to the normal story.
	if met_kittens:
		message += (
			" I should tell her about those "
			+ "two kittens at the shelter, too."
		)


	# Mom responds to Fry's circumstances first.
	if exam_completed and not exam_passed:
		honest_reaction = (
			"One exam doesn't define you, Fry. "
			+ "Learn from it and keep trying. "
			+ "I'm proud you're doing your best."
		)

	elif money < 40.0:
		honest_reaction = (
			"I'm glad you told me. Keep an eye "
			+ "on your bills, okay? You don't "
			+ "have to figure everything out today."
		)

	else:
		honest_reaction = (
			"You've been handling a lot lately. "
			+ "It's good hearing your voice. "
			+ "I'm proud of you, Fry!"
		)

	# Add the kitten reference without replacing
	# the main family conversation.
	if met_kittens:
		honest_reaction += (
			" And those two kittens sound adorable! "
			+ "I'd love to see pictures."
		)

	# Mom always gives her regular budgeting advice.
	advice_reaction = (
		"Start with rent and your bills. "
		+ "Then groceries. Whatever's left "
		+ "is what you can spend on extras."
	)

	# Additional advice about adopting both kittens.
	if met_kittens:
		advice_reaction += (
			" And remember, two kittens mean "
			+ "food, litter, and vet expenses!"
		)

	# Visiting costs money for transportation.
	# Low-cash players get a free alternative.
	if money >= 8.0:
		third_choice = {
			"text": "Visit family for dinner - $8",
			"reaction_emotion": "soft",
			"money": -8.0,
			"mood": 9,
			"energy": -7,
			"consumes_period": true,
			"finance_label": "Family visit transportation",
			"finance_category": "Transport",
			"set_flag": "day14_family_visit",
			"flag_value": true,
			"reaction_speaker": "MOM",
			"reaction": (
				"I'm so glad you came over! "
				+ "We saved you a plate. "
				+ "Come sit down and eat!"
			),
			"after_period_reaction": (
				"Last night's family dinner was nice. "
				+ "I should make time to visit "
				+ "them more often."
			)
		}
	else:
		third_choice = {
			"text": "Stay on the call - $0",
			"reaction_emotion": "soft",
			"mood": 3,
			"energy": 2,
			"set_flag": "day14_long_call",
			"flag_value": true,
			"reaction_speaker": "MOM",
			"reaction": (
				"No need to spend money visiting "
				+ "right now. I'm just happy "
				+ "we got to talk. Love you!"
			)
		}

	return {
		"id": "fry_day14_family_checkin",
		"emotion": "soft",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Talk honestly - $0",
				"reaction_emotion": "soft",
				"energy": -3,
				"mood": 5,
				"set_flag": "day14_opened_up",
				"flag_value": true,
				"reaction_speaker": "MOM",
				"reaction": honest_reaction
			},
			{
				"text": "Ask for money advice - $0",
				"reaction_emotion": "soft",
				"energy": -4,
				"mood": 4,
				"set_flag": "day14_budget_advice",
				"flag_value": true,
				"reaction_speaker": "MOM",
				"reaction": advice_reaction
			},
			third_choice
		]
	}

#endregion


#region Fry - Day 15 New Assignment

func make_day15_new_assignment_event() -> Dictionary:
	var message: String = ""
	var planning_reaction: String = ""

	# Reflect Fry's experience with the first exam.
	if (
		exam_completed
		and not exam_passed
		and bool(story_flags.get("day12_reflected_on_exam", false))
	):
		message = (
			"A new group presentation was assigned. "
			+ "After my exam, I promised to plan ahead. "
			+ "We need slides and handouts soon."
		)

	elif exam_completed and not exam_passed:
		message = (
			"Another assignment already? My last exam "
			+ "didn't go well. Now we have a group "
			+ "presentation to prepare. Where do I start?"
		)

	elif exam_completed and exam_passed:
		message = (
			"I passed my first exam, but there's "
			+ "already a new group presentation! "
			+ "Slides, handouts... what's my plan?"
		)

	else:
		message = (
			"A new group presentation was assigned. "
			+ "We'll need slides and handouts. "
			+ "How should I get started?"
		)

	# Mom's earlier advice is remembered,
	# but it doesn't replace the assignment story.
	if bool(story_flags.get("day14_budget_advice", false)):
		planning_reaction = (
			"Mom said to think about expenses before "
			+ "spending. I'll price the handouts, "
			+ "check free options, and set a limit."
		)
	else:
		planning_reaction = (
			"Before buying anything, I should "
			+ "figure out what the project needs. "
			+ "Maybe free options will work."
		)

	return {
		"id": "fry_day15_new_assignment",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Plan project costs - $0",
				"energy": -4,
				"mood": 3,
				"set_flag": "day15_project_budget",
				"flag_value": true,
				"reaction": planning_reaction
			},
			{
				"text": "Start slides tonight - $0",
				"energy": -13,
				"mood": 7,
				"consumes_period": true,
				"set_flag": "day15_started_slides",
				"flag_value": true,
				"reaction": (
					"Alright, I finished the first "
					+ "draft of our slides! It took "
					+ "a while, but we're making progress."
				),
				"after_period_reaction": (
					"Glad I started those slides last night. "
					+ "Now I just need to figure out "
					+ "the handouts."
				)
			},
			{
				"text": "Split tasks with friends - $0",
				"reaction_emotion": "excited",
				"energy": -3,
				"mood": 4,
				"set_flag": "day15_split_tasks",
				"flag_value": true,
				"reaction_speaker": "DULCE",
				"reaction": (
					"Good idea! I can handle the visuals, "
					+ "Steve can research, and you can "
					+ "put everything together."
				)
			}
		]
	}

#endregion


#region Fry - Day 16 Unexpected Invitation

func make_day16_unexpected_invitation_event() -> Dictionary:
	var message: String = ""
	var first_choice: Dictionary = {}

	var electricity_bill: Dictionary = bills.get(
		"electricity", {}
	)
	var bill_paid: bool = bool(
		electricity_bill.get("paid", false)
	)

	# The invitation happens regardless of earlier decisions.

	# Keep the main invitation short.
	message = (
		"Steve and Dulce invited me to the arcade. "
		+ "Should I go?"
	)

	# Brief reference to the electricity bill.
	if bill_paid:
		message += " My power bill is paid."
	else:
		message += " My $40 power bill is unpaid."

	# Small callback to Day 15.
	if bool(story_flags.get("day15_project_budget", false)):
		message += " I planned my project costs."

	elif bool(story_flags.get("day15_started_slides", false)):
		message += " My slides are underway."

	# The first option changes when cash is low.
	if money >= 14.0:
		first_choice = {
			"text": "Go to the arcade - $14",
			"reaction_emotion": "dramatic",
			"money": -14.0,
			"mood": 8,
			"energy": -8,
			"consumes_period": true,
			"finance_label": "Arcade night with friends",
			"finance_category": "Entertainment",
			"set_flag": "day16_arcade",
			"flag_value": true,
			"reaction_speaker": "STEVE",
			"reaction": (
				"There's no way you beat my score! "
				+ "[shake rate=15 level=3]That machine is clearly broken.[/shake] "
				+ "Dulce, back me up here!"
			),
			"after_period_reaction": (
				"Last night's arcade trip was fun. "
				+ "I spent $14, though. I'd better "
				+ "watch the rest of my budget."
			)
		}

	else:
		first_choice = {
			"text": "Play games online - $0",
			"reaction_emotion": "excited",
			"mood": 5,
			"energy": -5,
			"consumes_period": true,
			"set_flag": "day16_online_games",
			"flag_value": true,
			"reaction_speaker": "STEVE",
			"reaction": (
				"Can't make it to the arcade? "
				+ "No problem! Let's play online. "
				+ "Just don't rage quit when I win!"
			),
			"after_period_reaction": (
				"Last night's online games were "
				+ "a lot of fun, and I didn't "
				+ "have to spend anything."
			)
		}

	return {
		"id": "fry_day16_unexpected_invitation",
		"speaker": "FRY",
		"message": message,
		"choices": [
			first_choice,
			{
				"text": "Take a free walk - $0",
				"reaction_emotion": "soft",
				"energy": -7,
				"mood": 6,
				"consumes_period": true,
				"set_flag": "day16_free_walk",
				"flag_value": true,
				"reaction_speaker": "DULCE",
				"reaction": (
					"An evening walk sounds nice! "
					+ "We don't have to spend money "
					+ "every time we hang out."
				),
				"after_period_reaction": (
					"That walk with Steve and Dulce "
					+ "was actually really nice. "
					+ "We should do that more often."
				)
			},
			{
				"text": "Stay home and recharge - $0",
				"energy": 5,
				"mood": 2,
				"set_flag": "day16_stayed_home",
				"flag_value": true,
				"reaction": (
					"I told Steve and Dulce I couldn't "
					+ "make it tonight. They understood. "
					+ "I could really use some rest."
				)
			}
		]
	}

#endregion


#region Fry - Day 18 Homeless Shelter

func make_day18_homeless_shelter_event() -> Dictionary:
	var first_choice: Dictionary = {}
	var volunteer_reaction: String = ""

	# Players who helped at the food pantry
	# get a small callback in their reaction.
	if bool(story_flags.get("day9_volunteered", false)):
		volunteer_reaction = (
			"That pantry shift really helped. "
			+ "We packed the care kits and got "
			+ "everything ready for the shelter."
		)
	else:
		volunteer_reaction = (
			"We packed soap, socks, and other "
			+ "essentials into care kits. "
			+ "Glad I could lend a hand!"
		)

	# A donation is offered only when affordable.
	if money >= 12.0:
		first_choice = {
			"text": "Donate hygiene supplies - $12",
			"money": -12.0,
			"energy": -2,
			"mood": 5,
			"finance_label": "Shelter hygiene supplies",
			"finance_category": "Charity",
			"set_flag": "day18_donated_supplies",
			"flag_value": true,
			"reaction": (
				"I sent $12 for hygiene supplies. "
				+ "I'll need to keep an eye on "
				+ "my school payment, too."
			)
		}
	else:
		first_choice = {
			"text": "Collect spare supplies - $0",
			"energy": -5,
			"mood": 4,
			"set_flag": "day18_collected_supplies",
			"flag_value": true,
			"reaction": (
				"I asked around and collected "
				+ "some unused supplies. "
				+ "No money needed!"
			)
		}

	return {
		"id": "fry_day18_homeless_shelter",
		"emotion": "soft",
		"speaker": "FRY",
		"message": (
			"Dulce says the local homeless shelter "
			+ "needs help packing care kits tonight. "
			+ "How can I help?"
		),
		"choices": [
			first_choice,
			{
				"text": "Volunteer to pack kits - $0",
				"energy": -14,
				"mood": 7,
				"consumes_period": true,
				"set_flag": "day18_volunteered",
				"flag_value": true,
				"reaction": volunteer_reaction,
				"after_period_reaction": (
					"That shelter shift was tiring, "
					+ "but it felt good helping out. "
					+ "Now, back to my own responsibilities."
				)
			},
			{
				"text": "Share shelter request - $0",
				"energy": -2,
				"mood": 3,
				"set_flag": "day18_shared_request",
				"flag_value": true,
				"reaction": (
					"I shared the shelter's supply list "
					+ "with my classmates. Hopefully "
					+ "it reaches someone who can help."
				)
			}
		]
	}

#endregion


#region Fry - Day 21 Kitten Adoption

func make_day21_kitten_adoption_event() -> Dictionary:
	var message: String = (
		"The shelter called! The two kitten sisters "
		+ "can be adopted together."
	)
	var first_choice: Dictionary = {}

	var unpaid_total: float = get_unpaid_total()

	# Remind Fry about financial commitments
	# before he decides to adopt.
	if unpaid_total > 0.0:
		message += (
			" I still have $%.0f in bills to cover."
			% unpaid_total
		)
	else:
		message += " Should I bring them home?"

	# Adoption includes initial supplies.
	if money >= 85.0:
		first_choice = {
			"text": "Adopt both kittens - $85",
			"reaction_emotion": "excited",
			"money": -85.0,
			"mood": 9,
			"energy": -8,
			"consumes_period": true,
			"finance_label": "Two kitten adoptions and starter supplies",
			"finance_category": "Pets",
			"set_flag": "day21_kittens_adopted",
			"flag_value": true,
			"reaction": (
				"[wave amp=8 freq=4]I signed the papers![/wave] The black "
				+ "kitten is Pantera, and her gray "
				+ "sister is Galleta!"
			),
			"after_period_reaction": (
				"Pantera and Galleta are officially "
				+ "mine. I need to get the apartment "
				+ "ready for both of them!"
			)
		}
	else:
		first_choice = {
			"text": "Start saving for adoption - $0",
			"reaction_emotion": "sad",
			"mood": 2,
			"energy": -2,
			"set_flag": "day21_saving_for_kittens",
			"flag_value": true,
			"reaction": (
				"I'd love to bring them home, "
				+ "but I can't afford it yet. "
				+ "I'll have to save up."
			)
		}

	return {
		"id": "fry_day21_kitten_adoption",
		"emotion": "excited",
		"speaker": "FRY",
		"message": message,
		"choices": [
			first_choice,
			{
				"text": "Visit the kittens - $0",
				"reaction_emotion": "excited",
				"mood": 5,
				"energy": -6,
				"consumes_period": true,
				"set_flag": "day21_visited_kittens",
				"flag_value": true,
				"reaction": (
					"The black kitten ran right up "
					+ "to me! Her gray sister wasn't "
					+ "far behind. They're inseparable."
				),
				"after_period_reaction": (
					"That shelter visit made me want "
					+ "to adopt the sisters even more. "
					+ "I should think about the cost."
				)
			},
			{
				"text": "Help find them a home - $0",
				"mood": 4,
				"energy": -3,
				"set_flag": "day21_helped_rehome",
				"flag_value": true,
				"reaction": (
					"I shared their adoption listing. "
					+ "They deserve a good home "
					+ "where they can stay together."
				)
			}
		]
	}

#endregion


#region Fry - Day 21 A Friend Needs Help

func make_day21_friend_help_event() -> Dictionary:
	var transport_choice: Dictionary = {}

	# Provide an affordable way to help Steve.
	if money >= 8.0:
		transport_choice = {
			"text": "Help with bus fare - $8",
			"reaction_emotion": "soft",
			"money": -8.0,
			"mood": 4,
			"energy": -2,
			"finance_label": "Helping Steve with transportation",
			"finance_category": "Social",
			"set_flag": "day21_paid_transport",
			"flag_value": true,
			"reaction_speaker": "STEVE",
			"reaction": (
				"Seriously, thanks! I'll be able "
				+ "to get to the interview now. "
				+ "I owe you one!"
			),
			"delayed": {
				"days_later": 1,
				"period": "Morning",
				"mood": 1,
				"text": (
					"Steve texted: Made it to the "
					+ "interview on time! Thanks again!"
				)
			}
		}
	else:
		transport_choice = {
			"text": "Find a bus route - $0",
			"mood": 3,
			"energy": -5,
			"set_flag": "day21_found_bus_route",
			"flag_value": true,
			"reaction_speaker": "STEVE",
			"reaction": (
				"Oh, there's a bus that stops "
				+ "near the place? Nice! "
				+ "Thanks for checking!"
			),
			"delayed": {
				"days_later": 1,
				"period": "Morning",
				"mood": 1,
				"text": (
					"Steve texted: That bus route "
					+ "worked! I made it on time."
				)
			}
		}

	return {
		"id": "fry_day21_friend_help",
		"emotion": "nervous",
		"speaker": "STEVE",
		"message": (
			"I have a job interview tomorrow! "
			+ "My ride fell through, and I'm "
			+ "[shake rate=14 level=3]pretty nervous[/shake]. Can you help?"
		),
		"choices": [
			{
				"text": "Practice interview - $0",
				"reaction_emotion": "excited",
				"mood": 6,
				"energy": -12,
				"consumes_period": true,
				"set_flag": "day21_practiced_interview",
				"flag_value": true,
				"reaction_speaker": "STEVE",
				"reaction": (
					"Okay, that actually helped a lot! "
					+ "I feel way more prepared now. "
					+ "Thanks, Fry!"
				),
				"delayed": {
					"days_later": 1,
					"period": "Morning",
					"mood": 2,
					"text": (
						"Steve texted: The interview "
						+ "went pretty well! Thanks "
						+ "for practicing with me."
					)
				}
			},
			transport_choice,
			{
				"text": "Send encouragement - $0",
				"reaction_emotion": "soft",
				"mood": 2,
				"energy": 3,
				"set_flag": "day21_encouraged_steve",
				"flag_value": true,
				"reaction_speaker": "STEVE",
				"reaction": (
					"Thanks, man. I'll figure "
					+ "something out. Wish me luck!"
				)
			}
		]
	}

#endregion


#region Fry - Day 22 Professor's Office Hours

func make_day22_professor_event() -> Dictionary:
	var message: String = ""
	var rest_reaction: String = ""

	# Reference the bookstore shift without
	# replacing the main office-hours event.
	if bool(story_flags.get("day22_inventory_worked", false)):
		message = (
			"Bookstore shift's done. Professor has "
			+ "online office hours tonight. "
			+ "Should I join?"
		)
	else:
		message = (
			"Professor has online office hours tonight. "
			+ "I could ask about our presentation."
		)

	# Adopted kittens appear naturally in Fry's
	# free time, without changing the academic story.
	if bool(story_flags.get("day21_kittens_adopted", false)):
		rest_reaction = (
			"Pantera curled up beside me while "
			+ "Galleta chased a shoelace. "
			+ "This is a pretty nice evening."
		)
	else:
		rest_reaction = (
			"I've had a lot going on lately. "
			+ "I'll recharge tonight and "
			+ "work on school tomorrow."
		)

	return {
		"id": "fry_day22_professor",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Attend office hours - $0",
				"reaction_emotion": "soft",
				"energy": -10,
				"mood": 6,
				"consumes_period": true,
				"set_flag": "day22_office_hours",
				"flag_value": true,
				"reaction_speaker": "PROFESSOR",
				"reaction": (
					"Your project has potential, Fry. "
					+ "Keep examples of your work. "
					+ "They'll help with internships."
				),
				"after_period_reaction": (
					"Professor's feedback was helpful. "
					+ "I should polish my work "
					+ "for future opportunities."
				)
			},
			{
				"text": "Email the professor - $0",
				"energy": -3,
				"mood": 3,
				"set_flag": "day22_emailed_professor",
				"flag_value": true,
				"reaction": (
					"I sent a quick email asking "
					+ "for project feedback. "
					+ "Hopefully I hear back."
				),
				"delayed": {
					"days_later": 1,
					"period": "Morning",
					"mood": 1,
					"text": (
						"Professor replied! She suggested "
						+ "adding my project to a portfolio."
					)
				}
			},
			{
				"text": "Stay home and rest - $0",
				"reaction_emotion": "soft",
				"energy": 8,
				"mood": 2,
				"set_flag": "day22_rest",
				"flag_value": true,
				"reaction": rest_reaction
			}
		]
	}

#endregion


#region Fry - Day 24 Internship Opportunity

func make_day24_internship_event() -> Dictionary:
	var message: String = ""
	var portfolio_reaction: String = ""

	# Remember the professor's earlier advice.
	if bool(story_flags.get("day22_office_hours", false)):
		message = (
			"[color=#FFD89B]Paid internship opening![/color] My professor "
			+ "said my projects could help. Apply now?"
		)

	elif bool(story_flags.get("day22_emailed_professor", false)):
		message = (
			"Paid internship opening! My professor "
			+ "mentioned portfolios. Should I apply?"
		)

	else:
		message = (
			"There's a paid internship opening! "
			+ "I could apply using my class projects."
		)

	# Reward players who completed and tested
	# the club fundraiser website.
	if (
		bool(story_flags.get("club_helped", false))
		and bool(story_flags.get("club_ready", false))
	):
		portfolio_reaction = (
			"I added our tested fundraiser website "
			+ "to my portfolio. Application sent!"
		)
	else:
		portfolio_reaction = (
			"I cleaned up my class projects and "
			+ "finished the application. Sent!"
		)

	return {
		"id": "fry_day24_internship",
		"emotion": "excited",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Polish and apply - $0",
				"reaction_emotion": "excited",
				"energy": -16,
				"mood": 6,
				"consumes_period": true,
				"set_flag": "day24_portfolio_applied",
				"flag_value": true,
				"reaction": portfolio_reaction,
				"after_period_reaction": (
					"That took a while, but I'm glad "
					+ "I put effort into my application."
				),
				"delayed": {
					"days_later": 3,
					"period": "Morning",
					"mood": 3,
					"text": (
						"The internship team emailed! "
						+ "They liked my portfolio and "
						+ "want me to complete a screening task."
					)
				}
			},
			{
				"text": "Apply quickly - $0",
				"reaction_emotion": "nervous",
				"energy": -5,
				"mood": 2,
				"set_flag": "day24_quick_applied",
				"flag_value": true,
				"reaction": (
					"Application sent. I could've "
					+ "spent more time on it, "
					+ "but at least I applied."
				),
				"delayed": {
					"days_later": 3,
					"period": "Morning",
					"mood": 1,
					"text": (
						"The internship team replied. "
						+ "They asked me to send "
						+ "an example of my work."
					)
				}
			},
			{
				"text": "Save listing - $0",
				"energy": 3,
				"mood": 1,
				"set_flag": "day24_saved_listing",
				"flag_value": true,
				"reaction": (
					"I saved the listing. "
					+ "I should review my projects "
					+ "before deciding."
				),
				"delayed": {
					"days_later": 3,
					"period": "Morning",
					"text": (
						"That internship listing is "
						+ "still saved. I should "
						+ "decide whether to apply."
					)
				}
			}
		]
	}

#endregion


#region Fry - Day 27 Internship Follow-Up

func make_day27_internship_followup_event() -> Dictionary:
	var message: String = ""
	var choices: Array[Dictionary] = []

	# Fry submitted a polished application.
	if bool(story_flags.get("day24_portfolio_applied", false)):
		message = (
			"The internship team wants a screening "
			+ "task. How should I handle it?"
		)

		var screening_reaction: String = (
			"I finished the screening task and "
			+ "checked my answers. Submitted!"
		)

		if bool(story_flags.get("day22_office_hours", false)):
			screening_reaction = (
				"I followed my professor's advice "
				+ "and reviewed everything. Sent!"
			)

		choices = [
			{
				"text": "Finish screening task - $0",
				"reaction_emotion": "excited",
				"energy": -15,
				"mood": 6,
				"consumes_period": true,
				"set_flag": "day27_screening_submitted",
				"flag_value": true,
				"reaction": screening_reaction
			},
			{
				"text": "Start task outline - $0",
				"energy": -6,
				"mood": 3,
				"set_flag": "day27_screening_started",
				"flag_value": true,
				"reaction": (
					"I've outlined the task. "
					+ "Still need to finish and submit it."
				)
			},
			{
				"text": "Ask for more time - $0",
				"reaction_emotion": "nervous",
				"energy": 4,
				"mood": -2,
				"set_flag": "day27_requested_more_time",
				"flag_value": true,
				"reaction": (
					"I asked about an extension. "
					+ "Hopefully they get back to me."
				)
			}
		]

	# Fry sent a quick application on Day 24.
	elif bool(story_flags.get("day24_quick_applied", false)):
		message = (
			"They want a sample of my work. "
			+ "What should I send?"
		)

		choices = [
			{
				"text": "Polish and send sample - $0",
				"reaction_emotion": "excited",
				"energy": -12,
				"mood": 5,
				"consumes_period": true,
				"set_flag": "day27_sample_polished",
				"flag_value": true,
				"reaction": (
					"I cleaned up my best project "
					+ "and sent it over. Much better!"
				)
			},
			{
				"text": "Send existing project - $0",
				"energy": -4,
				"mood": 2,
				"set_flag": "day27_sample_sent",
				"flag_value": true,
				"reaction": (
					"I sent one of my class projects. "
					+ "Hopefully it's what they need."
				)
			},
			{
				"text": "Request more time - $0",
				"energy": 3,
				"mood": -1,
				"set_flag": "day27_requested_more_time",
				"flag_value": true,
				"reaction": (
					"I asked for a little more time "
					+ "to prepare my work sample."
				)
			}
		]

	# Fry saved the internship listing.
	else:
		message = (
			"That internship listing is still saved. "
			+ "Should I finally apply?"
		)

		choices = [
			{
				"text": "Apply with portfolio - $0",
				"energy": -12,
				"mood": 5,
				"consumes_period": true,
				"set_flag": "day27_late_application",
				"flag_value": true,
				"reaction": (
					"I got my projects together "
					+ "and submitted the application!"
				)
			},
			{
				"text": "Prepare application - $0",
				"energy": -5,
				"mood": 2,
				"set_flag": "day27_prepared_application",
				"flag_value": true,
				"reaction": (
					"I've updated my portfolio. "
					+ "Just need to finish applying."
				)
			},
			{
				"text": "Leave listing saved - $0",
				"energy": 3,
				"mood": -1,
				"set_flag": "day27_listing_deferred",
				"flag_value": true,
				"reaction": (
					"I'll leave it saved for now. "
					+ "I know openings don't last forever."
				)
			}
		]

	return {
		"id": "fry_day27_internship_followup",
		"emotion": "nervous",
		"speaker": "FRY",
		"message": message,
		"choices": choices
	}

#endregion


#region Fry - Day 27 Kitten Supplies

func make_day27_pet_care_event() -> Dictionary:
	var message: String = ""
	var full_choice: Dictionary = {}
	var essentials_choice: Dictionary = {}

	# Keep the introduction compact.
	if bool(bills.get("rent", {}).get("paid", false)):
		message = (
			"Pantera and Galleta's starter supplies "
			+ "are running low. Time to restock?"
		)
	else:
		message = (
			"The kittens need supplies soon, "
			+ "but rent's still unpaid. "
			+ "What should I do?"
		)

	# First option: a fuller supply purchase.
	if money >= 22.0:
		full_choice = {
			"text": "Buy food and litter - $22",
			"money": -22.0,
			"energy": -8,
			"mood": 5,
			"consumes_period": true,
			"finance_label": "Cat food and litter",
			"finance_category": "Pets",
			"set_flag": "day27_pet_full_supplies",
			"flag_value": true,
			"reaction": (
				"Food and litter are stocked! "
				+ "Pantera and Galleta are all set."
			)
		}
	else:
		full_choice = {
			"text": "Compare supply prices - $0",
			"energy": -5,
			"mood": 2,
			"set_flag": "day27_pet_compared_prices",
			"flag_value": true,
			"reaction": (
				"I found some cheaper options. "
				+ "I'll need to buy them soon."
			)
		}

	# Second option: the smaller purchase.
	if money >= 9.0:
		essentials_choice = {
			"text": "Buy essentials - $9",
			"money": -9.0,
			"energy": -3,
			"mood": 3,
			"finance_label": "Essential kitten supplies",
			"finance_category": "Pets",
			"set_flag": "day27_pet_essentials",
			"flag_value": true,
			"reaction": (
				"This should get us through "
				+ "the next few days. "
				+ "I'll budget for more later."
			)
		}
	else:
		essentials_choice = {
			"text": "Use starter supplies - $0",
			"energy": -2,
			"mood": 1,
			"set_flag": "day27_pet_used_starter",
			"flag_value": true,
			"reaction": (
				"There's still some food and litter "
				+ "left. I'll have to restock soon."
			)
		}

	return {
		"id": "fry_day27_pet_care",
		"emotion": "nervous" if not bool(bills.get("rent", {}).get("paid", false)) else "neutral",
		"speaker": "FRY",
		"message": message,
		"choices": [
			full_choice,
			essentials_choice,
			{
				"text": "Plan a pet budget - $0",
				"energy": -4,
				"mood": 3,
				"set_flag": "day27_pet_budget_planned",
				"flag_value": true,
				"reaction": (
					"I set aside a plan for future "
					+ "food, litter, and vet costs. "
					+ "Now I need to follow it."
				)
			}
		]
	}

#endregion


#region Fry - Day 28 The Final Paycheck

func make_day28_final_paycheck_event() -> Dictionary:
	var message: String = ""
	var budget_reaction: String = ""
	var rest_reaction: String = ""
	var treat_reaction: String = ""
	var third_choice: Dictionary = {}

	var unpaid_total: float = get_unpaid_total()

	var adopted_kittens: bool = bool(
		story_flags.get("day21_kittens_adopted", false)
	)

	var kitten_visit: bool = bool(
		story_flags.get("day27_kitten_visit_seen", false)
	)

	# Acknowledge Fry's actual financial situation.
	if unpaid_total > 0.0:
		message = (
			"Last paycheck's in. I still owe "
			+ "$%.2f in bills. What should I do?"
		) % unpaid_total
	else:
		message = (
			"Last paycheck's in, and my bills "
			+ "are paid! How should I end today?"
		)

	# Reviewing finances includes responsibilities
	# from earlier story decisions.
	if unpaid_total > 0.0:
		if adopted_kittens:
			budget_reaction = (
				"I listed my unpaid bills and "
				+ "the kittens' future expenses. "
				+ "I need a better plan."
			)
		else:
			budget_reaction = (
				"I listed my unpaid bills and "
				+ "figured out what needs priority."
			)
	else:
		if adopted_kittens:
			budget_reaction = (
				"My bills are covered. "
				+ "Now to plan for Pantera "
				+ "and Galleta's expenses!"
			)
		else:
			budget_reaction = (
				"My bills are paid. I'll look "
				+ "at my spending and plan "
				+ "for next month."
			)

	# Small personal callbacks after Day 27 Night.
	if adopted_kittens and kitten_visit:
		rest_reaction = (
			"Yesterday was fun. Dulce and Steve "
			+ "really loved the kittens. "
			+ "I'm still smiling about it."
		)

	elif adopted_kittens:
		rest_reaction = (
			"Pantera and Galleta curled up "
			+ "beside me. It's nice having "
			+ "them around."
		)

	else:
		rest_reaction = (
			"I've done enough for today. "
			+ "Time to relax."
		)

	if adopted_kittens:
		treat_reaction = (
			"I got myself a little treat. "
			+ "Pantera and Galleta were "
			+ "waiting when I got home!"
		)
	else:
		treat_reaction = (
			"A little treat was nice. "
			+ "I'll make sure it doesn't "
			+ "become an everyday expense."
		)

	# Give players an affordable alternative.
	if money >= 12.0:
		third_choice = {
			"text": "Enjoy a small treat - $12",
			"money": -12.0,
			"mood": 6,
			"energy": 2,
			"finance_label": "Sunday treat",
			"finance_category": "Entertainment",
			"set_flag": "day28_small_treat",
			"flag_value": true,
			"reaction": treat_reaction
		}
	else:
		third_choice = {
			"text": "Relax at home - $0",
			"mood": 3,
			"energy": 8,
			"set_flag": "day28_relaxed",
			"flag_value": true,
			"reaction": rest_reaction
		}

	return {
		"id": "fry_day28_final_paycheck",
		"emotion": "nervous" if unpaid_total > 0.0 else "excited",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Review my budget - $0",
				"energy": -5,
				"mood": 4,
				"set_flag": "day28_budget_reviewed",
				"flag_value": true,
				"reaction": budget_reaction
			},
			{
				"text": "Take a web gig (+$28)",
				"reaction_emotion": "tired",
				"money": 28.0,
				"energy": -16,
				"mood": -2,
				"consumes_period": true,
				"finance_label": "Last-minute website gig",
				"finance_category": "Income",
				"set_flag": "day28_extra_gig",
				"flag_value": true,
				"reaction": (
					"A client needs a quick website "
					+ "fix tonight. Let's get it done!"
				),
				"after_period_reaction": (
					"Finally finished! The $28 came "
					+ "through. I should check "
					+ "what I still owe."
				)
			},
			third_choice
		]
	}

#endregion


#region Fry - Day 30 Final Evening

func make_day30_final_evening_event() -> Dictionary:
	var message: String = ""
	var plan_reaction: String = ""
	var friends_reaction: String = ""
	var rest_reaction: String = ""

	var unpaid_total: float = get_unpaid_total()

	var adopted_kittens: bool = bool(
		story_flags.get("day21_kittens_adopted", false)
	)

	var kitten_visit: bool = bool(
		story_flags.get("day27_kitten_visit_seen", false)
	)

	var caught_up: bool = bool(
		story_flags.get("caught_up_with_dulce", false)
	)

	# Opening depends on Fry's finances.
	if unpaid_total > 0.0:
		message = (
			"Last evening of the month. "
			+ "I still owe $%.2f in bills. "
			+ "What should I do tonight?"
		) % unpaid_total
	else:
		message = (
			"[color=#FFD89B]Thirty days already?[/color] My bills "
			+ "are paid. How should I "
			+ "spend my last evening?"
		)

	# Financial reflection.
	if unpaid_total > 0.0:
		plan_reaction = (
			"I wrote down what I still owe. "
			+ "Next month, bills need "
			+ "to come first."
		)
	else:
		plan_reaction = (
			"I looked through my spending "
			+ "and made a plan for next month. "
			+ "Not a bad start!"
		)

	if adopted_kittens:
		plan_reaction += (
			" The kittens need a budget too."
		)

	# Friendship callback.
	if kitten_visit and caught_up:
		friends_reaction = (
			"Dulce replied almost immediately. "
			+ "She asked about the kittens again. "
			+ "Steve sent a ridiculous cat meme."
		)

	elif kitten_visit:
		friends_reaction = (
			"Dulce asked how Pantera and Galleta "
			+ "were doing. Steve says he's "
			+ "still planning his ninja entrance."
		)

	elif caught_up:
		friends_reaction = (
			"Dulce said she enjoyed catching up. "
			+ "Steve immediately started "
			+ "planning another hangout."
		)

	else:
		friends_reaction = (
			"I sent Dulce and Steve a message. "
			+ "Maybe we can hang out "
			+ "more next month."
		)

	# Quiet ending with an optional kitten callback.
	if adopted_kittens:
		rest_reaction = (
			"Pantera and Galleta are asleep "
			+ "nearby. It's been a busy month. "
			+ "I'm glad they're here."
		)
	else:
		rest_reaction = (
			"I turned everything off "
			+ "and got comfortable. "
			+ "What a month."
		)

	return {
		"id": "fry_day30_final_evening",
		"emotion": "tired" if unpaid_total > 0.0 else "soft",
		"speaker": "FRY",
		"message": message,
		"choices": [
			{
				"text": "Plan next month's bills - $0",
				"energy": -5,
				"mood": 4,
				"set_flag": "day30_planned_next_month",
				"flag_value": true,
				"reaction": plan_reaction
			},
			{
				"text": "Text Dulce and Steve - $0",
				"reaction_emotion": "soft",
				"energy": -2,
				"mood": 5,
				"set_flag": "day30_texted_friends",
				"flag_value": true,
				"reaction": friends_reaction
			},
			{
				"text": "Wind down at home - $0",
				"reaction_emotion": "tired",
				"energy": 8,
				"mood": 3,
				"set_flag": "day30_rest",
				"flag_value": true,
				"reaction": rest_reaction
			}
		]
	}

#endregion


#region Fry - Day 27 Kitten Visit

var day27_kitten_visit_lines: Array[Dictionary] = []


func start_day27_kitten_visit_story() -> void:
	# Reuse the existing bedroom guest positioning.
	show_day5_party_guests()

	day27_kitten_visit_lines = [
		{
			"speaker": "FRY",
			"message": (
				"Steve and Dulce came over to meet "
				+ "Pantera and Galleta!"
			)
		},
		{
			"speaker": "DULCE",
			"emotion": "excited",
			"message": (
				"Aww, they're so adorable! "
				+ "I wish I had pets, but my "
				+ "roommate is allergic."
			)
		},
		{
			"speaker": "FRY",
			"message": (
				"That's a shame. They're "
				+ "really fun to have around."
			)
		},
		{
			"speaker": "DULCE",
			"emotion": "nervous",
			"message": (
				"[shake rate=18 level=4]Maybe... if you're okay with it,[/shake] "
				+ "I could come by every other day "
				+ "to... see the kittens?"
			)
		},
		{
			"speaker": "FRY",
			"emotion": "nervous",
			"message": (
				"[shake rate=22 level=5]Yeah, I'd love— I mean,[/shake] "
				+ "THEY'D love that for sure!"
			)
		},
		{
			"speaker": "STEVE",
			"message": "..."
		},
		{
			"speaker": "FRY",
			"message": "..."
		},
		{
			"speaker": "DULCE",
			"message": "..."
		},
		{
			"speaker": "STEVE",
			"emotion": "dramatic",
			"message": (
				"Okay, why are we all quiet? "
				+ "And where's MY invitation? "
				+ "I love the kittens too!"
			)
		},
		{
			"speaker": "FRY",
			"message": (
				"You're invited too, Steve! "
				+ "Just text me before either "
				+ "of you comes over."
			)
		},
		{
			"speaker": "DULCE",
			"emotion": "soft",
			"message": "Will do!"
		},
		{
			"speaker": "STEVE",
			"emotion": "dramatic",
			"message": (
				"I'm just gonna "
				+ "[wave amp=12 freq=5]show up like a ninja.[/wave]"
			)
		},
		{
			"speaker": "FRY",
			"message": (
				"Of course you are."
			)
		}
	]

	event_state = "day27_kitten_visit_line"
	next_day_button.hide()
	show_next_day27_kitten_visit_line()


func show_next_day27_kitten_visit_line() -> void:
	if not day27_kitten_visit_lines.is_empty():
		var line: Dictionary = (
			day27_kitten_visit_lines.pop_front()
		)

		dialogue_manager.show_dialogue(
			str(line.get("speaker", "FRY")),
			str(line.get("message", "")),
			["Continue"],
			str(line.get("emotion", "neutral"))
		)
		return

	# End the scene after Steve's final joke.
	story_flags["day27_kitten_visit_seen"] = true

	event_state = ""
	dialogue_manager.close_dialogue()

	reset_speaker_effects()
	steve_campus.hide()
	dulce_campus.hide()

	# Continue naturally to Day 28 Morning.
	advance_time(true)

#endregion


#region Fry - Movie Night

# A unique social event on Day 10 Evening, before the Day 12 exam.
# Film dialogue, friendship reactions, and theater presentation are Fry-only.
const MOVIE_TICKET_COST: float = 22.0
const MOVIE_STUDY_ENERGY_COST: int = 25
const MOVIE_STUDY_BONUS: int = 2

var movie_route: String = ""
var movie_lines: Array[Dictionary] = []

const CINEMA_BACKGROUNDS = {
	"steve": preload("res://Images/Backgrounds/Cinema/cinema_fry_steve.png"),
	"dulce": preload("res://Images/Backgrounds/Cinema/cinema_fry_dulce.png"),
	"both": preload("res://Images/Backgrounds/Cinema/cinema_fry_steve_dulce.png")
}

var cinema_set: TextureRect

# Subtitle panel shown on the theater screen only for movie characters.
var cinema_subtitle_panel: PanelContainer
var cinema_subtitle_speaker: Label
var cinema_subtitle_text: Label
var cinema_subtitle_continue: Button

var original_campus_backdrop_color: Color

# Restore the ordinary dialogue placement after leaving the cinema.
var dialogue_default_position: Vector2 = Vector2.ZERO



func build_cinema_background() -> void:
	original_campus_backdrop_color = campus_backdrop.color

	cinema_set = TextureRect.new()
	cinema_set.name = "CinemaSet"

	cinema_set.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cinema_set.stretch_mode = TextureRect.STRETCH_SCALE
	cinema_set.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cinema_set.mouse_filter = Control.MOUSE_FILTER_IGNORE

	campus_backdrop.add_child(cinema_set)
	cinema_set.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# The art is 1920x1080. Place subtitles inside the blank movie screen.
	# The screen occupies roughly X 456-1465 / Y 122-540.
	cinema_subtitle_panel = PanelContainer.new()
	cinema_subtitle_panel.name = "CinemaSubtitlePanel"
	cinema_subtitle_panel.position = Vector2(495, 337)
	cinema_subtitle_panel.custom_minimum_size = Vector2(930, 180)
	cinema_subtitle_panel.size = Vector2(930, 180)
	cinema_subtitle_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	cinema_set.add_child(cinema_subtitle_panel)

	var subtitle_style := StyleBoxFlat.new()
	subtitle_style.bg_color = Color(0.075, 0.085, 0.12, 0.93)
	subtitle_style.border_color = Color("#65768B")
	subtitle_style.set_border_width_all(2)
	subtitle_style.set_corner_radius_all(10)
	subtitle_style.shadow_color = Color(0, 0, 0, 0.38)
	subtitle_style.shadow_size = 5
	cinema_subtitle_panel.add_theme_stylebox_override("panel", subtitle_style)

	var subtitle_margin := MarginContainer.new()
	for side in ["left", "right"]:
		subtitle_margin.add_theme_constant_override("margin_" + side, 16)
	for side in ["top", "bottom"]:
		subtitle_margin.add_theme_constant_override("margin_" + side, 10)
	cinema_subtitle_panel.add_child(subtitle_margin)

	var subtitle_column := VBoxContainer.new()
	subtitle_column.add_theme_constant_override("separation", 6)
	subtitle_margin.add_child(subtitle_column)

	cinema_subtitle_speaker = Label.new()
	cinema_subtitle_speaker.add_theme_font_size_override("font_size", 18)
	cinema_subtitle_speaker.add_theme_color_override("font_color", Color("#EBC477"))
	subtitle_column.add_child(cinema_subtitle_speaker)

	cinema_subtitle_text = Label.new()
	cinema_subtitle_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cinema_subtitle_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cinema_subtitle_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cinema_subtitle_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cinema_subtitle_text.add_theme_font_size_override("font_size", 23)
	cinema_subtitle_text.add_theme_color_override("font_color", Color("#F4F1EA"))
	subtitle_column.add_child(cinema_subtitle_text)

	cinema_subtitle_continue = Button.new()
	cinema_subtitle_continue.text = "Continue"
	cinema_subtitle_continue.custom_minimum_size = Vector2(0, 40)
	cinema_subtitle_continue.add_theme_font_size_override("font_size", 19)
	cinema_subtitle_continue.add_theme_color_override("font_color", Color("#F4F1EA"))
	cinema_subtitle_continue.add_theme_color_override("font_hover_color", Color.WHITE)
	var continue_style := StyleBoxFlat.new()
	continue_style.bg_color = Color("#405C70")
	continue_style.set_corner_radius_all(7)
	cinema_subtitle_continue.add_theme_stylebox_override("normal", continue_style)
	var hover_style := continue_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color("#52748A")
	cinema_subtitle_continue.add_theme_stylebox_override("hover", hover_style)
	var pressed_style := continue_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = Color("#304756")
	cinema_subtitle_continue.add_theme_stylebox_override("pressed", pressed_style)
	
	# Subtle focus indicator instead of Godot's white outline.
	var focus_style := StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.border_color = Color("#52748A")
	focus_style.set_border_width_all(1)
	focus_style.set_corner_radius_all(7)

	cinema_subtitle_continue.add_theme_stylebox_override("focus", focus_style)

	subtitle_column.add_child(cinema_subtitle_continue)
	cinema_subtitle_continue.pressed.connect(_on_cinema_subtitle_continue_pressed)

	cinema_subtitle_panel.hide()
	cinema_set.hide()


func show_cinema_subtitle(speaker: String, message: String) -> void:
	cinema_subtitle_speaker.text = speaker
	cinema_subtitle_text.text = message
	cinema_subtitle_panel.show()


func hide_cinema_subtitle() -> void:
	cinema_subtitle_panel.hide()


func _on_cinema_subtitle_continue_pressed() -> void:
	# The same movie_line sequence is used by both dialogue styles.
	if current_location == "cinema" and event_state == "movie_line":
		show_next_movie_line()


func start_movie_night() -> void:
	movie_route = ""
	movie_lines.clear()
	event_state = "movie_intro"
	next_day_button.hide()
	dialogue_manager.show_dialogue(
		"FRY",
		"There are some new movies out tonight. I could use a break... "
		+ "but my exam is in two days. What should I do?",
		["Go to the movies - $22", "Stay home and study (2x)", "Stay home and rest"]
	)


func choose_movie_night_plan(index: int) -> void:
	match index:
		0:
			if money < MOVIE_TICKET_COST:
				show_movie_option_unavailable(
					"Tickets and snacks would cost $22. I don't have enough for that."
				)
				return
			show_movie_invitation()

		1:
			if exam_completed or study_sessions >= 4:
				show_movie_option_unavailable(
					"I've already prepared as much as I can for this exam. "
					+ "Maybe I should do something else tonight."
				)
				return
			if last_study_day == DayManager.current_day:
				show_movie_option_unavailable(
					"I already studied today. I need to give my brain a break."
				)
				return
			if energy < MOVIE_STUDY_ENERGY_COST:
				show_movie_option_unavailable(
					"I can't focus for a long study session with this little Energy."
				)
				return

			study_sessions += MOVIE_STUDY_BONUS
			last_study_day = DayManager.current_day
			change_energy(-MOVIE_STUDY_ENERGY_COST)
			change_mood(-3)
			activity_history.append({
				"day": DayManager.current_day,
				"period": DayManager.get_period(),
				"activity": "movie_night_double_study"
			})
			show_movie_home_result(
				"That was intense, but I got two study sessions' worth of "
				+ "preparation done. I'll catch a movie another time."
			)

		2:
			change_energy(20)
			change_mood(2)
			show_movie_home_result(
				"The movie can wait. A quiet evening was exactly what I needed."
			)


func show_movie_option_unavailable(message: String) -> void:
	event_state = "movie_option_unavailable"
	dialogue_manager.show_dialogue("FRY", message, ["Choose again"])


func show_movie_invitation() -> void:
	event_state = "movie_invite"
	dialogue_manager.show_dialogue(
		"FRY",
		"Alright, a night at the movies sounds good. Who should I invite?",
		["Steve", "Dulce", "Both"]
	)


func choose_movie_companion(index: int) -> void:
	var routes: Array[String] = ["steve", "dulce", "both"]
	if index < 0 or index >= routes.size():
		return
	if money < MOVIE_TICKET_COST:
		show_movie_option_unavailable("I can't afford the movie tonight after all.")
		return

	movie_route = routes[index]
	story_flags["movie_with_" + movie_route] = true

	var company: String = "Steve and Dulce" if movie_route == "both" else movie_route.capitalize()
	change_money(-MOVIE_TICKET_COST, "Movie night with " + company, "Entertainment")
	change_energy(-9 if movie_route == "both" else -7)
	change_mood(16 if movie_route == "both" else (14 if movie_route == "dulce" else 12))

	# Display the background matching Fry's invited companion.
	cinema_set.texture = CINEMA_BACKGROUNDS[movie_route]

	movie_lines = get_movie_dialogue(movie_route)
	event_state = "movie_travel"
	next_day_button.hide()
	dialogue_manager.close_dialogue()
	await fade_to_location("cinema")
	show_next_movie_line()


func get_movie_dialogue(route: String) -> Array[Dictionary]:
	match route:
		"steve":
			return [
				{"speaker": "STEVE", "emotion": "excited", "message": "[wave amp=8 freq=4]Shark Attack![/wave] Finally, a movie with some real cinema."},
				{"speaker": "FRY", "message": "You haven't even seen it yet."},
				{"speaker": "MOVIE CAPTAIN", "message": "GET OFF THE BOAT! THERE'S SOMETHING UNDERNEATH US!"},
				{"speaker": "MOVIE SAILOR", "message": "CAPTAIN! WE LOST THE ENGINE!"},
				{"speaker": "STEVE", "emotion": "angry", "message": "Bro, [shake rate=16 level=3]WHY[/shake] would you stay on the boat?!"},
				{"speaker": "FRY", "message": "What would you do? Swim? There's like 12 sharks!"},
				{"speaker": "STEVE", "emotion": "dramatic", "message": "I'd simply [wave amp=9 freq=4]defeat them.[/wave]"},
				{"speaker": "FRY", "message": "Oh yeah, my bad. Didn't realize I invited Aquaman."}
			]
		"dulce":
			return [
				{"speaker": "DULCE", "emotion": "excited", "message": "A mystery? Good choice. I've already got three theories."},
				{"speaker": "FRY", "message": "The opening credits aren't even over."},
				{"speaker": "MOVIE DETECTIVE", "message": "I know who's responsible. The only witness who never changed their story... was you."},
				{"speaker": "MOVIE SUSPECT", "message": "You can't prove a thing!"},
				{"speaker": "DULCE", "emotion": "excited", "message": "[wave amp=7 freq=4]I knew it![/wave] I called that twenty minutes ago."},
				{"speaker": "FRY", "message": "You also accused the dog."},
				{"speaker": "DULCE", "message": "He looked suspicious."},
				{"speaker": "DULCE", "emotion": "soft", "message": "I'm glad you asked me, by the way. It's nice hanging out when we're not rushing to class."},
				{"speaker": "FRY", "emotion": "nervous", "message": "[shake rate=12 level=2]Yeah...[/shake] I was hoping you'd say yes."},
				{"speaker": "DULCE", "emotion": "soft", "message": "Well, maybe ask me again sometime."}
			]
		"both":
			return [
				{"speaker": "MOVIE DUM DUM 1", "message": "Alright, who's the genius that locked us in here?!"},
				{"speaker": "MOVIE DUM DUM 2", "message": "I don't know! I thought YOU had the key!"},
				{"speaker": "MOVIE DUM DUM 3", "message": "What key? I thought we were looking for the door!"},
				{"speaker": "MOVIE DUM DUM 1", "message": "WE'RE STANDING NEXT TO IT!"},
				{"speaker": "STEVE", "message": "I'm not gonna lie, I'd probably be the third guy."},
				{"speaker": "DULCE", "message": "Probably?"},
				{"speaker": "FRY", "message": "Nah, Steve's the first guy. He'd lock us in there."},
				{"speaker": "STEVE", "emotion": "dramatic", "message": "[shake rate=14 level=3]WOW.[/shake] This is how you treat the person who invited you?"},
				{"speaker": "DULCE", "message": "Fry invited us."},
				{"speaker": "STEVE", "emotion": "soft", "message": "...Oh."}
			]
	return []


func show_next_movie_line() -> void:
	if movie_lines.is_empty():
		hide_cinema_subtitle()
		event_state = "movie_wrapup"
		var closing: String = ""
		match movie_route:
			"steve":
				closing = "I'm glad I invited Steve. That movie was ridiculous, in the best way."
			"dulce":
				closing = "I think I liked the company even more than the movie..."
			"both":
				closing = "My face hurts from laughing. We should do this again sometime."
		dialogue_manager.show_dialogue(
			"FRY", closing, ["Head home"],
			"soft" if movie_route == "dulce" else "neutral"
		)
		return

	var line: Dictionary = movie_lines.pop_front()
	var speaker: String = str(line.get("speaker", "FRY"))
	var message: String = str(line.get("message", ""))
	event_state = "movie_line"

	if speaker.begins_with("MOVIE "):
		# Movie actors speak inside the projected screen.
		dialogue_manager.close_dialogue()
		show_cinema_subtitle(speaker, message)
	else:
		# Fry, Dulce, and Steve use the regular dialogue box.
		hide_cinema_subtitle()
		dialogue_manager.show_dialogue(
			speaker, message, ["Continue"],
			str(line.get("emotion", "neutral"))
		)


func show_movie_home_result(message: String) -> void:
	event_state = "movie_home_result"
	dialogue_manager.show_dialogue("FRY", message, ["Continue"], "soft")


func finish_movie_night() -> void:
	event_state = "movie_return"
	hide_cinema_subtitle()
	dialogue_manager.close_dialogue()
	if current_location == "cinema":
		await fade_to_location("bedroom")
	event_state = ""
	advance_time(false)

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
@onready var classroom_set: TextureRect = $CampusBackdrop/ClassroomSet
@onready var bedroom_camera: Camera2D = $Camera2D

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


#region Fry - Bedroom Movement

# Fry walks along one horizontal floor. The cinema and campus use their
# existing fixed character positions. World coordinates match 1920x1080 art.
const FRY_BEDROOM_WALK_SPEED: float = 400.0
const FRY_BEDROOM_EDGE_PADDING: float = 80.0
const FRY_BEDROOM_COLLISION_LAYER: int = 1 << 9 # Layer 10, Fry-only.

var fry_bedroom_min_x: float = 0.0
var fry_bedroom_max_x: float = 0.0

var fry_room_body: CharacterBody2D
var fry_default_flip_h: bool = false
var fry_bedroom_flip_h: bool = false
var steve_default_flip_h: bool = false


func build_fry_bedroom_collision() -> void:
	# Keep Fry as Sprite2D for existing dialogue and story systems.
	# A separate physics body handles bedroom movement.
	fry_room_body = CharacterBody2D.new()
	fry_room_body.name = "FryBedroomMovementBody"
	fry_room_body.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	fry_room_body.collision_layer = FRY_BEDROOM_COLLISION_LAYER
	fry_room_body.collision_mask = FRY_BEDROOM_COLLISION_LAYER
	add_child(fry_room_body)

	# Calculate Fry's size.
	var visual_width: float = fry_sprite.get_rect().size.x * absf(fry_sprite.scale.x)
	var visual_height: float = fry_sprite.get_rect().size.y * absf(fry_sprite.scale.y)

	# Calculate bedroom boundaries using Camera2D.
	var edge_inset: float = maxf(
		FRY_BEDROOM_EDGE_PADDING,
		visual_width * 0.5
	)

	fry_bedroom_min_x = float(bedroom_camera.limit_left) + edge_inset
	fry_bedroom_max_x = float(bedroom_camera.limit_right) - edge_inset

	# Place Fry inside the allowed movement area.
	fry_room_body.position = fry_bedroom_position
	fry_room_body.position.x = clampf(
		fry_room_body.position.x,
		fry_bedroom_min_x,
		fry_bedroom_max_x
	)

	fry_bedroom_position.x = fry_room_body.position.x
	fry_sprite.position.x = fry_room_body.position.x

	# Character collider.
	var body_width: float = clampf(visual_width * 0.45, 32.0, 80.0)
	var body_height: float = clampf(visual_height * 0.75, 48.0, 144.0)

	var character_shape := RectangleShape2D.new()
	character_shape.size = Vector2(body_width, body_height)

	var character_collider := CollisionShape2D.new()
	character_collider.name = "FryCollision"
	character_collider.shape = character_shape
	fry_room_body.add_child(character_collider)

	# Invisible walls at the bedroom edges.
	create_fry_bedroom_wall(
		fry_bedroom_min_x - body_width * 0.5 - 12.0,
		"LeftBedroomWall"
	)

	create_fry_bedroom_wall(
		fry_bedroom_max_x + body_width * 0.5 + 12.0,
		"RightBedroomWall"
	)



func create_fry_bedroom_wall(wall_x: float, wall_name: String) -> void:
	var wall := StaticBody2D.new()
	wall.name = wall_name
	wall.position = Vector2(wall_x, fry_bedroom_position.y)
	wall.collision_layer = FRY_BEDROOM_COLLISION_LAYER
	wall.collision_mask = 0
	add_child(wall)

	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(24.0, 2160.0)
	var collider := CollisionShape2D.new()
	collider.shape = rectangle
	wall.add_child(collider)


func _physics_process(_delta: float) -> void:
	if fry_room_body == null:
		return

	# Do not walk during events, dialogue, cutscenes or end-of-month UI.
	var can_walk: bool = (
		current_location == "bedroom"
		and not transitioning
		and not DayManager.finished
		and not dialogue_manager.visible
		and event_state == ""
		and active_event.is_empty()
		and period_queue.is_empty()
		and not month_recap_overlay.visible
		and not month_complete_overlay.visible
	)

	if not can_walk:
		fry_room_body.velocity = Vector2.ZERO
		room_interaction_prompt.hide()
		return

	var direction: float = 0.0
	if Input.is_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction += 1.0

	fry_room_body.velocity = Vector2(direction * FRY_BEDROOM_WALK_SPEED, 0.0)
	fry_room_body.move_and_slide()
	
	fry_room_body.position.x = clampf(
		fry_room_body.position.x,
		fry_bedroom_min_x,
		fry_bedroom_max_x
	)

	if not is_zero_approx(direction):
		fry_bedroom_flip_h = direction < 0.0
		fry_sprite.flip_h = fry_bedroom_flip_h

	# Preserve Fry's last bedroom spot when returning from campus/cinema.
	fry_sprite.position.x = fry_room_body.position.x
	fry_bedroom_position.x = fry_room_body.position.x
	
	# Follow Fry horizontally while exploring the bedroom.
	bedroom_camera.position.x = fry_room_body.position.x
	update_room_interaction_prompt()

#endregion

#region Fry - Bedroom Interaction Prompts

const ROOM_INTERACTION_RANGE: float = 150.0

var room_interaction_prompt: PanelContainer
var room_interaction_label: Label


func build_room_interaction_prompt() -> void:
	room_interaction_prompt = PanelContainer.new()
	room_interaction_prompt.name = "RoomInteractionPrompt"
	room_interaction_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1A2530")
	style.border_color = Color("#7898AC")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 7
	style.content_margin_bottom = 7

	room_interaction_prompt.add_theme_stylebox_override(
		"panel", style
	)

	room_interaction_label = Label.new()
	room_interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_interaction_label.add_theme_font_size_override("font_size", 21)
	room_interaction_label.add_theme_color_override(
		"font_color", Color("#F4F1EA")
	)
	room_interaction_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	room_interaction_prompt.add_child(room_interaction_label)
	$UI/HUD.add_child(room_interaction_prompt)
	room_interaction_prompt.hide()


func get_room_area_center_x(area: Area2D) -> float:
	# Use the existing click target's collision shape as its center.
	for child in area.get_children():
		if child is CollisionShape2D:
			return child.global_position.x

	return area.global_position.x


func get_nearby_room_activity() -> String:
	if not can_use_room_activity():
		return ""

	if dialogue_manager.visible:
		return ""

	var fry_x: float = fry_sprite.global_position.x

	var bed_distance: float = absf(
		fry_x - get_room_area_center_x(bed_area)
	)

	var desk_distance: float = absf(
		fry_x - get_room_area_center_x(desk_area)
	)

	if bed_distance <= ROOM_INTERACTION_RANGE:
		if bed_distance <= desk_distance:
			return "sleep"

	if desk_distance <= ROOM_INTERACTION_RANGE:
		return "study"

	return ""


func update_room_interaction_prompt() -> void:
	# Never show the prompt during dialogue or an event.
	if dialogue_manager.visible or not can_use_room_activity():
		room_interaction_prompt.hide()
		return

	var activity: String = get_nearby_room_activity()

	if activity.is_empty():
		room_interaction_prompt.hide()
		return

	if activity == "sleep":
		room_interaction_label.text = "[E] Use Bed"
	else:
		room_interaction_label.text = "[E] Study at Desk"

	room_interaction_prompt.show()
	room_interaction_prompt.reset_size()

	# Keep the prompt near the bottom center of the screen,
	# independently of Fry's position and camera movement.
	var hud_size: Vector2 = $UI/HUD.size

	room_interaction_prompt.position = Vector2(
		(hud_size.x - room_interaction_prompt.size.x) * 0.5,
		hud_size.y - 210.0
	)


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return

	var key_event: InputEventKey = event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode != KEY_E and key_event.physical_keycode != KEY_E:
		return

	var activity: String = get_nearby_room_activity()

	if activity.is_empty():
		return

	room_interaction_prompt.hide()
	show_room_activity(activity)
	get_viewport().set_input_as_handled()

#endregion


#region Fry - Initialization

func _ready() -> void:
	# Remember how the characters look normally.
	fry_bedroom_position = fry_sprite.position
	fry_normal_scale = fry_sprite.scale
	dulce_normal_scale = dulce_campus.scale
	steve_normal_scale = steve_campus.scale
	dialogue_default_position = dialogue_manager.position
	fry_default_flip_h = fry_sprite.flip_h
	fry_bedroom_flip_h = fry_sprite.flip_h
	steve_default_flip_h = steve_campus.flip_h
	
	build_fry_bedroom_collision()
	build_room_interaction_prompt()
	
	bedroom_camera.position.x = fry_room_body.position.x
	bedroom_camera.reset_smoothing()
	
	campus_backdrop.hide()
	dulce_campus.hide()
	steve_campus.hide()
	build_cinema_background()
	screen_fade.color = Color.BLACK
	screen_fade.modulate.a = 0.0
	screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# The full-screen HUD must not swallow clicks meant for bedroom objects.
	# Child buttons and the visible dialogue panel keep their own input filters.
	$UI/HUD.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	DayManager.reset_calendar()
	
	#=========================== DEBUG ======================================== #
	# DAY DEBUG: Choose which day and period to start on. DEVELOPER DELETE
	#DayManager.current_day = 1
	#DayManager.period_index = 3
	#DayManager.isWeekend = DayManager.is_weekend_day(DayManager.current_day)
	## Register the special Night period.
	#DayManager.schedule_night_for_day(27)
#
	## Ensure the kitten visit takes place.
	#story_flags["day21_kittens_adopted"] = true
	#story_flags["day27_kitten_visit_seen"] = false
	#=========================== DEBUG ======================================== #

	fry_random_rng.randomize()
	fry_random_uses.clear()
	fry_random_last_day.clear()
	fry_last_random_day = -100
	fry_last_small_event_line.clear()

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
			change_mood(-3) # Stress from missing the payment.
			
			period_queue.append({
				"type": "notice",
				"speaker": "BILL ALERT",
				"message": "%s is overdue. A $%.2f late fee was added." % [str(bill["name"]), fee]
			})
		
		# Offer payment on the due date, later paydays, and the last day of the month.
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
				["Continue"],
				str(item.get("emotion", "neutral"))
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
		# Show the bill information first.
		# The shortfall is revealed in separate dialogue.
		event_state = "bill_shortfall_intro"
		dialogue_manager.show_dialogue(
			"FRY",
			message,
			["Continue"]
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
	var bill_items: Array[Dictionary] = []

	# Send due dates and readable countdowns to the Finances app.
	for bill_id in bills.keys():
		var bill: Dictionary = bills[bill_id]
		var days_left: int = int(bill["due_day"]) - DayManager.current_day
		var paid: bool = bool(bill["paid"])
		var due_text: String = ""

		if paid:
			due_text = "Paid"
		elif days_left > 0:
			due_text = "Due in %d %s" % [
				days_left,
				"day" if days_left == 1 else "days"
			]
		elif days_left == 0:
			due_text = "Due today"
		else:
			due_text = "Overdue by %d %s" % [
				abs(days_left),
				"day" if abs(days_left) == 1 else "days"
			]

		bill_items.append({
			"id": str(bill_id),
			"name": str(bill["name"]),
			"amount": float(bill["amount"]),
			"due_day": int(bill["due_day"]),
			"days_until_due": days_left,
			"paid": paid,
			"status": due_text
		})

	bill_items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["due_day"]) < int(b["due_day"])
	)

	return {
		"balance": money,
		"income": total_income,
		"spending": total_spending,
		"unpaid_bills": unpaid,
		"after_bills": money - unpaid,
		"transactions": finance_history.duplicate(true),
		"bills": bill_items
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


func customize_fry_shared_small_event() -> void:
	var event_id: String = str(active_event.get("id", ""))
	var choices: Array = active_event.get("choices", [])

	match event_id:
		"wishlist_sale":
			if choices.size() < 1:
				return

			var sale_price: int = fry_random_rng.randi_range(12, 28)

			active_event["message"] = fry_small_event_line(event_id, [
				"Something on my wishlist is on sale for $%d. Do I get it?",
				"Oh, that thing I wanted is only $%d right now. Is it really worth buying?",
				"A $%d sale price sounds tempting, but I've got bills to think about."
			]) % sale_price

			var buy_choice: Dictionary = choices[0]
			buy_choice["text"] = "Buy it - $%d" % sale_price
			buy_choice["money"] = -sale_price
			buy_choice["finance_label"] = "Wishlist sale purchase"
			buy_choice["finance_category"] = "Shopping"

			choices[0] = buy_choice
			active_event["choices"] = choices

		"small_refund":
			if choices.size() < 2:
				return

			var refund_amount: int = fry_random_rng.randi_range(15, 35)
			var spend_amount: int = int(round(float(refund_amount) * 0.80))
			var net_amount: int = refund_amount - spend_amount

			active_event["message"] = fry_small_event_line(event_id, [
				"A $%d refund just arrived. Nice! What should I do with it?",
				"Huh, I got $%d back from a store. That's a nice surprise.",
				"Wait, is that a $%d refund? I wasn't expecting that today."
			]) % refund_amount

			var keep_choice: Dictionary = choices[0]
			keep_choice["text"] = "Keep the $%d" % refund_amount
			keep_choice["money"] = refund_amount
			keep_choice["finance_label"] = "Small store refund"
			keep_choice["finance_category"] = "Refund"
			choices[0] = keep_choice

			var spend_choice: Dictionary = choices[1]
			spend_choice["text"] = "Spend $%d of it (keep $%d)" % [spend_amount, net_amount]
			spend_choice["money"] = net_amount
			spend_choice["reaction"] = "A little treat, and I still have $%d left." % net_amount
			spend_choice["finance_label"] = "Refund after small treat"
			spend_choice["finance_category"] = "Refund"
			choices[1] = spend_choice

			active_event["choices"] = choices


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
			if exam_completed:
				show_room_activity_unavailable(
					"My exam is already over. I don't need to study for it anymore."
				)
				return

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
			if exam_completed:
				show_room_activity_unavailable(
					"The exam is over. I'll focus on something else."
				)
				return

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
	
	# Day 27: schedule the kitten visit before updating
	# the UI so the button correctly displays TO NIGHT.
	if (
		DayManager.current_day == 27
		and DayManager.get_period() == "Evening"
		and bool(story_flags.get("day21_kittens_adopted", false))
		and not bool(story_flags.get("day27_kitten_visit_seen", false))
	):
		DayManager.schedule_night_for_day(27)

	# Party guests leave when the next bedroom period begins.
	if current_location == "bedroom":
		dulce_campus.hide()
		steve_campus.hide()
		steve_campus.flip_h = steve_default_flip_h

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

	# Day 18 Morning: optional update about
	# the two kitten sisters from Day 13.
	if (
		DayManager.current_day == 18
		and DayManager.get_period() == "Morning"
		and not bool(story_flags.get("day18_kitten_update_seen", false))
		and (
			bool(story_flags.get("day13_volunteered", false))
			or bool(story_flags.get("day13_adoption_posted", false))
		)
	):
		story_flags["day18_kitten_update_seen"] = true

		period_queue.append({
			"type": "notice",
			"speaker": "DULCE",
			"emotion": "soft",
			"message": (
				"The black kitten and her gray sister "
				+ "are still together at the animal shelter. "
				+ "They're doing well, but still need a home."
			)
		})

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

	# Day 29 Morning: follow up on Fry's internship work.
	if (
		DayManager.current_day == 29
		and DayManager.get_period() == "Morning"
		and not bool(story_flags.get(
			"day29_internship_update_seen", false
		))
	):
		var internship_message: String = ""
		var internship_speaker: String = "FRY"

		if bool(story_flags.get(
			"day27_screening_submitted", false
		)):
			internship_speaker = "INBOX"
			internship_message = (
				"The internship team received my "
				+ "screening task. They're reviewing it!"
			)

		elif (
			bool(story_flags.get(
				"day27_sample_polished", false
			))
			or bool(story_flags.get(
				"day27_sample_sent", false
			))
		):
			internship_speaker = "INBOX"
			internship_message = (
				"The internship team confirmed "
				+ "they received my work sample."
			)

		elif bool(story_flags.get(
			"day27_late_application", false
		)):
			internship_speaker = "INBOX"
			internship_message = (
				"My internship application was "
				+ "received. Now I wait!"
			)

		elif bool(story_flags.get(
			"day27_requested_more_time", false
		)):
			internship_message = (
				"No reply yet about getting more "
				+ "time. I should follow up."
			)

		elif (
			bool(story_flags.get(
				"day27_screening_started", false
			))
			or bool(story_flags.get(
				"day27_prepared_application", false
			))
		):
			internship_message = (
				"I still need to finish my "
				+ "internship application work."
			)

		if not internship_message.is_empty():
			story_flags["day29_internship_update_seen"] = true

			period_queue.append({
				"type": "notice",
				"speaker": internship_speaker,
				"emotion": "nervous" if internship_speaker == "FRY" else "neutral",
				"message": internship_message
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
	# Day 1: introduce budgeting without consuming the Evening.
	if key == "1_Evening" and not bool(
		story_flags.get("day1_evening_seen", false)
	):
		scheduled = make_day1_first_night_event()

	# Day 2: a short college assignment story.
	# Show it once, without consuming the Evening.
	if key == "2_Evening" and not bool(
		story_flags.get("day2_evening_seen", false)
	):
		scheduled = make_day2_late_night_assignment_event()

	# Day 4: follow up on the campus club fair.
	# This event is shown once and does not consume Evening.
	if key == "4_Evening" and not bool(
		story_flags.get("day4_evening_seen", false)
	):
		scheduled = make_day4_after_fair_event()

	# Day 6: follow up on the previous night's decision.
	# Show once, then allow the normal random encounter roll.
	if key == "6_Evening" and not bool(
		story_flags.get("day6_evening_seen", false)
	):
		scheduled = make_day6_morning_after_event()

	# Day 7: first paycheck spending decision.
	# The automatic paycheck already arrived in the Morning.
	if key == "7_Evening" and not bool(
		story_flags.get("day7_evening_seen", false)
	):
		scheduled = make_day7_payday_temptation_event()

	# Day 8: optional study call after the textbook campus trip.
	if key == "8_Evening" and not bool(
		story_flags.get("day8_evening_seen", false)
	):
		scheduled = make_day8_study_group_event()

	# Day 9: a student-run campus food pantry.
	if key == "9_Evening" and not bool(
		story_flags.get("day9_evening_seen", false)
	):
		scheduled = make_day9_campus_pantry_event()

	# Day 11: the night before Fry's first exam.
	if key == "11_Evening" and not bool(
		story_flags.get("day11_evening_seen", false)
	):
		scheduled = make_day11_last_minute_studying_event()

	# Day 12: react to the exam result after the
	# existing result notification has been shown.
	if (
		key == "12_Evening"
		and exam_completed
		and not bool(story_flags.get("day12_evening_seen", false))
	):
		scheduled = make_day12_after_exam_event()

	# Day 13: optional animal shelter community event.
	# Fry may contribute money, time, or creative skills.
	if key == "13_Evening" and not bool(
		story_flags.get("day13_evening_seen", false)
	):
		scheduled = make_day13_animal_shelter_event()

	# Day 14: family check-in after the second payday.
	if key == "14_Evening" and not bool(
		story_flags.get("day14_evening_seen", false)
	):
		scheduled = make_day14_family_checkin_event()

	# Day 15: prepare for the new group presentation.
	if key == "15_Evening" and not bool(
		story_flags.get("day15_evening_seen", false)
	):
		scheduled = make_day15_new_assignment_event()

	# Day 16: unexpected invitation from Steve and Dulce.
	if key == "16_Evening" and not bool(
		story_flags.get("day16_evening_seen", false)
	):
		scheduled = make_day16_unexpected_invitation_event()

	# Day 16: remember how Fry prepared for the presentation.
	# Change only the introduction, not the costs or options.
	if key == "16_Afternoon" and scheduled is Dictionary:
		scheduled = scheduled.duplicate(true)

		if bool(story_flags.get("day15_started_slides", false)):
			scheduled["message"] = (
				"The slides I drafted last night are ready! "
				+ "Now I need to prepare the handouts. "
				+ "Which option should I use?"
			)

		elif bool(story_flags.get("day15_project_budget", false)):
			scheduled["message"] = (
				"I made a budget for this presentation. "
				+ "Now I need handouts. Should I spend "
				+ "extra on printing or go digital?"
			)

		elif bool(story_flags.get("day15_split_tasks", false)):
			scheduled["message"] = (
				"Dulce and Steve are working on their "
				+ "parts of the presentation. Handouts "
				+ "are my responsibility. What should I do?"
			)

	# Day 18: community shelter support.
	if key == "18_Evening" and not bool(
		story_flags.get("day18_evening_seen", false)
	):
		scheduled = make_day18_homeless_shelter_event()

	# Day 19: respond to Fry's actual school bill.
	if key == "19_Evening":
		if bool(story_flags.get("day19_evening_seen", false)):
			scheduled = null

		elif scheduled is Dictionary:
			scheduled = scheduled.duplicate(true)

			var school_bill: Dictionary = bills.get("school", {})
			var school_amount: float = float(
				school_bill.get("amount", 150.0)
			)

			if bool(school_bill.get("paid", false)):
				scheduled["message"] = (
					"My school payment's covered. "
					+ "A rush job popped up tonight. "
					+ "Should I take it?"
				)

			elif money >= school_amount:
				scheduled["message"] = (
					"My school payment is due tomorrow, "
					+ "but I have enough saved. "
					+ "Should I earn more?"
				)

			else:
				var shortfall: float = school_amount - money
				scheduled["message"] = (
					"School payment's due tomorrow. "
					+ "I'm $%.2f short. What should I do?"
				) % shortfall

	# Day 21 Morning: optional kitten adoption.
	# Financial notifications and bill payments run first.
	if (
		key == "21_Morning"
		and not bool(story_flags.get("day21_kitten_decision_seen", false))
		and (
			bool(story_flags.get("day13_volunteered", false))
			or bool(story_flags.get("day13_adoption_posted", false))
		)
	):
		scheduled = make_day21_kitten_adoption_event()

	# Day 21 Evening: Steve needs help.
	if key == "21_Evening" and not bool(
		story_flags.get("day21_friend_event_seen", false)
	):
		scheduled = make_day21_friend_help_event()

	# Day 22: virtual office hours after the bookstore shift.
	if key == "22_Evening" and not bool(
		story_flags.get("day22_evening_seen", false)
	):
		scheduled = make_day22_professor_event()

	# Day 24 Afternoon: paid internship opportunity.
	if key == "24_Afternoon" and not bool(
		story_flags.get("day24_afternoon_seen", false)
	):
		scheduled = make_day24_internship_event()

	# Day 27 Morning: respond to the internship email.
	if (
		key == "27_Morning"
		and not bool(story_flags.get("day27_internship_seen", false))
		and (
			bool(story_flags.get("day24_portfolio_applied", false))
			or bool(story_flags.get("day24_quick_applied", false))
			or bool(story_flags.get("day24_saved_listing", false))
		)
	):
		scheduled = make_day27_internship_followup_event()

	# Day 27 Evening: caring for the adopted kittens.
	# Players without the kittens keep normal free time.
	if (
		key == "27_Evening"
		and bool(story_flags.get("day21_kittens_adopted", false))
		and not bool(story_flags.get("day27_pet_care_seen", false))
	):
		scheduled = make_day27_pet_care_event()

	# Day 28 Evening: final paycheck decisions.
	# The actual paycheck was already added in Morning.
	if key == "28_Evening" and not bool(
		story_flags.get("day28_evening_seen", false)
	):
		scheduled = make_day28_final_paycheck_event()

	# Day 30: Fry's final evening reflection.
	if key == "30_Evening" and not bool(
		story_flags.get("day30_evening_seen", false)
	):
		scheduled = make_day30_final_evening_event()

	# Day 27: optional kitten visit with Steve and Dulce.
	if key == "27_Night":
		if (
			bool(story_flags.get("day21_kittens_adopted", false))
			and not bool(story_flags.get(
				"day27_kitten_visit_seen", false
			))
		):
			start_day27_kitten_visit_story()
		else:
			# Safeguard for direct debug jumps to Night.
			event_state = ""
			advance_time(true)
		return

	# Day 5: a special Evening invitation and Night event.
	if key == "5_Evening":
		scheduled = make_day5_party_invitation_event()

	elif key == "5_Night":
		if bool(story_flags.get("day5_party_invited", false)):
			start_day5_party_story()
			return

		scheduled = make_day5_quiet_night_event()

	# Day 10: Movie Night is always a player-initiated choice.
	# It runs before the regular random events and never overwrites other days.
	if key == "10_Evening":
		start_movie_night()
		return


	# Day 29: catch up with Dulce.
	# Remember the kitten visit and movie night.
	if key == "29_Evening":
		if bool(story_flags.get(
			"day29_evening_seen", false
		)):
			scheduled = null

		elif scheduled is Dictionary:
			scheduled = scheduled.duplicate(true)

			var kitten_visit: bool = (
				bool(story_flags.get(
					"day21_kittens_adopted", false
				))
				and bool(story_flags.get(
					"day27_kitten_visit_seen", false
				))
			)

			# The kitten visit takes priority.
			if kitten_visit:
				scheduled["emotion"] = "nervous"
				scheduled["message"] = (
					"Hey, Fry! How are Pantera and "
					+ "Galleta? I was thinking we "
					+ "could hang out again... "
					+ "[shake rate=12 level=2]if you're free?[/shake]"
				)

			elif bool(story_flags.get(
				"movie_with_dulce", false
			)):
				scheduled["message"] = (
					"Hey, Fry! I've been thinking "
					+ "about that mystery movie. "
					+ "Want to catch up tonight?"
				)

			elif bool(story_flags.get(
				"movie_with_both", false
			)):
				scheduled["message"] = (
					"Fry! Steve still won't stop "
					+ "quoting The Three Dum Dums. "
					+ "Want to catch up tonight?"
				)

			var choices: Array = scheduled.get(
				"choices", []
			)

			if choices.size() >= 3:
				var meet_choice: Dictionary = choices[0]
				var call_choice: Dictionary = choices[1]
				var rest_choice: Dictionary = choices[2]

				# Make meeting up possible even
				# when Fry can't afford coffee.
				if money < 9.0:
					meet_choice = {
						"text": "Take a walk together - $0",
						"reaction_emotion": "soft",
						"energy": -5,
						"mood": 6,
						"consumes_period": true,
						"set_flag": "caught_up_with_dulce",
						"flag_value": true,
						"reaction": (
							"We walked around and talked "
							+ "for a while. It was nice "
							+ "not worrying about money."
						)
					}

				# Personalize the reactions.
				if kitten_visit:
					meet_choice["reaction"] = (
						"We talked about the kittens, "
						+ "classes, and everything else. "
						+ "I didn't want the night to end."
					)

					call_choice["reaction"] = (
						"Dulce asked how the kittens "
						+ "were doing. Somehow, we "
						+ "ended up talking for an hour."
					)

					rest_choice["reaction"] = (
						"Pantera and Galleta curled up "
						+ "beside me. I'll catch up "
						+ "with Dulce another time."
					)

				elif bool(story_flags.get(
					"movie_with_dulce", false
				)):
					meet_choice["reaction"] = (
						"We talked about that movie "
						+ "and ended up laughing a lot. "
						+ "I really enjoyed tonight."
					)

					call_choice["reaction"] = (
						"Dulce still has theories "
						+ "about that mystery movie. "
						+ "It was fun talking again."
					)

				choices[0] = meet_choice
				choices[1] = call_choice
				choices[2] = rest_choice

				scheduled["choices"] = choices


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
	# Show Day 17 once, then allow random encounters.
	if key == "17_Evening" and not bool(
		story_flags.get("day17_evening_seen", false)
	):
		scheduled = make_club_invitation_event()

	elif key == "23_Evening" and not bool(
		story_flags.get("day23_evening_seen", false)
	):
		scheduled = make_club_preparation_event()

	elif key == "25_Evening" and not bool(
		story_flags.get("day25_evening_seen", false)
	):
		scheduled = make_club_result_event()

	# Day 26: customize dinner based on groceries,
	# rent, and whether Fry adopted the kittens.
	if key == "26_Evening":
		if bool(story_flags.get("day26_evening_seen", false)):
			scheduled = null

		elif scheduled is Dictionary:
			scheduled = scheduled.duplicate(true)

			var rent_bill: Dictionary = bills.get("rent", {})
			var rent_paid: bool = bool(
				rent_bill.get("paid", false)
			)

			var adopted_kittens: bool = bool(
				story_flags.get(
					"day21_kittens_adopted", false
				)
			)

			# Short opening dialogue.
			if rent_paid:
				scheduled["message"] = (
					"Finally Friday. I'm hungry. "
					+ "What's for dinner?"
				)
			else:
				scheduled["message"] = (
					"It's Friday, and rent's still unpaid. "
					+ "What should I do for dinner?"
				)

			var dinner_choices: Array = scheduled.get(
				"choices", []
			)

			if dinner_choices.size() >= 3:

				# No groceries: offer a free meal instead.
				if grocery_meals <= 0:
					dinner_choices[0] = {
						"text": "Find a community meal - $0",
						"energy": -7,
						"mood": 2,
						"consumes_period": true,
						"set_flag": "day26_community_meal",
						"flag_value": true,
						"reaction": (
							"I found a free dinner "
							+ "at the community center. "
							+ "Glad I checked!"
						),
						"after_period_reaction": (
							"That meal helped. "
							+ "I need to plan "
							+ "my next grocery trip."
						)
					}

				# Small kitten callbacks, without
				# replacing the main dinner story.
				if adopted_kittens:
					if grocery_meals > 0:
						dinner_choices[0]["reaction"] = (
							"Dinner's ready! Pantera and "
							+ "Galleta are napping nearby."
						)
					else:
						dinner_choices[0][
							"after_period_reaction"
						] = (
							"Pantera and Galleta greeted "
							+ "me when I got home. "
							+ "Time to plan groceries."
						)

					dinner_choices[1]["reaction"] = (
						"Takeout was good! Pantera and "
						+ "Galleta keep sniffing the bag."
					)

					dinner_choices[2]["reaction"] = (
						"I skipped dinner, but Pantera "
						+ "and Galleta have eaten. "
						+ "I should eat, too."
					)

				scheduled["choices"] = dinner_choices

	if scheduled is String:
		active_event = EventManager.create_shared_event(
			scheduled,
			fry_profile
		)
	
	elif scheduled is Dictionary:
		active_event = scheduled.duplicate(true)
	
	else:
		# Fry-only surprises have priority when a period is otherwise free.
		# If none appears, shared random events still get their normal chance.
		active_event = roll_fry_random_event(
			DayManager.current_day,
			DayManager.get_period()
		)
		if active_event.is_empty():
			active_event = EventManager.roll_random_event(
				DayManager.current_day,
				DayManager.get_period(),
				fry_profile
			)
	# Characterful delivery for a few surprising Fry-only encounters.
	# Do not alter their finances, frequency or available choices!!
	if not active_event.is_empty() and not active_event.has("emotion"):
		match str(active_event.get("id", "")):
			"fry_rand_laptop", "fry_rand_bike":
				active_event["emotion"] = "angry"
			"fry_rand_utility":
				active_event["emotion"] = "nervous"
			"fry_rand_refund":
				active_event["emotion"] = "excited"
		
	if active_event.is_empty():
		event_state = ""
		dialogue_manager.close_dialogue()
		next_day_button.show()
		return

	# Apply small refund and sale variations only to Fry.
	customize_fry_shared_small_event()

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
		
		active_event["message"] = fry_small_event_line("breakfast", [
			"I'm starving. Should I order breakfast or just make something at home?",
			"I'm hungry. Should I order something or make some good food at home?",
			"I could really go for breakfast right now. Do I cook or just order something?"
		])
		
		customize_fry_breakfast_event()

	EventManager.record_event_shown(
		str(active_event.get("id", "")),
		DayManager.current_day
	)
	record_fry_random_event(
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
		option_texts,
		str(active_event.get("emotion", "neutral"))
	)


func advance_time(force_fade: bool = false) -> void:
	if event_state != "" or transitioning:
		return

	var previous_day: int = DayManager.current_day
	DayManager.advance_period()

	if DayManager.finished:
		return

	# Time passing is not completely free, even when skipping an event.
	change_energy(-PERIOD_ENERGY_COST)

	# A new day restores some Energy; sleeping early restores more.
	if DayManager.current_day > previous_day:
		change_energy(OVERNIGHT_ENERGY_GAIN)
		if energy <= 20:
			change_mood(-2) # Prolonged fatigue starts affecting Fry's mood.

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
			result_mood = -25
		
		# Apply the result when Fry reaches the evening.
		pending_exam_result = {
			"mood": result_mood,
			"text": result_message
		}
		
	# Validate Day 8 group studying before spending Energy.
	if (
		str(active_event.get("id", "")) == "fry_day8_study_group"
		and bool(choice.get("day8_study_session", false))
	):
		if (
			exam_completed
			or study_sessions >= 4
			or last_study_day == DayManager.current_day
			or energy < STUDY_ENERGY_COST
		):
			event_state = "day8_study_unavailable"
			dialogue_manager.show_dialogue(
				"FRY",
				"I can't manage a full study session "
				+ "right now. I'll choose something else.",
				["Choose again"]
			)
			return

	# Validate Day 11 studying before applying its Energy cost.
	if (
		str(active_event.get("id", "")) == "fry_day11_last_minute_studying"
		and bool(choice.get("day11_study_session", false))
	):
		if (
			exam_completed
			or study_sessions >= 4
			or last_study_day == DayManager.current_day
			or energy < STUDY_ENERGY_COST
		):
			# Refresh the choices if studying became unavailable.
			active_event = make_day11_last_minute_studying_event()

			var refreshed_labels: Array[String] = []
			for option in active_event.get("choices", []):
				refreshed_labels.append(str(option.get("text", "Choose")))

			dialogue_manager.show_dialogue(
				"FRY",
				str(active_event.get("message", "")),
				refreshed_labels
			)
			return

	# Apply money, mood, and energy changes exactly once.
	apply_stat_changes(choice)

	# Day 11: count a real, paid-for study session.
	if (
		str(active_event.get("id", "")) == "fry_day11_last_minute_studying"
		and bool(choice.get("day11_study_session", false))
	):
		study_sessions += 1
		last_study_day = DayManager.current_day

		activity_history.append({
			"day": DayManager.current_day,
			"period": DayManager.get_period(),
			"activity": "last_minute_study"
		})

	# A full Day 8 study call counts as one real session.
	# It costs Energy and consumes Evening, like desk studying.
	if (
		str(active_event.get("id", "")) == "fry_day8_study_group"
		and bool(choice.get("day8_study_session", false))
	):
		study_sessions += 1
		last_study_day = DayManager.current_day

		activity_history.append({
			"day": DayManager.current_day,
			"period": DayManager.get_period(),
			"activity": "group_study"
		})

	# Some surprise encounters offer pay-later invoices. They join
	# the same bill list used by Phone > Finances and the Month Recap.
	if choice.has("create_bill"):
		add_fry_unexpected_bill(choice["create_bill"])

	# Cheap DIY fixes carry a randomized Mood/Energy consequence.
	# The risk never charges extra money without player confirmation.
	if choice.has("risk_effect"):
		var risk_effect: Dictionary = choice["risk_effect"]
		if fry_random_rng.randf() < float(risk_effect.get("chance", 0.0)):
			apply_stat_changes(risk_effect)
			choice["reaction"] = (
				str(choice.get("reaction", "")) + "\n" +
				str(risk_effect.get("reaction", ""))
			)
	
	# Consume groceries only after the choice succeeds.
	if portions_needed > 0:
		grocery_meals -= portions_needed
		
		if is_home_cooked_breakfast:
			choice["reaction"] = (
				"Not bad! Made breakfast with what I already had. "
				+ "I've got %d meal portion(s) left."
			) % grocery_meals
	
	# Day 9: receiving food from the campus pantry.
	# This is a one-time story reward, not a cash transaction.
	if (
		str(active_event.get("id", "")) == "fry_day9_campus_pantry"
		and choice.has("day9_pantry_gain")
	):
		var received_meals: int = maxi(
			0,
			int(choice.get("day9_pantry_gain", 0))
		)

		grocery_meals += received_meals
		update_ui()
	
	# Remember Fry's textbook decision.
	if choice.has("textbook_choice"):
		textbook_choice = str(choice["textbook_choice"])
		has_textbook = textbook_choice != "library"
	
	# Used by later textbook events.
	if choice.has("has_textbook"):
		has_textbook = bool(choice["has_textbook"])
	
	if choice.has("textbook_returned"):
		textbook_returned = bool(choice["textbook_returned"])
	# Save which Day 5 Night choice actually succeeded.
	# This runs after money and grocery requirements are checked.
	if str(active_event.get("id", "")) in [
		"fry_day5_party",
		"fry_day5_quiet_night"
	]:
		day5_night_choice = index

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
		str(choice.get("reaction_speaker", "FRY")),
		str(choice.get("reaction", "Alright, that's settled.")),
		["Continue"],
		str(choice.get("reaction_emotion", "neutral"))
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

	# After the Day 1 introduction, allow the usual random
	# encounter roll. Then return to normal bedroom free time.
	if finished_id == "fry_day1_first_night":
		story_flags["day1_evening_seen"] = true
		load_period_event()
		return

	# Day 2: mark the assignment story as completed.
	# The seen flag prevents the story from repeating.
	# Roll for a normal encounter, then restore free time.
	if finished_id == "fry_day2_late_night_assignment":
		story_flags["day2_evening_seen"] = true
		load_period_event()
		return

	# Day 4: finish the fair follow-up without using up Evening.
	# The flag prevents replay when we check random encounters.
	if finished_id == "fry_day4_after_fair":
		story_flags["day4_evening_seen"] = true
		load_period_event()
		return

	# Day 6: complete the follow-up without ending Evening.
	if finished_id == "fry_day6_morning_after":
		story_flags["day6_evening_seen"] = true
		load_period_event()
		return

	# Day 7: remember the payday decision.
	# Allow one normal random-event opportunity afterward.
	if finished_id == "fry_day7_payday_temptation":
		story_flags["day7_evening_seen"] = true
		load_period_event()
		return

	# Day 8: full studying uses the Evening.
	if finished_id == "fry_day8_study_group":
		story_flags["day8_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 9: campus food pantry.
	# Volunteering consumes Evening; quick choices do not.
	if finished_id == "fry_day9_campus_pantry":
		story_flags["day9_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 11: full reviewing consumes Evening.
	# Short choices allow random encounters and free time.
	if finished_id == "fry_day11_last_minute_studying":
		story_flags["day11_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 12: the exam result has already been applied.
	# This follow-up can either use Evening or return to free time.
	if finished_id == "fry_day12_after_exam":
		story_flags["day12_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 13: volunteering takes the entire Evening.
	# Donations and adoption posts leave free time available.
	if finished_id == "fry_day13_animal_shelter":
		story_flags["day13_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 14: visiting family takes the Evening.
	# Phone conversations leave free time available.
	if finished_id == "fry_day14_family_checkin":
		story_flags["day14_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 15: drafting slides consumes Evening.
	# Planning and teamwork leave free time available.
	if finished_id == "fry_day15_new_assignment":
		story_flags["day15_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 16: social outings consume the Evening.
	# Staying home allows normal free time.
	if finished_id == "fry_day16_unexpected_invitation":
		story_flags["day16_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 17: building the signup page uses Evening.
	# Other options can lead to random encounters.
	if finished_id == "fry_club_invitation":
		story_flags["day17_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 18: volunteering consumes Evening.
	# Other ways of helping leave free time.
	if finished_id == "fry_day18_homeless_shelter":
		story_flags["day18_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 19: prevent the financial-pressure event
	# from repeating after a choice.
	if finished_id == "fry_quick_money":
		story_flags["day19_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 21 Morning: complete the adoption decision.
	if finished_id == "fry_day21_kitten_adoption":
		story_flags["day21_kitten_decision_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()

		return

	# Day 21 Evening: complete Steve's friendship event.
	if finished_id == "fry_day21_friend_help":
		story_flags["day21_friend_event_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 22: office hours consume Evening.
	# Emailing or resting leave free time available.
	if finished_id == "fry_day22_professor":
		story_flags["day22_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 23: full testing or promotional work
	# consumes Evening.
	if finished_id == "fry_club_preparation":
		story_flags["day23_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 24: polishing the portfolio uses Afternoon.
	# Quick choices allow other random encounters.
	if finished_id == "fry_day24_internship":
		story_flags["day24_afternoon_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 25: meeting friends or repairing the
	# website consumes Evening.
	# Quick responses preserve free time.
	if finished_id == "fry_club_result":
		story_flags["day25_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 26: dinner decisions play only once.
	if finished_id == "fry_friday_dinner":
		story_flags["day26_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 27 Morning: internship follow-up.
	if finished_id == "fry_day27_internship_followup":
		story_flags["day27_internship_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()

		return

	# Day 27 Evening: kitten supplies.
	# Longer shopping advances into the special Night.
	if finished_id == "fry_day27_pet_care":
		story_flags["day27_pet_care_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 28: the web gig consumes Evening.
	# Budgeting and treating oneself preserve free time.
	if finished_id == "fry_day28_final_paycheck":
		story_flags["day28_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 29: Dulce's catch-up event plays once.
	# Coffee and walking consume Evening.
	# Calling or resting leave free time available.
	if finished_id == "fry_dulce_checkin":
		story_flags["day29_evening_seen"] = true

		if should_advance:
			advance_time(true)
		else:
			load_period_event()
		return

	# Day 30: end the final conversation,
	# but let the player choose FINISH MONTH.
	if finished_id == "fry_day30_final_evening":
		story_flags["day30_evening_seen"] = true

		update_ui()
		next_day_button.show()
		return

	if should_advance:
		advance_time(true)
	else:
		next_day_button.show()


#endregion


#region Fry - Dialogue Handling


func _on_dialogue_choice_selected(index: int) -> void:

	match event_state:

		"movie_intro":
			choose_movie_night_plan(index)

		"day5_party_line":
			show_next_day5_party_line()

		"day27_kitten_visit_line":
			show_next_day27_kitten_visit_line()

		"movie_invite":
			choose_movie_companion(index)

		"movie_option_unavailable":
			start_movie_night()

		"movie_line":
			show_next_movie_line()

		"movie_wrapup":
			finish_movie_night()

		"movie_home_result":
			finish_movie_night()

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

		# First Continue: Fry pauses.
		"bill_shortfall_intro":
			event_state = "bill_shortfall_pause"

			dialogue_manager.show_dialogue(
				"FRY",
				"...",
				["Continue"]
			)

		# Second Continue: Fry realizes he cannot pay.
		"bill_shortfall_pause":
			event_state = "bill_reaction"

			dialogue_manager.show_dialogue(
				"FRY",
				"I don't have enough money to pay it. "
				+ "I'll have to wait.",
				["Continue"]
			)
			
		# Final Continue: resume the normal day.
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

		"day8_study_unavailable":
			active_event = make_day8_study_group_event()
			event_state = "event_choice"

			var labels: Array[String] = []
			for option in active_event.get("choices", []):
				labels.append(str(option.get("text", "Choose")))

			dialogue_manager.show_dialogue(
				str(active_event.get("speaker", "FRY")),
				str(active_event.get("message", "")),
				labels
			)

		
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
	var pet_spending: float = 0.0

	for transaction in finance_history:
		var amount: float = float(transaction.get("amount", 0.0))
		var category: String = str(transaction.get("category", ""))

		if amount >= 0.0:
			continue

		if category == "Groceries":
			grocery_spending += absf(amount)

		elif category == "Delivery Fees":
			delivery_spending += absf(amount)

		elif category == "Pets":
			pet_spending += absf(amount)

	# Internship progress at the end of the month.
	var internship_summary: String = "Not pursued"

	if bool(story_flags.get(
		"day27_screening_submitted", false
	)):
		internship_summary = "Screening submitted"

	elif (
		bool(story_flags.get(
			"day27_sample_polished", false
		))
		or bool(story_flags.get(
			"day27_sample_sent", false
		))
	):
		internship_summary = "Work sample sent"

	elif bool(story_flags.get(
		"day27_late_application", false
	)):
		internship_summary = "Applied"

	elif bool(story_flags.get(
		"day27_requested_more_time", false
	)):
		internship_summary = "More time requested"

	elif (
		bool(story_flags.get(
			"day27_screening_started", false
		))
		or bool(story_flags.get(
			"day27_prepared_application", false
		))
	):
		internship_summary = "In progress"

	elif (
		bool(story_flags.get(
			"day24_portfolio_applied", false
		))
		or bool(story_flags.get(
			"day24_quick_applied", false
		))
	):
		internship_summary = "Application sent"

	# Adoption and friendship outcomes.
	var kitten_summary: String = "Not adopted"

	if bool(story_flags.get(
		"day21_kittens_adopted", false
	)):
		kitten_summary = "Pantera and Galleta"

	var dulce_summary: String = "No catch-up"

	if bool(story_flags.get(
		"caught_up_with_dulce", false
	)):
		dulce_summary = "Caught up"

	elif bool(story_flags.get(
		"day27_kitten_visit_seen", false
	)):
		dulce_summary = "Visited the kittens"

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
		"title": "LIFE & FUTURE",
		"body": (
			"Internship: %s\n"
			+ "Kittens: %s\n"
			+ "Pet spending: $%.2f\n"
			+ "Dulce: %s"
		) % [
			internship_summary,
			kitten_summary,
			pet_spending,
			dulce_summary
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

	if bool(story_flags.get("day4_club_links_saved", false)):
		message = (
			"That club from my saved links needs a "
			+ "fundraiser signup page. Dulce and Steve "
			+ "asked for help."
		)

	elif bool(story_flags.get("attend_campus", false)):
		message = (
			"The club from the fair needs a fundraiser "
			+ "signup page. Dulce and Steve want my help."
		)

	else:
		message = (
			"Dulce and Steve need a signup page for "
			+ "a club fundraiser. Should I help?"
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
				"consumes_period": true,
				"set_flag": "club_helped",
				"flag_value": true,
				"reaction": (
					"I'll build the signup page myself. "
					+ "Time to get to work!"
				),
				"after_period_reaction": (
					"I finished the club signup page "
					+ "and sent it to Dulce. "
					+ "Hopefully everything works!"
				)
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
	var test_reaction: String = (
		"I found a few broken links and fixed them. "
		+ "Glad I checked before the fundraiser!"
	)

	# The professor's advice adds a personal callback.
	if bool(story_flags.get("day22_office_hours", false)):
		test_reaction = (
			"The professor said to save my best work. "
			+ "Good thing I fixed those broken links!"
		)

	elif bool(story_flags.get("day22_emailed_professor", false)):
		test_reaction = (
			"Professor mentioned building a portfolio. "
			+ "I'll fix these links before saving the page."
		)

	# Fry helped create the fundraiser website.
	if bool(story_flags.get("club_helped", false)):
		return {
			"id": "fry_club_preparation",
			"speaker": "FRY",
			"message": (
				"Dulce says the fundraiser signup page "
				+ "is ready. Should we test it first?"
			),
			"choices": [
				{
					"text": "Test the page myself - $0",
					"energy": -12,
					"mood": 5,
					"consumes_period": true,
					"set_flag": "club_ready",
					"flag_value": true,
					"reaction": test_reaction,
					"after_period_reaction": (
						"The signup page is tested and "
						+ "ready. Hope the fundraiser "
						+ "goes well!"
					)
				},
				{
					"text": "Ask Steve to test - $0",
					"reaction_emotion": "excited",
					"energy": -4,
					"mood": 3,
					"set_flag": "club_ready",
					"flag_value": true,
					"reaction_speaker": "STEVE",
					"reaction": (
						"Found two broken links! "
						+ "Fixed them for you. "
						+ "You owe me a rematch!"
					)
				},
				{
					"text": "Skip testing - $0",
					"energy": 4,
					"mood": -2,
					"set_flag": "club_ready",
					"flag_value": false,
					"reaction": (
						"The page looks fine. "
						+ "Hopefully nothing breaks "
						+ "during the fundraiser."
					)
				}
			]
		}

	# Fry declined the website work on Day 17.
	# He can still contribute in other ways.
	return {
		"id": "fry_club_preparation",
		"speaker": "FRY",
		"message": (
			"Steve and Dulce finished the website. "
			+ "They need help spreading the word. "
			+ "Should I pitch in?"
		),
		"choices": [
			{
				"text": "Make promotional posts - $0",
				"energy": -10,
				"mood": 5,
				"consumes_period": true,
				"set_flag": "club_supported",
				"flag_value": true,
				"reaction": (
					"I put together some posters "
					+ "and social posts. Dulce "
					+ "really liked them!"
				),
				"after_period_reaction": (
					"The fundraiser posts are ready. "
					+ "Hopefully they reach "
					+ "more people!"
				)
			},
			{
				"text": "Share fundraiser link - $0",
				"energy": -2,
				"mood": 2,
				"set_flag": "club_supported",
				"flag_value": true,
				"reaction": (
					"I shared their signup link "
					+ "with classmates. "
					+ "Hope it helps!"
				)
			},
			{
				"text": "Sit this one out - $0",
				"energy": 5,
				"set_flag": "club_supported",
				"flag_value": false,
				"reaction": (
					"They've got things under control. "
					+ "I'll focus on my own work tonight."
				)
			}
		]
	}


func make_club_result_event() -> Dictionary:
	var message: String = ""
	var choices: Array[Dictionary] = []
	var social_choice: Dictionary = {}

	var helped: bool = bool(
		story_flags.get("club_helped", false)
	)
	var club_is_ready: bool = bool(
		story_flags.get("club_ready", false)
	)
	var supported: bool = bool(
		story_flags.get("club_supported", false)
	)

	# Remember rent without overcrowding
	# the main fundraiser dialogue.
	var rent_paid: bool = bool(
		bills.get("rent", {}).get("paid", false)
	)

	var rent_note: String = (
		" I still need to sort out rent."
	)
	if rent_paid:
		rent_note = " Glad my rent is paid."

	# Route 1: Fry built and tested the website.
	if helped and club_is_ready:
		message = (
			"[wave amp=8 freq=4]The fundraiser went great![/wave] "
			+ "Our signup page worked, and "
			+ "Steve wants to celebrate!"
		)

		if money >= 8.0:
			social_choice = {
				"text": "Get snacks together - $8",
				"money": -8.0,
				"energy": -3,
				"mood": 8,
				"consumes_period": true,
				"finance_label": "Fundraiser celebration",
				"finance_category": "Social",
				"reaction": (
					"That was a fun night!" + rent_note
				)
			}
		else:
			social_choice = {
				"text": "Meet up for free - $0",
				"energy": -3,
				"mood": 5,
				"consumes_period": true,
				"reaction": (
					"We hung out without spending "
					+ "anything. Still had a great time!"
				)
			}

		choices = [
			social_choice,
			{
				"text": "Celebrate by text - $0",
				"mood": 5,
				"reaction": (
					"I'm proud of what we built. "
					+ "Dulce sent a bunch of "
					+ "celebration emojis!"
				)
			}
		]

	# Route 2: Fry built the website but
	# didn't test it properly.
	elif helped:
		message = (
			"The fundraiser happened, but some "
			+ "signup links broke. I should've "
			+ "tested the page."
		)

		choices = [
			{
				"text": "Fix broken links - $0",
				"energy": -8,
				"mood": 4,
				"consumes_period": true,
				"reaction": (
					"I fixed the links and sent "
					+ "Dulce the updated page. "
					+ "Better late than never."
				),
				"after_period_reaction": (
					"The website is working now. "
					+ "I'll remember to test "
					+ "my projects next time."
				)
			},
			{
				"text": "Leave it for now - $0",
				"energy": 3,
				"mood": -2,
				"reaction": (
					"At least the fundraiser happened. "
					+ "I'll be more careful next time."
				)
			}
		]

	# Route 3: Fry didn't build the website,
	# but helped promote the fundraiser.
	elif supported:
		message = (
			"The fundraiser went well! Dulce "
			+ "thanked me for helping "
			+ "spread the word."
		)

		if money >= 9.0:
			social_choice = {
				"text": "Meet up with them - $9",
				"money": -9.0,
				"energy": -3,
				"mood": 6,
				"consumes_period": true,
				"finance_label": "Meeting friends",
				"finance_category": "Social",
				"reaction": (
					"Nice catching up with everyone!"
					+ rent_note
				)
			}
		else:
			social_choice = {
				"text": "Meet at the park - $0",
				"energy": -3,
				"mood": 4,
				"consumes_period": true,
				"reaction": (
					"We caught up at the park. "
					+ "Didn't cost a thing!"
				)
			}

		choices = [
			social_choice,
			{
				"text": "Send congratulations - $0",
				"mood": 3,
				"reaction": (
					"Dulce seemed really happy. "
					+ "Glad I could help a little!"
				)
			}
		]

	# Route 4: Fry didn't participate.
	else:
		message = (
			"Steve and Dulce's fundraiser is over. "
			+ "Looks like they managed "
			+ "to pull it off!"
		)

		choices = [
			{
				"text": "Congratulate them - $0",
				"mood": 2,
				"reaction": (
					"They were happy to hear from me. "
					+ "Maybe I'll join next time."
				)
			},
			{
				"text": "Focus on my plans - $0",
				"energy": 4,
				"reaction": (
					"Glad things worked out for them. "
					+ "I've got my own plans to finish."
				)
			}
		]

	return {
		"id": "fry_club_result",
		"emotion": "excited" if ((helped and club_is_ready) or supported) else ("sad" if helped else "neutral"),
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
			"emotion": "excited",
			"message": "Fry! You made it! Come on, Steve's over by the student booths."
		},
		{
			"speaker": "STEVE",
			"emotion": "excited",
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
		["Continue"],
		str(line.get("emotion", "neutral"))
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
			"emotion": "dramatic",
			"message": "Hey, Fry! Dulce and I were just talking about textbook prices. Some of them are [shake rate=12 level=2]ridiculous.[/shake]"
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
			"emotion": "soft",
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

	# Dulce remembers helping Fry the night before.
	var dulce_opening: String = (
		"Hey, Fry! Ready for the exam? "
		+ "I swear this week went by so fast."
	)

	if bool(story_flags.get("day11_asked_dulce", false)):
		dulce_opening = (
			"Hey, Fry! I hope those tips helped. "
			+ "Ready for the exam? You've got this!"
		)

	campus_lines = [
		{
			"speaker": "DULCE",
			"emotion": "soft",
			"message": dulce_opening
		},
		{
			"speaker": "FRY",
			"emotion": "nervous",
			"message": preparation_line
		},
		{
			"speaker": "FRY",
			"message": textbook_line
		},
		{
			"speaker": "DULCE",
			"emotion": "soft",
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
		["Begin exam"],
		"nervous"
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
	
	# Follow Fry in the bedroom.
	# Use the normal camera center for campus and cinema.
	if destination == "bedroom":
		bedroom_camera.position.x = fry_bedroom_position.x
	else:
		bedroom_camera.position.x = 960.0
	
	bedroom_camera.reset_smoothing()
	
	# Preserve the tested -180 Movie Night offset.
	if destination == "cinema":
		dialogue_manager.position = dialogue_default_position + Vector2(0, -180)
	else:
		dialogue_manager.position = dialogue_default_position
	campus_backdrop.visible = destination in ["campus", "cinema"]
	campus_backdrop.color = (
		Color("#141924") if destination == "cinema"
		else original_campus_backdrop_color
	)
	cinema_set.visible = (destination == "cinema")

	# Show the classroom whenever Fry is at school.
	classroom_set.visible = (destination == "campus")

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
		fry_sprite.show()
		fry_sprite.flip_h = fry_default_flip_h
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

	elif destination == "cinema":
		# Characters are already drawn into the cinema background.
		fry_sprite.hide()
		dulce_campus.hide()
		steve_campus.hide()

	else:
		# Return Fry to his bedroom.
		fry_sprite.position = fry_bedroom_position
		fry_sprite.flip_h = fry_bedroom_flip_h
		if fry_room_body != null:
			fry_room_body.position = fry_bedroom_position
			fry_room_body.velocity = Vector2.ZERO
		fry_sprite.show()

		dulce_campus.hide()
		steve_campus.hide()




func _on_dialogue_speaker_changed(speaker: String) -> void:
	# Allow speaker animations on campus and during
	# the Day 27 kitten visit in Fry's bedroom.
	var is_campus_scene: bool = (
		current_location == "campus"
	)

	var is_kitten_visit: bool = (
		current_location == "bedroom"
		and event_state == "day27_kitten_visit_line"
	)

	if not is_campus_scene and not is_kitten_visit:
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
	if current_location in ["campus", "cinema"]:
		reset_speaker_effects()

#endregion


#region Fry - Animations

# Animations will be implemented later.

#endregion
