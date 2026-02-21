extends Control
class_name FinancialPanel

## Financial Overview Panel - Shows revenue, expenses, profit, loans, and financial health
## Pattern matches FleetManagementPanel.gd architecture

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer

# KPI value labels
var kpi_revenue_value: Label
var kpi_expenses_value: Label
var kpi_profit_value: Label
var kpi_balance_value: Label

# Section containers (for refresh)
var revenue_section_container: VBoxContainer
var cost_section_container: VBoxContainer
var loan_section_container: VBoxContainer
var summary_section_container: VBoxContainer

func _ready() -> void:
	build_ui()

func build_ui() -> void:
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

	# Title
	var title = Label.new()
	title.text = "Financial Overview"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	outer_vbox.add_child(title)

	# KPI row
	_create_kpi_row(outer_vbox)

	# Scrollable content
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)

	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 20)
	scroll_container.add_child(main_vbox)

	# Revenue Breakdown Section
	_create_revenue_section(main_vbox)

	# Cost Breakdown Section
	_create_cost_section(main_vbox)

	# Loan Management Section
	_create_loan_section(main_vbox)

	# Financial Summary Section
	_create_summary_section(main_vbox)

# ============================================================================
# KPI ROW
# ============================================================================

func _create_kpi_row(parent: VBoxContainer) -> void:
	var kpi_row = HBoxContainer.new()
	kpi_row.add_theme_constant_override("separation", 12)
	parent.add_child(kpi_row)

	var revenue_kpi = _create_kpi_card("Weekly Revenue", "$0")
	kpi_revenue_value = revenue_kpi.get_node("VBox/Value")
	kpi_row.add_child(revenue_kpi)

	var expenses_kpi = _create_kpi_card("Weekly Expenses", "$0")
	kpi_expenses_value = expenses_kpi.get_node("VBox/Value")
	kpi_row.add_child(expenses_kpi)

	var profit_kpi = _create_kpi_card("Weekly Profit", "$0")
	kpi_profit_value = profit_kpi.get_node("VBox/Value")
	kpi_row.add_child(profit_kpi)

	var balance_kpi = _create_kpi_card("Balance", "$0")
	kpi_balance_value = balance_kpi.get_node("VBox/Value")
	kpi_row.add_child(balance_kpi)

func _create_kpi_card(title_text: String, value_text: String) -> PanelContainer:
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 70)
	card.add_theme_stylebox_override("panel", UITheme.create_kpi_card_style())

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	var title = Label.new()
	title.name = "Title"
	title.text = title_text
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", UITheme.get_text_muted())
	vbox.add_child(title)

	var value = Label.new()
	value.name = "Value"
	value.text = value_text
	value.add_theme_font_size_override("font_size", 18)
	value.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(value)

	return card

# ============================================================================
# REVENUE BREAKDOWN
# ============================================================================

func _create_revenue_section(parent: VBoxContainer) -> void:
	var section = _create_section_panel("Revenue Breakdown")
	parent.add_child(section)
	revenue_section_container = section.get_node("Margin/VBox/Content")

func _create_cost_section(parent: VBoxContainer) -> void:
	var section = _create_section_panel("Cost Breakdown")
	parent.add_child(section)
	cost_section_container = section.get_node("Margin/VBox/Content")

func _create_loan_section(parent: VBoxContainer) -> void:
	var section = _create_section_panel("Loan Management")
	parent.add_child(section)
	loan_section_container = section.get_node("Margin/VBox/Content")

func _create_summary_section(parent: VBoxContainer) -> void:
	var section = _create_section_panel("Financial Health")
	parent.add_child(section)
	summary_section_container = section.get_node("Margin/VBox/Content")

func _create_section_panel(title_text: String) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UITheme.create_panel_style())

	var section_margin = MarginContainer.new()
	section_margin.name = "Margin"
	section_margin.add_theme_constant_override("margin_left", 20)
	section_margin.add_theme_constant_override("margin_right", 20)
	section_margin.add_theme_constant_override("margin_top", 16)
	section_margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(section_margin)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 12)
	section_margin.add_child(vbox)

	# Section title
	var title = Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(title)

	var sep = HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.2)
	vbox.add_child(sep)

	# Content container (populated on refresh)
	var content = VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 8)
	vbox.add_child(content)

	return panel

# ============================================================================
# BREAKDOWN BAR HELPER
# ============================================================================

func _create_breakdown_bar(label_text: String, value: float, max_value: float, color: Color) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 140
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	row.add_child(label)

	# Progress bar
	var bar_bg = Panel.new()
	bar_bg.custom_minimum_size = Vector2(0, 14)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = UITheme.get_panel_border()
	bg_style.set_corner_radius_all(4)
	bar_bg.add_theme_stylebox_override("panel", bg_style)
	row.add_child(bar_bg)

	# Fill
	var fill_ratio = value / max_value if max_value > 0 else 0.0
	fill_ratio = clamp(fill_ratio, 0.0, 1.0)

	var bar_fill = ColorRect.new()
	bar_fill.color = color
	bar_fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	bar_fill.anchor_right = fill_ratio
	bar_fill.offset_right = 0
	bar_bg.add_child(bar_fill)

	# Value label
	var value_label = Label.new()
	value_label.text = UITheme.format_money(value)
	value_label.custom_minimum_size.x = 80
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 13)
	value_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	row.add_child(value_label)

	return row

# ============================================================================
# LOAN CARD HELPER
# ============================================================================

func _create_loan_card(loan: Loan) -> PanelContainer:
	var card = PanelContainer.new()
	var card_style = UITheme.create_card_style()
	card.add_theme_stylebox_override("panel", card_style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	card.add_child(hbox)

	# Loan info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)

	var name_label = Label.new()
	name_label.text = "Aircraft Loan"
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(name_label)

	var details_label = Label.new()
	details_label.text = "Principal: %s | Rate: %.1f%%" % [UITheme.format_money(loan.principal), loan.interest_rate * 100]
	details_label.add_theme_font_size_override("font_size", 11)
	details_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	info_vbox.add_child(details_label)

	# Progress bar
	var progress_vbox = VBoxContainer.new()
	progress_vbox.custom_minimum_size.x = 150
	progress_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(progress_vbox)

	var progress_label = Label.new()
	progress_label.text = "%.0f%% repaid" % loan.get_progress_percent()
	progress_label.add_theme_font_size_override("font_size", 11)
	progress_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_vbox.add_child(progress_label)

	var bar_bg = Panel.new()
	bar_bg.custom_minimum_size = Vector2(150, 10)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = UITheme.get_panel_border()
	bg_style.set_corner_radius_all(5)
	bar_bg.add_theme_stylebox_override("panel", bg_style)
	progress_vbox.add_child(bar_bg)

	var progress_fill = ColorRect.new()
	progress_fill.color = UITheme.PRIMARY_BLUE
	progress_fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	progress_fill.anchor_right = loan.get_progress_percent() / 100.0
	progress_fill.offset_right = 0
	bar_bg.add_child(progress_fill)

	# Remaining & payment
	var payment_vbox = VBoxContainer.new()
	payment_vbox.custom_minimum_size.x = 100
	payment_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(payment_vbox)

	var remaining_label = Label.new()
	remaining_label.text = UITheme.format_money(loan.remaining_balance)
	remaining_label.add_theme_font_size_override("font_size", 14)
	remaining_label.add_theme_color_override("font_color", UITheme.WARNING_COLOR)
	remaining_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	payment_vbox.add_child(remaining_label)

	var payment_label = Label.new()
	payment_label.text = "%s/wk" % UITheme.format_money(loan.weekly_payment)
	payment_label.add_theme_font_size_override("font_size", 11)
	payment_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	payment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	payment_vbox.add_child(payment_label)

	return card

# ============================================================================
# REFRESH
# ============================================================================

func refresh() -> void:
	if not GameData.player_airline:
		return

	var airline = GameData.player_airline

	# Update KPIs
	_update_kpis(airline)

	# Update revenue breakdown
	_update_revenue_breakdown(airline)

	# Update cost breakdown
	_update_cost_breakdown(airline)

	# Update loan section
	_update_loan_section(airline)

	# Update financial summary
	_update_financial_summary(airline)

func _update_kpis(airline: Airline) -> void:
	var profit = airline.calculate_weekly_profit()

	if kpi_revenue_value:
		kpi_revenue_value.text = UITheme.format_money(airline.weekly_revenue)
		kpi_revenue_value.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)

	if kpi_expenses_value:
		kpi_expenses_value.text = UITheme.format_money(airline.weekly_expenses)
		kpi_expenses_value.add_theme_color_override("font_color", UITheme.LOSS_COLOR)

	if kpi_profit_value:
		kpi_profit_value.text = UITheme.format_money(profit, true)
		kpi_profit_value.add_theme_color_override("font_color", UITheme.get_profit_color(profit))

	if kpi_balance_value:
		kpi_balance_value.text = UITheme.format_money(airline.balance)
		kpi_balance_value.add_theme_color_override("font_color", UITheme.get_text_primary())

func _update_revenue_breakdown(airline: Airline) -> void:
	if not revenue_section_container:
		return

	# Clear existing
	for child in revenue_section_container.get_children():
		child.queue_free()

	if airline.routes.is_empty():
		var empty = Label.new()
		empty.text = "No route revenue yet"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", UITheme.get_text_muted())
		revenue_section_container.add_child(empty)
		return

	# Sort routes by revenue (descending)
	var sorted_routes = airline.routes.duplicate()
	sorted_routes.sort_custom(func(a, b): return a.revenue_generated > b.revenue_generated)

	# Find max for bar scaling
	var max_revenue: float = 0.0
	for route in sorted_routes:
		max_revenue = max(max_revenue, route.revenue_generated)

	# Show top 8 routes
	var count = min(sorted_routes.size(), 8)
	for i in range(count):
		var route = sorted_routes[i]
		var bar = _create_breakdown_bar(
			route.get_display_name(),
			route.revenue_generated,
			max_revenue,
			UITheme.PROFIT_COLOR
		)
		revenue_section_container.add_child(bar)

	# Total
	var total_row = HBoxContainer.new()
	total_row.add_theme_constant_override("separation", 12)
	revenue_section_container.add_child(total_row)

	var total_label = Label.new()
	total_label.text = "Total Revenue"
	total_label.custom_minimum_size.x = 140
	total_label.add_theme_font_size_override("font_size", 14)
	total_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	total_row.add_child(total_label)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	total_row.add_child(spacer)

	var total_value = Label.new()
	total_value.text = UITheme.format_money(airline.weekly_revenue)
	total_value.custom_minimum_size.x = 80
	total_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	total_value.add_theme_font_size_override("font_size", 14)
	total_value.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	total_row.add_child(total_value)

func _update_cost_breakdown(airline: Airline) -> void:
	if not cost_section_container:
		return

	for child in cost_section_container.get_children():
		child.queue_free()

	# Calculate cost categories
	var fuel_cost: float = 0.0
	for route in airline.routes:
		fuel_cost += route.fuel_cost

	var loan_payments: float = airline.weekly_loan_payment
	var maintenance: float = 0.0
	for aircraft in airline.aircraft:
		if aircraft.needs_maintenance():
			maintenance += 5000.0  # Estimated maintenance cost per aircraft needing it

	var total_expenses = airline.weekly_expenses
	var other_costs = max(0.0, total_expenses - fuel_cost - loan_payments - maintenance)

	# Build bars
	var max_cost = max(fuel_cost, max(loan_payments, max(maintenance, other_costs)))
	if max_cost <= 0:
		max_cost = 1.0

	var cost_items = [
		{"label": "Fuel", "value": fuel_cost, "color": UITheme.WARNING_COLOR},
		{"label": "Loan Payments", "value": loan_payments, "color": UITheme.LOSS_COLOR},
		{"label": "Maintenance", "value": maintenance, "color": Color("#f97316")},  # Orange
		{"label": "Other", "value": other_costs, "color": UITheme.NEUTRAL_COLOR},
	]

	for item in cost_items:
		if item.value > 0:
			var bar = _create_breakdown_bar(item.label, item.value, max_cost, item.color)
			cost_section_container.add_child(bar)

	if total_expenses <= 0:
		var empty = Label.new()
		empty.text = "No expenses yet"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", UITheme.get_text_muted())
		cost_section_container.add_child(empty)

func _update_loan_section(airline: Airline) -> void:
	if not loan_section_container:
		return

	for child in loan_section_container.get_children():
		child.queue_free()

	if airline.loans.is_empty():
		var empty = Label.new()
		empty.text = "No active loans"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", UITheme.get_text_muted())
		loan_section_container.add_child(empty)
	else:
		for loan in airline.loans:
			if not loan.is_paid_off():
				var card = _create_loan_card(loan)
				loan_section_container.add_child(card)

	# Credit info
	var credit_row = HBoxContainer.new()
	credit_row.add_theme_constant_override("separation", 16)
	loan_section_container.add_child(credit_row)

	var credit_label = Label.new()
	credit_label.text = "Available Credit: %s" % UITheme.format_money(airline.get_credit_limit())
	credit_label.add_theme_font_size_override("font_size", 12)
	credit_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	credit_row.add_child(credit_label)

	var rate_label = Label.new()
	rate_label.text = "Interest Rate: %.1f%%" % (airline.get_interest_rate() * 100)
	rate_label.add_theme_font_size_override("font_size", 12)
	rate_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	credit_row.add_child(rate_label)

func _update_financial_summary(airline: Airline) -> void:
	if not summary_section_container:
		return

	for child in summary_section_container.get_children():
		child.queue_free()

	var profit = airline.calculate_weekly_profit()
	var margin_pct = (profit / airline.weekly_revenue * 100) if airline.weekly_revenue > 0 else 0.0

	var stats = [
		{"label": "Airline Grade", "value": airline.get_grade(), "color": UITheme.get_grade_color(airline.get_grade())},
		{"label": "Reputation", "value": "%.1f" % airline.reputation, "color": UITheme.HUB_COLOR},
		{"label": "Net Margin", "value": "%.1f%%" % margin_pct, "color": UITheme.get_profit_color(margin_pct)},
		{"label": "Total Debt", "value": UITheme.format_money(airline.total_debt), "color": UITheme.WARNING_COLOR if airline.total_debt > 0 else UITheme.PROFIT_COLOR},
		{"label": "Fleet Size", "value": str(airline.aircraft.size()), "color": UITheme.PRIMARY_BLUE},
		{"label": "Hub Count", "value": str(airline.get_hub_count()), "color": UITheme.PRIMARY_BLUE},
	]

	# Display as 2-column grid
	var grid_row: HBoxContainer = null
	for i in range(stats.size()):
		if i % 2 == 0:
			grid_row = HBoxContainer.new()
			grid_row.add_theme_constant_override("separation", 24)
			summary_section_container.add_child(grid_row)

		var stat_hbox = HBoxContainer.new()
		stat_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_hbox.add_theme_constant_override("separation", 8)
		grid_row.add_child(stat_hbox)

		var stat_label = Label.new()
		stat_label.text = stats[i].label + ":"
		stat_label.add_theme_font_size_override("font_size", 13)
		stat_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
		stat_hbox.add_child(stat_label)

		var stat_value = Label.new()
		stat_value.text = stats[i].value
		stat_value.add_theme_font_size_override("font_size", 14)
		stat_value.add_theme_color_override("font_color", stats[i].color)
		stat_hbox.add_child(stat_value)
