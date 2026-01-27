## FleetComparisonPanel.gd
## Displays side-by-side comparison of all aircraft types with stats,
## per-aircraft metrics, and sorting options.
## Part of the Fleet tab in the main dashboard UI.
extends Control
class_name FleetComparisonPanel

## Sort options for the comparison table
enum SortBy {
	PROFITABILITY,
	UTILIZATION,
	COST_EFFICIENCY,
	SEATS,
	RANGE,
	PRICE
}

## Current sort mode
var current_sort: SortBy = SortBy.PROFITABILITY

## UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var sort_buttons: Dictionary = {}
var comparison_container: VBoxContainer

## "Best for" labels for each aircraft category
const AIRCRAFT_BEST_FOR: Dictionary = {
	"ATR 72-600": "Regional routes (< 1,500km)",
	"Airbus A320neo": "Medium-haul dense routes",
	"Boeing 737-800": "Medium-haul network building"
}

## Aircraft image paths
const AIRCRAFT_IMAGES: Dictionary = {
	"ATR 72-600": "res://assets/aircraft/atr-72-600.png",
	"Airbus A320neo": "res://assets/aircraft/airbus-a320neo.png",
	"Boeing 737-800": "res://assets/aircraft/boeing-737-800.png"
}

## Cached textures
var aircraft_textures: Dictionary = {}

func _ready() -> void:
	_load_aircraft_textures()
	build_ui()
	refresh()


func _load_aircraft_textures() -> void:
	"""Preload aircraft images"""
	for aircraft_name in AIRCRAFT_IMAGES:
		var path: String = AIRCRAFT_IMAGES[aircraft_name]
		if ResourceLoader.exists(path):
			aircraft_textures[aircraft_name] = load(path)
		else:
			push_warning("Aircraft image not found: %s" % path)


func build_ui() -> void:
	"""Build the comparison panel UI"""
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
	
	# Sort options
	create_sort_bar(outer_vbox)
	
	# Scrollable comparison content
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)
	
	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 16)
	scroll_container.add_child(main_vbox)
	
	# Comparison cards container
	comparison_container = VBoxContainer.new()
	comparison_container.add_theme_constant_override("separation", 16)
	main_vbox.add_child(comparison_container)


func create_header(parent: VBoxContainer) -> void:
	"""Create header section"""
	var header_vbox = VBoxContainer.new()
	header_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(header_vbox)
	
	var title = Label.new()
	title.text = "Fleet Comparison"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	header_vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Compare aircraft specifications and performance metrics"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_secondary())
	header_vbox.add_child(subtitle)


func create_sort_bar(parent: VBoxContainer) -> void:
	"""Create sort options bar"""
	var sort_hbox = HBoxContainer.new()
	sort_hbox.add_theme_constant_override("separation", 8)
	parent.add_child(sort_hbox)
	
	var sort_label = Label.new()
	sort_label.text = "Sort by:"
	sort_label.add_theme_font_size_override("font_size", 13)
	sort_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	sort_hbox.add_child(sort_label)
	
	var sort_options: Array = [
		["Profitability", SortBy.PROFITABILITY],
		["Utilization", SortBy.UTILIZATION],
		["Cost Efficiency", SortBy.COST_EFFICIENCY],
		["Seats", SortBy.SEATS],
		["Range", SortBy.RANGE],
		["Price", SortBy.PRICE]
	]
	
	for option in sort_options:
		var btn = Button.new()
		btn.text = option[0]
		btn.custom_minimum_size = Vector2(100, 32)
		btn.add_theme_font_size_override("font_size", 12)
		btn.toggle_mode = true
		btn.button_pressed = (option[1] == current_sort)
		btn.pressed.connect(_on_sort_button_pressed.bind(option[1]))
		
		_style_sort_button(btn, option[1] == current_sort)
		sort_buttons[option[1]] = btn
		sort_hbox.add_child(btn)


func _style_sort_button(btn: Button, active: bool) -> void:
	"""Style a sort button based on active state"""
	var style = StyleBoxFlat.new()
	if active:
		style.bg_color = UITheme.PRIMARY_BLUE
	else:
		style.bg_color = UITheme.get_button_bg()
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("pressed", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = hover_style.bg_color.lightened(0.1)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_color_override("font_color", UITheme.TEXT_WHITE if active else UITheme.get_text_primary())


func _on_sort_button_pressed(sort_by: SortBy) -> void:
	"""Handle sort button press"""
	current_sort = sort_by
	
	# Update button styles
	for sort_type in sort_buttons:
		var btn: Button = sort_buttons[sort_type]
		btn.button_pressed = (sort_type == current_sort)
		_style_sort_button(btn, sort_type == current_sort)
	
	refresh()


func refresh() -> void:
	"""Refresh comparison data"""
	# Clear existing cards
	for child in comparison_container.get_children():
		child.queue_free()
	
	# Get aircraft data
	var aircraft_data: Array = _get_aircraft_comparison_data()
	
	# Sort by current criteria
	aircraft_data.sort_custom(_sort_aircraft)
	
	# Create comparison cards
	for data in aircraft_data:
		var card = create_aircraft_comparison_card(data)
		comparison_container.add_child(card)


func _get_aircraft_comparison_data() -> Array:
	"""Gather comparison data for all aircraft types"""
	var data: Array = []
	
	if not GameData.aircraft_models:
		return data
	
	for model in GameData.aircraft_models:
		var daily_cost: float = model.get_meta("daily_cost", 3500.0)
		var lease_rate: float = model.get_meta("lease_rate_monthly", 100000.0)
		var display_name: String = model.model_name
		
		var model_data: Dictionary = {
			"model": model,
			"name": display_name,
			"seats": model.max_total_seats,
			"range_km": model.range_km,
			"speed_kmh": model.speed_kmh,
			"daily_cost": daily_cost,
			"price": model.price,
			"lease_rate": lease_rate,
			"fuel_burn": model.fuel_burn,
			"best_for": AIRCRAFT_BEST_FOR.get(display_name, "General purpose"),
			# Per-aircraft metrics (aggregated from player's fleet)
			"fleet_count": 0,
			"total_utilization": 0.0,
			"total_revenue": 0.0,
			"total_profit": 0.0,
			"avg_utilization": 0.0,
			"weekly_revenue": 0.0,
			"weekly_profit": 0.0,
			"cost_per_seat": daily_cost / float(model.max_total_seats) if model.max_total_seats > 0 else 0.0
		}
		
		# Calculate metrics from player's aircraft of this type
		if GameData.player_airline:
			for aircraft in GameData.player_airline.aircraft:
				if aircraft.model.model_name == display_name:
					model_data.fleet_count += 1
					# Utilization: 1.0 if assigned to a route, 0.0 if idle
					var utilization: float = 1.0 if aircraft.is_assigned else 0.0
					model_data.total_utilization += utilization
					
					# Sum revenue/profit from routes using this aircraft
					for route in GameData.player_airline.routes:
						for assigned in route.assigned_aircraft:
							if assigned == aircraft:
								model_data.total_revenue += route.revenue_generated
								model_data.total_profit += route.weekly_profit
			
			if model_data.fleet_count > 0:
				model_data.avg_utilization = model_data.total_utilization / model_data.fleet_count
				model_data.weekly_revenue = model_data.total_revenue
				model_data.weekly_profit = model_data.total_profit
		
		data.append(model_data)
	
	return data


func _sort_aircraft(a: Dictionary, b: Dictionary) -> bool:
	"""Sort comparison data based on current sort mode"""
	match current_sort:
		SortBy.PROFITABILITY:
			# Sort by profit per seat (efficiency), then by total profit
			var a_profit_per_seat = a.weekly_profit / float(a.seats) if a.seats > 0 else 0
			var b_profit_per_seat = b.weekly_profit / float(b.seats) if b.seats > 0 else 0
			if a.fleet_count == 0 and b.fleet_count == 0:
				return a.cost_per_seat < b.cost_per_seat  # Lower cost = better
			return a_profit_per_seat > b_profit_per_seat
		SortBy.UTILIZATION:
			return a.avg_utilization > b.avg_utilization
		SortBy.COST_EFFICIENCY:
			return a.cost_per_seat < b.cost_per_seat
		SortBy.SEATS:
			return a.seats > b.seats
		SortBy.RANGE:
			return a.range_km > b.range_km
		SortBy.PRICE:
			return a.price < b.price
	return false


func create_aircraft_comparison_card(data: Dictionary) -> Control:
	"""Create a comparison card for an aircraft type"""
	var card = _create_card_container()
	var margin: MarginContainer = card.get_child(0)
	var main_hbox: HBoxContainer = margin.get_child(0)
	
	# Add aircraft image
	_add_aircraft_image(main_hbox, data)
	
	# Content section
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	main_hbox.add_child(vbox)
	
	# Add header row with name and badges
	_add_header_row(vbox, data)
	
	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Add specs grid
	_add_specs_grid(vbox, data)
	
	# Add fleet metrics or efficiency info
	_add_fleet_metrics(vbox, data)
	
	return card


func _create_card_container() -> PanelContainer:
	"""Create the outer card container with margin and main hbox"""
	var card = PanelContainer.new()
	
	var style = UITheme.create_card_panel_style()
	card.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_all", 16)
	card.add_child(margin)
	
	var main_hbox = HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 20)
	margin.add_child(main_hbox)
	
	return card


func _add_aircraft_image(parent: HBoxContainer, data: Dictionary) -> void:
	"""Add aircraft image section to the card"""
	var image_container = PanelContainer.new()
	image_container.custom_minimum_size = Vector2(200, 120)
	
	var image_style = StyleBoxFlat.new()
	image_style.bg_color = Color(0.1, 0.1, 0.12)
	image_style.set_corner_radius_all(8)
	image_container.add_theme_stylebox_override("panel", image_style)
	parent.add_child(image_container)
	
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image_container.add_child(center)
	
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(180, 100)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if data.name in aircraft_textures:
		texture_rect.texture = aircraft_textures[data.name]
	center.add_child(texture_rect)


func _add_header_row(parent: VBoxContainer, data: Dictionary) -> void:
	"""Add header row with aircraft name, best-for badge, and fleet count"""
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 12)
	parent.add_child(header_hbox)
	
	# Aircraft name
	var name_label = Label.new()
	name_label.text = data.name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	header_hbox.add_child(name_label)
	
	# Best For badge
	var best_for_badge = Label.new()
	best_for_badge.text = data.best_for
	best_for_badge.add_theme_font_size_override("font_size", 11)
	best_for_badge.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = Color(UITheme.PRIMARY_BLUE.r, UITheme.PRIMARY_BLUE.g, UITheme.PRIMARY_BLUE.b, 0.15)
	badge_style.set_corner_radius_all(4)
	badge_style.set_content_margin_all(6)
	best_for_badge.add_theme_stylebox_override("normal", badge_style)
	header_hbox.add_child(best_for_badge)
	
	# Spacer
	var header_spacer = Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(header_spacer)
	
	# Fleet count if player owns any
	if data.fleet_count > 0:
		var fleet_label = Label.new()
		fleet_label.text = "You own: %d" % data.fleet_count
		fleet_label.add_theme_font_size_override("font_size", 12)
		fleet_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		header_hbox.add_child(fleet_label)


func _add_specs_grid(parent: VBoxContainer, data: Dictionary) -> void:
	"""Add specifications grid with seats, range, speed, costs"""
	var stats_grid = GridContainer.new()
	stats_grid.columns = 6
	stats_grid.add_theme_constant_override("h_separation", 24)
	stats_grid.add_theme_constant_override("v_separation", 8)
	parent.add_child(stats_grid)
	
	var specs: Array = [
		["Seats", "%d" % data.seats],
		["Range", "%s km" % UITheme.format_number(data.range_km)],
		["Speed", "%d km/h" % data.speed_kmh],
		["Cost/Day", UITheme.format_money(data.daily_cost)],
		["Price", UITheme.format_money(data.price)],
		["Lease/mo", UITheme.format_money(data.lease_rate)]
	]
	
	for spec in specs:
		_add_spec_item(stats_grid, spec[0], spec[1])


func _add_spec_item(parent: GridContainer, title: String, value: String) -> void:
	"""Add a single spec item (title + value) to the grid"""
	var spec_vbox = VBoxContainer.new()
	spec_vbox.add_theme_constant_override("separation", 2)
	parent.add_child(spec_vbox)
	
	var spec_title = Label.new()
	spec_title.text = title
	spec_title.add_theme_font_size_override("font_size", 11)
	spec_title.add_theme_color_override("font_color", UITheme.get_text_secondary())
	spec_vbox.add_child(spec_title)
	
	var spec_value = Label.new()
	spec_value.text = value
	spec_value.add_theme_font_size_override("font_size", 14)
	spec_value.add_theme_color_override("font_color", UITheme.get_text_primary())
	spec_vbox.add_child(spec_value)


func _add_fleet_metrics(parent: VBoxContainer, data: Dictionary) -> void:
	"""Add fleet performance metrics or efficiency info"""
	if data.fleet_count > 0:
		_add_owned_fleet_metrics(parent, data)
	else:
		_add_unowned_efficiency_info(parent, data)


func _add_owned_fleet_metrics(parent: VBoxContainer, data: Dictionary) -> void:
	"""Add performance metrics for owned aircraft"""
	var metrics_sep = HSeparator.new()
	parent.add_child(metrics_sep)
	
	var metrics_label = Label.new()
	metrics_label.text = "Your Fleet Performance"
	metrics_label.add_theme_font_size_override("font_size", 13)
	metrics_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	parent.add_child(metrics_label)
	
	var metrics_hbox = HBoxContainer.new()
	metrics_hbox.add_theme_constant_override("separation", 32)
	parent.add_child(metrics_hbox)
	
	# Utilization
	var util_color = UITheme.PROFIT_COLOR if data.avg_utilization >= 0.6 else UITheme.WARNING_COLOR if data.avg_utilization >= 0.4 else UITheme.get_text_primary()
	_add_metric_item(metrics_hbox, "Avg Utilization", "%.0f%%" % (data.avg_utilization * 100), util_color)
	
	# Weekly Revenue
	_add_metric_item(metrics_hbox, "Revenue/Week", UITheme.format_money(data.weekly_revenue), UITheme.get_text_primary())
	
	# Weekly Profit
	_add_metric_item(metrics_hbox, "Profit/Week", UITheme.format_money(data.weekly_profit, true), UITheme.get_profit_color(data.weekly_profit))
	
	# Cost per Seat
	_add_metric_item(metrics_hbox, "Cost/Seat/Day", "€%.2f" % data.cost_per_seat, UITheme.get_text_primary())


func _add_metric_item(parent: HBoxContainer, title: String, value: String, value_color: Color) -> void:
	"""Add a single metric item to the metrics row"""
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	parent.add_child(vbox)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 11)
	title_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	vbox.add_child(title_label)
	
	var value_label = Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", value_color)
	vbox.add_child(value_label)


func _add_unowned_efficiency_info(parent: VBoxContainer, data: Dictionary) -> void:
	"""Add efficiency info for aircraft not owned"""
	var efficiency_hbox = HBoxContainer.new()
	efficiency_hbox.add_theme_constant_override("separation", 16)
	parent.add_child(efficiency_hbox)
	
	var eff_label = Label.new()
	eff_label.text = "Cost/Seat/Day: €%.2f" % data.cost_per_seat
	eff_label.add_theme_font_size_override("font_size", 12)
	eff_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	efficiency_hbox.add_child(eff_label)
	
	var fuel_label = Label.new()
	fuel_label.text = "Fuel Burn: %d L/hr" % data.fuel_burn
	fuel_label.add_theme_font_size_override("font_size", 12)
	fuel_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	efficiency_hbox.add_child(fuel_label)
