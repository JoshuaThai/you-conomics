class_name FinancesApp
extends VBoxContainer

signal back_requested

var balance_label: Label
var income_label: Label
var spending_label: Label
var bills_label: Label
var after_bills_label: Label
var transactions_list: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	build_interface()


func make_text(
	message: String,
	font_size: int,
	font_color: Color
) -> Label:
	var label := Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	return label


func build_interface() -> void:
	# Header with a button to return to the phone's home screen.
	var header := HBoxContainer.new()
	add_child(header)
	
	var back_button := Button.new()
	back_button.text = "< Back"
	back_button.custom_minimum_size = Vector2(105, 48)
	back_button.pressed.connect(_on_back_pressed)
	header.add_child(back_button)
	
	var title := make_text(
		"FINANCES", 26, Color("#E9EFF7")
	)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(title)
	
	# Main balance card.
	var balance_card := PanelContainer.new()
	add_child(balance_card)
	
	balance_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#263B39")
	card_style.set_corner_radius_all(18)
	balance_card.add_theme_stylebox_override("panel", card_style)
	
	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 18)
	card_margin.add_theme_constant_override("margin_right", 18)
	card_margin.add_theme_constant_override("margin_top", 18)
	card_margin.add_theme_constant_override("margin_bottom", 18)
	balance_card.add_child(card_margin)
	
	var card_contents := VBoxContainer.new()
	card_margin.add_child(card_contents)
	
	card_contents.add_child(make_text(
		"CURRENT BALANCE", 17, Color("#C3D8D3")
	))
	
	balance_label = make_text(
		"$0.00", 35, Color("#BAE8C6")
	)
	card_contents.add_child(balance_label)
	
	# Financial summary.
	income_label = make_text(
		"Income: $0.00", 21, Color("#A6D8B5")
	)
	add_child(income_label)
	
	spending_label = make_text(
		"Spending: $0.00", 21, Color("#F0B9BD")
	)
	add_child(spending_label)
	
	bills_label = make_text(
		"Unpaid Bills: $0.00", 21, Color("#E9EFF7")
	)
	add_child(bills_label)
	
	after_bills_label = make_text(
		"After Unpaid Bills: $0.00",
		20,
		Color("#E9EFF7")
	)
	add_child(after_bills_label)
	
	add_child(HSeparator.new())
	
	add_child(make_text(
		"RECENT TRANSACTIONS",
		21,
		Color("#E9EFF7")
	))

	# Scrollable transaction history.
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	
	transactions_list = VBoxContainer.new()
	transactions_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	transactions_list.add_theme_constant_override("separation", 12)
	scroll.add_child(transactions_list)


func display_snapshot(snapshot: Dictionary) -> void:
	var balance: float = float(snapshot.get("balance", 0.0))
	var income: float = float(snapshot.get("income", 0.0))
	var spending: float = float(snapshot.get("spending", 0.0))
	var bills: float = float(snapshot.get("unpaid_bills", 0.0))
	var after_bills: float = float(snapshot.get("after_bills", 0.0))
	
	balance_label.text = "$%.2f" % balance
	income_label.text = "Total Income: $%.2f" % income
	spending_label.text = "Total Spending: $%.2f" % spending
	bills_label.text = "Unpaid Bills: $%.2f" % bills
	
	if after_bills >= 0.0:
		after_bills_label.text = "After Unpaid Bills: $%.2f" % after_bills
		after_bills_label.add_theme_color_override(
			"font_color", Color("#A6D8B5")
		)
	else:
		after_bills_label.text = "After Unpaid Bills: -$%.2f" % absf(after_bills)
		after_bills_label.add_theme_color_override(
			"font_color", Color("#F0B9BD")
		)
	
	var transactions: Array = snapshot.get("transactions", [])
	refresh_transactions(transactions)


func refresh_transactions(transactions: Array) -> void:
	for child in transactions_list.get_children():
		child.queue_free()
	
	if transactions.is_empty():
		transactions_list.add_child(
			make_text(
				"No transactions yet.",
				18,
				Color("#B8C9DD")
			)
		)
		return

	# Show the 15 most recent transactions, newest first.
	var start_index: int = transactions.size() - 1
	var end_index: int = maxi(0, transactions.size() - 15)
	
	for i in range(start_index, end_index - 1, -1):
		var entry: Dictionary = transactions[i]
		var amount: float = float(entry.get("amount", 0.0))
		
		var amount_text: String = ""
		var entry_color: Color
		
		if amount >= 0.0:
			amount_text = "+$%.2f" % amount
			entry_color = Color("#A6D8B5")
		else:
			amount_text = "-$%.2f" % absf(amount)
			entry_color = Color("#F0B9BD")
		
		var description: String = "%s\nDay %d | %s | %s | %s" % [
			str(entry.get("reason", "Transaction")),
			int(entry.get("day", 1)),
			str(entry.get("period", "Morning")),
			str(entry.get("category", "Other")),
			amount_text
		]
		
		var row := make_text(
			description,
			17,
			entry_color
		)
		
		transactions_list.add_child(row)
		transactions_list.add_child(HSeparator.new())


func _on_back_pressed() -> void:
	back_requested.emit()
