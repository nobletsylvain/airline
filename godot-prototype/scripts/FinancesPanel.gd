## FinancesPanel.gd
## Displays airline financial overview including balance, revenue/expenses,
## detailed breakdowns by route and category, historical trends, and loan management.
## Part of the main dashboard UI.
extends Control
class_name FinancesPanel

## Emitted when user clicks "Take Loan" button to open loan dialog
signal loan_requested

## Emitted when user requests to pay off a specific loan early
## @param loan: The Loan resource to pay off
signal loan_payoff_requested(loan: Loan)

## Standard width for label columns in financial displays
const LABEL_COLUMN_WIDTH := 140.0
const VALUE_COLUMN_WIDTH := 100.0

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer

# Cards
var summary_card: PanelContainer
var revenue_detail_card: PanelContainer
var expense_detail_card: PanelContainer
var history_card: PanelContainer
var loans_card: PanelContainer
var credit_card: PanelContainer

# Summary labels
var balance_label: Label
var balance_trend_label: Label
var total_revenue_label: Label
var total_expenses_label: Label
var net_profit_label: Label
var profit_margin_label: Label

# Revenue detail container
var revenue_routes_container: VBoxContainer

# Expense detail labels
var expense_fuel_label: Label
var expense_crew_label: Label
var expense_maintenance_label: Label
var expense_airport_label: Label
var expense_research_label: Label
var expense_loan_interest_label: Label
var expense_total_label: Label

# History labels (simple table)
var history_container: VBoxContainer

# Loans labels
var total_debt_label: Label
var weekly_payment_label: Label

# Credit labels
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

	# Financial cards in order
	create_summary_card(main_vbox)
	create_revenue_detail_card(main_vbox)
	create_expense_detail_card(main_vbox)
	create_history_card(main_vbox)
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
	title.text = "💰 Financial Overview"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	title_vbox.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Monitor revenue, expenses, and financial health"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_secondary())
	title_vbox.add_child(subtitle)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)


func create_summary_card(parent: VBoxContainer) -> void:
	"""Create top summary card with key metrics"""
	summary_card = create_finance_card("📊 Weekly Summary", parent)
	var card_vbox = summary_card.get_node("MarginContainer/VBoxContainer")
	
	# Main metrics grid (2 columns)
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 12)
	card_vbox.add_child(grid)
	
	# Balance (large, prominent)
	var balance_vbox = VBoxContainer.new()
	balance_vbox.add_theme_constant_override("separation", 4)
	grid.add_child(balance_vbox)
	
	var balance_title = Label.new()
	balance_title.text = "Cash on Hand"
	balance_title.add_theme_font_size_override("font_size", 12)
	balance_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	balance_vbox.add_child(balance_title)
	
	balance_label = Label.new()
	balance_label.add_theme_font_size_override("font_size", 28)
	balance_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	balance_vbox.add_child(balance_label)
	
	balance_trend_label = Label.new()
	balance_trend_label.add_theme_font_size_override("font_size", 12)
	balance_vbox.add_child(balance_trend_label)
	
	# Profit margin
	var margin_vbox = VBoxContainer.new()
	margin_vbox.add_theme_constant_override("separation", 4)
	grid.add_child(margin_vbox)
	
	var margin_title = Label.new()
	margin_title.text = "Profit Margin"
	margin_title.add_theme_font_size_override("font_size", 12)
	margin_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	margin_vbox.add_child(margin_title)
	
	profit_margin_label = Label.new()
	profit_margin_label.add_theme_font_size_override("font_size", 28)
	margin_vbox.add_child(profit_margin_label)
	
	# Separator
	var sep = HSeparator.new()
	card_vbox.add_child(sep)
	
	# Revenue / Expenses / Net Profit row
	var metrics_hbox = HBoxContainer.new()
	metrics_hbox.add_theme_constant_override("separation", 30)
	card_vbox.add_child(metrics_hbox)
	
	# Total Revenue
	var rev_vbox = VBoxContainer.new()
	rev_vbox.add_theme_constant_override("separation", 2)
	metrics_hbox.add_child(rev_vbox)
	
	var rev_title = Label.new()
	rev_title.text = "Total Revenue"
	rev_title.add_theme_font_size_override("font_size", 11)
	rev_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	rev_vbox.add_child(rev_title)
	
	total_revenue_label = Label.new()
	total_revenue_label.add_theme_font_size_override("font_size", 18)
	total_revenue_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	rev_vbox.add_child(total_revenue_label)
	
	# Total Expenses
	var exp_vbox = VBoxContainer.new()
	exp_vbox.add_theme_constant_override("separation", 2)
	metrics_hbox.add_child(exp_vbox)
	
	var exp_title = Label.new()
	exp_title.text = "Total Expenses"
	exp_title.add_theme_font_size_override("font_size", 11)
	exp_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	exp_vbox.add_child(exp_title)
	
	total_expenses_label = Label.new()
	total_expenses_label.add_theme_font_size_override("font_size", 18)
	total_expenses_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
	exp_vbox.add_child(total_expenses_label)
	
	# Net Profit
	var profit_vbox = VBoxContainer.new()
	profit_vbox.add_theme_constant_override("separation", 2)
	metrics_hbox.add_child(profit_vbox)
	
	var profit_title = Label.new()
	profit_title.text = "Net Profit/Loss"
	profit_title.add_theme_font_size_override("font_size", 11)
	profit_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	profit_vbox.add_child(profit_title)
	
	net_profit_label = Label.new()
	net_profit_label.add_theme_font_size_override("font_size", 18)
	profit_vbox.add_child(net_profit_label)


func create_revenue_detail_card(parent: VBoxContainer) -> void:
	"""Create revenue breakdown by route card"""
	revenue_detail_card = create_finance_card("📈 Revenue by Route", parent)
	var card_vbox = revenue_detail_card.get_node("MarginContainer/VBoxContainer")
	
	var description = Label.new()
	description.text = "Weekly revenue contribution from each route"
	description.add_theme_font_size_override("font_size", 11)
	description.add_theme_color_override("font_color", UITheme.get_text_muted())
	card_vbox.add_child(description)
	
	# Header row
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	card_vbox.add_child(header)
	
	var route_header = Label.new()
	route_header.text = "Route"
	route_header.custom_minimum_size = Vector2(120, 0)
	route_header.add_theme_font_size_override("font_size", 11)
	route_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	header.add_child(route_header)
	
	var pax_header = Label.new()
	pax_header.text = "Passengers"
	pax_header.custom_minimum_size = Vector2(80, 0)
	pax_header.add_theme_font_size_override("font_size", 11)
	pax_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	header.add_child(pax_header)
	
	var rev_header = Label.new()
	rev_header.text = "Revenue"
	rev_header.custom_minimum_size = Vector2(100, 0)
	rev_header.add_theme_font_size_override("font_size", 11)
	rev_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	rev_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(rev_header)
	
	var pct_header = Label.new()
	pct_header.text = "% of Total"
	pct_header.custom_minimum_size = Vector2(70, 0)
	pct_header.add_theme_font_size_override("font_size", 11)
	pct_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	pct_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(pct_header)
	
	# Routes container
	revenue_routes_container = VBoxContainer.new()
	revenue_routes_container.add_theme_constant_override("separation", 6)
	card_vbox.add_child(revenue_routes_container)


func create_expense_detail_card(parent: VBoxContainer) -> void:
	"""Create expense breakdown by category card"""
	expense_detail_card = create_finance_card("📉 Expenses by Category", parent)
	var card_vbox = expense_detail_card.get_node("MarginContainer/VBoxContainer")
	
	var description = Label.new()
	description.text = "Weekly operating costs breakdown"
	description.add_theme_font_size_override("font_size", 11)
	description.add_theme_color_override("font_color", UITheme.get_text_muted())
	card_vbox.add_child(description)
	
	# Expense rows
	var expense_types: Array = [
		["⛽ Fuel", "expense_fuel"],
		["👥 Crew", "expense_crew"],
		["🔧 Maintenance", "expense_maintenance"],
		["🛫 Airport Fees", "expense_airport"],
		["🔍 Market Research", "expense_research"],
		["💳 Loan Interest", "expense_loan_interest"],
	]
	
	for expense_info in expense_types:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		card_vbox.add_child(hbox)
		
		var title = Label.new()
		title.text = expense_info[0]
		title.add_theme_font_size_override("font_size", 13)
		title.add_theme_color_override("font_color", UITheme.get_text_secondary())
		title.custom_minimum_size = Vector2(LABEL_COLUMN_WIDTH, 0)
		hbox.add_child(title)
		
		var value_label = Label.new()
		value_label.add_theme_font_size_override("font_size", 13)
		value_label.add_theme_color_override("font_color", UITheme.get_text_primary())
		hbox.add_child(value_label)
		
		# Store reference
		match expense_info[1]:
			"expense_fuel":
				expense_fuel_label = value_label
			"expense_crew":
				expense_crew_label = value_label
			"expense_maintenance":
				expense_maintenance_label = value_label
			"expense_airport":
				expense_airport_label = value_label
			"expense_research":
				expense_research_label = value_label
			"expense_loan_interest":
				expense_loan_interest_label = value_label
		
		var spacer = Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(spacer)
	
	# Separator
	var sep = HSeparator.new()
	card_vbox.add_child(sep)
	
	# Total row
	var total_hbox = HBoxContainer.new()
	total_hbox.add_theme_constant_override("separation", 12)
	card_vbox.add_child(total_hbox)
	
	var total_title = Label.new()
	total_title.text = "📊 Total Weekly Expenses"
	total_title.add_theme_font_size_override("font_size", 14)
	total_title.add_theme_color_override("font_color", UITheme.get_text_primary())
	total_title.custom_minimum_size = Vector2(LABEL_COLUMN_WIDTH, 0)
	total_hbox.add_child(total_title)
	
	expense_total_label = Label.new()
	expense_total_label.add_theme_font_size_override("font_size", 14)
	expense_total_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
	total_hbox.add_child(expense_total_label)


func create_history_card(parent: VBoxContainer) -> void:
	"""Create historical performance card"""
	history_card = create_finance_card("📅 Performance History (Last 8 Weeks)", parent)
	var card_vbox = history_card.get_node("MarginContainer/VBoxContainer")
	
	var description = Label.new()
	description.text = "Weekly financial trends"
	description.add_theme_font_size_override("font_size", 11)
	description.add_theme_color_override("font_color", UITheme.get_text_muted())
	card_vbox.add_child(description)
	
	# Header row
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	card_vbox.add_child(header)
	
	var week_header = Label.new()
	week_header.text = "Week"
	week_header.custom_minimum_size = Vector2(60, 0)
	week_header.add_theme_font_size_override("font_size", 11)
	week_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	header.add_child(week_header)
	
	var rev_header = Label.new()
	rev_header.text = "Revenue"
	rev_header.custom_minimum_size = Vector2(90, 0)
	rev_header.add_theme_font_size_override("font_size", 11)
	rev_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	rev_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(rev_header)
	
	var exp_header = Label.new()
	exp_header.text = "Expenses"
	exp_header.custom_minimum_size = Vector2(90, 0)
	exp_header.add_theme_font_size_override("font_size", 11)
	exp_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	exp_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(exp_header)
	
	var profit_header = Label.new()
	profit_header.text = "Profit"
	profit_header.custom_minimum_size = Vector2(90, 0)
	profit_header.add_theme_font_size_override("font_size", 11)
	profit_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	profit_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(profit_header)
	
	var bal_header = Label.new()
	bal_header.text = "Balance"
	bal_header.custom_minimum_size = Vector2(100, 0)
	bal_header.add_theme_font_size_override("font_size", 11)
	bal_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	bal_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(bal_header)
	
	# History rows container
	history_container = VBoxContainer.new()
	history_container.add_theme_constant_override("separation", 4)
	card_vbox.add_child(history_container)


func create_loans_card(parent: VBoxContainer) -> void:
	"""Create loans management card"""
	loans_card = create_finance_card("🏦 Active Loans", parent)
	var card_vbox = loans_card.get_node("MarginContainer/VBoxContainer")

	# Total debt summary
	var debt_hbox = HBoxContainer.new()
	debt_hbox.add_theme_constant_override("separation", 12)
	card_vbox.add_child(debt_hbox)

	var debt_title = Label.new()
	debt_title.text = "Total Debt:"
	debt_title.add_theme_font_size_override("font_size", 14)
	debt_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	debt_title.custom_minimum_size = Vector2(LABEL_COLUMN_WIDTH, 0)
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
	card_vbox.add_child(payment_hbox)

	var payment_title = Label.new()
	payment_title.text = "Weekly Payment:"
	payment_title.add_theme_font_size_override("font_size", 14)
	payment_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	payment_title.custom_minimum_size = Vector2(LABEL_COLUMN_WIDTH, 0)
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
	card_vbox.add_child(loans_list)

	# Take loan button
	var take_loan_btn = Button.new()
	take_loan_btn.text = "💳 Take Loan"
	take_loan_btn.custom_minimum_size = Vector2(0, 40)
	take_loan_btn.add_theme_font_size_override("font_size", 14)
	var btn_style = UITheme.create_primary_button_style()
	take_loan_btn.add_theme_stylebox_override("normal", btn_style)
	take_loan_btn.pressed.connect(_on_take_loan_pressed)
	card_vbox.add_child(take_loan_btn)


func create_credit_card(parent: VBoxContainer) -> void:
	"""Create credit information card"""
	credit_card = create_finance_card("💳 Credit Information", parent)
	var card_vbox = credit_card.get_node("MarginContainer/VBoxContainer")

	# Credit limit
	var credit_hbox = HBoxContainer.new()
	credit_hbox.add_theme_constant_override("separation", 12)
	card_vbox.add_child(credit_hbox)

	var credit_title = Label.new()
	credit_title.text = "Credit Limit:"
	credit_title.add_theme_font_size_override("font_size", 14)
	credit_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	credit_title.custom_minimum_size = Vector2(LABEL_COLUMN_WIDTH, 0)
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
	card_vbox.add_child(rate_hbox)

	var rate_title = Label.new()
	rate_title.text = "Interest Rate:"
	rate_title.add_theme_font_size_override("font_size", 14)
	rate_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	rate_title.custom_minimum_size = Vector2(LABEL_COLUMN_WIDTH, 0)
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
	vbox.name = "VBoxContainer"
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

	# Summary card
	_update_summary(airline)
	
	# Revenue by route
	_update_revenue_breakdown(airline)
	
	# Expense breakdown
	_update_expense_breakdown(airline)
	
	# History
	_update_history(airline)

	# Loans
	total_debt_label.text = UITheme.format_money(airline.total_debt)
	weekly_payment_label.text = UITheme.format_money(airline.weekly_loan_payment)

	# Credit
	credit_limit_label.text = UITheme.format_money(airline.get_credit_limit())
	var interest_rate = airline.get_interest_rate()
	interest_rate_label.text = "%.1f%%" % (interest_rate * 100.0)

	# Update loans list
	_update_loans_list()


func _update_summary(airline: Airline) -> void:
	"""Update the summary card"""
	# Balance
	balance_label.text = UITheme.format_money(airline.balance)
	
	# Balance trend
	var trend = airline.get_balance_trend()
	if trend > 0:
		balance_trend_label.text = "↑ +%s vs last week" % UITheme.format_money(trend)
		balance_trend_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	elif trend < 0:
		balance_trend_label.text = "↓ %s vs last week" % UITheme.format_money(trend)
		balance_trend_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
	else:
		balance_trend_label.text = "→ No change vs last week"
		balance_trend_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	
	# Revenue / Expenses / Profit
	total_revenue_label.text = UITheme.format_money(airline.weekly_revenue)
	total_expenses_label.text = UITheme.format_money(airline.weekly_expenses)
	
	var profit = airline.calculate_weekly_profit()
	var profit_sign = "+" if profit >= 0 else ""
	net_profit_label.text = "%s%s" % [profit_sign, UITheme.format_money(profit)]
	net_profit_label.add_theme_color_override("font_color", UITheme.get_profit_color(profit))
	
	# Profit margin
	var margin = airline.get_profit_margin()
	profit_margin_label.text = "%.1f%%" % margin
	if margin >= 20:
		profit_margin_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	elif margin >= 0:
		profit_margin_label.add_theme_color_override("font_color", Color("#4ECDC4"))
	else:
		profit_margin_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)


func _update_revenue_breakdown(airline: Airline) -> void:
	"""Update revenue by route breakdown"""
	# Clear existing rows
	for child in revenue_routes_container.get_children():
		child.queue_free()
	
	var route_data = airline.get_revenue_by_route()
	var total_revenue = airline.weekly_revenue
	
	if route_data.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No routes operating"
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", UITheme.get_text_muted())
		revenue_routes_container.add_child(empty_label)
		return
	
	for data in route_data:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		revenue_routes_container.add_child(row)
		
		var route_label = Label.new()
		route_label.text = data.name
		route_label.custom_minimum_size = Vector2(120, 0)
		route_label.add_theme_font_size_override("font_size", 12)
		route_label.add_theme_color_override("font_color", UITheme.get_text_primary())
		row.add_child(route_label)
		
		var pax_label = Label.new()
		pax_label.text = "%d pax" % data.passengers
		pax_label.custom_minimum_size = Vector2(80, 0)
		pax_label.add_theme_font_size_override("font_size", 12)
		pax_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
		row.add_child(pax_label)
		
		var rev_label = Label.new()
		rev_label.text = UITheme.format_money(data.revenue)
		rev_label.custom_minimum_size = Vector2(100, 0)
		rev_label.add_theme_font_size_override("font_size", 12)
		rev_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		rev_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(rev_label)
		
		var pct_label = Label.new()
		var pct = (data.revenue / total_revenue * 100.0) if total_revenue > 0 else 0.0
		pct_label.text = "%.1f%%" % pct
		pct_label.custom_minimum_size = Vector2(70, 0)
		pct_label.add_theme_font_size_override("font_size", 12)
		pct_label.add_theme_color_override("font_color", UITheme.get_text_muted())
		pct_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(pct_label)


func _update_expense_breakdown(airline: Airline) -> void:
	"""Update expense breakdown by category"""
	if not expense_fuel_label:
		return
	
	expense_fuel_label.text = "%s/wk" % UITheme.format_money(airline.weekly_fuel_cost)
	expense_crew_label.text = "%s/wk" % UITheme.format_money(airline.weekly_crew_cost)
	expense_maintenance_label.text = "%s/wk" % UITheme.format_money(airline.weekly_maintenance_cost)
	expense_airport_label.text = "%s/wk" % UITheme.format_money(airline.weekly_airport_fees)
	expense_research_label.text = "%s/wk" % UITheme.format_money(airline.weekly_market_research_cost)
	expense_loan_interest_label.text = "%s/wk" % UITheme.format_money(airline.weekly_loan_interest)
	expense_total_label.text = "%s/wk" % UITheme.format_money(airline.weekly_expenses)


func _update_history(airline: Airline) -> void:
	"""Update historical performance table"""
	# Clear existing rows
	for child in history_container.get_children():
		child.queue_free()
	
	if airline.revenue_history.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No historical data yet - complete a week to see trends"
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", UITheme.get_text_muted())
		history_container.add_child(empty_label)
		return
	
	# Show history in reverse order (most recent first)
	var current_week = GameData.current_week
	var history_size = airline.revenue_history.size()
	
	for i in range(history_size - 1, -1, -1):
		var week_num = current_week - (history_size - 1 - i)
		var revenue = airline.revenue_history[i]
		var expenses = airline.expenses_history[i] if i < airline.expenses_history.size() else 0.0
		var profit = airline.profit_history[i] if i < airline.profit_history.size() else 0.0
		var balance = airline.balance_history[i] if i < airline.balance_history.size() else 0.0
		
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		history_container.add_child(row)
		
		# Alternate row colors
		if i % 2 == 0:
			var bg = ColorRect.new()
			bg.color = Color(0.1, 0.1, 0.12, 0.5)
			bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			row.add_child(bg)
			row.move_child(bg, 0)
		
		var week_label = Label.new()
		week_label.text = "W%d" % week_num
		week_label.custom_minimum_size = Vector2(60, 0)
		week_label.add_theme_font_size_override("font_size", 11)
		week_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
		row.add_child(week_label)
		
		var rev_label = Label.new()
		rev_label.text = UITheme.format_money(revenue)
		rev_label.custom_minimum_size = Vector2(90, 0)
		rev_label.add_theme_font_size_override("font_size", 11)
		rev_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		rev_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(rev_label)
		
		var exp_label = Label.new()
		exp_label.text = UITheme.format_money(expenses)
		exp_label.custom_minimum_size = Vector2(90, 0)
		exp_label.add_theme_font_size_override("font_size", 11)
		exp_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
		exp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(exp_label)
		
		var profit_label = Label.new()
		var profit_sign = "+" if profit >= 0 else ""
		profit_label.text = "%s%s" % [profit_sign, UITheme.format_money(profit)]
		profit_label.custom_minimum_size = Vector2(90, 0)
		profit_label.add_theme_font_size_override("font_size", 11)
		profit_label.add_theme_color_override("font_color", UITheme.get_profit_color(profit))
		profit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(profit_label)
		
		var bal_label = Label.new()
		bal_label.text = UITheme.format_money(balance)
		bal_label.custom_minimum_size = Vector2(100, 0)
		bal_label.add_theme_font_size_override("font_size", 11)
		bal_label.add_theme_color_override("font_color", UITheme.get_text_primary())
		bal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(bal_label)


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
