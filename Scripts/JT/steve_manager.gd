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
var normal_morning_events = [
	"Lunch"
]

var normal_afternoon_events = [
	"Work a extra shift", "Snack", "Nap", "Nothing"
]

var normal_evening_events = [
	"Dinner",
	"Work on Hobby", "Sleep", "Scam Email",
	"Legit Email", "Nothing"
]

var normal_night_events = [
	"Get a Drink", "Nothing"
]

var normal_morning_events_info = {
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
	},
}

var normal_afternoon_events_info = {
	"Work a extra shift" : {
		"message": "You-ville are hoping I could work an extra shift today. Should I do it?",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Yes",
			"money": randi_range(20, 40),
			"energy": randi_range(-10, -5),
			"mood": randi_range(-15, -10),
			"reaction": "Work hard! Play hard!"
			},
			{"text": "No",
			"money": 0,
			"energy": 5,
			"mood": randi_range(1, 2),
			"reaction": "Not my shift. Not my problem!"
			}
		]
	},
	"Snack" : {
		"message": "What shall I do for a snack?",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Order a Snack",
			"money": randi_range(-10, -5),
			"energy": 10,
			"mood": randi_range(5, 10),
			"reaction": "Yay! Snacktime is going to be fire!"
			},
			{"text": "Prepare a Snack",
			"money": 0,
			"energy": 5,
			"mood": randi_range(5, 10),
			"reaction": "Yay! Snacktime is going to be fire!"
			},
			{"text": "Skip Snacktime",
			"money": 0,
			"energy": -10,
			"mood": randi_range(-10, -5),
			"reaction": "Snack is for the weak! *scoffs*"
			}
		]
	},
	"Nap" : {
		"message": "A little tired. Take a nap?",
#		Prevent the user from napping every period
#	The user can only nap once a day.
		"cooldown": false, 
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Yes",
			"money": 0,
			"energy": 10,
			"mood": 10,
			"reaction": "Woo! I love napping!"
			},
			{"text": "No",
			"money": 0,
			"energy": -5,
			"mood": -10,
			"reaction": "Welp! Going to be tired. But time waits for no man!"
			}
		]
	},
		
}

var normal_evening_events_info = {
	"Dinner" : {
		"message": "What shall I do for Dinner?",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Order Dinner",
			"money": randi_range(-30, -15),
			"energy": 10,
			"mood": randi_range(5, 10),
			"reaction": "Yay! Dinnertime is going to be fire!"
			},
			{"text": "Prepare Dinner Yourself",
			"money": 0,
			"energy": 5,
			"mood": randi_range(5, 10),
			"reaction": "Yay! Dinnertime is going to be fire!"
			},
			{"text": "Skip Dinner",
			"money": 0,
			"energy": -10,
			"mood": randi_range(-10, -5),
			"reaction": "Choo choo! The Dinner hate train is here!"
			}
		]
	},
	"Work on Hobby" : {
		"message": "I got time to work on developing my video game! I should totally do it!",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Yes",
			"money": 0,
			"energy": -15,
			"mood": randi_range(5, 10),
			"reaction": "So excited! It is going to give Roblox a run for its money."
			},
			{"text": "No",
			"money": 0,
			"energy": 1,
			"mood": randi_range(-10, -5),
			"reaction": "Aw man!"
			},
			{"text": "Work on one feature",
			"money": 0,
			"energy": -5,
			"mood": randi_range(-10, -5),
			"reaction": "Let me not get carried away and work on getting one feature done!"
			}
		]
	},
	"Sleep" : {
		"message": "I am tired! Let's go to sleep!",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Yes",
			"money": 0,
			"energy": 15,
			"mood": randi_range(5, 10),
			"reaction": "*yawns*"
			},
			{"text": "No",
			"money": 0,
			"energy": 1,
			"mood": randi_range(-10, -5),
			"reaction": "Nah. Let me stay up a little longer!"
			}
		]
	},
	
	"Scam Email" : {
		"message": "*Ding* Oh I got a email on my computer!",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Check it!",
			"money": 0,
			"energy": 0,
			"mood": 0,
			},
		]
	},
	"Legit Email" : {
		"message": "*Ding* Oh I got a email on my computer!",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Check it!",
			"money": 0,
			"energy": 0,
			"mood": 0,
			},
		]
	},
}

var normal_night_events_info = {
	"Get a Drink" : {
		"message": "I am feeling a little thirsty!",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Yes",
			"money": 0,
			"energy": 10,
			"mood": 10,
			"reaction": "That was much needed."
			},
			{"text": "No",
			"money": 0,
			"energy": -5,
			"mood": -10,
			"reaction": "Too lazy to get up! Back to sleep I go!"
			}
		]
	},
}

# These are the events that are character specific and
# can randomly pop up on a weekday in whatever time period.
var steve_weekly_events = [
	"Pay Bonus", "Hate Mail",
	"Buy New Computer", "Buy New Socks", "Nothing"
]

# We will use the period to determine when the event will show itself on a specific day
var steve_weekly_events_info = {
	"Pay Bonus" : {
		"message": "I received a a pay bonus of $20!",
		"period": "Evening",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Save it!",
			"money": 20,
			"energy": 0,
			"mood": randi_range(1, 2),
			"reaction": "It could become useful later!"
			},
			{"text": "Spend some of it!",
			"money": 5,
			"energy": 0,
			"mood": randi_range(5, 10),
			"reaction": "Gotta have a little fun with my money!"
			}
		]
	},
	
	"Hate Mail" : {
		"message": "Some mail came today!",
		"period": "Morning",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Check it out!",
			"money": 20,
			"energy": 0,
			"mood": randi_range(-10, -5),
			"reaction": "I wonder what came today!"
			},
		]
	},
	
	"Buy New Computer" : {
		"message": "I really want to buy a new computer, so I can play games with my friend, Fry!",
		"period": "Evening",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Buy it! (-$75)",
			"money": -75,
			"energy": 0,
			"mood": randi_range(8, 20),
			"reaction": "Auto Theft 67, here we come!"
			},
			{"text": "No",
			"money": 0,
			"energy": 0,
			"mood": randi_range(-15, -8),
			"reaction": "Maybe another time! I need to save my money!"
			}
		]
	},
	
	"Buy New Socks" : {
		"message": "My socks are starting to get smelly. Maybe it is time for some new ones!",
		"period": "Evening",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Buy some! (-$25)",
			"money": -25,
			"energy": 0,
			"mood": randi_range(5, 10),
			"reaction": "Hooray! No more smelly socks!"
			},
			{"text": "No",
			"money": 0,
			"energy": 0,
			"mood": randi_range(-20, -10),
			"reaction": "I can tolerate my socks just to save some money"
			}
		]
	},
}

# These are events that can appear if the character is beginning to
# stress out about their finances.

# Some other ways to make consequences more interesting
# is to make player be only able to say yes to fun events 
# if their mood is down

# or Make player only able to say no when there energy is low!
# If steve becomes aware that he is struggling with money, he will
# start to get risky in some events
var steve_low_money_events = [
	"Wager a bet", "Ask for Promotion", "Take out a loan"
]


# Sometimes, if the energy is low enough, then these events could play

var steve_low_energy_events = [
	"Visit the Doctor", "Take an unpaid day off"
]

var steve_low_energy_events_info = {
	"Visit the Doctor" : {
		"message": "Not feeling so good! I need to see my doctor!",
		"period": "Evening",
		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Go (-$35)",
			"money": -35,
			"energy": 0,
			"mood": randi_range(20, 30),
			"reaction": "Ugh!"
			},
		]
	},
	"Take an unpaid day off" : {
		"message": "Not feeling so good! I need to take time off work!",

		#"Options": ["Yes", "No"],
		"choices": [
			{"text" :"Go",
			"money": 0,
			"energy": 10,
			"mood": randi_range(20, 30),
			"reaction": "Ugh!"
			},
		]
	},
}

var steve_special_events = [
	"Hang out with friends", "Go to the movies",
	"Buy Auto Theft 67", "Nothing"
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
