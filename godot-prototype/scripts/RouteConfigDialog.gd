extends ConfirmationDialog
class_name RouteConfigDialog

## Dialog for configuring routes (create new or edit existing)
## P.1: Enhanced with expanded route opportunity details

signal route_configured(config: Dictionary)
signal buy_aircraft_requested()  # Emitted when user wants to buy aircraft from this dialog

# P.1: Route analysis constants
const SHORT_HAUL_THRESHOLD := 1500.0  # km - short-haul threshold
const LONG_HAUL_THRESHOLD := 4000.0   # km - long-haul threshold
const BUSINESS_RATIO_SHORT := 0.30    # 30% business on short-haul
const BUSINESS_RATIO_MEDIUM := 0.40   # 40% business on medium-haul
const BUSINESS_RATIO_LONG := 0.50     # 50% business on long-haul

# UI Elements (to be created programmatically or in scene)
var from_airport_label: Label
var to_airport_label: Label
var distance_label: Label
var market_analysis_label: RichTextLabel

# P.1: Expanded analysis UI elements
var demand_breakdown_label: RichTextLabel
var competitor_pricing_label: RichTextLabel
var price_range_label: RichTextLabel
var breakeven_label: RichTextLabel

# P.2: Competitor pricing intelligence (for existing routes)
var competitor_intel_panel: PanelContainer
var competitor_intel_label: RichTextLabel

# Q.1: Market Research button
var buy_research_button: Button

# Aircraft selection
var aircraft_list: ItemList
var aircraft_details_label: Label
var no_aircraft_container: VBoxContainer  # Container shown when no aircraft available
var buy_aircraft_button: Button

# Route settings
var frequency_slider: HSlider
var frequency_label: Label

# Pricing
var economy_price_input: SpinBox
var business_price_input: SpinBox
var first_price_input: SpinBox
var use_recommended_button: Button
var recommended_label: Label
var pending_price_label: Label  # G.6: Shows pending price status

# E.4: Demand impact preview
var demand_preview_label: RichTextLabel

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
	# Larger dialog size to reduce scrolling - ~85% of typical screen height
	size = Vector2i(850, 900)
	min_size = Vector2i(700, 600)  # Minimum size for smaller screens
	ok_button_text = "Create Route"
	# Note: cancel button text set in _ready() via get_cancel_button().text

func _ready() -> void:
	get_cancel_button().text = "Cancel"
	build_ui()
	confirmed.connect(_on_confirmed)

func build_ui() -> void:
	"""Build the dialog UI programmatically"""
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(820, 800)  # Increased to match larger dialog
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 15)
	scroll.add_child(vbox)

	# === Route Info Section ===
	var route_info_panel = create_section_panel("Route Information")
	vbox.add_child(route_info_panel)
	var route_info_content: VBoxContainer = route_info_panel.get_meta("content_container")

	from_airport_label = Label.new()
	from_airport_label.add_theme_font_size_override("font_size", 16)
	route_info_content.add_child(from_airport_label)

	to_airport_label = Label.new()
	to_airport_label.add_theme_font_size_override("font_size", 16)
	route_info_content.add_child(to_airport_label)

	distance_label = Label.new()
	distance_label.add_theme_font_size_override("font_size", 14)
	distance_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	route_info_content.add_child(distance_label)
	
	# === P.2: Competitor Pricing Intelligence (for existing routes) ===
	competitor_intel_panel = PanelContainer.new()
	competitor_intel_panel.name = "CompetitorIntelPanel"
	competitor_intel_panel.visible = false  # Hidden by default, shown when editing
	var intel_style = StyleBoxFlat.new()
	intel_style.bg_color = Color(0.15, 0.12, 0.18)
	intel_style.set_corner_radius_all(8)
	intel_style.set_content_margin_all(12)
	intel_style.border_color = Color(0.4, 0.3, 0.5)
	intel_style.set_border_width_all(1)
	competitor_intel_panel.add_theme_stylebox_override("panel", intel_style)
	vbox.add_child(competitor_intel_panel)
	
	var intel_vbox = VBoxContainer.new()
	intel_vbox.add_theme_constant_override("separation", 8)
	competitor_intel_panel.add_child(intel_vbox)
	
	var intel_header = Label.new()
	intel_header.text = "🏢 Competitor Pricing Intelligence"
	intel_header.add_theme_font_size_override("font_size", 16)
	intel_header.add_theme_color_override("font_color", Color(0.7, 0.5, 0.9))
	intel_vbox.add_child(intel_header)
	
	competitor_intel_label = RichTextLabel.new()
	competitor_intel_label.bbcode_enabled = true
	competitor_intel_label.fit_content = true
	competitor_intel_label.custom_minimum_size = Vector2(0, 100)
	competitor_intel_label.add_theme_font_size_override("normal_font_size", 13)
	intel_vbox.add_child(competitor_intel_label)

	# === Market Analysis Section ===
	var market_panel = create_section_panel("Market Analysis")
	vbox.add_child(market_panel)
	var market_content: VBoxContainer = market_panel.get_meta("content_container")

	market_analysis_label = RichTextLabel.new()
	market_analysis_label.bbcode_enabled = true
	market_analysis_label.fit_content = true
	market_analysis_label.custom_minimum_size = Vector2(0, 100)
	market_analysis_label.add_theme_font_size_override("normal_font_size", 14)
	market_content.add_child(market_analysis_label)
	
	# Q.1: Buy Research button (shown when demand is uncertain)
	buy_research_button = Button.new()
	buy_research_button.text = "🔍 Buy Market Research (€50K)"
	buy_research_button.custom_minimum_size = Vector2(220, 35)
	buy_research_button.add_theme_font_size_override("font_size", 12)
	buy_research_button.pressed.connect(_on_buy_research_pressed)
	buy_research_button.visible = false  # Hidden by default
	
	var research_btn_style = StyleBoxFlat.new()
	research_btn_style.bg_color = Color(0.3, 0.25, 0.5)
	research_btn_style.set_corner_radius_all(6)
	research_btn_style.set_content_margin_all(8)
	buy_research_button.add_theme_stylebox_override("normal", research_btn_style)
	
	var research_btn_hover = research_btn_style.duplicate()
	research_btn_hover.bg_color = Color(0.4, 0.35, 0.6)
	buy_research_button.add_theme_stylebox_override("hover", research_btn_hover)
	
	buy_research_button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	market_content.add_child(buy_research_button)
	
	# P.1: Expanded Route Opportunity Details
	var details_panel = create_section_panel("Route Opportunity Details")
	vbox.add_child(details_panel)
	var details_content: VBoxContainer = details_panel.get_meta("content_container")
	
	# P.1: Demand breakdown (business vs leisure)
	var demand_header = Label.new()
	demand_header.text = "📊 Demand Breakdown"
	demand_header.add_theme_font_size_override("font_size", 14)
	demand_header.add_theme_color_override("font_color", UITheme.get_text_primary())
	details_content.add_child(demand_header)
	
	demand_breakdown_label = RichTextLabel.new()
	demand_breakdown_label.bbcode_enabled = true
	demand_breakdown_label.fit_content = true
	demand_breakdown_label.custom_minimum_size = Vector2(0, 60)
	demand_breakdown_label.add_theme_font_size_override("normal_font_size", 13)
	details_content.add_child(demand_breakdown_label)
	
	# P.1: Competitor pricing
	var competitor_header = Label.new()
	competitor_header.text = "🏢 Competitor Analysis"
	competitor_header.add_theme_font_size_override("font_size", 14)
	competitor_header.add_theme_color_override("font_color", UITheme.get_text_primary())
	details_content.add_child(competitor_header)
	
	competitor_pricing_label = RichTextLabel.new()
	competitor_pricing_label.bbcode_enabled = true
	competitor_pricing_label.fit_content = true
	competitor_pricing_label.custom_minimum_size = Vector2(0, 50)
	competitor_pricing_label.add_theme_font_size_override("normal_font_size", 13)
	details_content.add_child(competitor_pricing_label)
	
	# P.1: Recommended price range
	var price_range_header = Label.new()
	price_range_header.text = "💰 Recommended Price Range"
	price_range_header.add_theme_font_size_override("font_size", 14)
	price_range_header.add_theme_color_override("font_color", UITheme.get_text_primary())
	details_content.add_child(price_range_header)
	
	price_range_label = RichTextLabel.new()
	price_range_label.bbcode_enabled = true
	price_range_label.fit_content = true
	price_range_label.custom_minimum_size = Vector2(0, 40)
	price_range_label.add_theme_font_size_override("normal_font_size", 13)
	details_content.add_child(price_range_label)
	
	# P.1: Break-even analysis
	var breakeven_header = Label.new()
	breakeven_header.text = "📈 Break-Even Analysis"
	breakeven_header.add_theme_font_size_override("font_size", 14)
	breakeven_header.add_theme_color_override("font_color", UITheme.get_text_primary())
	details_content.add_child(breakeven_header)
	
	breakeven_label = RichTextLabel.new()
	breakeven_label.bbcode_enabled = true
	breakeven_label.fit_content = true
	breakeven_label.custom_minimum_size = Vector2(0, 50)
	breakeven_label.add_theme_font_size_override("normal_font_size", 13)
	details_content.add_child(breakeven_label)

	# === Aircraft Selection Section ===
	var aircraft_panel = create_section_panel("Select Aircraft")
	vbox.add_child(aircraft_panel)
	var aircraft_content: VBoxContainer = aircraft_panel.get_meta("content_container")
	aircraft_content.add_theme_constant_override("separation", 10)

	var aircraft_label = Label.new()
	aircraft_label.text = "Available Aircraft:"
	aircraft_label.add_theme_font_size_override("font_size", 14)
	aircraft_content.add_child(aircraft_label)

	# No aircraft available container (shown when fleet has no unassigned aircraft)
	no_aircraft_container = VBoxContainer.new()
	no_aircraft_container.add_theme_constant_override("separation", 12)
	no_aircraft_container.visible = false
	aircraft_content.add_child(no_aircraft_container)
	
	var no_aircraft_message = Label.new()
	no_aircraft_message.name = "NoAircraftMessage"
	no_aircraft_message.text = "⚠ No aircraft available for this route.\n\nAll your aircraft are currently assigned to other routes, or you don't have any aircraft yet."
	no_aircraft_message.add_theme_font_size_override("font_size", 13)
	no_aircraft_message.add_theme_color_override("font_color", UITheme.WARNING_COLOR)
	no_aircraft_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	no_aircraft_container.add_child(no_aircraft_message)
	
	buy_aircraft_button = Button.new()
	buy_aircraft_button.text = "✈ Buy Aircraft"
	buy_aircraft_button.custom_minimum_size = Vector2(180, 40)
	buy_aircraft_button.add_theme_font_size_override("font_size", 14)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = UITheme.PRIMARY_BLUE
	btn_style.set_corner_radius_all(8)
	btn_style.set_content_margin_all(10)
	buy_aircraft_button.add_theme_stylebox_override("normal", btn_style)
	
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = UITheme.PRIMARY_BLUE.lightened(0.1)
	buy_aircraft_button.add_theme_stylebox_override("hover", btn_hover)
	
	buy_aircraft_button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	buy_aircraft_button.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
	buy_aircraft_button.pressed.connect(_on_buy_aircraft_pressed)
	no_aircraft_container.add_child(buy_aircraft_button)

	aircraft_list = ItemList.new()
	aircraft_list.custom_minimum_size = Vector2(0, 120)  # Slightly larger for better visibility
	aircraft_list.item_selected.connect(_on_aircraft_selected)
	aircraft_content.add_child(aircraft_list)

	aircraft_details_label = Label.new()
	aircraft_details_label.add_theme_font_size_override("font_size", 12)
	aircraft_details_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	aircraft_content.add_child(aircraft_details_label)

	# === Frequency Section ===
	var frequency_panel = create_section_panel("Flight Frequency")
	vbox.add_child(frequency_panel)
	var freq_content: VBoxContainer = frequency_panel.get_meta("content_container")
	freq_content.add_theme_constant_override("separation", 10)

	frequency_label = Label.new()
	frequency_label.add_theme_font_size_override("font_size", 14)
	freq_content.add_child(frequency_label)

	frequency_slider = HSlider.new()
	frequency_slider.min_value = 1
	frequency_slider.max_value = 14
	frequency_slider.step = 1
	frequency_slider.value = 7
	frequency_slider.custom_minimum_size = Vector2(400, 30)
	frequency_slider.value_changed.connect(_on_frequency_changed)
	freq_content.add_child(frequency_slider)

	var freq_hint = Label.new()
	freq_hint.text = "Flights per week (1-14). More flights = more revenue but higher costs."
	freq_hint.add_theme_font_size_override("font_size", 12)
	freq_hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	freq_content.add_child(freq_hint)

	# === Pricing Section ===
	var pricing_panel = create_section_panel("Ticket Pricing")
	vbox.add_child(pricing_panel)
	var pricing_content: VBoxContainer = pricing_panel.get_meta("content_container")
	pricing_content.add_theme_constant_override("separation", 10)

	# Recommended pricing button and label
	var rec_hbox = HBoxContainer.new()
	rec_hbox.add_theme_constant_override("separation", 10)
	pricing_content.add_child(rec_hbox)

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
	pricing_content.add_child(eco_hbox)
	economy_price_input = eco_hbox.get_node("SpinBox")

	# Business price
	var bus_hbox = create_price_input_row("Business Class:", "business")
	pricing_content.add_child(bus_hbox)
	business_price_input = bus_hbox.get_node("SpinBox")

	# First price
	var first_hbox = create_price_input_row("First Class:", "first")
	pricing_content.add_child(first_hbox)
	first_price_input = first_hbox.get_node("SpinBox")
	
	# G.6: Pending price indicator
	pending_price_label = Label.new()
	pending_price_label.name = "PendingPriceLabel"
	pending_price_label.add_theme_font_size_override("font_size", 12)
	pending_price_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))  # Yellow/orange
	pending_price_label.visible = false  # Hidden by default
	pricing_content.add_child(pending_price_label)
	
	# E.4 + P.1: "What-If" Pricing Preview Panel
	var whatif_header = Label.new()
	whatif_header.text = "🔮 What-If Pricing Preview"
	whatif_header.add_theme_font_size_override("font_size", 14)
	whatif_header.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	pricing_content.add_child(whatif_header)
	
	var whatif_hint = Label.new()
	whatif_hint.text = "Adjust prices above to see projected demand and revenue"
	whatif_hint.add_theme_font_size_override("font_size", 11)
	whatif_hint.add_theme_color_override("font_color", UITheme.get_text_muted())
	pricing_content.add_child(whatif_hint)
	
	var preview_panel = PanelContainer.new()
	preview_panel.name = "DemandPreviewPanel"
	var preview_style = StyleBoxFlat.new()
	preview_style.bg_color = Color(0.12, 0.18, 0.22, 0.95)
	preview_style.set_corner_radius_all(8)
	preview_style.set_content_margin_all(12)
	preview_style.border_color = UITheme.PRIMARY_BLUE.darkened(0.3)
	preview_style.set_border_width_all(1)
	preview_panel.add_theme_stylebox_override("panel", preview_style)
	pricing_content.add_child(preview_panel)
	
	demand_preview_label = RichTextLabel.new()
	demand_preview_label.name = "DemandPreviewLabel"
	demand_preview_label.bbcode_enabled = true
	demand_preview_label.fit_content = true
	demand_preview_label.custom_minimum_size = Vector2(0, 100)
	demand_preview_label.add_theme_font_size_override("normal_font_size", 13)
	preview_panel.add_child(demand_preview_label)
	
	# Connect price inputs to update preview (E.4)
	economy_price_input.value_changed.connect(_on_price_changed)
	business_price_input.value_changed.connect(_on_price_changed)
	first_price_input.value_changed.connect(_on_price_changed)

func create_section_panel(title: String) -> PanelContainer:
	"""Create a styled panel for a section with proper spacing.
	Returns the content container where child elements should be added."""
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Add panel styling
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.13, 0.16)
	panel_style.set_corner_radius_all(8)
	panel_style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", panel_style)

	var outer_vbox = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 12)
	panel.add_child(outer_vbox)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	outer_vbox.add_child(title_label)

	var separator = HSeparator.new()
	separator.add_theme_constant_override("separation", 4)
	outer_vbox.add_child(separator)
	
	# Content container - this is where section content should go
	var content_container = VBoxContainer.new()
	content_container.name = "ContentContainer"
	content_container.add_theme_constant_override("separation", 8)
	outer_vbox.add_child(content_container)

	# Store reference for retrieval
	panel.set_meta("content_container", content_container)

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
	update_route_opportunity_details()  # P.1: Expanded details
	_hide_competitor_intel()  # P.2: Hide for new routes
	update_aircraft_list()
	update_frequency_label()
	update_recommended_pricing()
	update_demand_preview()  # E.4: Show initial demand forecast

func setup_edit_route(route: Route) -> void:
	"""Initialize dialog for editing an existing route
	G.6: Price changes take effect next day for cause-effect visibility
	"""
	editing_route = route
	ok_button_text = "Save (prices effective tomorrow)"

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
	update_route_opportunity_details()  # P.1: Expanded details
	_update_competitor_intel()  # P.2: Show competitor pricing intelligence
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

	# G.6: Show pending price info if applicable
	update_pending_price_display()

	update_frequency_label()
	update_aircraft_details()
	update_demand_preview()  # E.4: Show initial demand forecast

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

	# Q.2: Show demand with uncertainty
	var demand_text: String
	var confidence_text: String = ""
	var show_research_button: bool = false
	if from_airport and to_airport:
		var demand_info = GameData.get_demand_display(from_airport, to_airport, demand)
		demand_text = "[color=%s][b]%s[/b][/color]" % [demand_info.confidence_color, demand_info.display_text]
		if not demand_info.is_exact:
			confidence_text = " [i](%s confidence)[/i]" % demand_info.confidence
			show_research_button = true
	else:
		demand_text = "[b]%.0f[/b] passengers" % demand
	
	# Q.1: Show/hide research button
	if buy_research_button:
		buy_research_button.visible = show_research_button
		if show_research_button:
			# Update button state based on affordability
			if GameData.player_airline and GameData.player_airline.balance >= GameData.MARKET_RESEARCH_COST:
				buy_research_button.disabled = false
				buy_research_button.text = "🔍 Buy Market Research (€50K)"
			else:
				buy_research_button.disabled = true
				buy_research_button.text = "🔍 Can't Afford Research (€50K)"

	var text: String = "[b]Market Conditions:[/b]\n"
	text += "• Weekly Demand: %s%s\n" % [demand_text, confidence_text]
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


func update_route_opportunity_details() -> void:
	"""P.1: Update expanded route opportunity details"""
	_update_demand_breakdown()
	_update_competitor_pricing()
	_update_price_range()
	_update_breakeven_analysis()


func _update_demand_breakdown() -> void:
	"""P.1: Calculate and display business vs leisure demand breakdown"""
	if not demand_breakdown_label:
		return
	
	var total_demand: float = market_analysis.get("demand", 500)
	
	# Calculate business/leisure split based on distance
	var business_ratio: float
	var route_type: String
	
	if route_distance < SHORT_HAUL_THRESHOLD:
		business_ratio = BUSINESS_RATIO_SHORT
		route_type = "Short-haul"
	elif route_distance < LONG_HAUL_THRESHOLD:
		business_ratio = BUSINESS_RATIO_MEDIUM
		route_type = "Medium-haul"
	else:
		business_ratio = BUSINESS_RATIO_LONG
		route_type = "Long-haul"
	
	var business_demand: int = int(total_demand * business_ratio)
	var leisure_demand: int = int(total_demand * (1.0 - business_ratio))
	
	# Adjust based on airport characteristics
	var business_bonus: float = 0.0
	if from_airport and to_airport:
		# Higher GDP airports have more business travelers
		var avg_gdp = (from_airport.gdp_per_capita + to_airport.gdp_per_capita) / 2.0
		if avg_gdp > 40000:
			business_bonus = 0.10  # 10% more business travelers
		elif avg_gdp < 20000:
			business_bonus = -0.10  # 10% fewer business travelers
	
	var adjusted_business_ratio = clamp(business_ratio + business_bonus, 0.15, 0.70)
	business_demand = int(total_demand * adjusted_business_ratio)
	leisure_demand = int(total_demand * (1.0 - adjusted_business_ratio))
	
	var text: String = ""
	text += "[b]%s[/b] route (%.0f km)\n" % [route_type, route_distance]
	text += "• Business travelers: [color=#66AAFF][b]~%d pax/week[/b][/color] (%.0f%%)\n" % [
		business_demand, adjusted_business_ratio * 100
	]
	text += "• Leisure travelers: [color=#66FF66][b]~%d pax/week[/b][/color] (%.0f%%)" % [
		leisure_demand, (1.0 - adjusted_business_ratio) * 100
	]
	
	# Add insight
	if adjusted_business_ratio >= 0.45:
		text += "\n[i][color=#AAAAAA]💼 High business demand - premium pricing viable[/color][/i]"
	elif adjusted_business_ratio <= 0.25:
		text += "\n[i][color=#AAAAAA]🏖 Leisure-dominated - focus on competitive economy pricing[/color][/i]"
	
	demand_breakdown_label.text = text


func _update_competitor_pricing() -> void:
	"""P.1: Display competitor presence and their pricing"""
	if not competitor_pricing_label:
		return
	
	var competitors: Array = _get_competitor_routes()
	
	if competitors.is_empty():
		competitor_pricing_label.text = "[color=#66FF66]✓ No direct competitors on this route![/color]\nYou'll have pricing power - consider premium positioning."
		return
	
	var text: String = ""
	for comp in competitors:
		var airline_name: String = comp.airline_name
		var price_eco: float = comp.price_economy
		var price_bus: float = comp.price_business
		var frequency: int = comp.frequency
		
		text += "• [b]%s[/b]: €%.0f / €%.0f (Y/J) | %d flights/wk\n" % [
			airline_name, price_eco, price_bus, frequency
		]
	
	# Calculate average competitor price
	var avg_price: float = 0.0
	for comp in competitors:
		avg_price += comp.price_economy
	avg_price /= competitors.size()
	
	text += "\n[i]Avg competitor economy price: [b]€%.0f[/b][/i]" % avg_price
	
	competitor_pricing_label.text = text


func _get_competitor_routes() -> Array:
	"""P.1: Get competitor routes between from and to airports"""
	var competitors: Array = []
	
	if not from_airport or not to_airport:
		return competitors
	
	for airline in GameData.airlines:
		if airline == GameData.player_airline:
			continue
		
		for route in airline.routes:
			if (route.from_airport == from_airport and route.to_airport == to_airport) or \
			   (route.from_airport == to_airport and route.to_airport == from_airport):
				competitors.append({
					"airline_name": airline.name,
					"price_economy": route.price_economy,
					"price_business": route.price_business,
					"price_first": route.price_first,
					"frequency": route.frequency,
					"load_factor": _estimate_competitor_load_factor(route)
				})
	
	return competitors


func _estimate_competitor_load_factor(route: Route) -> float:
	"""Estimate competitor's load factor (rough approximation)"""
	if route.get_total_capacity() <= 0:
		return 0.0
	var capacity = route.get_total_capacity() * route.frequency
	if capacity <= 0:
		return 0.0
	return clamp(float(route.passengers_transported) / capacity * 100.0, 0.0, 100.0)


func _update_price_range() -> void:
	"""P.1: Display recommended min/max price range"""
	if not price_range_label:
		return
	
	# Get baseline price (cost-based floor)
	var baseline_price: float = max(50.0, route_distance * 0.15)
	
	# Get competitor pricing (if any)
	var competitors: Array = _get_competitor_routes()
	var competitor_avg: float = 0.0
	var has_competition: bool = not competitors.is_empty()
	
	if has_competition:
		for comp in competitors:
			competitor_avg += comp.price_economy
		competitor_avg /= competitors.size()
	
	# Calculate recommended range
	var min_price: float
	var max_price: float
	var sweet_spot: float
	
	if has_competition:
		# Competitive market - price around competitors
		min_price = competitor_avg * 0.85  # Can undercut by 15%
		max_price = competitor_avg * 1.15  # Can premium by 15%
		sweet_spot = competitor_avg * 0.95  # Slight undercut is usually optimal
	else:
		# Monopoly - more pricing freedom
		min_price = baseline_price * 1.0   # At least cover costs
		max_price = baseline_price * 2.5   # Can charge premium
		sweet_spot = baseline_price * 1.5  # Moderate premium
	
	# Ensure minimum is sensible
	min_price = max(min_price, baseline_price * 0.9)
	
	var text: String = ""
	text += "Economy: [b]€%.0f - €%.0f[/b]\n" % [min_price, max_price]
	text += "Sweet spot: [color=#66FF66][b]€%.0f[/b][/color]" % sweet_spot
	
	if not has_competition:
		text += " [i](monopoly pricing)[/i]"
	
	price_range_label.text = text


func _update_breakeven_analysis() -> void:
	"""P.1: Calculate and display break-even load factor"""
	if not breakeven_label:
		return
	
	# Get current/default prices
	var price_economy: float = economy_price_input.value if economy_price_input else 150.0
	var price_business: float = business_price_input.value if business_price_input else 300.0
	var frequency: int = int(frequency_slider.value) if frequency_slider else 7
	
	# Estimate costs per flight
	var fuel_cost_per_km: float = 3.5  # € per km (rough estimate for narrowbody)
	var crew_cost_per_flight: float = 1500.0
	var airport_fees_per_flight: float = 800.0
	var maintenance_per_flight: float = 500.0
	
	var cost_per_flight: float = (route_distance * fuel_cost_per_km) + crew_cost_per_flight + airport_fees_per_flight + maintenance_per_flight
	var weekly_fixed_costs: float = cost_per_flight * frequency
	
	# Calculate capacity (use selected aircraft or estimate)
	var capacity_per_flight: int = 150  # Default estimate
	if selected_aircraft:
		capacity_per_flight = selected_aircraft.get_total_capacity()
	
	var weekly_capacity: int = capacity_per_flight * frequency
	
	# Calculate weighted average ticket price
	var avg_ticket_price: float = price_economy * 0.80 + price_business * 0.15 + (price_business * 1.5) * 0.05
	
	# Calculate break-even passengers
	var breakeven_passengers: int = ceili(weekly_fixed_costs / avg_ticket_price)
	var breakeven_load_factor: float = float(breakeven_passengers) / float(weekly_capacity) * 100.0 if weekly_capacity > 0 else 100.0
	
	# Safety margin (profitable threshold)
	var profitable_load_factor: float = breakeven_load_factor * 1.2  # 20% margin over breakeven
	
	var text: String = ""
	text += "Est. weekly costs: [b]%s[/b]\n" % UITheme.format_money(weekly_fixed_costs)
	text += "Break-even: [b]%d pax[/b] " % breakeven_passengers
	
	# Color code based on how achievable the breakeven is
	var breakeven_color: String
	if breakeven_load_factor <= 50:
		breakeven_color = "#66FF66"  # Easy to achieve
	elif breakeven_load_factor <= 70:
		breakeven_color = "#4ECDC4"  # Light cyan - Moderate
	elif breakeven_load_factor <= 85:
		breakeven_color = "#FFAA00"  # Challenging
	else:
		breakeven_color = "#FF6666"  # Very difficult
	
	text += "[color=%s]([b]%.0f%% load factor[/b])[/color]\n" % [breakeven_color, breakeven_load_factor]
	text += "Profitable target: [color=#66FF66][b]≥%.0f%% load[/b][/color]" % profitable_load_factor
	
	breakeven_label.text = text


## ============================================================================
## P.2: COMPETITOR PRICING INTELLIGENCE
## Shows detailed competitor analysis for existing routes
## ============================================================================

func _hide_competitor_intel() -> void:
	"""P.2: Hide competitor intel panel (for new routes)"""
	if competitor_intel_panel:
		competitor_intel_panel.visible = false


func _update_competitor_intel() -> void:
	"""P.2: Update and show competitor pricing intelligence for existing routes"""
	if not competitor_intel_panel or not competitor_intel_label:
		return
	
	if not editing_route or not GameData.player_airline:
		competitor_intel_panel.visible = false
		return
	
	# Get competitor intelligence
	var intel: Dictionary = MarketAnalysis.get_competitor_pricing_intelligence(editing_route, GameData.player_airline)
	
	# Build display text
	var text: String = ""
	
	if not intel.has_competitors:
		text += "[color=#66FF66][b]✓ No competitors on this route![/b][/color]\n\n"
		text += "You control pricing. Consider:\n"
		text += "• Premium pricing if demand is strong\n"
		text += "• Moderate pricing to discourage new entrants"
		competitor_intel_panel.visible = true
		competitor_intel_label.text = text
		return
	
	# Price comparison header
	text += "[b]Price Comparison[/b]\n"
	text += "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
	text += "[b]You:[/b] €%.0f (economy)\n" % intel.player_price
	text += "[b]Competitors:[/b] €%.0f avg (€%.0f - €%.0f)\n\n" % [
		intel.avg_competitor_price, intel.min_competitor_price, intel.max_competitor_price
	]
	
	# Market positioning with icon and color
	var pos_color: String
	var pos_icon: String
	match intel.positioning:
		"premium":
			pos_color = "#66AAFF"
			pos_icon = "▲"
		"discount":
			pos_color = "#66FF66"
			pos_icon = "▼"
		_:
			pos_color = "#4ECDC4"  # Light cyan - matched
			pos_icon = "●"
	
	text += "[b]Market Position:[/b] [color=%s]%s %s[/color]\n" % [
		pos_color, pos_icon, intel.positioning.capitalize()
	]
	
	# Price difference
	if intel.price_difference_pct > 0:
		text += "[color=#FF6B6B]+%.1f%% above competitors[/color]\n\n" % intel.price_difference_pct  # Soft red
	elif intel.price_difference_pct < 0:
		text += "[color=#66FF66]%.1f%% below competitors[/color]\n\n" % intel.price_difference_pct
	else:
		text += "[color=#4ECDC4]Matched with competitors[/color]\n\n"  # Light cyan
	
	# Competitor details
	text += "[b]Competitors on Route:[/b]\n"
	for comp in intel.competitors:
		text += "• %s: €%.0f / €%.0f (Y/J), %dx/wk\n" % [
			comp.airline_name, comp.price_economy, comp.price_business, comp.frequency
		]
	
	text += "\n"
	
	# Strategic recommendation
	var rec_color: String
	match intel.recommendation_type:
		"undercut":
			rec_color = "#FF6B6B"  # Soft red - action needed
		"differentiate":
			rec_color = "#4ECDC4"  # Light cyan - consider options
		_:
			rec_color = "#66FF66"  # Green - maintain
	
	text += "[b]💡 Recommendation:[/b]\n"
	text += "[color=%s]%s[/color]" % [rec_color, intel.recommendation]
	
	competitor_intel_panel.visible = true
	competitor_intel_label.text = text


func update_pending_price_display() -> void:
	"""G.6: Update pending price indicator for existing routes"""
	if not pending_price_label:
		return
	
	# Only show for existing routes being edited
	if not editing_route:
		pending_price_label.visible = false
		return
	
	if editing_route.has_pending_price_changes():
		pending_price_label.visible = true
		pending_price_label.text = "⏳ " + editing_route.get_price_change_summary()
	else:
		pending_price_label.visible = false


func update_aircraft_list() -> void:
	"""Update available aircraft list"""
	if not aircraft_list:
		return

	aircraft_list.clear()

	if available_aircraft.is_empty():
		# Show the no aircraft container with buy button
		if no_aircraft_container:
			no_aircraft_container.visible = true
		aircraft_list.visible = false
		aircraft_details_label.visible = false
		get_ok_button().disabled = true
		return
	
	# Hide the no aircraft container, show the list
	if no_aircraft_container:
		no_aircraft_container.visible = false
	aircraft_list.visible = true
	aircraft_details_label.visible = true
	get_ok_button().disabled = false

	for aircraft in available_aircraft:
		var can_fly: bool = aircraft.model.can_fly_distance(route_distance)
		var range_status: String
		if can_fly:
			var margin: int = int(aircraft.model.range_km - route_distance)
			range_status = "✓ Range: %d km (+%d km margin)" % [aircraft.model.range_km, margin]
		else:
			var shortfall: int = int(route_distance - aircraft.model.range_km)
			range_status = "✗ Range: %d km (-%d km short)" % [aircraft.model.range_km, shortfall]
		
		var text: String = "%s | %s | Cap: %d" % [
			aircraft.model.get_display_name(),
			range_status,
			aircraft.get_total_capacity()
		]

		aircraft_list.add_item(text)

		# Disable if can't fly distance
		if not can_fly:
			aircraft_list.set_item_disabled(aircraft_list.item_count - 1, true)
			aircraft_list.set_item_tooltip(aircraft_list.item_count - 1, 
				"Range too short! Aircraft range: %d km, Route distance: %d km" % [
					aircraft.model.range_km, int(route_distance)
				])

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
		_update_breakeven_analysis()  # P.1: Update breakeven when aircraft changes
		update_demand_preview()  # E.4: Update preview when aircraft changes

func _on_frequency_changed(value: float) -> void:
	"""Frequency slider changed"""
	update_frequency_label()
	_update_breakeven_analysis()  # P.1: Update breakeven when frequency changes
	update_demand_preview()  # E.4: Update preview when frequency changes


func _on_price_changed(_value: float) -> void:
	"""E.4: Price input changed - update demand preview"""
	_update_breakeven_analysis()  # P.1: Update breakeven when prices change
	update_demand_preview()


func update_demand_preview() -> void:
	"""E.4: Calculate and display demand impact preview based on current price settings.
	Uses the same elasticity formula as SimulationEngine (G.2) for consistency.
	"""
	if not demand_preview_label:
		return
	
	if not from_airport or not to_airport or not selected_aircraft:
		demand_preview_label.text = "[i]Select an aircraft to see demand forecast[/i]"
		return
	
	# Get current settings from UI
	var price_economy: float = economy_price_input.value if economy_price_input else 100.0
	var frequency: int = int(frequency_slider.value) if frequency_slider else 7
	
	# Calculate baseline price (same formula as SimulationEngine)
	var baseline_price: float = max(50.0, route_distance * 0.15)
	
	# Calculate elasticity multiplier (same formula as SimulationEngine G.2)
	var elasticity_factor: float = 1.2  # Default leisure market elasticity
	if route_distance < 800:
		elasticity_factor = 1.4  # Short routes more price-sensitive
	elif route_distance > 3000:
		elasticity_factor = 1.0  # Long routes less sensitive (business)
	
	var price_ratio: float = baseline_price / price_economy if price_economy > 0 else 1.0
	var elasticity_multiplier: float = pow(price_ratio, elasticity_factor)
	elasticity_multiplier = clamp(elasticity_multiplier, 0.3, 2.0)
	
	# Get base market demand
	var base_demand: float = market_analysis.get("demand", 500)
	
	# Calculate market share (simplified - assume we capture portion based on competition)
	var competition: int = market_analysis.get("competition", 0)
	var market_share: float = 1.0 / (1 + competition * 0.5)  # Rough approximation
	
	# Calculate adjusted demand with elasticity
	var route_demand: float = base_demand * market_share * elasticity_multiplier
	
	# Calculate weekly capacity
	var weekly_capacity: int = selected_aircraft.get_total_capacity() * frequency
	
	# Calculate load factor (capped at 100%)
	var projected_passengers: int = mini(int(route_demand), weekly_capacity)
	var load_factor: float = float(projected_passengers) / float(weekly_capacity) * 100.0 if weekly_capacity > 0 else 0.0
	
	# Calculate estimated revenue
	var estimated_revenue: float = projected_passengers * price_economy
	
	# Determine price status
	var price_status: String
	var price_color: String
	var price_deviation: float = ((price_economy - baseline_price) / baseline_price) * 100.0
	
	if abs(price_deviation) < 5:
		price_status = "competitive"
		price_color = "#66FF66"
	elif price_deviation > 0:
		price_status = "+%.0f%% above baseline" % price_deviation
		price_color = "#FF6B6B" if price_deviation > 30 else "#4ECDC4"  # Soft red if high, cyan if moderate
	else:
		price_status = "%.0f%% below baseline" % price_deviation
		price_color = "#66FFFF"
	
	# Determine load factor color
	var load_color: String
	if load_factor >= 85:
		load_color = "#66FF66"  # Green - excellent
	elif load_factor >= 65:
		load_color = "#4ECDC4"  # Light cyan - good
	elif load_factor >= 45:
		load_color = "#A0A0A0"  # Light gray - moderate
	else:
		load_color = "#FF6666"  # Red - low
	
	# Build preview text - enhanced for P.1 "what-if" functionality
	var text: String = ""
	
	# Price analysis row
	text += "[b]Your Price:[/b] [color=#FFFFFF]€%.0f[/color] vs market €%.0f " % [price_economy, baseline_price]
	text += "[color=%s]%s[/color]\n" % [price_color, price_status]
	
	# Demand impact visualization
	var demand_bar_width: int = int(clamp(elasticity_multiplier, 0.3, 2.0) * 50)
	text += "[b]Demand Impact:[/b] "
	if elasticity_multiplier < 0.8:
		text += "[color=#FF6666]▼ Low demand (%.0f%%)[/color]" % (elasticity_multiplier * 100)
	elif elasticity_multiplier > 1.2:
		text += "[color=#66FF66]▲ High demand (%.0f%%)[/color]" % (elasticity_multiplier * 100)
	else:
		text += "[color=#FFFFFF]● Normal demand (%.0f%%)[/color]" % (elasticity_multiplier * 100)  # White for normal
	text += "\n\n"
	
	# Key projections in a clear format
	text += "[b]━━ Weekly Projections ━━[/b]\n"
	text += "  Passengers: [b]%d[/b] / %d seats\n" % [projected_passengers, weekly_capacity]
	text += "  Load Factor: [color=%s][b]%.0f%%[/b][/color]\n" % [load_color, load_factor]
	text += "  Revenue: [b]%s[/b]\n" % UITheme.format_money(estimated_revenue)
	
	# Actionable recommendation
	text += "\n"
	if price_deviation > 50:
		text += "[color=#FF6666]⚠ HIGH RISK: Price significantly above market[/color]\n"
		text += "[i]Try lowering to ~€%.0f for better demand[/i]" % baseline_price
	elif price_deviation > 25:
		text += "[color=#FFAA00]⚡ Premium pricing - monitor load factor closely[/color]"
	elif load_factor > 95:
		text += "[color=#66FF66]💰 OPPORTUNITY: Demand exceeds capacity![/color]\n"
		text += "[i]Consider raising price or adding frequency[/i]"
	elif load_factor < 50:
		text += "[color=#FFAA00]💡 Low projected load - consider lower price[/color]"
	else:
		text += "[color=#66FF66]✓ Good balance of price and demand[/color]"
	
	demand_preview_label.text = text


func _on_use_recommended_pressed() -> void:
	"""Apply recommended pricing"""
	update_recommended_pricing()


func _on_buy_aircraft_pressed() -> void:
	"""Buy Aircraft button pressed - emit signal and hide dialog"""
	buy_aircraft_requested.emit()
	hide()  # Hide this dialog so aircraft purchase can open


func _on_buy_research_pressed() -> void:
	"""Q.1: Buy research button pressed"""
	if not from_airport or not to_airport:
		return
	
	if GameData.purchase_market_research(from_airport, to_airport):
		# Refresh the market analysis to show exact numbers
		update_market_analysis()
		update_route_opportunity_details()
		
		# Show success feedback
		if buy_research_button:
			buy_research_button.text = "✓ Research Purchased!"
			buy_research_button.disabled = true


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
