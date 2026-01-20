extends Window
class_name RouteOpportunityDialog

## Dialog for exploring route opportunities from a hub

signal route_selected(from_airport: Airport, to_airport: Airport)

# UI Elements
var distance_filter_short: Button
var distance_filter_medium: Button
var distance_filter_long: Button
var distance_filter_all: Button
var destination_list: ItemList
var destination_details_label: RichTextLabel
var create_route_button: Button

# Data
var hub_airport: Airport = null
var opportunities: Array[Dictionary] = []
var filtered_opportunities: Array[Dictionary] = []
var selected_opportunity: Dictionary = {}
var current_filter: String = "all"  # all, short, medium, long
var is_filter_collapsed: bool = false  # Track filter section collapse state

# Distance thresholds (based on Airline Club)
const SHORT_HAUL_MAX: float = 2000.0
const MEDIUM_HAUL_MAX: float = 5000.0
# Anything above is long haul

func _init() -> void:
	title = "Route Planning"
	size = Vector2i(900, 700)
	unresizable = false

func _ready() -> void:
	build_ui()
	hide()  # Start hidden, only show when hub is selected

	# Allow ESC key and close button to close dialog
	close_requested.connect(hide)

func _input(event: InputEvent) -> void:
	"""Handle ESC key to close dialog"""
	if not visible:
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide()
		get_viewport().set_input_as_handled()

func build_ui() -> void:
	"""Build the dialog UI programmatically"""
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)

	# === Header Section ===
	var header_label = Label.new()
	header_label.add_theme_font_size_override("font_size", 18)
	header_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	vbox.add_child(header_label)

	# === Distance Filter Buttons ===
	var filter_panel = create_section_panel("Filter by Distance")
	vbox.add_child(filter_panel)

	var filter_hbox = HBoxContainer.new()
	filter_hbox.add_theme_constant_override("separation", 10)
	filter_panel.add_child(filter_hbox)

	# Collapse button for filter section
	var collapse_button = Button.new()
	collapse_button.text = "▼"
	collapse_button.custom_minimum_size = Vector2(30, 40)
	collapse_button.tooltip_text = "Collapse/Expand Filter"
	collapse_button.pressed.connect(func():
		is_filter_collapsed = not is_filter_collapsed
		distance_filter_all.visible = not is_filter_collapsed
		distance_filter_short.visible = not is_filter_collapsed
		distance_filter_medium.visible = not is_filter_collapsed
		distance_filter_long.visible = not is_filter_collapsed
		collapse_button.text = "▶" if is_filter_collapsed else "▼"
	)
	filter_hbox.add_child(collapse_button)

	distance_filter_all = create_filter_button("All Routes", "all")
	filter_hbox.add_child(distance_filter_all)

	distance_filter_short = create_filter_button("Short Haul (<2000km)", "short")
	filter_hbox.add_child(distance_filter_short)

	distance_filter_medium = create_filter_button("Medium Haul (2000-5000km)", "medium")
	filter_hbox.add_child(distance_filter_medium)

	distance_filter_long = create_filter_button("Long Haul (>5000km)", "long")
	filter_hbox.add_child(distance_filter_long)

	# === Destination List Section ===
	var destinations_panel = create_section_panel("Destination Opportunities (sorted by profitability)")
	vbox.add_child(destinations_panel)

	destination_list = ItemList.new()
	destination_list.custom_minimum_size = Vector2(0, 300)
	destination_list.item_selected.connect(_on_destination_selected)
	destination_list.item_activated.connect(_on_destination_activated)
	destinations_panel.add_child(destination_list)

	# === Details Section ===
	var details_panel = create_section_panel("Route Details")
	vbox.add_child(details_panel)

	destination_details_label = RichTextLabel.new()
	destination_details_label.bbcode_enabled = true
	destination_details_label.fit_content = true
	destination_details_label.custom_minimum_size = Vector2(0, 150)
	destination_details_label.add_theme_font_size_override("normal_font_size", 14)
	destination_details_label.text = "[i]Select a destination to view details[/i]"
	details_panel.add_child(destination_details_label)

	# === Action Buttons ===
	var button_hbox = HBoxContainer.new()
	button_hbox.add_theme_constant_override("separation", 10)
	button_hbox.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(button_hbox)

	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.custom_minimum_size = Vector2(100, 40)
	cancel_button.pressed.connect(hide)
	button_hbox.add_child(cancel_button)

	create_route_button = Button.new()
	create_route_button.text = "Create Route"
	create_route_button.custom_minimum_size = Vector2(150, 40)
	create_route_button.disabled = true
	create_route_button.pressed.connect(_on_create_route_pressed)
	button_hbox.add_child(create_route_button)

func create_section_panel(title: String) -> VBoxContainer:
	"""Create a styled section with title"""
	var section_vbox = VBoxContainer.new()
	section_vbox.add_theme_constant_override("separation", 8)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	section_vbox.add_child(title_label)

	var separator = HSeparator.new()
	section_vbox.add_child(separator)

	return section_vbox

func create_filter_button(text: String, filter_type: String) -> Button:
	"""Create a distance filter button"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(180, 40)
	button.toggle_mode = true
	button.button_pressed = (filter_type == "all")
	button.pressed.connect(_on_filter_pressed.bind(filter_type))
	return button

func show_for_hub(airport: Airport) -> void:
	"""Show the dialog for a specific hub"""
	hub_airport = airport
	title = "Route Planning: %s (%s)" % [airport.iata_code, airport.city]

	# Analyze all route opportunities from this hub
	analyze_opportunities()

	# Apply default filter
	apply_filter("all")

	# Show dialog
	popup_centered()

func analyze_opportunities() -> void:
	"""Analyze all possible routes from the hub"""
	opportunities.clear()

	if not hub_airport or not GameData.player_airline:
		return

	# Get all airports except the hub itself
	for airport in GameData.airports:
		if airport == hub_airport:
			continue  # Skip self

		# Calculate distance
		var distance: float = MarketAnalysis.calculate_great_circle_distance(hub_airport, airport)

		# Get market analysis
		var analysis: Dictionary = GameData.analyze_route(hub_airport, airport)

		# Get bidirectional demand breakdown
		var bidirectional: Dictionary = MarketAnalysis.calculate_bidirectional_demand(hub_airport, airport, distance)

		# Check if any owned aircraft can fly this distance
		var can_fly: bool = false
		var compatible_aircraft: Array[String] = []

		for aircraft in GameData.player_airline.aircraft:
			if aircraft.model.can_fly_distance(distance):
				can_fly = true
				if aircraft.model.get_display_name() not in compatible_aircraft:
					compatible_aircraft.append(aircraft.model.get_display_name())

		# Determine flight type
		var flight_type: String = get_flight_type(distance, hub_airport, airport)

		# Create opportunity record
		var opportunity: Dictionary = {
			"airport": airport,
			"distance": distance,
			"flight_type": flight_type,
			"analysis": analysis,
			"bidirectional": bidirectional,  # NEW: Bidirectional demand data
			"can_fly": can_fly,
			"compatible_aircraft": compatible_aircraft,
			"profitability_score": analysis.get("profitability_score", 0)
		}

		opportunities.append(opportunity)

	# Sort by profitability score (highest first)
	opportunities.sort_custom(func(a, b): return a.profitability_score > b.profitability_score)

func get_flight_type(distance: float, from: Airport, to: Airport) -> String:
	"""Classify flight type based on distance"""
	# Simplified version - you can expand this with domestic/international logic
	if distance <= SHORT_HAUL_MAX:
		return "Short Haul"
	elif distance <= MEDIUM_HAUL_MAX:
		return "Medium Haul"
	elif distance <= 12000:
		return "Long Haul"
	else:
		return "Ultra Long Haul"

func apply_filter(filter_type: String) -> void:
	"""Apply distance filter to opportunities"""
	current_filter = filter_type

	# Update button states
	distance_filter_all.button_pressed = (filter_type == "all")
	distance_filter_short.button_pressed = (filter_type == "short")
	distance_filter_medium.button_pressed = (filter_type == "medium")
	distance_filter_long.button_pressed = (filter_type == "long")

	# Filter opportunities
	filtered_opportunities.clear()

	for opp in opportunities:
		var distance: float = opp.distance

		match filter_type:
			"all":
				filtered_opportunities.append(opp)
			"short":
				if distance <= SHORT_HAUL_MAX:
					filtered_opportunities.append(opp)
			"medium":
				if distance > SHORT_HAUL_MAX and distance <= MEDIUM_HAUL_MAX:
					filtered_opportunities.append(opp)
			"long":
				if distance > MEDIUM_HAUL_MAX:
					filtered_opportunities.append(opp)

	# Update list display
	update_destination_list()

func update_destination_list() -> void:
	"""Update the destination list display"""
	if not destination_list:
		return

	destination_list.clear()

	for opp in filtered_opportunities:
		var airport: Airport = opp.airport
		var distance: float = opp.distance
		var flight_type: String = opp.flight_type
		var score: float = opp.profitability_score
		var can_fly: bool = opp.can_fly
		var demand: float = opp.analysis.get("demand", 0)
		var competition: int = opp.analysis.get("competition", 0)

		# Icon based on aircraft availability
		var icon: String = "✓" if can_fly else "✗"

		# Score indicator (stars/symbols instead of colors since ItemList doesn't support BBCode)
		var score_indicator: String = "★★★" if score >= 70 else ("★★" if score >= 50 else "★")

		# Build display text (ItemList doesn't support BBCode, keep it simple)
		var text: String = "%s %s - %s | Score: %.0f %s\n" % [
			icon,
			airport.iata_code,
			airport.city,
			score,
			score_indicator
		]
		text += "    %.0f km (%s) | Demand: %.0f/wk | Competition: %d" % [
			distance,
			flight_type,
			demand,
			competition
		]

		destination_list.add_item(text)

	if filtered_opportunities.is_empty():
		destination_list.add_item("No routes match this filter")

func _on_filter_pressed(filter_type: String) -> void:
	"""Handle filter button press"""
	apply_filter(filter_type)

func _on_destination_selected(index: int) -> void:
	"""Destination selected from list"""
	if index >= 0 and index < filtered_opportunities.size():
		selected_opportunity = filtered_opportunities[index]
		update_destination_details()
		create_route_button.disabled = not selected_opportunity.can_fly

func _on_destination_activated(index: int) -> void:
	"""Destination double-clicked - create route immediately"""
	if index >= 0 and index < filtered_opportunities.size():
		selected_opportunity = filtered_opportunities[index]
		if selected_opportunity.can_fly:
			_on_create_route_pressed()

func update_destination_details() -> void:
	"""Update detailed information for selected destination"""
	if not destination_details_label or selected_opportunity.is_empty():
		return

	var airport: Airport = selected_opportunity.airport
	var distance: float = selected_opportunity.distance
	var flight_type: String = selected_opportunity.flight_type
	var analysis: Dictionary = selected_opportunity.analysis
	var bidirectional: Dictionary = selected_opportunity.get("bidirectional", {})
	var can_fly: bool = selected_opportunity.can_fly
	var compatible: Array[String] = selected_opportunity.compatible_aircraft

	var demand: float = analysis.get("demand", 0)
	var supply: float = analysis.get("supply", 0)
	var gap: float = analysis.get("gap", 0)
	var competition: int = analysis.get("competition", 0)
	var score: float = analysis.get("profitability_score", 0)

	var score_color: String = "#66FF66" if score >= 70 else ("#FFAA00" if score >= 50 else "#FF6666")

	var text: String = "[b]%s → %s[/b]\n" % [hub_airport.iata_code, airport.iata_code]
	text += "[i]%s, %s[/i]\n\n" % [airport.city, airport.country]

	text += "• Distance: [b]%.0f km[/b] (%s)\n" % [distance, flight_type]
	text += "• Flight Time: [b]%.1f hours[/b]\n\n" % (distance / 800.0)

	# NEW: Bidirectional Demand Breakdown
	if not bidirectional.is_empty():
		text += "[b]Demand Analysis (Bidirectional):[/b]\n"

		var outbound_business: float = bidirectional.get("outbound_business", 0)
		var outbound_tourist: float = bidirectional.get("outbound_tourist", 0)
		var outbound_total: float = bidirectional.get("outbound_total", 0)
		var inbound_business: float = bidirectional.get("inbound_business", 0)
		var inbound_tourist: float = bidirectional.get("inbound_tourist", 0)
		var inbound_total: float = bidirectional.get("inbound_total", 0)

		# Outbound direction
		text += "• [b]Outbound[/b] (%s → %s): [color=#88DDFF]%.0f pax/week[/color]\n" % [hub_airport.iata_code, airport.iata_code, outbound_total]
		text += "    Business: %.0f | Tourist: %.0f\n" % [outbound_business, outbound_tourist]

		# Inbound direction
		text += "• [b]Inbound[/b] (%s → %s): [color=#FFAA88]%.0f pax/week[/color]\n" % [airport.iata_code, hub_airport.iata_code, inbound_total]
		text += "    Business: %.0f | Tourist: %.0f\n" % [inbound_business, inbound_tourist]

		# Show asymmetry indicator
		var stronger_direction: String = ""
		var asymmetry_ratio: float = 0.0
		if outbound_total > inbound_total * 1.2:
			asymmetry_ratio = outbound_total / inbound_total if inbound_total > 0 else 0.0
			stronger_direction = "[color=#88DDFF]▲ Outbound stronger (%.1fx)[/color]" % asymmetry_ratio
		elif inbound_total > outbound_total * 1.2:
			asymmetry_ratio = inbound_total / outbound_total if outbound_total > 0 else 0.0
			stronger_direction = "[color=#FFAA88]▼ Inbound stronger (%.1fx)[/color]" % asymmetry_ratio
		else:
			stronger_direction = "[color=#AAAAAA]≈ Balanced demand[/color]"

		text += "• [b]Direction:[/b] %s\n\n" % stronger_direction

	# === HUB NETWORK EFFECTS ===
	var connection_analysis: Dictionary = analyze_connection_potential(airport)
	if connection_analysis.total_connections > 0:
		text += "[b]Hub Network Effects:[/b]\n"
		text += "• Potential Connections: [b]%d routes[/b]\n" % connection_analysis.total_connections
		text += "• Estimated Connecting Pax: [color=#88FF88][b]+%.0f/week[/b][/color]\n" % connection_analysis.estimated_pax

		if connection_analysis.top_connections.size() > 0:
			text += "• [i]Top Connections:[/i]\n"
			for conn in connection_analysis.top_connections.slice(0, 3):  # Show top 3
				text += "    %s via %s (%.0f pax/wk)\n" % [conn.route, hub_airport.iata_code, conn.pax]

		text += "\n"

	text += "[b]Market Summary:[/b]\n"
	text += "• Profitability Score: [color=%s][b]%.0f/100[/b][/color]\n" % [score_color, score]
	text += "• Total Weekly Demand: [b]%.0f[/b] passengers\n" % demand
	text += "• Current Supply: [b]%.0f[/b] seats (%d airlines)\n" % [supply, competition]
	text += "• Unmet Demand: [b]%.0f[/b] passengers\n\n" % max(0, gap)

	if can_fly:
		text += "[b][color=#66FF66]✓ Compatible Aircraft:[/color][/b]\n"
		for aircraft_name in compatible:
			text += "  • %s\n" % aircraft_name
	else:
		text += "[b][color=#FF6666]✗ No aircraft with sufficient range![/color][/b]\n"
		text += "This route requires %.0f km range.\n" % distance

	if score >= 70:
		text += "\n[color=#66FF66]★ Excellent opportunity![/color]"
	elif score >= 50:
		text += "\n[color=#FFAA00]⚠ Moderate opportunity[/color]"
	else:
		text += "\n[color=#FF6666]⚠ Low profitability expected[/color]"

	destination_details_label.text = text

func analyze_connection_potential(destination: Airport) -> Dictionary:
	"""
	Analyze the potential connecting passengers if a new route hub→destination is created
	Returns: {
		total_connections: int,  # Number of connecting route pairs
		estimated_pax: float,  # Total connecting passengers per week
		top_connections: Array[Dictionary]  # Top connections by passenger count
	}
	"""
	var result: Dictionary = {
		"total_connections": 0,
		"estimated_pax": 0.0,
		"top_connections": []
	}

	if not GameData.player_airline or not hub_airport:
		return result

	# This new route would be: hub → destination
	# Check for two types of connections:

	# 1. Routes ENDING at hub (origin→hub) that could connect to new route (hub→destination)
	#    Creates: origin→hub→destination
	for existing_route in GameData.player_airline.routes:
		if existing_route.to_airport == hub_airport:
			var origin: Airport = existing_route.from_airport

			# Skip if origin = destination (pointless connection)
			if origin == destination:
				continue

			# Build hypothetical connection
			var connection: Dictionary = {
				"first_leg": existing_route,
				"hub": hub_airport,
				"total_distance": existing_route.distance_km + MarketAnalysis.calculate_great_circle_distance(hub_airport, destination),
				"connection_quality": 50.0  # Estimated quality (we don't have second leg yet)
			}

			# Estimate connection quality based on existing route frequency
			# Assume new route would have frequency 1-7
			var estimated_frequency: int = 3  # Assume 3x per week for new route
			var quality: float = 50.0

			# Frequency bonus
			var min_freq: int = min(existing_route.frequency, estimated_frequency)
			if min_freq >= 7:
				quality += 20.0
			elif min_freq >= 3:
				quality += 10.0

			# Hub tier adjustment
			match hub_airport.hub_tier:
				1: quality -= 15.0
				2: quality -= 5.0
				3: quality += 5.0
				4: quality += 10.0

			connection.connection_quality = clamp(quality, 0.0, 100.0)

			# Calculate connecting passengers
			var connecting_pax: float = MarketAnalysis.calculate_connecting_passenger_demand(
				origin,
				destination,
				connection,
				0.0  # Assume no direct competition
			)

			if connecting_pax > 5.0:  # Only count meaningful connections
				result.total_connections += 1
				result.estimated_pax += connecting_pax
				result.top_connections.append({
					"route": "%s→%s" % [origin.iata_code, destination.iata_code],
					"pax": connecting_pax
				})

	# 2. Routes STARTING from hub (hub→other) that could receive connections from new route
	#    Creates: destination→hub→other
	for existing_route in GameData.player_airline.routes:
		if existing_route.from_airport == hub_airport:
			var other_destination: Airport = existing_route.to_airport

			# Skip if same as destination (pointless connection)
			if other_destination == destination:
				continue

			# Build hypothetical connection
			var connection: Dictionary = {
				"second_leg": existing_route,
				"hub": hub_airport,
				"total_distance": MarketAnalysis.calculate_great_circle_distance(destination, hub_airport) + existing_route.distance_km,
				"connection_quality": 50.0  # Estimated quality
			}

			# Estimate connection quality
			var estimated_frequency: int = 3
			var quality: float = 50.0

			var min_freq: int = min(existing_route.frequency, estimated_frequency)
			if min_freq >= 7:
				quality += 20.0
			elif min_freq >= 3:
				quality += 10.0

			match hub_airport.hub_tier:
				1: quality -= 15.0
				2: quality -= 5.0
				3: quality += 5.0
				4: quality += 10.0

			connection.connection_quality = clamp(quality, 0.0, 100.0)

			# Calculate connecting passengers
			var connecting_pax: float = MarketAnalysis.calculate_connecting_passenger_demand(
				destination,
				other_destination,
				connection,
				0.0  # Assume no direct competition
			)

			if connecting_pax > 5.0:
				result.total_connections += 1
				result.estimated_pax += connecting_pax
				result.top_connections.append({
					"route": "%s→%s" % [destination.iata_code, other_destination.iata_code],
					"pax": connecting_pax
				})

	# Sort connections by passenger count
	result.top_connections.sort_custom(func(a, b): return a.pax > b.pax)

	return result

func _on_create_route_pressed() -> void:
	"""Create route button pressed"""
	if selected_opportunity.is_empty() or not selected_opportunity.can_fly:
		return

	var to_airport: Airport = selected_opportunity.airport
	route_selected.emit(hub_airport, to_airport)
	hide()
