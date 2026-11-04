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
	"Breakfast" : {
		
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
		"Caption": "Your friends want to hang out today!",
		"Options": ["Yes", "No"],
		"Yes": {
			"minCash": -20,
			"maxCash": -50,
			"minEnergy": -5,
			"maxEnergy": -10,
			"minMood": 5,
			"maxMood": 10,
		},
		"No":{
			"minCash": 0,
			"maxCash": 0,
			"minEnergy": 5,
			"maxEnergy": 10,
			"minMood": -5,
			"maxMood": -10,
		}
	},
	"Go to the movies" :{
		"Caption": "You are thinking about going to the movies to watch",
		"Options": ["Yes", "No", "Stream the movie"],
		"Yes": {
			"minCash": -10,
			"maxCash": -20,
			"minEnergy": -5,
			"maxEnergy": -10,
			"minMood": 5,
			"maxMood": 10,
		},
		"No":{
			"minCash": 0,
			"maxCash": 0,
			"minEnergy": 5,
			"maxEnergy": 10,
			"minMood": -5,
			"maxMood": -15,
		},
		"Stream the movie": {
			"minCash": -5,
			"maxCash": -10,
			"minEnergy": -1,
			"maxEnergy": -2,
			"minMood": 1,
			"maxMood": 2,
		}
	},
	"Buy Auto Theft 67" :{
		"Caption": "You are thinking about buying that new Auto Theft 67 video game.",
		"Options": ["Yes", "No", "Pirate it!"],
		"Yes": {
			"minCash": -60,
			"maxCash": -100,
			"minEnergy": -5,
			"maxEnergy": -10,
			"minMood": 10,
			"maxMood": 20,
		},
		"No":{
			"minCash": 0,
			"maxCash": 0,
			"minEnergy": 5,
			"maxEnergy": 10,
			"minMood": -10,
			"maxMood": -20,
		},
		"Pirate it!": {
			"minCash": 0,
			"maxCash": -300,
			"minEnergy": 5,
			"maxEnergy": 10,
			"minMood": 20,
			"maxMood": -20,
		}
	}
}
