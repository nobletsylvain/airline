extends Control
class_name FinancesPanel

## Financial Overview Panel - Display balance, revenue, expenses, loans

signal loan_requested
signal loan_payoff_requested(loan: Loan)

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var balance_card: PanelContainer
var revenue_expenses_card: PanelContainer
var loans_card: PanelContainer
var credit_card: PanelContainer

# Labels
var balance_label: Label
var weekly_profit_label: Label
var weekly_revenue_label: Label
var weekly_expenses_label: Label
var total_debt_label: Label
var weekly_payment_label: Label
var credit_limit_label: Label
var interest_rate_label: Label

func _ready() -> void:
	build_ui()
	refresh()

func build_ui() -> void:
	"""Build the finances panel UI"""
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var outer_vbox = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 16)
	margin.add_child(outer_vbox)

	# Header
	create_header(outer_vbox)

	# Scrollable content
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)

	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 16)
	scroll_container.add_child(main_vbox)

	# Financial cards
	create_balance_card(main_vbox)
	create_revenue_expenses_card(main_vbox)
	create_loans_card(main_vbox)
	create_credit_card(main_vbox)

func create_header(parent: VBoxContainer) -> void:
	"""Create header section"""
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 16)
	parent.add_child(header_hbox)

	var title_vbox = VBoxContainer.new()
	title_vbox.add_theme_constant_override("separation", 4)
	header_hbox.add_child(title_vbox)

	var title = Label.new()
	title.text = "Financial Overview"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	title_vbox.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Monitor your airline's financial health and manage debt"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_secondary())
	title_vbox.add_child(subtitle)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

func create_balance_card(parent: VBoxContainer) -> void:
	"""Create balance overview card"""
	balance_card = create_finance_card("Current Balance", parent)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 8)
	balance_card.get_node("MarginContainer").add_child(content_vbox)

	balance_label = Label.new()
	balance_label.add_theme_font_size_override("font_size", 32)
	content_vbox.add_child(balance_label)

	weekly_profit_label = Label.new()
	weekly_profit_label.add_theme_font_size_override("font_size", 14)
	content_vbox.add_child(weekly_profit_label)

func create_revenue_expenses_card(parent: VBoxContainer) -> void:
	"""Create revenue and expenses card"""
	revenue_expenses_card = create_finance_card("Weekly Performance", parent)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 12)
	revenue_expenses_card.get_node("MarginContainer").add_child(content_vbox)

	# Revenue
	var revenue_hbox = HBoxContainer.new()
	revenue_hbox.add_theme_constant_override("separation", 12)
	content_vbox.add_child(revenue_hbox)

	var revenue_title = Label.new()
	revenue_title.text = "Revenue:"
	revenue_title.add_theme_font_size_override("font_size", 14)
	revenue_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	revenue_title.custom_minimum_size = Vector2(120, 0)
	revenue_hbox.add_child(revenue_title)

	weekly_revenue_label = Label.new()
	weekly_revenue_label.add_theme_font_size_override("font_size", 14)
	weekly_revenue_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	revenue_hbox.add_child(weekly_revenue_label)

	var revenue_spacer = Control.new()
	revenue_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	revenue_hbox.add_child(revenue_spacer)

	# Expenses
	var expenses_hbox = HBoxContainer.new()
	expenses_hbox.add_theme_constant_override("separation", 12)
	content_vbox.add_child(expenses_hbox)

	var expenses_title = Label.new()
	expenses_title.text = "Expenses:"
	expenses_title.add_theme_font_size_override("font_size", 14)
	expenses_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	expenses_title.custom_minimum_size = Vector2(120, 0)
	expenses_hbox.add_child(expenses_title)

	weekly_expenses_label = Label.new()
	weekly_expenses_label.add_theme_font_size_override("font_size", 14)
	weekly_expenses_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
	expenses_hbox.add_child(weekly_expenses_label)

	var expenses_spacer = Control.new()
	expenses_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	expenses_hbox.add_child(expenses_spacer)

func create_loans_card(parent: VBoxContainer) -> void:
	"""Create loans management card"""
	loans_card = create_finance_card("Active Loans", parent)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 12)
	loans_card.get_node("MarginContainer").add_child(content_vbox)

	# Total debt summary
	var debt_hbox = HBoxContainer.new()
	debt_hbox.add_theme_constant_override("separation", 12)
	content_vbox.add_child(debt_hbox)

	var debt_title = Label.new()
	debt_title.text = "Total Debt:"
	debt_title.add_theme_font_size_override("font_size", 14)
	debt_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	debt_title.custom_minimum_size = Vector2(120, 0)
	debt_hbox.add_child(debt_title)

	total_debt_label = Label.new()
	total_debt_label.add_theme_font_size_override("font_size", 14)
	total_debt_label.add_theme_color_override("font_color", UITheme.WARNING_COLOR)
	debt_hbox.add_child(total_debt_label)

	var debt_spacer = Control.new()
	debt_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debt_hbox.add_child(debt_spacer)

	# Weekly payment
	var payment_hbox = HBoxContainer.new()
	payment_hbox.add_theme_constant_override("separation", 12)
	content_vbox.add_child(payment_hbox)

	var payment_title = Label.new()
	payment_title.text = "Weekly Payment:"
	payment_title.add_theme_font_size_override("font_size", 14)
	payment_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	payment_title.custom_minimum_size = Vector2(120, 0)
	payment_hbox.add_child(payment_title)

	weekly_payment_label = Label.new()
	weekly_payment_label.add_theme_font_size_override("font_size", 14)
	weekly_payment_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	payment_hbox.add_child(weekly_payment_label)

	var payment_spacer = Control.new()
	payment_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	payment_hbox.add_child(payment_spacer)

	# Loans list
	var loans_list = VBoxContainer.new()
	loans_list.name = "LoansList"
	loans_list.add_theme_constant_override("separation", 8)
	content_vbox.add_child(loans_list)

	# Take loan button
	var take_loan_btn = Button.new()
	take_loan_btn.text = "Take Loan"
	take_loan_btn.custom_minimum_size = Vector2(0, 40)
	take_loan_btn.add_theme_font_size_override("font_size", 14)
	var btn_style = UITheme.create_primary_button_style()
	take_loan_btn.add_theme_stylebox_override("normal", btn_style)
	take_loan_btn.pressed.connect(_on_take_loan_pressed)
	content_vbox.add_child(take_loan_btn)

func create_credit_card(parent: VBoxContainer) -> void:
	"""Create credit information card"""
	credit_card = create_finance_card("Credit Information", parent)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 12)
	credit_card.get_node("MarginContainer").add_child(content_vbox)

	# Credit limit
	var credit_hbox = HBoxContainer.new()
	credit_hbox.add_theme_constant_override("separation", 12)
	content_vbox.add_child(credit_hbox)

	var credit_title = Label.new()
	credit_title.text = "Credit Limit:"
	credit_title.add_theme_font_size_override("font_size", 14)
	credit_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	credit_title.custom_minimum_size = Vector2(120, 0)
	credit_hbox.add_child(credit_title)

	credit_limit_label = Label.new()
	credit_limit_label.add_theme_font_size_override("font_size", 14)
	credit_limit_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	credit_hbox.add_child(credit_limit_label)

	var credit_spacer = Control.new()
	credit_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	credit_hbox.add_child(credit_spacer)

	# Interest rate
	var rate_hbox = HBoxContainer.new()
	rate_hbox.add_theme_constant_override("separation", 12)
	content_vbox.add_child(rate_hbox)

	var rate_title = Label.new()
	rate_title.text = "Interest Rate:"
	rate_title.add_theme_font_size_override("font_size", 14)
	rate_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	rate_title.custom_minimum_size = Vector2(120, 0)
	rate_hbox.add_child(rate_title)

	interest_rate_label = Label.new()
	interest_rate_label.add_theme_font_size_override("font_size", 14)
	interest_rate_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	rate_hbox.add_child(interest_rate_label)

	var rate_spacer = Control.new()
	rate_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rate_hbox.add_child(rate_spacer)

func create_finance_card(title: String, parent: VBoxContainer) -> PanelContainer:
	"""Create a styled finance card"""
	var card = PanelContainer.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.get_card_bg()
	style.border_color = UITheme.get_panel_border()
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	style.shadow_color = Color(0, 0, 0, 0.05)
	style.shadow_size = 2
	card.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_all", 16)
	card.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var card_title = Label.new()
	card_title.text = title
	card_title.add_theme_font_size_override("font_size", 18)
	card_title.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(card_title)

	parent.add_child(card)
	return card

func refresh() -> void:
	"""Refresh all financial data"""
	if not GameData.player_airline:
		return

	var airline = GameData.player_airline

	# Balance
	balance_label.text = UITheme.format_money(airline.balance)
	var profit = airline.calculate_weekly_profit()
	var profit_color = UITheme.get_profit_color(profit)
	var profit_sign = "+" if profit >= 0 else ""
	weekly_profit_label.text = "Weekly Profit: %s%s" % [profit_sign, UITheme.format_money(profit)]
	weekly_profit_label.add_theme_color_override("font_color", profit_color)

	# Revenue and expenses
	weekly_revenue_label.text = UITheme.format_money(airline.weekly_revenue)
	weekly_expenses_label.text = UITheme.format_money(airline.weekly_expenses)

	# Loans
	total_debt_label.text = UITheme.format_money(airline.total_debt)
	weekly_payment_label.text = UITheme.format_money(airline.weekly_loan_payment)

	# Credit
	credit_limit_label.text = UITheme.format_money(airline.get_credit_limit())
	var interest_rate = airline.get_interest_rate()
	interest_rate_label.text = "%.1f%%" % (interest_rate * 100.0)

	# Update loans list
	_update_loans_list()

func _update_loans_list() -> void:
	"""Update the loans list display"""
	var loans_list = loans_card.get_node_or_null("MarginContainer/VBoxContainer/LoansList")
	if not loans_list:
		return

	# Clear existing loan items
	for child in loans_list.get_children():
		child.queue_free()

	if not GameData.player_airline:
		return

	# Add loan items
	for loan in GameData.player_airline.loans:
		if loan.is_paid_off():
			continue

		var loan_item = create_loan_item(loan)
		loans_list.add_child(loan_item)

func create_loan_item(loan: Loan) -> Control:
	"""Create a loan item card"""
	var item = PanelContainer.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.get_panel_bg()
	style.border_color = UITheme.get_panel_border()
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	item.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_all", 8)
	item.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	# Loan info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	var loan_amount = Label.new()
	loan_amount.text = "Principal: %s" % UITheme.format_money(loan.principal)
	loan_amount.add_theme_font_size_override("font_size", 14)
	loan_amount.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(loan_amount)

	var loan_details = Label.new()
	loan_details.text = "Balance: %s | Rate: %.1f%% | %d weeks remaining" % [
		UITheme.format_money(loan.remaining_balance),
		loan.interest_rate * 100.0,
		loan.weeks_remaining
	]
	loan_details.add_theme_font_size_override("font_size", 12)
	loan_details.add_theme_color_override("font_color", UITheme.get_text_secondary())
	info_vbox.add_child(loan_details)

	# Pay off button
	var payoff_btn = Button.new()
	payoff_btn.text = "Pay Off"
	payoff_btn.custom_minimum_size = Vector2(100, 32)
	payoff_btn.add_theme_font_size_override("font_size", 12)
	var btn_style = UITheme.create_secondary_button_style()
	payoff_btn.add_theme_stylebox_override("normal", btn_style)
	payoff_btn.pressed.connect(_on_payoff_loan_pressed.bind(loan))
	hbox.add_child(payoff_btn)

	return item

func _on_take_loan_pressed() -> void:
	"""Handle take loan button press"""
	loan_requested.emit()

func _on_payoff_loan_pressed(loan: Loan) -> void:
	"""Handle pay off loan button press"""
	loan_payoff_requested.emit(loan)
