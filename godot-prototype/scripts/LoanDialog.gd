extends ConfirmationDialog
class_name LoanDialog

## Dialog for taking out loans

signal loan_created(loan: Loan)

# UI Elements
var amount_input: SpinBox
var term_selector: OptionButton
var interest_rate_label: Label
var weekly_payment_label: Label
var total_cost_label: Label
var credit_limit_label: Label

# Data
var airline: Airline = null
var selected_amount: float = 0.0
var selected_term: int = 52  # weeks

func _init() -> void:
	title = "Take Loan"
	size = Vector2i(500, 400)
	ok_button_text = "Take Loan"

func _ready() -> void:
	get_cancel_button().text = "Cancel"
	build_ui()
	confirmed.connect(_on_confirmed)
	hide()

func build_ui() -> void:
	"""Build the loan dialog UI"""
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(480, 300)
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(vbox)

	# Title section
	var title_vbox = VBoxContainer.new()
	title_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(title_vbox)

	var title_label = Label.new()
	title_label.text = "Loan Application"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	title_vbox.add_child(title_label)

	var subtitle = Label.new()
	subtitle.text = "Borrow money to expand your airline operations"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_secondary())
	title_vbox.add_child(subtitle)

	# Credit limit info
	var credit_panel = PanelContainer.new()
	var credit_style = UITheme.create_panel_style()
	credit_panel.add_theme_stylebox_override("panel", credit_style)
	vbox.add_child(credit_panel)

	var credit_margin = MarginContainer.new()
	credit_margin.add_theme_constant_override("margin_all", 12)
	credit_panel.add_child(credit_margin)

	var credit_hbox = HBoxContainer.new()
	credit_margin.add_child(credit_hbox)

	var credit_title = Label.new()
	credit_title.text = "Available Credit:"
	credit_title.add_theme_font_size_override("font_size", 14)
	credit_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	credit_hbox.add_child(credit_title)

	credit_limit_label = Label.new()
	credit_limit_label.add_theme_font_size_override("font_size", 14)
	credit_limit_label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	credit_hbox.add_child(credit_limit_label)

	var credit_spacer = Control.new()
	credit_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	credit_hbox.add_child(credit_spacer)

	# Loan amount
	var amount_container = VBoxContainer.new()
	amount_container.add_theme_constant_override("separation", 8)
	vbox.add_child(amount_container)

	var amount_title = Label.new()
	amount_title.text = "Loan Amount:"
	amount_title.add_theme_font_size_override("font_size", 14)
	amount_title.add_theme_color_override("font_color", UITheme.get_text_primary())
	amount_container.add_child(amount_title)

	amount_input = SpinBox.new()
	amount_input.custom_minimum_size = Vector2(0, 40)
	amount_input.min_value = 10000.0
	amount_input.max_value = 100000000.0
	amount_input.step = 10000.0
	amount_input.value = 100000.0
	amount_input.value_changed.connect(_on_amount_changed)
	amount_container.add_child(amount_input)

	# Loan term
	var term_container = VBoxContainer.new()
	term_container.add_theme_constant_override("separation", 8)
	vbox.add_child(term_container)

	var term_title = Label.new()
	term_title.text = "Loan Term:"
	term_title.add_theme_font_size_override("font_size", 14)
	term_title.add_theme_color_override("font_color", UITheme.get_text_primary())
	term_container.add_child(term_title)

	term_selector = OptionButton.new()
	term_selector.custom_minimum_size = Vector2(0, 40)
	term_selector.add_item("26 weeks (6 months)", 26)
	term_selector.add_item("52 weeks (1 year)", 52)
	term_selector.add_item("104 weeks (2 years)", 104)
	term_selector.add_item("156 weeks (3 years)", 156)
	term_selector.selected = 1  # Default to 1 year
	term_selector.item_selected.connect(_on_term_changed)
	term_container.add_child(term_selector)

	# Loan details panel
	var details_panel = PanelContainer.new()
	var details_style = UITheme.create_panel_style()
	details_panel.add_theme_stylebox_override("panel", details_style)
	vbox.add_child(details_panel)

	var details_margin = MarginContainer.new()
	details_margin.add_theme_constant_override("margin_all", 12)
	details_panel.add_child(details_margin)

	var details_vbox = VBoxContainer.new()
	details_vbox.add_theme_constant_override("separation", 8)
	details_margin.add_child(details_vbox)

	var details_title = Label.new()
	details_title.text = "Loan Details"
	details_title.add_theme_font_size_override("font_size", 14)
	details_title.add_theme_color_override("font_color", UITheme.get_text_primary())
	details_vbox.add_child(details_title)

	# Interest rate
	var rate_hbox = HBoxContainer.new()
	rate_hbox.add_theme_constant_override("separation", 12)
	details_vbox.add_child(rate_hbox)

	var rate_title = Label.new()
	rate_title.text = "Interest Rate:"
	rate_title.add_theme_font_size_override("font_size", 12)
	rate_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	rate_title.custom_minimum_size = Vector2(120, 0)
	rate_hbox.add_child(rate_title)

	interest_rate_label = Label.new()
	interest_rate_label.add_theme_font_size_override("font_size", 12)
	interest_rate_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	rate_hbox.add_child(interest_rate_label)

	# Weekly payment
	var payment_hbox = HBoxContainer.new()
	payment_hbox.add_theme_constant_override("separation", 12)
	details_vbox.add_child(payment_hbox)

	var payment_title = Label.new()
	payment_title.text = "Weekly Payment:"
	payment_title.add_theme_font_size_override("font_size", 12)
	payment_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	payment_title.custom_minimum_size = Vector2(120, 0)
	payment_hbox.add_child(payment_title)

	weekly_payment_label = Label.new()
	weekly_payment_label.add_theme_font_size_override("font_size", 12)
	weekly_payment_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	payment_hbox.add_child(weekly_payment_label)

	# Total cost
	var total_hbox = HBoxContainer.new()
	total_hbox.add_theme_constant_override("separation", 12)
	details_vbox.add_child(total_hbox)

	var total_title = Label.new()
	total_title.text = "Total Cost:"
	total_title.add_theme_font_size_override("font_size", 12)
	total_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	total_title.custom_minimum_size = Vector2(120, 0)
	total_hbox.add_child(total_title)

	total_cost_label = Label.new()
	total_cost_label.add_theme_font_size_override("font_size", 12)
	total_cost_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	total_hbox.add_child(total_cost_label)

func show_for_airline(p_airline: Airline) -> void:
	"""Show dialog for specific airline"""
	airline = p_airline
	if not airline:
		return

	# Update credit limit
	var credit_limit = airline.get_credit_limit()
	var current_debt = airline.total_debt
	var available_credit = max(0.0, credit_limit - current_debt)
	
	credit_limit_label.text = UITheme.format_money(available_credit)
	
	# Set max loan amount to available credit
	amount_input.max_value = available_credit
	if amount_input.value > available_credit:
		amount_input.value = available_credit
	
	# Update loan details
	_update_loan_details()
	
	popup_centered()

func _on_amount_changed(value: float) -> void:
	"""Handle loan amount change"""
	selected_amount = value
	_update_loan_details()

func _on_term_changed(index: int) -> void:
	"""Handle loan term change"""
	selected_term = term_selector.get_item_id(index)
	_update_loan_details()

func _update_loan_details() -> void:
	"""Update loan details display"""
	if not airline:
		return

	var interest_rate = airline.get_interest_rate()
	interest_rate_label.text = "%.1f%%" % (interest_rate * 100.0)

	# Calculate loan details
	var temp_loan = Loan.new(
		0,  # id will be assigned
		airline.id,
		selected_amount,
		interest_rate,
		selected_term,
		GameData.current_week
	)

	weekly_payment_label.text = UITheme.format_money(temp_loan.weekly_payment)
	
	# Total cost = weekly payment * term
	var total_cost = temp_loan.weekly_payment * selected_term
	total_cost_label.text = UITheme.format_money(total_cost)

func _on_confirmed() -> void:
	"""Handle dialog confirmation"""
	if not airline:
		return

	# Validate loan amount
	var credit_limit = airline.get_credit_limit()
	var current_debt = airline.total_debt
	var available_credit = max(0.0, credit_limit - current_debt)

	if selected_amount > available_credit:
		# Show error
		var error_dialog = AcceptDialog.new()
		error_dialog.title = "Loan Denied"
		error_dialog.dialog_text = "Loan amount exceeds available credit limit of %s" % UITheme.format_money(available_credit)
		get_tree().root.add_child(error_dialog)
		error_dialog.popup_centered()
		return

	# Create loan
	var loan = Loan.new(
		GameData.next_loan_id,
		airline.id,
		selected_amount,
		airline.get_interest_rate(),
		selected_term,
		GameData.current_week
	)
	GameData.next_loan_id += 1

	# Add loan to airline
	airline.add_loan(loan)
	airline.add_balance(selected_amount)

	# Emit signal
	loan_created.emit(loan)

	print("Loan created: $%.0f at %.1f%% for %d weeks" % [
		selected_amount,
		airline.get_interest_rate() * 100.0,
		selected_term
	])
