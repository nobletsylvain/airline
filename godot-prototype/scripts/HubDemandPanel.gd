## HubDemandPanel.gd
## Shows most-demanded unserved destinations from player's hub airports (Task O.1)
## Also shows unserved city pairs with connection opportunities (Task O.3)
## Displays ranked list with estimated passengers and fleet range indicators
extends Control
class_name HubDemandPanel

## Emitted when player clicks a destination to create a route
signal destination_selected(hub: Airport, destination: Airport)

## Emitted when player clicks an unserved city pair to create connection
signal city_pair_selected(origin: Airport, destination: Airport, action: String)

## Maximum destinations to show per hub
const MAX_DESTINATIONS := 8

## Maximum city pairs to show
const MAX_CITY_PAIRS := 6

## Minimum demand threshold to show a destination
const MIN_DEMAND_THRESHOLD := 50.0

## Minimum demand threshold for city pairs
const MIN_CITY_PAIR_DEMAND := 100.0

# UI elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var hub_sections: Dictionary = {}  # Airport -> VBoxContainer

# Performance cache: pre-computed served pairs to avoid O(n²×m) lookups
var _served_pairs_cache: Dictionary = {}  # "IATA1-IATA2" -> true if any service exists

func _ready() -> void:
	build_ui()


func build_ui() -> void:
	"""Build the hub demand panel UI"""
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
	outer_vbox.add_theme_constant_override("separation", 16)
	margin.add_child(outer_vbox)
	
	# Header
	var header = Label.new()
	header.text = "✈ Passengers Want to Fly To..."
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", UITheme.get_text_primary())
	outer_vbox.add_child(header)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "Top unserved destinations from your hubs"
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
	main_vbox.add_theme_constant_override("separation", 20)
	scroll_container.add_child(main_vbox)


func refresh() -> void:
	"""Refresh the demand list with current data"""
	# Clear existing content
	for child in main_vbox.get_children():
		child.queue_free()
	hub_sections.clear()
	
	if not GameData.player_airline or GameData.player_airline.hubs.is_empty():
		_show_no_hub_message()
		return
	
	# Build served pairs cache once (performance optimization)
	_build_served_pairs_cache()
	
	# Get top demanded destinations for each hub
	for hub in GameData.player_airline.hubs:
		var destinations = _get_top_demanded_destinations(hub)
		if not destinations.is_empty():
			_create_hub_section(hub, destinations)
	
	# Add unserved city pairs section (O.3)
	_create_unserved_city_pairs_section()
	
	# Show empty state if no opportunities
	if main_vbox.get_child_count() == 0:
		_show_no_opportunities_message()


func _build_served_pairs_cache() -> void:
	"""Pre-compute all served airport pairs for O(1) lookup.
	Reduces complexity from O(n²×m) to O(n²) + O(m) where m = total routes."""
	_served_pairs_cache.clear()
	
	# Add all direct routes from all airlines
	for airline in GameData.airlines:
		for route in airline.routes:
			var key = _get_pair_key(route.from_airport, route.to_airport)
			_served_pairs_cache[key] = true
	
	# Add player airline routes
	if GameData.player_airline:
		for route in GameData.player_airline.routes:
			var key = _get_pair_key(route.from_airport, route.to_airport)
			_served_pairs_cache[key] = true
		
		# Add hub-connected pairs (indirect service via player hubs)
		for hub in GameData.player_airline.hubs:
			var connected_to_hub: Array[Airport] = []
			for route in GameData.player_airline.routes:
				if route.from_airport == hub:
					connected_to_hub.append(route.to_airport)
				elif route.to_airport == hub:
					connected_to_hub.append(route.from_airport)
			
			# Mark all pairs reachable through this hub as served
			for i in range(connected_to_hub.size()):
				for j in range(i + 1, connected_to_hub.size()):
					var key = _get_pair_key(connected_to_hub[i], connected_to_hub[j])
					_served_pairs_cache[key] = true


func _show_no_hub_message() -> void:
	"""Show message when player has no hubs"""
	var message = Label.new()
	message.text = "Purchase a hub airport first to see passenger demand."
	message.add_theme_font_size_override("font_size", 13)
	message.add_theme_color_override("font_color", UITheme.get_text_muted())
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(message)


func _show_no_opportunities_message() -> void:
	"""Show message when no opportunities available"""
	var message = Label.new()
	message.text = "All high-demand destinations are already served!\nGreat job building your network."
	message.add_theme_font_size_override("font_size", 13)
	message.add_theme_color_override("font_color", UITheme.get_text_muted())
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(message)


func _get_top_demanded_destinations(hub: Airport) -> Array[Dictionary]:
	"""Get top demanded unserved destinations from a hub"""
	var opportunities: Array[Dictionary] = []
	
	# Get all airports except the hub
	for airport in GameData.airports:
		if airport == hub:
			continue
		
		# Check if we already have a route to this destination
		if _has_route_to(hub, airport):
			continue
		
		# Calculate demand
		var distance = MarketAnalysis.calculate_great_circle_distance(hub, airport)
		var demand = MarketAnalysis.calculate_potential_demand(hub, airport, distance)
		
		if demand < MIN_DEMAND_THRESHOLD:
			continue
		
		# Check if we have aircraft that can fly this distance
		var can_fly = _can_fleet_fly_distance(distance)
		var max_range = _get_fleet_max_range()
		
		# Check competition
		var competition = _count_competition(hub, airport)
		
		opportunities.append({
			"airport": airport,
			"distance": distance,
			"demand": demand,
			"can_fly": can_fly,
			"max_range": max_range,
			"competition": competition
		})
	
	# Sort by demand (highest first)
	opportunities.sort_custom(func(a, b): return a.demand > b.demand)
	
	# Return top N
	var result: Array[Dictionary] = []
	for i in range(min(MAX_DESTINATIONS, opportunities.size())):
		result.append(opportunities[i])
	
	return result


func _has_route_to(hub: Airport, destination: Airport) -> bool:
	"""Check if player already has a route between these airports"""
	return GameData.has_route_between(hub, destination, GameData.player_airline)


func _can_fleet_fly_distance(distance_km: float) -> bool:
	"""Check if any aircraft in fleet can fly this distance"""
	if not GameData.player_airline:
		return false
	
	for aircraft in GameData.player_airline.aircraft:
		if aircraft.model and aircraft.model.can_fly_distance(distance_km):
			return true
	return false


func _get_fleet_max_range() -> float:
	"""Get the maximum range of any aircraft in the fleet"""
	var max_range: float = 0.0
	
	if not GameData.player_airline:
		return max_range
	
	for aircraft in GameData.player_airline.aircraft:
		if aircraft.model and aircraft.model.range_km > max_range:
			max_range = aircraft.model.range_km
	
	return max_range


func _count_competition(hub: Airport, destination: Airport) -> int:
	"""Count competitors on this route"""
	return GameData.count_competitors_on_route(hub, destination, GameData.player_airline)


func _create_hub_section(hub: Airport, destinations: Array[Dictionary]) -> void:
	"""Create a section for a hub with its top destinations"""
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 10)
	main_vbox.add_child(section)
	hub_sections[hub] = section
	
	# Hub header
	var hub_header = HBoxContainer.new()
	hub_header.add_theme_constant_override("separation", 8)
	section.add_child(hub_header)
	
	var hub_icon = Label.new()
	hub_icon.text = "🏢"
	hub_icon.add_theme_font_size_override("font_size", 14)
	hub_header.add_child(hub_icon)
	
	var hub_name = Label.new()
	hub_name.text = "From %s (%s)" % [hub.name, hub.iata_code]
	hub_name.add_theme_font_size_override("font_size", 14)
	hub_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	hub_header.add_child(hub_name)
	
	# Destinations list
	for dest_data in destinations:
		var dest_row = _create_destination_row(hub, dest_data)
		section.add_child(dest_row)


func _create_destination_row(hub: Airport, dest_data: Dictionary) -> Control:
	"""Create a clickable row for a destination"""
	var airport: Airport = dest_data.airport
	var demand: float = dest_data.demand
	var distance: float = dest_data.distance
	var can_fly: bool = dest_data.can_fly
	var competition: int = dest_data.competition
	
	var row = PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 50)
	
	# Row style
	var row_style = StyleBoxFlat.new()
	row_style.bg_color = UITheme.get_card_bg()
	row_style.set_corner_radius_all(8)
	row_style.set_content_margin_all(10)
	row_style.border_color = UITheme.get_panel_border()
	row_style.set_border_width_all(1)
	row.add_theme_stylebox_override("panel", row_style)
	
	# Hover effect
	var hover_style = row_style.duplicate()
	hover_style.border_color = UITheme.PRIMARY_BLUE
	hover_style.set_border_width_all(2)
	
	if can_fly:
		row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		row.tooltip_text = "Click to create route to %s" % airport.name
		
		row.mouse_entered.connect(func():
			row.add_theme_stylebox_override("panel", hover_style)
		)
		row.mouse_exited.connect(func():
			row.add_theme_stylebox_override("panel", row_style)
		)
		row.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				destination_selected.emit(hub, airport)
		)
	else:
		row.tooltip_text = "Distance: %.0f km\nYour fleet max range: %.0f km\nNeed longer-range aircraft!" % [distance, dest_data.max_range]
	
	# Content
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)
	
	# Destination info (left)
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)
	
	# Airport name row
	var name_hbox = HBoxContainer.new()
	name_hbox.add_theme_constant_override("separation", 8)
	info_vbox.add_child(name_hbox)
	
	var dest_name = Label.new()
	dest_name.text = "%s (%s)" % [airport.name, airport.iata_code]
	dest_name.add_theme_font_size_override("font_size", 13)
	dest_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	name_hbox.add_child(dest_name)
	
	# Competition indicator
	if competition > 0:
		var comp_badge = Label.new()
		comp_badge.text = "⚠ %d comp" % competition
		comp_badge.add_theme_font_size_override("font_size", 10)
		comp_badge.add_theme_color_override("font_color", UITheme.WARNING_COLOR)
		name_hbox.add_child(comp_badge)
	else:
		var no_comp_badge = Label.new()
		no_comp_badge.text = "★ No competition"
		no_comp_badge.add_theme_font_size_override("font_size", 10)
		no_comp_badge.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		name_hbox.add_child(no_comp_badge)
	
	# Distance
	var distance_label = Label.new()
	distance_label.text = "%.0f km" % distance
	distance_label.add_theme_font_size_override("font_size", 11)
	distance_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	info_vbox.add_child(distance_label)
	
	# Demand indicator (right) - Q.2: Show with uncertainty
	var demand_vbox = VBoxContainer.new()
	demand_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(demand_vbox)
	
	var demand_label = Label.new()
	var demand_info = GameData.get_demand_display(hub, airport, demand)
	# Extract just the number part for compact display
	if demand_info.is_exact:
		demand_label.text = "~%.0f" % demand
	else:
		# Show range more compactly
		var min_d = int(demand * 0.65) if demand_info.confidence == "low" else int(demand * 0.80)
		var max_d = int(demand * 1.35) if demand_info.confidence == "low" else int(demand * 1.20)
		demand_label.text = "%d-%d" % [min_d, max_d]
	demand_label.add_theme_font_size_override("font_size", 14)
	demand_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# Use readable white text with confidence shown via icon/tooltip
	demand_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	var confidence_icon = "●" if demand_info.is_exact else ("◐" if demand_info.confidence == "medium" else "○")
	demand_label.tooltip_text = "%s %s (Confidence: %s)" % [confidence_icon, demand_info.display_text, demand_info.confidence.capitalize()]
	demand_vbox.add_child(demand_label)
	
	var pax_label = Label.new()
	pax_label.text = "pax/week"
	pax_label.add_theme_font_size_override("font_size", 10)
	pax_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pax_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	demand_vbox.add_child(pax_label)
	
	# Fleet range indicator (far right)
	var range_indicator = Label.new()
	if can_fly:
		range_indicator.text = "✓"
		range_indicator.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		range_indicator.tooltip_text = "Your fleet can reach this destination"
	else:
		range_indicator.text = "✗"
		range_indicator.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
		range_indicator.tooltip_text = "Out of range - need longer-range aircraft"
	range_indicator.add_theme_font_size_override("font_size", 16)
	range_indicator.custom_minimum_size = Vector2(24, 0)
	hbox.add_child(range_indicator)
	
	return row


## ============================================================================
## UNSERVED CITY PAIRS (O.3)
## Shows city pairs with demand but no service (direct or via hub)
## ============================================================================

func _create_unserved_city_pairs_section() -> void:
	"""Create section showing unserved city pairs with connection opportunities"""
	var city_pairs = _get_unserved_city_pairs()
	
	if city_pairs.is_empty():
		return
	
	# Separator
	var sep = HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	main_vbox.add_child(sep)
	
	# Section container
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 10)
	main_vbox.add_child(section)
	
	# Header
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	section.add_child(header_hbox)
	
	var header_icon = Label.new()
	header_icon.text = "🔗"
	header_icon.add_theme_font_size_override("font_size", 14)
	header_hbox.add_child(header_icon)
	
	var header = Label.new()
	header.text = "Unserved City Pairs"
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", UITheme.get_text_primary())
	header_hbox.add_child(header)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "Passengers want to travel between these cities"
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_muted())
	section.add_child(subtitle)
	
	# City pair rows
	for pair_data in city_pairs:
		var row = _create_city_pair_row(pair_data)
		section.add_child(row)


func _get_unserved_city_pairs() -> Array[Dictionary]:
	"""Find city pairs with demand but no service (direct or via player's hub)"""
	var pairs: Array[Dictionary] = []
	var checked_pairs: Dictionary = {}  # "IATA1-IATA2" -> true to avoid duplicates
	
	if not GameData.player_airline:
		return pairs
	
	# Get airports connected to player's hubs
	var connected_airports: Array[Airport] = []
	for hub in GameData.player_airline.hubs:
		connected_airports.append(hub)
	for route in GameData.player_airline.routes:
		if route.to_airport not in connected_airports:
			connected_airports.append(route.to_airport)
		if route.from_airport not in connected_airports:
			connected_airports.append(route.from_airport)
	
	# Check all airport pairs
	for i in range(GameData.airports.size()):
		for j in range(i + 1, GameData.airports.size()):
			var airport1: Airport = GameData.airports[i]
			var airport2: Airport = GameData.airports[j]
			
			# Skip if both are player's hubs (already have service implicitly)
			if GameData.player_airline.has_hub(airport1) and GameData.player_airline.has_hub(airport2):
				continue
			
			# Create unique key
			var key = _get_pair_key(airport1, airport2)
			if checked_pairs.has(key):
				continue
			checked_pairs[key] = true
			
			# Check if there's any service (direct or via hub)
			if _has_any_service(airport1, airport2):
				continue
			
			# Calculate demand
			var distance = MarketAnalysis.calculate_great_circle_distance(airport1, airport2)
			var demand = MarketAnalysis.calculate_potential_demand(airport1, airport2, distance)
			
			if demand < MIN_CITY_PAIR_DEMAND:
				continue
			
			# Determine action type
			var action_info = _get_action_for_pair(airport1, airport2, connected_airports)
			
			pairs.append({
				"airport1": airport1,
				"airport2": airport2,
				"demand": demand,
				"distance": distance,
				"action_type": action_info.action_type,
				"action_text": action_info.action_text,
				"target_airport": action_info.target_airport,
				"hub": action_info.hub
			})
	
	# Sort by demand
	pairs.sort_custom(func(a, b): return a.demand > b.demand)
	
	# Return top N
	var result: Array[Dictionary] = []
	for i in range(min(MAX_CITY_PAIRS, pairs.size())):
		result.append(pairs[i])
	
	return result


func _get_pair_key(a1: Airport, a2: Airport) -> String:
	"""Get unique key for airport pair (order-independent)"""
	if a1.iata_code < a2.iata_code:
		return "%s-%s" % [a1.iata_code, a2.iata_code]
	else:
		return "%s-%s" % [a2.iata_code, a1.iata_code]


func _has_any_service(airport1: Airport, airport2: Airport) -> bool:
	"""Check if there's any service between these airports (direct by anyone, or via player's hub).
	Uses pre-computed cache for O(1) lookup."""
	var key = _get_pair_key(airport1, airport2)
	return _served_pairs_cache.has(key)


func _get_action_for_pair(airport1: Airport, airport2: Airport, connected_airports: Array[Airport]) -> Dictionary:
	"""Determine what action would enable service for this city pair"""
	var a1_connected = airport1 in connected_airports
	var a2_connected = airport2 in connected_airports
	
	if a1_connected and not a2_connected:
		# Airport 1 is in network, need to add route to airport 2
		var nearest_hub = _get_nearest_hub_for_airport(airport1)
		return {
			"action_type": "add_route",
			"action_text": "Add route to %s" % airport2.iata_code,
			"target_airport": airport2,
			"hub": nearest_hub
		}
	elif a2_connected and not a1_connected:
		# Airport 2 is in network, need to add route to airport 1
		var nearest_hub = _get_nearest_hub_for_airport(airport2)
		return {
			"action_type": "add_route",
			"action_text": "Add route to %s" % airport1.iata_code,
			"target_airport": airport1,
			"hub": nearest_hub
		}
	elif a1_connected and a2_connected:
		# Both connected but not through same hub - need to connect them
		return {
			"action_type": "connect_airports",
			"action_text": "Connect %s ↔ %s" % [airport1.iata_code, airport2.iata_code],
			"target_airport": null,
			"hub": null
		}
	else:
		# Neither connected - might need new hub or to connect both
		var nearest_hub = _get_nearest_hub(airport1, airport2)
		if nearest_hub:
			return {
				"action_type": "connect_both",
				"action_text": "Connect both from %s" % nearest_hub.iata_code,
				"target_airport": null,
				"hub": nearest_hub
			}
		else:
			return {
				"action_type": "new_hub",
				"action_text": "Requires new hub",
				"target_airport": null,
				"hub": null
			}


func _get_nearest_hub_for_airport(airport: Airport) -> Airport:
	"""Get the hub that this airport is connected to (or nearest if multiple)"""
	if not GameData.player_airline:
		return null
	
	# If the airport IS a hub, return it
	if GameData.player_airline.has_hub(airport):
		return airport
	
	# Find which hub has a route to this airport
	for hub in GameData.player_airline.hubs:
		for route in GameData.player_airline.routes:
			if (route.from_airport == hub and route.to_airport == airport) or \
			   (route.from_airport == airport and route.to_airport == hub):
				return hub
	
	# Fallback: return first hub
	if GameData.player_airline.hubs.size() > 0:
		return GameData.player_airline.hubs[0]
	
	return null


func _get_nearest_hub(airport1: Airport, airport2: Airport) -> Airport:
	"""Get the nearest player hub to either airport"""
	if not GameData.player_airline or GameData.player_airline.hubs.is_empty():
		return null
	
	var nearest: Airport = null
	var min_total_distance: float = INF
	
	for hub in GameData.player_airline.hubs:
		var d1 = MarketAnalysis.calculate_great_circle_distance(hub, airport1)
		var d2 = MarketAnalysis.calculate_great_circle_distance(hub, airport2)
		var total = d1 + d2
		
		if total < min_total_distance:
			min_total_distance = total
			nearest = hub
	
	return nearest


func _create_city_pair_row(pair_data: Dictionary) -> Control:
	"""Create a row for an unserved city pair"""
	var airport1: Airport = pair_data.airport1
	var airport2: Airport = pair_data.airport2
	var demand: float = pair_data.demand
	var action_type: String = pair_data.action_type
	var action_text: String = pair_data.action_text
	
	var row = PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 60)
	
	# Row style with color-coded left border based on action type
	var row_style = StyleBoxFlat.new()
	row_style.bg_color = UITheme.get_card_bg()
	row_style.set_corner_radius_all(8)
	row_style.set_content_margin_all(10)
	
	match action_type:
		"add_route":
			row_style.border_color = UITheme.PRIMARY_BLUE
			row_style.border_width_left = 4
		"connect_both", "connect_airports":
			row_style.border_color = UITheme.WARNING_COLOR
			row_style.border_width_left = 4
		"new_hub":
			row_style.border_color = UITheme.get_text_muted()
			row_style.border_width_left = 4
		_:
			row_style.border_color = UITheme.get_panel_border()
			row_style.set_border_width_all(1)
	
	row.add_theme_stylebox_override("panel", row_style)
	
	# Make clickable if actionable
	if action_type != "new_hub":
		var hover_style = row_style.duplicate()
		hover_style.bg_color = UITheme.get_card_bg().lightened(0.05)
		hover_style.border_color = UITheme.PRIMARY_BLUE
		hover_style.set_border_width_all(2)
		
		row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		row.tooltip_text = action_text
		
		row.mouse_entered.connect(func():
			row.add_theme_stylebox_override("panel", hover_style)
		)
		row.mouse_exited.connect(func():
			row.add_theme_stylebox_override("panel", row_style)
		)
		row.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_city_pair_clicked(pair_data)
		)
	
	# Content
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)
	
	# City pair info (left)
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)
	
	# City pair name row
	var name_hbox = HBoxContainer.new()
	name_hbox.add_theme_constant_override("separation", 8)
	info_vbox.add_child(name_hbox)
	
	var pair_name = Label.new()
	pair_name.text = "%s (%s) ↔ %s (%s)" % [airport1.city, airport1.iata_code, airport2.city, airport2.iata_code]
	pair_name.add_theme_font_size_override("font_size", 12)
	pair_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	name_hbox.add_child(pair_name)
	
	# Action text
	var action_label = Label.new()
	action_label.text = action_text
	action_label.add_theme_font_size_override("font_size", 11)
	
	match action_type:
		"add_route":
			action_label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
		"connect_both", "connect_airports":
			action_label.add_theme_color_override("font_color", UITheme.WARNING_COLOR)
		"new_hub":
			action_label.add_theme_color_override("font_color", UITheme.get_text_muted())
		_:
			action_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	
	info_vbox.add_child(action_label)
	
	# Demand indicator (right) - Q.2: Show with uncertainty
	var demand_vbox = VBoxContainer.new()
	demand_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(demand_vbox)
	
	var demand_label = Label.new()
	var demand_info = GameData.get_demand_display(airport1, airport2, demand)
	# Extract just the number part for compact display
	if demand_info.is_exact:
		demand_label.text = "~%.0f" % demand
	else:
		# Show range more compactly
		var min_d = int(demand * 0.65) if demand_info.confidence == "low" else int(demand * 0.80)
		var max_d = int(demand * 1.35) if demand_info.confidence == "low" else int(demand * 1.20)
		demand_label.text = "%d-%d" % [min_d, max_d]
	demand_label.add_theme_font_size_override("font_size", 14)
	demand_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# Use readable white text with confidence shown via icon/tooltip
	demand_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	var confidence_icon = "●" if demand_info.is_exact else ("◐" if demand_info.confidence == "medium" else "○")
	demand_label.tooltip_text = "%s %s (Confidence: %s)" % [confidence_icon, demand_info.display_text, demand_info.confidence.capitalize()]
	demand_vbox.add_child(demand_label)
	
	var pax_label = Label.new()
	pax_label.text = "pax/week"
	pax_label.add_theme_font_size_override("font_size", 10)
	pax_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pax_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	demand_vbox.add_child(pax_label)
	
	return row


func _on_city_pair_clicked(pair_data: Dictionary) -> void:
	"""Handle click on a city pair row"""
	var action_type: String = pair_data.action_type
	
	match action_type:
		"add_route":
			# Emit signal to create route from hub to target airport
			if pair_data.hub and pair_data.target_airport:
				destination_selected.emit(pair_data.hub, pair_data.target_airport)
		"connect_both":
			# Need to connect both airports - for now, suggest first one
			if pair_data.hub:
				destination_selected.emit(pair_data.hub, pair_data.airport1)
		"connect_airports":
			# Both airports are in network but not connected via hub
			# Suggest connecting to the first airport
			var hub = _get_nearest_hub_for_airport(pair_data.airport1)
			if hub:
				destination_selected.emit(hub, pair_data.airport2)
		_:
			# Emit general signal for other actions
			city_pair_selected.emit(pair_data.airport1, pair_data.airport2, action_type)
