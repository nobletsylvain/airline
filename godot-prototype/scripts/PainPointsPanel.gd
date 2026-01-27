## PainPointsPanel.gd
## Displays passenger pain points and actionable suggestions (Task O.2)
## Shows capacity constraints, pricing issues, and frequency problems
extends Control
class_name PainPointsPanel

## Emitted when player clicks an action to fix a pain point
signal action_requested(route: Route, action_type: String)

## Emitted when player clicks the row to open full route editor
signal route_edit_requested(route: Route)

## Pain point severity thresholds
const LOAD_FACTOR_HIGH := 0.90      # 90%+ is capacity-constrained
const LOAD_FACTOR_CRITICAL := 0.98  # 98%+ is severely constrained
const PRICE_PREMIUM_WARNING := 1.20 # 20%+ above market = overpriced warning
const PRICE_PREMIUM_CRITICAL := 1.40 # 40%+ above market = critical
const LOW_FREQUENCY_THRESHOLD := 4  # Fewer than 4 flights/week is low

## Pain point types
enum PainType {
	CAPACITY_CONSTRAINED,   # Demand > Capacity (spill)
	OVERPRICED,             # Price too high vs market
	LOW_FREQUENCY,          # Poor schedule for connections
	PROFIT_NEGATIVE         # Losing money
}

# UI elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var empty_label: Label

func _ready() -> void:
	build_ui()


func build_ui() -> void:
	"""Build the pain points panel UI"""
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var panel_container = PanelContainer.new()
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel_style = UITheme.create_card_panel_style()
	panel_style.bg_color = UITheme.get_panel_bg()
	panel_container.add_theme_stylebox_override("panel", panel_style)
	add_child(panel_container)
	
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel_container.add_child(margin)
	
	var outer_vbox = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 12)
	margin.add_child(outer_vbox)
	
	# Header
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	outer_vbox.add_child(header_hbox)
	
	var header_icon = Label.new()
	header_icon.text = "⚠"
	header_icon.add_theme_font_size_override("font_size", 18)
	header_icon.add_theme_color_override("font_color", UITheme.WARNING_COLOR)
	header_hbox.add_child(header_icon)
	
	var header = Label.new()
	header.text = "Passenger Pain Points"
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", UITheme.get_text_primary())
	header_hbox.add_child(header)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "Issues affecting your routes"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_muted())
	outer_vbox.add_child(subtitle)
	
	# Scrollable content
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)
	
	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 12)
	scroll_container.add_child(main_vbox)


func refresh() -> void:
	"""Refresh the pain points list with current data"""
	# Clear existing content
	for child in main_vbox.get_children():
		child.queue_free()
	
	if not GameData.player_airline or GameData.player_airline.routes.is_empty():
		_show_no_routes_message()
		return
	
	# Analyze all routes for pain points
	var pain_points: Array[Dictionary] = _analyze_all_routes()
	
	if pain_points.is_empty():
		_show_all_good_message()
		return
	
	# Sort by severity (highest first)
	pain_points.sort_custom(func(a, b): return a.severity > b.severity)
	
	# Display pain points (max 10)
	for i in range(min(10, pain_points.size())):
		var pain = pain_points[i]
		var row = _create_pain_point_row(pain)
		main_vbox.add_child(row)


func _show_no_routes_message() -> void:
	"""Show message when player has no routes"""
	var message = Label.new()
	message.text = "Create routes first to see pain points."
	message.add_theme_font_size_override("font_size", 13)
	message.add_theme_color_override("font_color", UITheme.get_text_muted())
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(message)


func _show_all_good_message() -> void:
	"""Show message when no pain points detected"""
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	main_vbox.add_child(container)
	
	var icon = Label.new()
	icon.text = "✓"
	icon.add_theme_font_size_override("font_size", 24)
	icon.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(icon)
	
	var message = Label.new()
	message.text = "All routes healthy!"
	message.add_theme_font_size_override("font_size", 14)
	message.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(message)
	
	var detail = Label.new()
	detail.text = "No capacity constraints, pricing issues, or frequency problems detected."
	detail.add_theme_font_size_override("font_size", 12)
	detail.add_theme_color_override("font_color", UITheme.get_text_muted())
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(detail)


func _analyze_all_routes() -> Array[Dictionary]:
	"""Analyze all player routes for pain points"""
	var pain_points: Array[Dictionary] = []
	
	for route in GameData.player_airline.routes:
		var route_pains = _analyze_route(route)
		pain_points.append_array(route_pains)
	
	return pain_points


func _analyze_route(route: Route) -> Array[Dictionary]:
	"""Analyze a single route for pain points"""
	var pains: Array[Dictionary] = []
	
	# Calculate load factor
	var weekly_capacity = route.get_total_capacity() * route.frequency
	var load_factor: float = 0.0
	if weekly_capacity > 0:
		load_factor = float(route.passengers_transported) / float(weekly_capacity)
	
	# Calculate market demand
	var distance = route.distance_km
	var market_demand = MarketAnalysis.calculate_potential_demand(
		route.from_airport, route.to_airport, distance
	)
	
	# Get market pricing for comparison
	var market_pricing = GameData.get_recommended_pricing_for_route(
		route.from_airport, route.to_airport
	)
	
	# Check 1: Capacity constrained (spill)
	if load_factor >= LOAD_FACTOR_HIGH:
		var spill_amount: int = 0
		if market_demand > weekly_capacity:
			spill_amount = int(market_demand - route.passengers_transported)
		
		var severity: float = 0.6 if load_factor < LOAD_FACTOR_CRITICAL else 1.0
		pains.append({
			"route": route,
			"type": PainType.CAPACITY_CONSTRAINED,
			"severity": severity,
			"title": "Capacity Constrained",
			"description": "%.0f%% load factor - passengers turned away" % (load_factor * 100),
			"detail": "~%d pax/week unserved (spill)" % spill_amount if spill_amount > 0 else "Near capacity limit",
			"action": "Add Aircraft",
			"action_type": "add_capacity",
			"icon": "📦",
			"color": UITheme.WARNING_COLOR if severity < 1.0 else UITheme.LOSS_COLOR
		})
	
	# Check 2: Overpriced compared to market
	var price_ratio: float = route.price_economy / market_pricing.economy if market_pricing.economy > 0 else 1.0
	if price_ratio >= PRICE_PREMIUM_WARNING:
		var severity: float = 0.5 if price_ratio < PRICE_PREMIUM_CRITICAL else 0.8
		var premium_pct: int = int((price_ratio - 1.0) * 100)
		pains.append({
			"route": route,
			"type": PainType.OVERPRICED,
			"severity": severity,
			"title": "Overpriced",
			"description": "%d%% above market rate" % premium_pct,
			"detail": "Economy: €%.0f (market: €%.0f)" % [route.price_economy, market_pricing.economy],
			"action": "Lower Price",
			"action_type": "lower_price",
			"icon": "💰",
			"color": UITheme.WARNING_COLOR
		})
	
	# Check 3: Low frequency (poor for connections)
	if route.frequency < LOW_FREQUENCY_THRESHOLD:
		var severity: float = 0.3 if route.frequency >= 2 else 0.5
		pains.append({
			"route": route,
			"type": PainType.LOW_FREQUENCY,
			"severity": severity,
			"title": "Low Frequency",
			"description": "Only %d flights/week" % route.frequency,
			"detail": "Passengers may choose competitors with better schedules",
			"action": "Add Frequency",
			"action_type": "add_frequency",
			"icon": "📅",
			"color": Color(0.6, 0.6, 0.2)
		})
	
	# Check 4: Losing money
	if route.weekly_profit < 0:
		var severity: float = 0.7 if route.weekly_profit > -50000 else 1.0
		pains.append({
			"route": route,
			"type": PainType.PROFIT_NEGATIVE,
			"severity": severity,
			"title": "Losing Money",
			"description": UITheme.format_money(route.weekly_profit, true) + "/week",
			"detail": "Consider adjusting pricing or reducing costs",
			"action": "Review Route",
			"action_type": "review_route",
			"icon": "📉",
			"color": UITheme.LOSS_COLOR
		})
	
	return pains


func _create_pain_point_row(pain: Dictionary) -> Control:
	"""Create a row displaying a pain point with action button"""
	var route: Route = pain.route
	var row = PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 70)
	
	# Row style with colored left border
	var row_style = StyleBoxFlat.new()
	row_style.bg_color = UITheme.get_card_bg()
	row_style.set_corner_radius_all(8)
	row_style.set_content_margin_all(12)
	row_style.border_color = pain.color
	row_style.border_width_left = 4
	row.add_theme_stylebox_override("panel", row_style)
	
	# Hover style for clickable row
	var hover_style = row_style.duplicate()
	hover_style.bg_color = UITheme.get_card_bg().lightened(0.05)
	hover_style.border_color = UITheme.PRIMARY_BLUE
	hover_style.set_border_width_all(2)
	hover_style.border_width_left = 4  # Keep left border thick
	
	# Make row clickable
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.tooltip_text = "Click to edit route • Use button for quick fix"
	
	row.mouse_entered.connect(func():
		row.add_theme_stylebox_override("panel", hover_style)
	)
	row.mouse_exited.connect(func():
		row.add_theme_stylebox_override("panel", row_style)
	)
	row.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			route_edit_requested.emit(route)
	)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)
	
	# Icon
	var icon_label = Label.new()
	icon_label.text = pain.icon
	icon_label.add_theme_font_size_override("font_size", 20)
	icon_label.custom_minimum_size = Vector2(28, 0)
	hbox.add_child(icon_label)
	
	# Info section
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)
	
	# Route name + issue title
	var title_hbox = HBoxContainer.new()
	title_hbox.add_theme_constant_override("separation", 8)
	info_vbox.add_child(title_hbox)
	
	var route_name = Label.new()
	route_name.text = route.get_display_name()
	route_name.add_theme_font_size_override("font_size", 13)
	route_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	title_hbox.add_child(route_name)
	
	var issue_badge = Label.new()
	issue_badge.text = pain.title
	issue_badge.add_theme_font_size_override("font_size", 11)
	issue_badge.add_theme_color_override("font_color", pain.color)
	title_hbox.add_child(issue_badge)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = pain.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	info_vbox.add_child(desc_label)
	
	# Detail
	var detail_label = Label.new()
	detail_label.text = pain.detail
	detail_label.add_theme_font_size_override("font_size", 11)
	detail_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	info_vbox.add_child(detail_label)
	
	# Action button
	var action_btn = Button.new()
	action_btn.text = pain.action
	action_btn.custom_minimum_size = Vector2(100, 32)
	action_btn.add_theme_font_size_override("font_size", 11)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(pain.color.r, pain.color.g, pain.color.b, 0.15)
	btn_style.border_color = pain.color
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(6)
	btn_style.set_content_margin_all(6)
	action_btn.add_theme_stylebox_override("normal", btn_style)
	
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color(pain.color.r, pain.color.g, pain.color.b, 0.3)
	action_btn.add_theme_stylebox_override("hover", btn_hover)
	
	action_btn.add_theme_color_override("font_color", pain.color)
	action_btn.add_theme_color_override("font_hover_color", pain.color)
	
	action_btn.pressed.connect(func():
		action_requested.emit(route, pain.action_type)
	)
	hbox.add_child(action_btn)
	
	return row
