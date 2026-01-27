## AircraftDetailsDialog.gd
## Shows detailed performance history for a specific aircraft (Task N.2)
## Displays revenue trend, routes flown, passengers carried, maintenance costs,
## and performance badges.
extends Window
class_name AircraftDetailsDialog

## The aircraft being displayed
var aircraft: AircraftInstance = null

## UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var header_label: Label
var badge_label: Label
var stats_container: VBoxContainer
var chart_container: Control
var routes_container: VBoxContainer

## Chart dimensions
const CHART_WIDTH: float = 400.0
const CHART_HEIGHT: float = 120.0
const MAX_HISTORY_WEEKS: int = 8

func _init() -> void:
	title = "Aircraft Performance Details"
	size = Vector2i(600, 700)
	min_size = Vector2i(500, 500)
	transient = true
	exclusive = false


func _ready() -> void:
	build_ui()
	close_requested.connect(hide)
	hide()  # Start hidden


func _input(event: InputEvent) -> void:
	"""Handle ESC key to close dialog"""
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide()
		get_viewport().set_input_as_handled()


func build_ui() -> void:
	"""Build the dialog UI"""
	# Add a styled background panel for better readability
	var bg_panel = PanelContainer.new()
	bg_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.12, 0.14, 0.18)  # Lighter than default, matches other dialogs
	bg_panel.add_theme_stylebox_override("panel", bg_style)
	add_child(bg_panel)
	
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	bg_panel.add_child(margin)
	
	scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll_container)
	
	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 20)
	scroll_container.add_child(main_vbox)


func show_aircraft(p_aircraft: AircraftInstance) -> void:
	"""Display details for the given aircraft"""
	aircraft = p_aircraft
	
	if not aircraft:
		return
	
	# Clear previous content
	for child in main_vbox.get_children():
		child.queue_free()
	
	# Build content
	create_header_section()
	create_lifetime_stats_section()
	create_revenue_chart_section()
	create_maintenance_chart_section()
	create_routes_section()
	
	# Update title
	title = "Aircraft Details: %s" % aircraft.get_display_name()
	
	popup_centered()


func create_header_section() -> void:
	"""Create header with aircraft name and performance badge"""
	var header_vbox = VBoxContainer.new()
	header_vbox.add_theme_constant_override("separation", 8)
	main_vbox.add_child(header_vbox)
	
	# Aircraft name and registration
	var name_hbox = HBoxContainer.new()
	name_hbox.add_theme_constant_override("separation", 16)
	header_vbox.add_child(name_hbox)
	
	header_label = Label.new()
	header_label.text = aircraft.get_display_name()
	header_label.add_theme_font_size_override("font_size", 22)
	header_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	name_hbox.add_child(header_label)
	
	var reg_label = Label.new()
	reg_label.text = "N%03dSK" % aircraft.id
	reg_label.add_theme_font_size_override("font_size", 14)
	reg_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	name_hbox.add_child(reg_label)
	
	# Performance badge (comparative against fleet)
	var badge_hbox = HBoxContainer.new()
	badge_hbox.add_theme_constant_override("separation", 12)
	header_vbox.add_child(badge_hbox)
	
	badge_label = Label.new()
	# Get comparative badge using all player aircraft
	var all_aircraft = GameData.player_airline.aircraft if GameData.player_airline else []
	var badge_text = aircraft.get_comparative_badge(all_aircraft)
	badge_label.text = badge_text
	badge_label.add_theme_font_size_override("font_size", 14)
	
	var badge_style = StyleBoxFlat.new()
	var badge_color = aircraft.get_comparative_badge_color(badge_text)
	badge_style.bg_color = Color(badge_color.r, badge_color.g, badge_color.b, 0.2)
	badge_style.set_corner_radius_all(6)
	badge_style.set_content_margin_all(8)
	badge_label.add_theme_stylebox_override("normal", badge_style)
	badge_label.add_theme_color_override("font_color", badge_color)
	badge_hbox.add_child(badge_label)
	
	# Profit margin indicator
	var margin_label = Label.new()
	var profit_margin = aircraft.get_profit_margin()
	margin_label.text = "Profit Margin: %.1f%%" % profit_margin
	margin_label.add_theme_font_size_override("font_size", 13)
	margin_label.add_theme_color_override("font_color", UITheme.get_profit_color(profit_margin))
	badge_hbox.add_child(margin_label)
	
	# Condition bar
	var condition_hbox = HBoxContainer.new()
	condition_hbox.add_theme_constant_override("separation", 12)
	header_vbox.add_child(condition_hbox)
	
	var cond_label = Label.new()
	cond_label.text = "Condition:"
	cond_label.add_theme_font_size_override("font_size", 13)
	cond_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	condition_hbox.add_child(cond_label)
	
	var cond_bar = create_progress_bar(aircraft.condition, 100.0, aircraft.get_condition_color())
	condition_hbox.add_child(cond_bar)
	
	var cond_pct = Label.new()
	cond_pct.text = "%.0f%%" % aircraft.condition
	cond_pct.add_theme_font_size_override("font_size", 13)
	cond_pct.add_theme_color_override("font_color", aircraft.get_condition_color())
	condition_hbox.add_child(cond_pct)
	
	# Separator
	var sep = HSeparator.new()
	main_vbox.add_child(sep)


func create_lifetime_stats_section() -> void:
	"""Create lifetime statistics section"""
	var section = create_section("Lifetime Statistics")
	main_vbox.add_child(section)
	
	var stats_grid = GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 40)
	stats_grid.add_theme_constant_override("v_separation", 12)
	section.add_child(stats_grid)
	
	# Total Passengers
	add_stat_item(stats_grid, "Total Passengers", "%s" % format_number(aircraft.total_passengers_carried))
	
	# Total Revenue
	add_stat_item(stats_grid, "Total Revenue", UITheme.format_money(aircraft.total_revenue_earned))
	
	# Total Maintenance
	add_stat_item(stats_grid, "Total Maintenance", UITheme.format_money(aircraft.total_maintenance_spent))
	
	# Routes Flown
	add_stat_item(stats_grid, "Routes Flown", "%d" % aircraft.routes_flown.size())
	
	# Average Weekly Revenue
	add_stat_item(stats_grid, "Avg Weekly Revenue", UITheme.format_money(aircraft.get_average_weekly_revenue()))
	
	# Average Weekly Profit
	var avg_profit = aircraft.get_average_weekly_profit()
	add_stat_item(stats_grid, "Avg Weekly Profit", UITheme.format_money(avg_profit, true), UITheme.get_profit_color(avg_profit))


func create_revenue_chart_section() -> void:
	"""Create revenue trend chart"""
	var section = create_section("Revenue Trend (Last %d Weeks)" % MAX_HISTORY_WEEKS)
	main_vbox.add_child(section)
	
	if aircraft.revenue_history.is_empty():
		var no_data = Label.new()
		no_data.text = "No revenue data yet. Assign to a route and run simulation."
		no_data.add_theme_font_size_override("font_size", 13)
		no_data.add_theme_color_override("font_color", UITheme.get_text_muted())
		section.add_child(no_data)
		return
	
	var chart = create_line_chart(aircraft.revenue_history, UITheme.PROFIT_COLOR, "Revenue")
	section.add_child(chart)
	
	# Trend indicator
	var trend = aircraft.get_revenue_trend()
	var trend_hbox = HBoxContainer.new()
	trend_hbox.add_theme_constant_override("separation", 8)
	section.add_child(trend_hbox)
	
	var trend_icon = Label.new()
	if trend > 5:
		trend_icon.text = "↑"
		trend_icon.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	elif trend < -5:
		trend_icon.text = "↓"
		trend_icon.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
	else:
		trend_icon.text = "→"
		trend_icon.add_theme_color_override("font_color", UITheme.get_text_muted())
	trend_icon.add_theme_font_size_override("font_size", 18)
	trend_hbox.add_child(trend_icon)
	
	var trend_label = Label.new()
	trend_label.text = "%.1f%% vs previous weeks" % trend if abs(trend) > 0.1 else "Stable"
	trend_label.add_theme_font_size_override("font_size", 12)
	trend_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	trend_hbox.add_child(trend_label)


func create_maintenance_chart_section() -> void:
	"""Create maintenance cost trend chart"""
	var section = create_section("Maintenance Costs (Last %d Weeks)" % MAX_HISTORY_WEEKS)
	main_vbox.add_child(section)
	
	if aircraft.maintenance_history.is_empty():
		var no_data = Label.new()
		no_data.text = "No maintenance data yet."
		no_data.add_theme_font_size_override("font_size", 13)
		no_data.add_theme_color_override("font_color", UITheme.get_text_muted())
		section.add_child(no_data)
		return
	
	# Convert to float array for chart
	var maint_floats: Array[float] = []
	for m in aircraft.maintenance_history:
		maint_floats.append(m)
	
	var chart = create_line_chart(maint_floats, UITheme.WARNING_COLOR, "Maintenance")
	section.add_child(chart)


func create_routes_section() -> void:
	"""Create routes flown section"""
	var section = create_section("Routes Flown")
	main_vbox.add_child(section)
	
	if aircraft.routes_flown.is_empty():
		var no_data = Label.new()
		no_data.text = "This aircraft hasn't flown any routes yet."
		no_data.add_theme_font_size_override("font_size", 13)
		no_data.add_theme_color_override("font_color", UITheme.get_text_muted())
		section.add_child(no_data)
		return
	
	var routes_flow = HFlowContainer.new()
	routes_flow.add_theme_constant_override("h_separation", 8)
	routes_flow.add_theme_constant_override("v_separation", 8)
	section.add_child(routes_flow)
	
	for route_id in aircraft.routes_flown:
		var route = find_route_by_id(route_id)
		if route:
			var route_badge = create_route_badge(route)
			routes_flow.add_child(route_badge)


func create_section(title_text: String) -> VBoxContainer:
	"""Create a section with title"""
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 12)
	
	var title = Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 16)
	# Use high-contrast white for section titles
	title.add_theme_color_override("font_color", Color(0.95, 0.95, 0.98))
	section.add_child(title)
	
	return section


func add_stat_item(parent: GridContainer, label_text: String, value_text: String, color: Color = Color.WHITE) -> void:
	"""Add a stat item to the grid"""
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 13)
	# Use lighter color for better readability on dark background
	label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.82))
	parent.add_child(label)
	
	var value = Label.new()
	value.text = value_text
	value.add_theme_font_size_override("font_size", 14)
	# Use high-contrast white for values
	value.add_theme_color_override("font_color", color if color != Color.WHITE else Color(0.95, 0.95, 0.98))
	parent.add_child(value)


func create_progress_bar(value: float, max_value: float, color: Color) -> Control:
	"""Create a simple progress bar"""
	var container = Control.new()
	container.custom_minimum_size = Vector2(150, 12)
	
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.16, 0.19)  # Lighter background for visibility
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_child(bg)
	
	var fill = ColorRect.new()
	fill.color = color
	fill.anchor_right = clamp(value / max_value, 0.0, 1.0)
	fill.anchor_bottom = 1.0
	container.add_child(fill)
	
	return container


func create_line_chart(data: Array, color: Color, label: String) -> Control:
	"""Create a simple line chart for historical data"""
	var chart_panel = PanelContainer.new()
	chart_panel.custom_minimum_size = Vector2(CHART_WIDTH, CHART_HEIGHT + 30)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.11)  # Slightly darker for chart area contrast
	style.border_color = Color(0.2, 0.22, 0.26)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10)
	chart_panel.add_theme_stylebox_override("panel", style)
	
	var chart_vbox = VBoxContainer.new()
	chart_vbox.add_theme_constant_override("separation", 4)
	chart_panel.add_child(chart_vbox)
	
	# Chart drawing area
	var chart_area = Control.new()
	chart_area.custom_minimum_size = Vector2(CHART_WIDTH - 20, CHART_HEIGHT)
	
	# Store data for drawing and connect draw signal
	chart_area.set_meta("data", data)
	chart_area.set_meta("color", color)
	chart_area.draw.connect(_draw_line_chart.bind(chart_area, data, color))
	chart_vbox.add_child(chart_area)
	
	# Value labels
	var labels_hbox = HBoxContainer.new()
	chart_vbox.add_child(labels_hbox)
	
	if not data.is_empty():
		var min_val: float = data[0]
		var max_val: float = data[0]
		for v in data:
			min_val = min(min_val, v)
			max_val = max(max_val, v)
		
		var min_label = Label.new()
		min_label.text = "Min: %s" % UITheme.format_money(min_val)
		min_label.add_theme_font_size_override("font_size", 10)
		min_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.72))  # Lighter for readability
		labels_hbox.add_child(min_label)
		
		var spacer = Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		labels_hbox.add_child(spacer)
		
		var max_label = Label.new()
		max_label.text = "Max: %s" % UITheme.format_money(max_val)
		max_label.add_theme_font_size_override("font_size", 10)
		max_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.72))  # Lighter for readability
		labels_hbox.add_child(max_label)
	
	return chart_panel


func _draw_line_chart(chart_area: Control, data: Array, color: Color) -> void:
	"""Draw the line chart"""
	if data.is_empty():
		return
	
	var rect = chart_area.get_rect()
	var width = rect.size.x
	var height = rect.size.y
	var padding = 5.0
	
	# Find min/max for scaling
	var min_val: float = data[0]
	var max_val: float = data[0]
	for v in data:
		min_val = min(min_val, v)
		max_val = max(max_val, v)
	
	# Add some padding to range
	var range_val = max_val - min_val
	if range_val == 0:
		range_val = max(1.0, max_val * 0.1)
	min_val -= range_val * 0.1
	max_val += range_val * 0.1
	range_val = max_val - min_val
	
	# Draw background grid lines
	var grid_color = Color(0.3, 0.3, 0.3, 0.3)
	for i in range(5):
		var y = padding + (height - padding * 2) * (i / 4.0)
		chart_area.draw_line(Vector2(padding, y), Vector2(width - padding, y), grid_color, 1.0)
	
	# Draw line chart
	var points: PackedVector2Array = []
	var step_x = (width - padding * 2) / max(1, data.size() - 1)
	
	for i in range(data.size()):
		var x = padding + i * step_x
		var normalized = (data[i] - min_val) / range_val if range_val > 0 else 0.5
		var y = height - padding - normalized * (height - padding * 2)
		points.append(Vector2(x, y))
	
	# Draw the line
	if points.size() >= 2:
		chart_area.draw_polyline(points, color, 2.0, true)
	
	# Draw points
	for point in points:
		chart_area.draw_circle(point, 4.0, color)


func create_route_badge(route) -> Control:
	"""Create a badge for a route"""
	var badge = PanelContainer.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(UITheme.PRIMARY_BLUE.r, UITheme.PRIMARY_BLUE.g, UITheme.PRIMARY_BLUE.b, 0.2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	badge.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = route.get_display_name()
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	badge.add_child(label)
	
	return badge


func find_route_by_id(route_id: int):
	"""Find a route by ID in player airline's routes"""
	if GameData.player_airline:
		for route in GameData.player_airline.routes:
			if route.id == route_id:
				return route
	return null


func format_number(value: int) -> String:
	"""Format large numbers with K/M suffixes"""
	if value >= 1000000:
		return "%.1fM" % (value / 1000000.0)
	elif value >= 1000:
		return "%.1fK" % (value / 1000.0)
	else:
		return str(value)
