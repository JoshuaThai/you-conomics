class_name FoodDashApp
extends VBoxContainer

signal back_requested
signal purchase_requested(delivery: bool)

var pantry_label: Label
var delivery_label: Label
var price_label: Label
var feedback_label: Label

var store_button: Button
var delivery_button: Button


func _ready() -> void:
	add_theme_constant_override("separation", 18)
	build_interface()


func make_label(message: String, font_size: int, font_color: Color) -> Label:
	var label := Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	return label


func build_interface() -> void:
	# Header.
	var header := HBoxContainer.new()
	add_child(header)
	
	var back_button := Button.new()
	back_button.text = "< Back"
	back_button.custom_minimum_size = Vector2(100, 48)
	back_button.pressed.connect(
		func(): back_requested.emit()
	)
	header.add_child(back_button)
	
	var title := make_label(
		"FOODDASH",
		26,
		Color("#F1E4D5")
	)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(title)
	
	# Pantry information.
	var pantry_card := PanelContainer.new()
	add_child(pantry_card)
	
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#34423B")
	card_style.set_corner_radius_all(18)
	pantry_card.add_theme_stylebox_override("panel", card_style)
	
	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 18)
	card_margin.add_theme_constant_override("margin_right", 18)
	card_margin.add_theme_constant_override("margin_top", 18)
	card_margin.add_theme_constant_override("margin_bottom", 18)
	pantry_card.add_child(card_margin)
	
	var card_contents := VBoxContainer.new()
	card_contents.add_theme_constant_override("separation", 10)
	card_margin.add_child(card_contents)
	
	pantry_label = make_label(
		"Groceries available: 0 meals",
		22,
		Color("#D8F0DD")
	)
	card_contents.add_child(pantry_label)
	
	delivery_label = make_label(
		"No delivery scheduled.",
		17,
		Color("#B9D3C3")
	)
	card_contents.add_child(delivery_label)
	
	add_child(make_label(
		"GROCERY OPTIONS",
		21,
		Color("#F1E4D5")
	))
	
	price_label = make_label(
		"",
		18,
		Color("#D3DCE5")
	)
	add_child(price_label)
	
	# In-person shopping.
	store_button = Button.new()
	store_button.custom_minimum_size = Vector2(0, 64)
	store_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	store_button.pressed.connect(
		func(): purchase_requested.emit(false)
	)
	add_child(store_button)
	
	# FoodDash delivery.
	delivery_button = Button.new()
	delivery_button.custom_minimum_size = Vector2(0, 64)
	delivery_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	delivery_button.pressed.connect(
		func(): purchase_requested.emit(true)
	)
	add_child(delivery_button)
	
	# The option not to spend anything.
	var skip_button := Button.new()
	skip_button.text = "Don't buy anything"
	skip_button.custom_minimum_size = Vector2(0, 54)
	skip_button.pressed.connect(
		func(): show_feedback(
			"No groceries purchased. Your pantry stays as it is."
		)
	)
	add_child(skip_button)
	
	add_child(HSeparator.new())
	
	feedback_label = make_label(
		"Compare the cost of convenience before deciding.",
		18,
		Color("#E5D4BB")
	)
	add_child(feedback_label)


func display_snapshot(snapshot: Dictionary) -> void:
	var meals: int = int(snapshot.get("meals", 0))
	var bundle: int = int(snapshot.get("bundle_size", 4))
	var store_price: float = float(snapshot.get("store_price", 24.0))
	var dash_price: float = float(snapshot.get("fooddash_price", 31.0))
	var delivery_fee: float = float(snapshot.get("delivery_fee", 7.0))
	
	pantry_label.text = "In your kitchen: %d meals" % meals
	
	delivery_label.text = str(
		snapshot.get("delivery_status", "No delivery scheduled.")
	)
	
	price_label.text = (
		"%d meals per purchase\n"
		+ "FoodDash includes a $%.2f delivery fee."
	) % [bundle, delivery_fee]
	
	store_button.text = "Visit store - $%.2f" % store_price
	delivery_button.text = "FoodDash delivery - $%.2f" % dash_price
	
	delivery_button.disabled = bool(
		snapshot.get("delivery_pending", false)
	)


func show_feedback(message: String) -> void:
	feedback_label.text = message
