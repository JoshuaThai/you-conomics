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

# Keep these indices stable for scripts that read period_index.
const PERIODS = ["Morning", "Afternoon", "Evening", "Night"]

# Day 1 is Monday. Days 6 and 7 are Saturday and Sunday.
const DAY_ONE_WEEKDAY_INDEX: int = 0

var current_day: int = 1
var period_index: int = 0
var finished: bool = false

# Preserved for compatibility
var isWeekend: bool = false

# Night is optional; add days here when their story events are built.
var special_night_days: Array[int] = []


const WEEKDAY_NAMES = [
	"Monday", "Tuesday", "Wednesday", "Thursday",
	"Friday", "Saturday", "Sunday"
]

func get_weekday_name(day: int = -1) -> String:
	var target_day: int = current_day if day == -1 else day
	var weekday_index: int = (DAY_ONE_WEEKDAY_INDEX + target_day - 1) % 7
	return WEEKDAY_NAMES[weekday_index]



#endregion

#region Calendar Functions

func reset_calendar() -> void:
	current_day = 1
	period_index = 0
	finished = false
	isWeekend = is_weekend_day(current_day)
	special_night_days.clear()
	
	period_changed.emit(current_day, get_period())


func get_period() -> String:
	return PERIODS[period_index]


func is_weekend_day(day: int) -> bool:
	var weekday_index: int = (DAY_ONE_WEEKDAY_INDEX + day - 1) % 7
	return weekday_index == 5 or weekday_index == 6


func get_periods_for_day(day: int) -> Array[String]:
	var day_periods: Array[String] = []
	
	if is_weekend_day(day):
		day_periods = ["Morning", "Evening"]
	else:
		day_periods = ["Morning", "Afternoon", "Evening"]
	
	if special_night_days.has(day):
		day_periods.append("Night")

	return day_periods


# Call this BEFORE advancing out of that day's Evening.
# Example: DayManager.schedule_night_for_day(12)
func schedule_night_for_day(day: int) -> void:
	if day < 1 or day > TOTAL_DAYS:
		push_warning("Cannot schedule a Night outside the 30-day calendar.")
		return
	
	if not special_night_days.has(day):
		special_night_days.append(day)


# Preview the next valid time without advancing the calendar.
# Returns {} when the current period is the final one of Day 30.
func get_next_time() -> Dictionary:
	if finished:
		return {}
	
	var today: Array[String] = get_periods_for_day(current_day)
	var current_position: int = today.find(get_period())
	
	if current_position >= 0 and current_position + 1 < today.size():
		return {
			"day": current_day,
			"period": today[current_position + 1]
		}
	
	if current_day < TOTAL_DAYS:
		return {
			"day": current_day + 1,
			"period": "Morning"
		}
	
	return {}


func advance_period() -> void:
	if finished:
		return
	
	var next_time: Dictionary = get_next_time()
	
	if next_time.is_empty():
		finished = true
		month_completed.emit()
		return
	
	current_day = int(next_time["day"])
	period_index = PERIODS.find(str(next_time["period"]))
	isWeekend = is_weekend_day(current_day)
	
	period_changed.emit(current_day, get_period())

## Find the next occurence of the day and return it's number.
## For example, you want to find the next saturday day number.
## If the current day is day 5, which is a Friday.
## Then the next saturday is day 13.
func find_next_day_number(dayName: String):
#	We add one to gets it real base number.
	var total = 0
	var baseWeekNumber = WEEKDAY_NAMES.find(dayName) + 1
#	We will add a offset if the current day is the 
# same as the day being searched
	var offset = 0
#	Find nearest sunday:
	var nearest_sundays = [7,14,21,28]
	for sunday in nearest_sundays:
		#Check if the current day is the same as the day being searched
		#if(DayManager.current_day == baseWeekNumber)
		if current_day + 1 < sunday:
			total = sunday - (7 - baseWeekNumber)
			break
	
	return total

#endregion
