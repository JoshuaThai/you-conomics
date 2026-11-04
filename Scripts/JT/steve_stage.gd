extends Node2D

#region Steve - Starting Information
var money: int = 100
var mood: int = 70
var energy: int = 80

var steve_profile = {
	"name": "Steve",
	"debt_amount": 1000,
	"salary": 200,
	"workplace": "You-ville IT Solutions" 
}

# Randomly generate load in the character's info
func _ready():
	steve_profile["debt_amount"] = randi() % 1000 + 800
	steve_profile["salary"] = randi() % 200 + 150
	%SteveEventHandler._show_current_period_dialogue()
