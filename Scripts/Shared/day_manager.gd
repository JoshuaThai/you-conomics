extends Node

# ==========================================================
# YOU-CONOMICS - SHARED DAY MANAGER
# ==========================================================


#region Signals

signal period_changed(day: int, period: String)
signal month_completed

#endregion

#region Calendar Settings

const TOTAL_DAYS: int = 30
const PERIODS = ["Morning", "Afternoon", "Evening"]

var current_day: int = 1
var period_index: int = 0
var finished: bool = false

#endregion

#region Calendar Functions

func reset_calendar() -> void:
	current_day = 1
	period_index = 0
	finished = false
	
	period_changed.emit(current_day, get_period())


func get_period() -> String:
	return PERIODS[period_index]


func advance_period() -> void:
	if finished:
		return
	
	if period_index < PERIODS.size() - 1:
		period_index += 1
	
	elif current_day < TOTAL_DAYS:
		current_day += 1
		period_index = 0
	
	else:
		finished = true
		month_completed.emit()
		return
	
	period_changed.emit(current_day, get_period())

#endregion
