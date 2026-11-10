class_name FinancesApp
extends VBoxContainer

signal back_requested

var balance_label: Label
var income_label: Label
var spending_label: Label
var bills_label: Label
var after_bills_label: Label
var bill_countdown_list: VBoxContainer
var transactions_list: VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 12)
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

	var title := make_text("FINANCES", 26, Color("#E9EFF7"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(title)

	# Main balance card.
	var balance_card := PanelContainer.new()
	balance_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(balance_card)

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#263B39")
	card_style.set_corner_radius_all(18)
	balance_card.add_theme_stylebox_override("panel", card_style)

	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 16)
	card_margin.add_theme_constant_override("margin_right", 16)
	card_margin.add_theme_constant_override("margin_top", 14)
	card_margin.add_theme_constant_override("margin_bottom", 14)
	balance_card.add_child(card_margin)

	var card_contents := VBoxContainer.new()
	card_margin.add_child(card_contents)
	card_contents.add_child(make_text("CURRENT BALANCE", 17, Color("#C3D8D3")))

	balance_label = make_text("$0.00", 32, Color("#BAE8C6"))
	card_contents.add_child(balance_label)

	# Keep the totals visible while scrolling through individual bills.
	income_label = make_text("Income: $0.00", 19, Color("#A6D8B5"))
	add_child(income_label)

	spending_label = make_text("Spending: $0.00", 19, Color("#F0B9BD"))
	add_child(spending_label)

	bills_label = make_text("Unpaid Bills: $0.00", 19, Color("#E9EFF7"))
	add_child(bills_label)

	after_bills_label = make_text(
		"After Unpaid Bills: $0.00", 18, Color("#E9EFF7")
	)
	add_child(after_bills_label)

	# A SINGLE scroll area contains both bill countdowns and transactions.
	# Five bills will not crowd the transaction history off the phone.
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var scroll_contents := VBoxContainer.new()
	scroll_contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_contents.add_theme_constant_override("separation", 14)
	scroll.add_child(scroll_contents)

	scroll_contents.add_child(HSeparator.new())
	scroll_contents.add_child(make_text(
		"BILL SCHEDULE", 21, Color("#E9EFF7")
	))

	bill_countdown_list = VBoxContainer.new()
	bill_countdown_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bill_countdown_list.add_theme_constant_override("separation", 10)
	scroll_contents.add_child(bill_countdown_list)

	scroll_contents.add_child(HSeparator.new())
	scroll_contents.add_child(make_text(
		"RECENT TRANSACTIONS", 21, Color("#E9EFF7")
	))

	transactions_list = VBoxContainer.new()
	transactions_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	transactions_list.add_theme_constant_override("separation", 12)
	scroll_contents.add_child(transactions_list)


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

	# New field from Fry's updated get_finance_snapshot().
	var bill_entries: Array = snapshot.get("bills", [])
	refresh_bill_countdowns(bill_entries)

	var transactions: Array = snapshot.get("transactions", [])
	refresh_transactions(transactions)


func _sort_bills(a: Dictionary, b: Dictionary) -> bool:
	# Unpaid bills first; keep the nearest due dates at the top.
	var a_paid: bool = bool(a.get("paid", false))
	var b_paid: bool = bool(b.get("paid", false))
	if a_paid != b_paid:
		return not a_paid
	return int(a.get("due_day", 0)) < int(b.get("due_day", 0))


func refresh_bill_countdowns(bills: Array) -> void:
	for child in bill_countdown_list.get_children():
		bill_countdown_list.remove_child(child)
		child.queue_free()

	if bills.is_empty():
		bill_countdown_list.add_child(make_text(
			"No bills available.", 18, Color("#B8C9DD")
		))
		return

	var ordered_bills: Array = bills.duplicate(true)
	ordered_bills.sort_custom(_sort_bills)

	for entry in ordered_bills:
		var bill: Dictionary = entry
		var bill_display_name: String = str(bill.get("name", "Bill"))
		var amount: float = float(bill.get("amount", 0.0))
		var paid: bool = bool(bill.get("paid", false))
		var days_until_due: int = int(bill.get("days_until_due", 0))
		var status: String = str(bill.get("status", ""))

		var status_color: Color = Color("#B8C9DD")
		if paid:
			status_color = Color("#8BDDA9")
		elif days_until_due < 0:
			status_color = Color("#F1A5A0")
		elif days_until_due <= 2:
			status_color = Color("#EBC477")

		var bill_card := PanelContainer.new()
		bill_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bill_countdown_list.add_child(bill_card)

		var style := StyleBoxFlat.new()
		style.bg_color = Color("#223246")
		style.border_color = Color("#40556A")
		style.set_border_width_all(1)
		style.set_corner_radius_all(12)
		bill_card.add_theme_stylebox_override("panel", style)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		bill_card.add_child(margin)

		var contents := VBoxContainer.new()
		contents.add_theme_constant_override("separation", 4)
		margin.add_child(contents)

		var heading := HBoxContainer.new()
		heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		heading.add_theme_constant_override("separation", 12)
		contents.add_child(heading)

		# Only the name is allowed to wrap. The amount needs its own
		# guaranteed width so $25.00 never stacks one character per line.
		var bill_name := make_text(bill_display_name, 18, Color("#E9EFF7"))
		bill_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bill_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		heading.add_child(bill_name)

		var bill_amount := make_text("$%.2f" % amount, 18, Color("#E9EFF7"))
		bill_amount.autowrap_mode = TextServer.AUTOWRAP_OFF
		bill_amount.custom_minimum_size = Vector2(105, 0)
		bill_amount.size_flags_horizontal = Control.SIZE_SHRINK_END
		bill_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		bill_amount.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		heading.add_child(bill_amount)

		var status_label := make_text(status, 16, status_color)
		contents.add_child(status_label)


func refresh_transactions(transactions: Array) -> void:
	for child in transactions_list.get_children():
		transactions_list.remove_child(child)
		child.queue_free()

	if transactions.is_empty():
		transactions_list.add_child(make_text(
			"No transactions yet.", 18, Color("#B8C9DD")
		))
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

		var row := make_text(description, 17, entry_color)
		transactions_list.add_child(row)
		transactions_list.add_child(HSeparator.new())


func _on_back_pressed() -> void:
	back_requested.emit()
