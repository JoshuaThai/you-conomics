extends Node
"""
THIS SCRIPT WILL CONTAIN DATA ON STEVE'S SPECIFIC EVENTS
"""


var steve_profile: Dictionary = {
	"name": "Steve",

	"breakfast_cost": 29,
	"home_breakfast_cost": 4,

	"breakfast_dialogue":
		"Ugh. Should I order breakfast or just make something at home?",

	"breakfast_order_reaction":
		"Yessir! ...Hold on, did I really just spend $29 on breakfast?",

	"breakfast_cook_reaction":
		"Required more effort than I thought. But worth it for the money being saved.",

	"breakfast_skip_reaction":
		"I will eat some other time. Money needs to be made! *yawns*"
		
}

# These are the events that you expect to occur on a weekday
var steve_normal_events = [
	"Lunch", "Snack", "Dinner",
	"Work on Hobby", "Sleep", "Scam Email",
	"Legit Email"
]

var steve_normal_events_info = {
#	If player run out of food in fridge, they will only be allowed
# to select order lunch or skip lunch
	"Lunch" : {
		"message": "What shall I do for Lunch?",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Order Lunch",
			"money": randi_range(-10, -5),
			"energy": 10,
			"mood": randi_range(5, 10),
			"reaction": "Yay! Lunchtime is going to be fire!"
			},
			{"text": "Prepare Lunch Yourself",
			"money": 0,
			"energy": 5,
			"mood": randi_range(5, 10),
			"reaction": "Yay! Lunchtime is going to be fire!"
			},
			{"text": "Skip Lunch",
			"money": 0,
			"energy": -10,
			"mood": randi_range(-10, -5),
			"reaction": "Lunch, Smunch! I will be fine without it."
			}
		]
	}
}
# These are the events that are character specific and
# can randomly pop up on a weekday
var steve_weekly_events = [
	"Work a extra shift", "Pay Bonus", "Hate Mail",
	"Buy New Computer", "Buy New Socks"
]

# These are events that can appear if the character is beginning to
# stress out about their finances.

# Some other ways to make consequences more interesting
# is to make player be only able to say yes to fun events 
# if their mood is down

# or Make player only able to say no when there energy is low!
# If steve becomes aware that he is struggling with money, he will
# start to get risky in some events
var steve_consequences_events = [
	"Wager a bet", "Ask for Promotion", "Take out a loan"
]

var steve_special_events = [
	"Hang out with friends", "Go to the movies",
	"Buy Auto Theft 67"
]
# This will contain all relevant info to the special events
# which will only happen during weekends
# The info will be the caption and the corresponding options
var steve_special_events_info = {
#	Yes and No will contain the min/max amount of money you 
# could lose and the min/max mood and energy you could lose
	"Hang out with friends" : {
		"message": "My friends want to hang out today!",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Yes",
			"money": randi_range(-50, -20),
			"energy": randi_range(-10, -5),
			"mood": randi_range(5, 10),
			"reaction": "We're going out today!"
			},
			{"text": "No",
			"money": 0,
			"energy": randi_range(5, 10),
			"mood": randi_range(-10, -5),
			"reaction": "Nope. Staying home!"
			}
		]

	},
	"Go to the movies" :{
		"Caption": "I am thinking about going to the movies. ",
		#"Options": ["Yes", "No", "Stream the movie"],
		"choices": [{
			"text": "Yes",
			"money": randi_range(-20, -10),
			"energy": randi_range(-10, -5),
			"mood": randi_range(5, 10),
			"reaction": "Movietime!"
			},
			{
			"text": "No",
			"money": 0,
			"energy": randi_range(1, 2),
			"mood": randi_range(-15, -5),
			"reaction": "Probably for the best. I need to lay off the money."
			},{
			"text": "Stream the movie",
			"money": randi_range(-10, -5),
			"energy": randi_range(-2, -1),
			"mood": randi_range(1, 2),
			"reaction": "Let me save myself the trouble. I will just stream it!"
		}],
	},
	"Buy Auto Theft 67" :{
		"message": "I am thinking about buying that new Auto Theft 67 video game.",
		"choices": [{
			"text": "Yes",
			"money": randi_range(-100, -60),
			"energy": randi_range(-10, -5),
			"mood": randi_range(10,20),
			"reaction": "Buying it because I am... Steve."
		},
		{	"text": "No",
			"money": 0,
			"energy": randi_range(5, 10),
			"mood": randi_range(-20,-10),
			"reaction": "Going to look like such a lame-o. But bills gotta be paid!"
			},
			{
			"text": "Pirate it!",
			"money": randi_range(-100, 0),
			"energy": randi_range(5, 10),
			"mood": randi_range(-20,20),
			"reaction": "Risking it for the biscuit? I am him!"
		}]
	}
}
