extends ConfirmationDialog
class_name RouteConfigDialog

## Dialog for configuring routes (create new or edit existing)

signal route_configured(config: Dictionary)

# UI Elements (to be created programmatically or in scene)
var from_airport_label: Label
var to_airport_label: Label
var distance_label: Label
var market_analysis_label: RichTextLabel

# Aircraft selection
var aircraft_list: ItemList
var aircraft_details_label: Label

# Route settings
var frequency_slider: HSlider
var frequency_label: Label

# Pricing
var economy_price_input: SpinBox
var business_price_input: SpinBox
var first_price_input: SpinBox
var use_recommended_button: Button
var recommended_label: Label

# Data
var from_airport: Airport = null
var to_airport: Airport = null
var selected_aircraft: AircraftInstance = null
var route_distance: float = 0.0
var market_analysis: Dictionary = {}
var available_aircraft: Array[AircraftInstance] = []
var editing_route: Route = null  # If set, we're editing an existing route

func _init() -> void:
	title = "Configure Route"
	size = Vector2i(800, 700)
	ok_button_text = "Create Route"
	cancel_button_text = "Cancel"

func _ready() -> void:
	build_ui()
	confirmed.connect(_on_confirmed)

func build_ui() -> void:
	"""Build the dialog UI programmatically"""
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(780, 600)
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 15)
	scroll.add_child(vbox)

	# === Route Info Section ===
	var route_info_panel = create_section_panel("Route Information")
	vbox.add_child(route_info_panel)

	var route_info_vbox = VBoxContainer.new()
	route_info_vbox.add_theme_constant_override("separation", 5)
	route_info_panel.add_child(route_info_vbox)

	from_airport_label = Label.new()
	from_airport_label.add_theme_font_size_override("font_size", 16)
	route_info_vbox.add_child(from_airport_label)

	to_airport_label = Label.new()
	to_airport_label.add_theme_font_size_override("font_size", 16)
	route_info_vbox.add_child(to_airport_label)

	distance_label = Label.new()
	distance_label.add_theme_font_size_override("font_size", 14)
	distance_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	route_info_vbox.add_child(distance_label)

	# === Market Analysis Section ===
	var market_panel = create_section_panel("Market Analysis")
	vbox.add_child(market_panel)

	market_analysis_label = RichTextLabel.new()
	market_analysis_label.bbcode_enabled = true
	market_analysis_label.fit_content = true
	market_analysis_label.custom_minimum_size = Vector2(0, 120)
	market_analysis_label.add_theme_font_size_override("normal_font_size", 14)
	market_panel.add_child(market_analysis_label)

	# === Aircraft Selection Section ===
	var aircraft_panel = create_section_panel("Select Aircraft")
	vbox.add_child(aircraft_panel)

	var aircraft_vbox = VBoxContainer.new()
	aircraft_vbox.add_theme_constant_override("separation", 10)
	aircraft_panel.add_child(aircraft_vbox)

	var aircraft_label = Label.new()
	aircraft_label.text = "Available Aircraft:"
	aircraft_label.add_theme_font_size_override("font_size", 14)
	aircraft_vbox.add_child(aircraft_label)

	aircraft_list = ItemList.new()
	aircraft_list.custom_minimum_size = Vector2(0, 100)
	aircraft_list.item_selected.connect(_on_aircraft_selected)
	aircraft_vbox.add_child(aircraft_list)

	aircraft_details_label = Label.new()
	aircraft_details_label.add_theme_font_size_override("font_size", 12)
	aircraft_details_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	aircraft_vbox.add_child(aircraft_details_label)

	# === Frequency Section ===
	var frequency_panel = create_section_panel("Flight Frequency")
	vbox.add_child(frequency_panel)

	var freq_vbox = VBoxContainer.new()
	freq_vbox.add_theme_constant_override("separation", 10)
	frequency_panel.add_child(freq_vbox)

	frequency_label = Label.new()
	frequency_label.add_theme_font_size_override("font_size", 14)
	freq_vbox.add_child(frequency_label)

	frequency_slider = HSlider.new()
	frequency_slider.min_value = 1
	frequency_slider.max_value = 14
	frequency_slider.step = 1
	frequency_slider.value = 7
	frequency_slider.custom_minimum_size = Vector2(400, 30)
	frequency_slider.value_changed.connect(_on_frequency_changed)
	freq_vbox.add_child(frequency_slider)

	var freq_hint = Label.new()
	freq_hint.text = "Flights per week (1-14). More flights = more revenue but higher costs."
	freq_hint.add_theme_font_size_override("font_size", 12)
	freq_hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	freq_vbox.add_child(freq_hint)

	# === Pricing Section ===
	var pricing_panel = create_section_panel("Ticket Pricing")
	vbox.add_child(pricing_panel)

	var pricing_vbox = VBoxContainer.new()
	pricing_vbox.add_theme_constant_override("separation", 10)
	pricing_panel.add_child(pricing_vbox)

	# Recommended pricing button and label
	var rec_hbox = HBoxContainer.new()
	rec_hbox.add_theme_constant_override("separation", 10)
	pricing_vbox.add_child(rec_hbox)

	use_recommended_button = Button.new()
	use_recommended_button.text = "Use AI Recommended Pricing"
	use_recommended_button.custom_minimum_size = Vector2(250, 35)
	use_recommended_button.pressed.connect(_on_use_recommended_pressed)
	rec_hbox.add_child(use_recommended_button)

	recommended_label = Label.new()
	recommended_label.add_theme_font_size_override("font_size", 12)
	rec_hbox.add_child(recommended_label)

	# Economy price
	var eco_hbox = create_price_input_row("Economy Class:", "economy")
	pricing_vbox.add_child(eco_hbox)
	economy_price_input = eco_hbox.get_node("SpinBox")

	# Business price
	var bus_hbox = create_price_input_row("Business Class:", "business")
	pricing_vbox.add_child(bus_hbox)
	business_price_input = bus_hbox.get_node("SpinBox")

	# First price
	var first_hbox = create_price_input_row("First Class:", "first")
	pricing_vbox.add_child(first_hbox)
	first_price_input = first_hbox.get_node("SpinBox")

func create_section_panel(title: String) -> PanelContainer:
	"""Create a styled panel for a section"""
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	vbox.add_child(title_label)

	var separator = HSeparator.new()
	vbox.add_child(separator)

	return panel

func create_price_input_row(label_text: String, class_type: String) -> HBoxContainer:
	"""Create a price input row"""
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(150, 0)
	label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(label)

	var spinbox = SpinBox.new()
	spinbox.name = "SpinBox"
	spinbox.min_value = 10
	spinbox.max_value = 10000
	spinbox.step = 10
	spinbox.custom_minimum_size = Vector2(150, 35)
	hbox.add_child(spinbox)

	var dollar_label = Label.new()
	dollar_label.text = "per passenger"
	dollar_label.add_theme_font_size_override("font_size", 12)
	dollar_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hbox.add_child(dollar_label)

	return hbox

func setup_route(p_from: Airport, p_to: Airport) -> void:
	"""Initialize dialog with route information"""
	editing_route = null  # Clear edit mode
	ok_button_text = "Create Route"

	from_airport = p_from
	to_airport = p_to

	# Calculate distance
	route_distance = MarketAnalysis.calculate_great_circle_distance(from_airport, to_airport)

	# Get market analysis
	market_analysis = GameData.analyze_route(from_airport, to_airport)

	# Get available aircraft
	available_aircraft.clear()
	if GameData.player_airline:
		for aircraft in GameData.player_airline.aircraft:
			if not aircraft.is_assigned:
				available_aircraft.append(aircraft)

	# Update UI
	update_route_info()
	update_market_analysis()
	update_aircraft_list()
	update_frequency_label()
	update_recommended_pricing()

func setup_edit_route(route: Route) -> void:
	"""Initialize dialog for editing an existing route"""
	editing_route = route
	ok_button_text = "Save Changes"

	from_airport = route.from_airport
	to_airport = route.to_airport

	# Calculate distance
	route_distance = MarketAnalysis.calculate_great_circle_distance(from_airport, to_airport)

	# Get market analysis
	market_analysis = GameData.analyze_route(from_airport, to_airport)

	# For editing, we keep the currently assigned aircraft but also show available ones
	available_aircraft.clear()
	if GameData.player_airline:
		# Add currently assigned aircraft first
		for aircraft in route.assigned_aircraft:
			available_aircraft.append(aircraft)
		# Add other unassigned aircraft
		for aircraft in GameData.player_airline.aircraft:
			if not aircraft.is_assigned and aircraft not in available_aircraft:
				available_aircraft.append(aircraft)

	# Set the first assigned aircraft as selected (or first available)
	if not route.assigned_aircraft.is_empty():
		selected_aircraft = route.assigned_aircraft[0]
	elif not available_aircraft.is_empty():
		selected_aircraft = available_aircraft[0]

	# Update UI
	update_route_info()
	update_market_analysis()
	update_aircraft_list()

	# Set current route values
	if frequency_slider:
		frequency_slider.value = route.frequency
	if economy_price_input:
		economy_price_input.value = route.price_economy
	if business_price_input:
		business_price_input.value = route.price_business
	if first_price_input:
		first_price_input.value = route.price_first

	update_frequency_label()
	update_aircraft_details()

func update_route_info() -> void:
	"""Update route information display"""
	if from_airport_label:
		from_airport_label.text = "From: %s (%s) - %s, %s" % [
			from_airport.name,
			from_airport.iata_code,
			from_airport.city,
			from_airport.country
		]

	if to_airport_label:
		to_airport_label.text = "To: %s (%s) - %s, %s" % [
			to_airport.name,
			to_airport.iata_code,
			to_airport.city,
			to_airport.country
		]

	if distance_label:
		var duration: float = route_distance / 800.0  # Assuming 800 km/h
		distance_label.text = "Distance: %.0f km | Flight Time: %.1f hours" % [route_distance, duration]

func update_market_analysis() -> void:
	"""Update market analysis display"""
	if not market_analysis_label:
		return

	var demand: float = market_analysis.get("demand", 0)
	var supply: float = market_analysis.get("supply", 0)
	var gap: float = market_analysis.get("gap", 0)
	var competition: int = market_analysis.get("competition", 0)
	var saturation: float = market_analysis.get("market_saturation", 0)
	var score: float = market_analysis.get("profitability_score", 0)

	var color: String = "#66FF66" if score >= 70 else ("#FFAA00" if score >= 50 else "#FF6666")

	var text: String = "[b]Market Conditions:[/b]\n"
	text += "• Weekly Demand: [b]%.0f[/b] passengers\n" % demand
	text += "• Current Supply: [b]%.0f[/b] seats/week (%d airlines)\n" % [supply, competition]
	text += "• Unmet Demand: [b]%.0f[/b] passengers\n" % max(0, gap)
	text += "• Market Saturation: [b]%.0f%%[/b]\n" % (saturation * 100)
	text += "• [color=%s]Profitability Score: [b]%.0f/100[/b][/color]" % [color, score]

	if score >= 70:
		text += "\n\n[color=#66FF66]★ Excellent opportunity![/color]"
	elif score >= 50:
		text += "\n\n[color=#FFAA00]⚠ Moderate opportunity[/color]"
	else:
		text += "\n\n[color=#FF6666]⚠ Low profitability - high competition or low demand[/color]"

	market_analysis_label.text = text

func update_aircraft_list() -> void:
	"""Update available aircraft list"""
	if not aircraft_list:
		return

	aircraft_list.clear()

	if available_aircraft.is_empty():
		aircraft_list.add_item("No available aircraft - purchase one first!")
		get_ok_button().disabled = true
		return

	get_ok_button().disabled = false

	for aircraft in available_aircraft:
		var can_fly: bool = aircraft.model.can_fly_distance(route_distance)
		var icon: String = "✓" if can_fly else "✗"
		var text: String = "%s %s | Range: %d km | Cap: %d" % [
			icon,
			aircraft.model.get_display_name(),
			aircraft.model.range_km,
			aircraft.get_total_capacity()
		]

		aircraft_list.add_item(text)

		# Disable if can't fly distance
		if not can_fly:
			aircraft_list.set_item_disabled(aircraft_list.item_count - 1, true)
			aircraft_list.set_item_tooltip(aircraft_list.item_count - 1, "Range too short for this route")

	# Auto-select first suitable aircraft
	for i in range(available_aircraft.size()):
		if available_aircraft[i].model.can_fly_distance(route_distance):
			aircraft_list.select(i)
			selected_aircraft = available_aircraft[i]
			update_aircraft_details()
			break

func update_aircraft_details() -> void:
	"""Update selected aircraft details"""
	if not aircraft_details_label or not selected_aircraft:
		return

	var config: AircraftConfiguration = selected_aircraft.configuration
	aircraft_details_label.text = "Configuration: Y:%d J:%d F:%d | Condition: %.0f%%" % [
		config.economy_seats,
		config.business_seats,
		config.first_seats,
		selected_aircraft.condition
	]

func update_frequency_label() -> void:
	"""Update frequency label"""
	if frequency_label and frequency_slider:
		var freq: int = int(frequency_slider.value)
		var weekly_capacity: int = 0
		if selected_aircraft:
			weekly_capacity = selected_aircraft.get_total_capacity() * freq

		frequency_label.text = "Flights per week: %d | Weekly Capacity: %d passengers" % [freq, weekly_capacity]

func update_recommended_pricing() -> void:
	"""Update recommended pricing display and set default prices"""
	var pricing: Dictionary = GameData.get_recommended_pricing_for_route(from_airport, to_airport)

	if recommended_label:
		recommended_label.text = "AI Recommends: Y:$%.0f J:$%.0f F:$%.0f" % [
			pricing.economy,
			pricing.business,
			pricing.first
		]

	# Set initial prices to recommended
	if economy_price_input:
		economy_price_input.value = pricing.economy
	if business_price_input:
		business_price_input.value = pricing.business
	if first_price_input:
		first_price_input.value = pricing.first

func _on_aircraft_selected(index: int) -> void:
	"""Aircraft selected from list"""
	if index >= 0 and index < available_aircraft.size():
		selected_aircraft = available_aircraft[index]
		update_aircraft_details()
		update_frequency_label()

func _on_frequency_changed(value: float) -> void:
	"""Frequency slider changed"""
	update_frequency_label()

func _on_use_recommended_pressed() -> void:
	"""Apply recommended pricing"""
	update_recommended_pricing()

func _on_confirmed() -> void:
	"""Dialog confirmed - emit configuration"""
	if not selected_aircraft:
		return

	var config: Dictionary = {
		"from_airport": from_airport,
		"to_airport": to_airport,
		"aircraft": selected_aircraft,
		"frequency": int(frequency_slider.value),
		"price_economy": economy_price_input.value,
		"price_business": business_price_input.value,
		"price_first": first_price_input.value,
		"editing_route": editing_route  # null if creating new, Route if editing
	}

	route_configured.emit(config)
