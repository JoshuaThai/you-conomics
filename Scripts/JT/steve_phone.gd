extends Control

var debounce : bool = false
var hovering : bool = false


@export var phone_owner_name: String = "Fry"

const PHONE_IDLE_Y: float = 40.0
const PHONE_HOVER_Y: float = 5.0
const HOVER_DURATION: float = 0.22

const APP_NAMES: Array[String] = [
	"Finances",
	"FoodDash",
	"Games",
	"Messages",
	"Calendar",
	"Settings"
]

const FINANCES_APP_SCENE: PackedScene = preload(
	"res://Scenes/UI/Apps/finances_app.tscn"
)

const FOODDASH_APP_SCENE: PackedScene = preload(
	"res://Scenes/UI/Apps/fooddash_app.tscn"
)

var fooddash_app: FoodDashApp

var finance_source: Node
var finances_app: FinancesApp

var phone_is_open: bool = false
var hover_tween: Tween

@onready var dock: Control = $Dock
@onready var peek_button: Button = %Button
@onready var notch: ColorRect = $Dock/PeekButton/Notch
@onready var peek_label: Label = $Dock/PeekButton/PeekLabel

@onready var overlay: ColorRect = $Overlay
@onready var phone_frame: PanelContainer = $Overlay/PhoneFrame
@onready var margin_container: MarginContainer = $Overlay/PhoneFrame/MarginContainer
@onready var home_screen: VBoxContainer = $Overlay/PhoneFrame/MarginContainer/HomeScreen
@onready var header_row: HBoxContainer = $Overlay/PhoneFrame/MarginContainer/HomeScreen/HeaderRow
@onready var phone_title: Label = $Overlay/PhoneFrame/MarginContainer/HomeScreen/HeaderRow/PhoneTitle
@onready var close_button: Button = $Overlay/PhoneFrame/MarginContainer/HomeScreen/HeaderRow/CloseButton
@onready var date_label: Label = $Overlay/PhoneFrame/MarginContainer/HomeScreen/DateLabel
@onready var app_grid: GridContainer = $Overlay/PhoneFrame/MarginContainer/HomeScreen/AppGrid
@onready var status_label: Label = $Overlay/PhoneFrame/MarginContainer/HomeScreen/StatusLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	#setup_dock()
	setup_overlay()
	setup_home_screen()
	setup_finances_app()
	setup_fooddash_app()
	
	peek_button.mouse_entered.connect(_on_peek_mouse_entered)
	peek_button.mouse_exited.connect(_on_peek_mouse_exited)
	peek_button.pressed.connect(open_phone)
	close_button.pressed.connect(close_phone)
	
	overlay.hide()


#region Phone - Dock

func setup_dock() -> void:
	# Anchored to the bottom-right of the game viewport.
	dock.anchor_left = 1.0
	dock.anchor_right = 1.0
	dock.anchor_top = 1.0
	dock.anchor_bottom = 1.0

	dock.offset_left = -180.0
	dock.offset_right = -20.0
	dock.offset_top = -150.0
	dock.offset_bottom = 0.0

	dock.mouse_filter = Control.MOUSE_FILTER_PASS

	peek_button.position = Vector2(12, PHONE_IDLE_Y)
	peek_button.size = Vector2(136, 245)
	peek_button.text = ""
	peek_button.mouse_filter = Control.MOUSE_FILTER_STOP
	peek_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var phone_style := StyleBoxFlat.new()
	phone_style.bg_color = Color("#27374B")
	phone_style.border_color = Color("#8599B3")
	phone_style.set_border_width_all(4)
	phone_style.set_corner_radius_all(25)

	peek_button.add_theme_stylebox_override("normal", phone_style)
	peek_button.add_theme_stylebox_override("hover", phone_style)
	peek_button.add_theme_stylebox_override("pressed", phone_style)

	notch.position = Vector2(43, 12)
	notch.size = Vector2(50, 7)
	notch.color = Color("#101924")
	notch.mouse_filter = Control.MOUSE_FILTER_IGNORE

	peek_label.position = Vector2(10, 48)
	peek_label.size = Vector2(116, 45)
	peek_label.text = "PHONE"
	peek_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	peek_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	peek_label.add_theme_font_size_override("font_size", 21)
	peek_label.add_theme_color_override(
		"font_color", Color("#EEF2F7")
	)


func _on_peek_mouse_entered() -> void:
	if not phone_is_open:
		animate_phone_dock(PHONE_HOVER_Y)


func _on_peek_mouse_exited() -> void:
	if not phone_is_open:
		animate_phone_dock(PHONE_IDLE_Y)


func animate_phone_dock(target_y: float) -> void:
	if hover_tween != null and hover_tween.is_running():
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_SINE)
	hover_tween.set_ease(Tween.EASE_OUT)

	hover_tween.tween_property(
		peek_button,
		"position",
		Vector2(12, target_y),
		HOVER_DURATION
	)

#endregion


#region Phone - Main Interface

func setup_overlay() -> void:
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.60)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Center a larger smartphone interface.
	phone_frame.anchor_left = 0.5
	phone_frame.anchor_right = 0.5
	phone_frame.anchor_top = 0.5
	phone_frame.anchor_bottom = 0.5
	
	phone_frame.offset_left = -225.0
	phone_frame.offset_right = 225.0
	phone_frame.offset_top = -390.0
	phone_frame.offset_bottom = 390.0
	
	# Keep the phone frame at a consistent minimum size.
	phone_frame.custom_minimum_size = Vector2(450, 780)
	
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color("#182332")
	frame_style.border_color = Color("#667B93")
	frame_style.set_border_width_all(5)
	frame_style.set_corner_radius_all(32)
	
	phone_frame.add_theme_stylebox_override("panel", frame_style)
	phone_frame.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Give the interior content breathing room.
	margin_container.add_theme_constant_override("margin_left", 25)
	margin_container.add_theme_constant_override("margin_right", 25)
	margin_container.add_theme_constant_override("margin_top", 28)
	margin_container.add_theme_constant_override("margin_bottom", 28)


func setup_home_screen() -> void:
	home_screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home_screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	home_screen.add_theme_constant_override("separation", 22)
	header_row.add_theme_constant_override("separation", 12)

	phone_title.text = phone_owner_name.to_upper() + "'S PHONE"
	phone_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phone_title.add_theme_font_size_override("font_size", 27)
	phone_title.add_theme_color_override(
		"font_color", Color("#E9EFF7")
	)
	
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(55, 50)
	
	date_label.add_theme_font_size_override("font_size", 23)
	date_label.add_theme_color_override(
		"font_color", Color("#B8C9DD")
	)
	
	app_grid.columns = 3
	app_grid.add_theme_constant_override("h_separation", 12)
	app_grid.add_theme_constant_override("v_separation", 14)
	
	status_label.text = "Choose an app."
	
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override(
		"font_color", Color("#C2CBD7")
	)
	
	create_app_buttons()
	update_phone_date()



func setup_finances_app() -> void:
	finances_app = FINANCES_APP_SCENE.instantiate() as FinancesApp
	
	finances_app.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	finances_app.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	margin_container.add_child(finances_app)

	finances_app.hide()
	finances_app.back_requested.connect(
		_on_finances_back_requested
	)



func setup_fooddash_app() -> void:
	fooddash_app = FOODDASH_APP_SCENE.instantiate() as FoodDashApp
	
	fooddash_app.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fooddash_app.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	margin_container.add_child(fooddash_app)
	fooddash_app.hide()
	
	fooddash_app.back_requested.connect(
		_on_fooddash_back_requested
	)
	
	fooddash_app.purchase_requested.connect(
		_on_food_purchase_requested
	)


func set_finance_source(source: Node) -> void:
	finance_source = source


func create_app_buttons() -> void:
	for app_name in APP_NAMES:
		var app_button := Button.new()
		app_button.text = app_name
		app_button.custom_minimum_size = Vector2(115, 95)
		app_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		app_button.add_theme_font_size_override("font_size", 17)
		
		var normal_style := StyleBoxFlat.new()
		normal_style.bg_color = Color("#30445C")
		normal_style.set_corner_radius_all(16)
		
		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color("#496684")
		hover_style.set_corner_radius_all(16)
		
		app_button.add_theme_stylebox_override("normal", normal_style)
		app_button.add_theme_stylebox_override("hover", hover_style)
		
		app_button.pressed.connect(
			_on_app_pressed.bind(app_name)
		)
		
		app_grid.add_child(app_button)


func update_phone_date() -> void:
	date_label.text = "DAY %d  |  %s  |  %s" % [
		DayManager.current_day,
		DayManager.get_weekday_name().to_upper(),
		DayManager.get_period().to_upper()
	]


func open_phone() -> void:
	if phone_is_open:
		return
	
	phone_is_open = true
	
	if hover_tween != null and hover_tween.is_running():
		hover_tween.kill()
	
	update_phone_date()
	status_label.text = "Choose an app."
	
	# Always start at the home screen.
	finances_app.hide()
	fooddash_app.hide()
	home_screen.show()

	dock.hide()
	overlay.show()


func close_phone() -> void:
	overlay.hide()
	
	peek_button.position = Vector2(12, PHONE_IDLE_Y)
	phone_is_open = false
	
	dock.show()


func _on_app_pressed(app_name: String) -> void:
	if app_name == "Finances":
		if finance_source == null or not is_instance_valid(finance_source):
			status_label.text = "No financial data connected."
			return
		
		if not finance_source.has_method("get_finance_snapshot"):
			status_label.text = "Financial data is unavailable."
			return
		
		var snapshot: Dictionary = finance_source.call(
			"get_finance_snapshot"
		)
		
		finances_app.display_snapshot(snapshot)
		
		home_screen.hide()
		finances_app.show()
		return
	
	if app_name == "FoodDash":
		if finance_source == null or not is_instance_valid(finance_source):
			status_label.text = "No character connected."
			return
		
		if not finance_source.has_method("get_grocery_snapshot"):
			status_label.text = "Grocery information unavailable."
			return
		
		var grocery_snapshot: Dictionary = finance_source.call(
			"get_grocery_snapshot"
		)
		
		fooddash_app.display_snapshot(grocery_snapshot)
		fooddash_app.show_feedback(
			"Compare the cost of convenience before deciding."
		)
		
		home_screen.hide()
		fooddash_app.show()
		return
	
	# Other apps are still placeholders.
	status_label.text = "%s is coming soon!" % app_name


func _on_finances_back_requested() -> void:
	finances_app.hide()
	home_screen.show()


func _on_fooddash_back_requested() -> void:
	fooddash_app.hide()
	home_screen.show()


func _on_food_purchase_requested(delivery: bool) -> void:
	if finance_source == null or not is_instance_valid(finance_source):
		return

	var result: Dictionary = finance_source.call(
		"purchase_groceries",
		delivery
	)

	# An in-person trip costs an entire period.
	if (
		bool(result.get("success", false))
		and bool(result.get("uses_period", false))
	):
		close_phone()
		finance_source.call("advance_time", true)
		return

	# Delivery does not consume time.
	var snapshot: Dictionary = finance_source.call(
		"get_grocery_snapshot"
	)

	fooddash_app.display_snapshot(snapshot)
	fooddash_app.show_feedback(
		str(result.get("message", "Something went wrong."))
	)


func _unhandled_key_input(event: InputEvent) -> void:
	if (
		phone_is_open
		and event is InputEventKey
		and event.pressed
		and event.keycode == KEY_ESCAPE
	):
		close_phone()
		get_viewport().set_input_as_handled()

#endregion


func _process(delta):
	if hovering:
		%Button.add_theme_stylebox_override('hover',
		load("res://Button Styles/on_hover_button_color.tres") )
		var tween = get_tree().create_tween()
		tween.tween_property(self.get_parent(), "position:y", 55, 2.0)
		await tween.finished
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self.get_parent(), "position:y", 95, 1.0)
		await tween.finished
	

#func _on_mouse_entered():

	#if debounce: return
	#debounce = true
	#debounce = false


#func _on_mouse_exited():

	#if debounce: return
	#debounce = true
#
	#debounce = false


func _on_button_mouse_entered():
	hovering = true


func _on_button_mouse_exited():
	hovering = false
