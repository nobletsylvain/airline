## PassengerFlowPanel.gd
## Displays passenger flow visualization from a connected airport
## Shows where passengers want to travel and connecting opportunities through player's hub
extends Window
class_name PassengerFlowPanel

## Emitted when player clicks to create a connecting route
signal connection_route_requested(hub: Airport, destination: Airport)

## Configuration
const MAX_DESTINATIONS := 12
const MIN_DEMAND_THRESHOLD := 5.0  # Lowered from 20.0 to catch more destinations

# UI elements
var main_vbox: VBoxContainer
var scroll_container: ScrollContainer
var destinations_vbox: VBoxContainer

# Data
var source_airport: Airport = null
var connecting_hub: Airport = null


func _init() -> void:
	title = "Passenger Flows"
	size = Vector2i(500, 550)
	unresizable = false
	transient = true
	exclusive = false


func _ready() -> void:
	close_requested.connect(hide)
	build_ui()


func build_ui() -> void:
	"""Build the panel UI"""
	# Main margin container fills the window
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)
	
	# Background panel
	var bg = PanelContainer.new()
	bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.10, 0.11, 0.14)
	bg_style.set_corner_radius_all(8)
	bg.add_theme_stylebox_override("panel", bg_style)
	margin.add_child(bg)
	
	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 12)
	bg.add_child(main_vbox)
	
	# Inner margin for content padding
	var inner_margin = MarginContainer.new()
	inner_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner_margin.add_theme_constant_override("margin_left", 12)
	inner_margin.add_theme_constant_override("margin_right", 12)
	inner_margin.add_theme_constant_override("margin_top", 12)
	inner_margin.add_theme_constant_override("margin_bottom", 12)
	main_vbox.add_child(inner_margin)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.name = "ContentVBox"
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 12)
	inner_margin.add_child(content_vbox)
	
	# Header section (will be populated in show_for_airport)
	var header_vbox = VBoxContainer.new()
	header_vbox.name = "HeaderSection"
	header_vbox.add_theme_constant_override("separation", 6)
	content_vbox.add_child(header_vbox)
	
	# Separator
	var sep = HSeparator.new()
	content_vbox.add_child(sep)
	
	# Destinations section - ScrollContainer with proper sizing
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content_vbox.add_child(scroll_container)
	
	destinations_vbox = VBoxContainer.new()
	destinations_vbox.name = "DestinationsVBox"
	destinations_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	destinations_vbox.add_theme_constant_override("separation", 8)
	scroll_container.add_child(destinations_vbox)


func show_for_airport(airport: Airport, hub: Airport) -> void:
	"""Show passenger flow panel for a connected airport"""
	source_airport = airport
	connecting_hub = hub
	
	# Update title
	title = "Passengers from %s (%s)" % [airport.city, airport.iata_code]
	
	# Clear and rebuild header - search through hierarchy
	var header: VBoxContainer = null
	for child in main_vbox.get_children():
		if child is MarginContainer:
			for inner in child.get_children():
				if inner is VBoxContainer and inner.name == "ContentVBox":
					header = inner.get_node_or_null("HeaderSection")
					break
	
	if not header:
		push_error("[PassengerFlow] Header not found in UI hierarchy")
	
	if header:
		for child in header.get_children():
			child.queue_free()
		
		# Airport name
		var title_label = Label.new()
		title_label.text = "✈ Passengers from %s" % airport.name
		title_label.add_theme_font_size_override("font_size", 18)
		title_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
		header.add_child(title_label)
		
		# Subtitle
		var subtitle = Label.new()
		subtitle.text = "Where do travelers from %s want to go?" % airport.city
		subtitle.add_theme_font_size_override("font_size", 13)
		subtitle.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
		header.add_child(subtitle)
		
		# Connection info
		var connection_info = Label.new()
		connection_info.text = "🔗 Connected via your hub: %s (%s)" % [hub.city, hub.iata_code]
		connection_info.add_theme_font_size_override("font_size", 12)
		connection_info.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
		header.add_child(connection_info)
	
	# Calculate and display destinations
	_refresh_destinations()
	
	popup_centered()


func _refresh_destinations() -> void:
	"""Calculate and display top destinations from the source airport"""
	# Ensure UI is built
	if not destinations_vbox:
		push_warning("[PassengerFlow] destinations_vbox is null, rebuilding UI")
		build_ui()
	
	if not destinations_vbox:
		push_error("[PassengerFlow] Still no destinations_vbox after rebuild")
		return
	
	# Clear existing children immediately (not queue_free which defers removal)
	for child in destinations_vbox.get_children():
		destinations_vbox.remove_child(child)
		child.queue_free()
	
	if not source_airport or not connecting_hub or not GameData.player_airline:
		_show_empty_message("Unable to analyze passenger flows")
		return
	
	# Get top destinations from this airport
	var destinations = _calculate_top_destinations()
	
	if destinations.is_empty():
		_show_empty_message("No significant passenger demand from this airport")
		return
	
	# Section title
	var section_title = Label.new()
	section_title.text = "Top Destinations (by weekly demand)"
	section_title.add_theme_font_size_override("font_size", 14)
	section_title.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	destinations_vbox.add_child(section_title)
	
	# Create rows for each destination
	for dest in destinations:
		var row = _create_destination_row(dest)
		destinations_vbox.add_child(row)


func _calculate_top_destinations() -> Array:
	"""Calculate top destinations passengers from source airport want to reach"""
	var destinations: Array = []
	
	# Get all airports
	var all_airports = GameData.airports
	
	if all_airports.is_empty():
		push_error("[PassengerFlow] No airports loaded")
		return destinations
	
	# Get player's routes from their hub
	var hub_destinations: Array[Airport] = []
	for route in GameData.player_airline.routes:
		if route.from_airport == connecting_hub:
			hub_destinations.append(route.to_airport)
		elif route.to_airport == connecting_hub:
			hub_destinations.append(route.from_airport)
	
	# For each potential destination, calculate demand
	for airport in all_airports:
		# Skip self and the connecting hub
		if airport == source_airport or airport == connecting_hub:
			continue
		
		# Calculate demand from source to this destination
		var distance = MarketAnalysis.calculate_great_circle_distance(source_airport, airport)
		var demand = MarketAnalysis.calculate_potential_demand(source_airport, airport, distance)
		
		# Skip low-demand destinations
		if demand < MIN_DEMAND_THRESHOLD:
			continue
		
		# Check if this destination is reachable via hub connection
		var has_hub_connection = airport in hub_destinations
		
		# Check for direct route from source
		var has_direct = _has_direct_route(source_airport, airport)
		
		# Calculate connecting passenger potential if hub connection exists
		var connecting_pax: float = 0.0
		var connection_quality: float = 0.0
		
		if has_hub_connection:
			# Source → Hub → Destination connection exists
			var connection = _build_connection_info(source_airport, connecting_hub, airport)
			connection_quality = connection.connection_quality
			
			# Calculate connecting passengers
			var direct_demand = demand if has_direct else 0.0
			connecting_pax = MarketAnalysis.calculate_connecting_passenger_demand(
				source_airport, airport, connection, direct_demand
			)
		
		destinations.append({
			"airport": airport,
			"demand": demand,
			"distance": distance,
			"has_hub_connection": has_hub_connection,
			"has_direct": has_direct,
			"connecting_pax": connecting_pax,
			"connection_quality": connection_quality
		})
	
	# Sort by demand (highest first)
	destinations.sort_custom(func(a, b): return a.demand > b.demand)
	
	# Limit to max
	return destinations.slice(0, MAX_DESTINATIONS)


func _build_connection_info(origin: Airport, hub: Airport, destination: Airport) -> Dictionary:
	"""Build connection info dictionary for calculating connecting passengers"""
	var leg1_distance = MarketAnalysis.calculate_great_circle_distance(origin, hub)
	var leg2_distance = MarketAnalysis.calculate_great_circle_distance(hub, destination)
	var direct_distance = MarketAnalysis.calculate_great_circle_distance(origin, destination)
	var total_distance = leg1_distance + leg2_distance
	
	# Calculate connection quality
	var connection_quality = MarketAnalysis.calculate_connection_quality_from_distances(
		leg1_distance, leg2_distance, direct_distance
	)
	
	return {
		"hub": hub,
		"total_distance": total_distance,
		"connection_quality": connection_quality,
		"layover_time": 1.5  # Assume average 1.5 hour layover
	}


func _has_direct_route(from: Airport, to: Airport) -> bool:
	"""Check if any airline has a direct route between airports"""
	# Check all AI airlines
	for airline in GameData.airlines:
		for route in airline.routes:
			if (route.from_airport == from and route.to_airport == to) or \
			   (route.from_airport == to and route.to_airport == from):
				return true
	# Also check player airline
	if GameData.player_airline:
		for route in GameData.player_airline.routes:
			if (route.from_airport == from and route.to_airport == to) or \
			   (route.from_airport == to and route.to_airport == from):
				return true
	return false


func _create_destination_row(dest: Dictionary) -> Control:
	"""Create a row for a destination"""
	var airport: Airport = dest.airport
	var row = PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 65)
	
	# Row style
	var row_style = StyleBoxFlat.new()
	row_style.bg_color = UITheme.get_card_bg()
	row_style.set_corner_radius_all(8)
	row_style.set_content_margin_all(12)
	
	# Color-coded left border based on connection status
	if dest.has_hub_connection:
		row_style.border_color = UITheme.PROFIT_COLOR  # Green - connected
		row_style.border_width_left = 4
	elif not dest.has_direct:
		row_style.border_color = UITheme.PRIMARY_BLUE  # Blue - opportunity
		row_style.border_width_left = 4
	else:
		row_style.border_color = UITheme.get_panel_border()
		row_style.set_border_width_all(1)
	
	row.add_theme_stylebox_override("panel", row_style)
	
	# Hover style for clickable rows (only if we can create a route)
	var can_create_route = not dest.has_hub_connection and not _player_has_route_to(airport)
	
	if can_create_route or dest.has_hub_connection:
		var hover_style = row_style.duplicate()
		hover_style.bg_color = UITheme.get_card_bg().lightened(0.05)
		hover_style.border_color = UITheme.PRIMARY_BLUE
		hover_style.set_border_width_all(2)
		if dest.has_hub_connection:
			hover_style.border_width_left = 4
		
		row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if can_create_route:
			row.tooltip_text = "Click to create route: %s → %s" % [connecting_hub.iata_code, airport.iata_code]
		else:
			row.tooltip_text = "Hub connection active: %s → %s → %s" % [
				source_airport.iata_code, connecting_hub.iata_code, airport.iata_code
			]
		
		row.mouse_entered.connect(func():
			row.add_theme_stylebox_override("panel", hover_style)
		)
		row.mouse_exited.connect(func():
			row.add_theme_stylebox_override("panel", row_style)
		)
		
		if can_create_route:
			row.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					connection_route_requested.emit(connecting_hub, airport)
					hide()
			)
	
	# Content
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)
	
	# Left: Destination info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)
	
	# Destination name
	var name_hbox = HBoxContainer.new()
	name_hbox.add_theme_constant_override("separation", 8)
	info_vbox.add_child(name_hbox)
	
	var name_label = Label.new()
	name_label.text = "%s (%s)" % [airport.city, airport.iata_code]
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	name_hbox.add_child(name_label)
	
	# Connection status badge
	if dest.has_hub_connection:
		var badge = Label.new()
		badge.text = "✓ Connected"
		badge.add_theme_font_size_override("font_size", 11)
		badge.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		name_hbox.add_child(badge)
	elif dest.has_direct:
		var badge = Label.new()
		badge.text = "Direct exists"
		badge.add_theme_font_size_override("font_size", 11)
		badge.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
		name_hbox.add_child(badge)
	else:
		var badge = Label.new()
		badge.text = "✦ Opportunity"
		badge.add_theme_font_size_override("font_size", 11)
		badge.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
		name_hbox.add_child(badge)
	
	# Stats row
	var stats_label = Label.new()
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	
	var stats_text = "%.0f km" % dest.distance
	if dest.has_hub_connection and dest.connecting_pax > 0:
		# Show connection path: SOURCE → HUB → DESTINATION
		stats_text += " • via %s → ~%.0f pax" % [connecting_hub.iata_code, dest.connecting_pax]
		if dest.connection_quality >= 70:
			stats_text += " ★"  # Good connection quality
	elif not dest.has_hub_connection and not dest.has_direct:
		# Opportunity - show potential connection revenue
		stats_text += " • Create %s→%s route" % [connecting_hub.iata_code, airport.iata_code]
	
	stats_label.text = stats_text
	info_vbox.add_child(stats_label)
	
	# Add connection path label for connected destinations
	if dest.has_hub_connection:
		var path_label = Label.new()
		path_label.text = "🔗 %s → %s → %s" % [source_airport.iata_code, connecting_hub.iata_code, airport.iata_code]
		path_label.add_theme_font_size_override("font_size", 11)
		path_label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
		info_vbox.add_child(path_label)
	
	# Right: Demand indicator
	var demand_vbox = VBoxContainer.new()
	demand_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(demand_vbox)
	
	var demand_label = Label.new()
	demand_label.text = "~%.0f" % dest.demand
	demand_label.add_theme_font_size_override("font_size", 16)
	demand_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	demand_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	demand_vbox.add_child(demand_label)
	
	var pax_label = Label.new()
	pax_label.text = "pax/week"
	pax_label.add_theme_font_size_override("font_size", 10)
	pax_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	pax_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	demand_vbox.add_child(pax_label)
	
	return row


func _player_has_route_to(airport: Airport) -> bool:
	"""Check if player already has a route to this airport from their hub"""
	if not GameData.player_airline:
		return false
	
	for route in GameData.player_airline.routes:
		if (route.from_airport == connecting_hub and route.to_airport == airport) or \
		   (route.from_airport == airport and route.to_airport == connecting_hub):
			return true
	return false


func _show_empty_message(text: String) -> void:
	"""Show an empty state message"""
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	destinations_vbox.add_child(label)
