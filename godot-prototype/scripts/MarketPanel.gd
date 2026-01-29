## MarketPanel.gd
## Displays market analysis including competitors, route opportunities,
## and route competition. Helps player identify profitable expansion targets.
## Part of the main dashboard UI.
extends Control
class_name MarketPanel

## Emitted when user selects a route opportunity to create
## @param opportunity: Dictionary containing origin, destination, demand, score
signal route_opportunity_selected(opportunity: Dictionary)

## Emitted when user wants to purchase market research
signal research_requested(from_airport: Airport, to_airport: Airport)

## Maximum route opportunities to display in the panel
const MAX_OPPORTUNITIES := 15

## Distance threshold for regional aircraft (ATR 72-600 optimal)
const REGIONAL_RANGE_KM := 1500.0

## Distance threshold for medium-haul narrowbody aircraft
const MEDIUM_HAUL_KM := 4000.0

## Score threshold for "excellent" opportunity (green badge)
const SCORE_EXCELLENT := 70.0

## Score threshold for "good" opportunity (yellow badge)
const SCORE_GOOD := 50.0

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var research_card: PanelContainer  # Q.1: Market Research card
var competitors_card: PanelContainer
var opportunities_card: PanelContainer
var competition_card: PanelContainer

# Q.1: Market Research UI
var research_list: VBoxContainer
var research_airport_dropdown: OptionButton
var research_destination_dropdown: OptionButton
var research_buy_button: Button
var research_preview_label: RichTextLabel

# Competitors list
var competitors_list: VBoxContainer

# Opportunities list
var opportunities_list: VBoxContainer

func _ready() -> void:
	build_ui()
	refresh()

func build_ui() -> void:
	"""Build the market panel UI"""
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

	# Market cards
	create_research_card(main_vbox)  # Q.1: Market Research
	create_competitors_card(main_vbox)
	create_opportunities_card(main_vbox)
	create_competition_card(main_vbox)

func create_header(parent: VBoxContainer) -> void:
	"""Create header section"""
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 16)
	parent.add_child(header_hbox)

	var title_vbox = VBoxContainer.new()
	title_vbox.add_theme_constant_override("separation", 4)
	header_hbox.add_child(title_vbox)

	var title = Label.new()
	title.text = "Market & Competitors"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	title_vbox.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Analyze competition and discover route opportunities"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_secondary())
	title_vbox.add_child(subtitle)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)


func create_research_card(parent: VBoxContainer) -> void:
	"""Q.1: Create market research purchase card"""
	research_card = create_market_card("🔍 Market Research", parent)
	
	var card_vbox = research_card.get_node("MarginContainer/VBoxContainer")
	
	var description = Label.new()
	description.text = "Purchase detailed market analysis for better route planning (€50K per report)"
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", UITheme.get_text_secondary())
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_vbox.add_child(description)
	
	# Selection row - dropdowns
	var dropdowns_hbox = HBoxContainer.new()
	dropdowns_hbox.add_theme_constant_override("separation", 16)
	card_vbox.add_child(dropdowns_hbox)
	
	# From airport dropdown
	var from_vbox = VBoxContainer.new()
	from_vbox.add_theme_constant_override("separation", 4)
	dropdowns_hbox.add_child(from_vbox)
	
	var from_label = Label.new()
	from_label.text = "From:"
	from_label.add_theme_font_size_override("font_size", 12)
	from_vbox.add_child(from_label)
	
	research_airport_dropdown = OptionButton.new()
	research_airport_dropdown.custom_minimum_size = Vector2(200, 35)
	research_airport_dropdown.item_selected.connect(_on_research_from_selected)
	from_vbox.add_child(research_airport_dropdown)
	
	# To airport dropdown
	var to_vbox = VBoxContainer.new()
	to_vbox.add_theme_constant_override("separation", 4)
	dropdowns_hbox.add_child(to_vbox)
	
	var to_label = Label.new()
	to_label.text = "To:"
	to_label.add_theme_font_size_override("font_size", 12)
	to_vbox.add_child(to_label)
	
	research_destination_dropdown = OptionButton.new()
	research_destination_dropdown.custom_minimum_size = Vector2(200, 35)
	research_destination_dropdown.item_selected.connect(_on_research_to_selected)
	to_vbox.add_child(research_destination_dropdown)
	
	# Spacer to push button right
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropdowns_hbox.add_child(spacer)
	
	# Buy button in its own container for vertical alignment
	var btn_vbox = VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 4)
	dropdowns_hbox.add_child(btn_vbox)
	
	# Empty label for alignment with "From:" and "To:" labels
	var btn_spacer = Label.new()
	btn_spacer.text = " "
	btn_spacer.add_theme_font_size_override("font_size", 12)
	btn_vbox.add_child(btn_spacer)
	
	research_buy_button = Button.new()
	research_buy_button.text = "Buy Research (€50K)"
	research_buy_button.custom_minimum_size = Vector2(180, 35)
	research_buy_button.pressed.connect(_on_buy_research_pressed)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = UITheme.PRIMARY_BLUE
	btn_style.set_corner_radius_all(6)
	btn_style.set_content_margin_all(8)
	research_buy_button.add_theme_stylebox_override("normal", btn_style)
	
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = UITheme.PRIMARY_BLUE.lightened(0.1)
	research_buy_button.add_theme_stylebox_override("hover", btn_hover)
	
	research_buy_button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	btn_vbox.add_child(research_buy_button)
	
	# Preview panel
	var preview_panel = PanelContainer.new()
	var preview_style = StyleBoxFlat.new()
	preview_style.bg_color = Color(0.1, 0.12, 0.15)
	preview_style.set_corner_radius_all(6)
	preview_style.set_content_margin_all(10)
	preview_panel.add_theme_stylebox_override("panel", preview_style)
	card_vbox.add_child(preview_panel)
	
	research_preview_label = RichTextLabel.new()
	research_preview_label.bbcode_enabled = true
	research_preview_label.fit_content = true
	research_preview_label.custom_minimum_size = Vector2(0, 60)
	research_preview_label.add_theme_font_size_override("normal_font_size", 12)
	research_preview_label.text = "[i]Select a route to preview research value[/i]"
	preview_panel.add_child(research_preview_label)
	
	# Purchased research list
	var purchased_header = Label.new()
	purchased_header.text = "Purchased Research:"
	purchased_header.add_theme_font_size_override("font_size", 13)
	purchased_header.add_theme_color_override("font_color", UITheme.get_text_primary())
	card_vbox.add_child(purchased_header)
	
	research_list = VBoxContainer.new()
	research_list.add_theme_constant_override("separation", 6)
	card_vbox.add_child(research_list)


func create_competitors_card(parent: VBoxContainer) -> void:
	"""Create competitors overview card"""
	competitors_card = create_market_card("Competitors", parent)
	
	# Add content to the VBoxContainer inside the card
	var card_vbox = competitors_card.get_node("MarginContainer/VBoxContainer")

	var description = Label.new()
	description.text = "Other airlines operating in the market"
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", UITheme.get_text_secondary())
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_vbox.add_child(description)

	competitors_list = VBoxContainer.new()
	competitors_list.add_theme_constant_override("separation", 8)
	card_vbox.add_child(competitors_list)

func create_opportunities_card(parent: VBoxContainer) -> void:
	"""Create market opportunities card"""
	opportunities_card = create_market_card("Route Opportunities", parent)
	
	# Add content to the VBoxContainer inside the card
	var card_vbox = opportunities_card.get_node("MarginContainer/VBoxContainer")

	var description = Label.new()
	description.text = "High-potential routes with strong profitability scores"
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", UITheme.get_text_secondary())
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_vbox.add_child(description)

	opportunities_list = VBoxContainer.new()
	opportunities_list.add_theme_constant_override("separation", 8)
	card_vbox.add_child(opportunities_list)

func create_competition_card(parent: VBoxContainer) -> void:
	"""Create route competition card"""
	competition_card = create_market_card("Route Competition", parent)
	
	# Add content to the VBoxContainer inside the card
	var card_vbox = competition_card.get_node("MarginContainer/VBoxContainer")

	var description = Label.new()
	description.text = "Routes with multiple airlines competing for passengers"
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", UITheme.get_text_secondary())
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_vbox.add_child(description)

	# Competition list will be populated dynamically
	var competition_list = VBoxContainer.new()
	competition_list.name = "CompetitionList"
	competition_list.add_theme_constant_override("separation", 8)
	card_vbox.add_child(competition_list)

func create_market_card(title: String, parent: VBoxContainer) -> PanelContainer:
	"""Create a styled market card"""
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
	vbox.name = "VBoxContainer"  # Name it so we can find it
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
	"""Refresh all market data"""
	_update_research()  # Q.1: Update research card
	_update_competitors()
	_update_opportunities()
	_update_competition()

func _update_competitors() -> void:
	"""Update competitors list"""
	# Clear existing items
	for child in competitors_list.get_children():
		child.queue_free()

	if not GameData.airlines:
		return

	# Add competitor items (excluding player)
	for airline in GameData.airlines:
		if airline == GameData.player_airline:
			continue

		var competitor_item = create_competitor_item(airline)
		competitors_list.add_child(competitor_item)

func create_competitor_item(airline: Airline) -> Control:
	"""Create a competitor item card"""
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

	# Airline info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	var airline_name = Label.new()
	airline_name.text = airline.name
	airline_name.add_theme_font_size_override("font_size", 14)
	airline_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(airline_name)

	var airline_stats = Label.new()
	airline_stats.text = "%d routes | %d aircraft | Reputation: %.0f" % [
		airline.routes.size(),
		airline.aircraft.size(),
		airline.reputation
	]
	airline_stats.add_theme_font_size_override("font_size", 12)
	airline_stats.add_theme_color_override("font_color", UITheme.get_text_secondary())
	info_vbox.add_child(airline_stats)

	return item

func _update_opportunities() -> void:
	"""Update route opportunities list"""
	# Clear existing items
	for child in opportunities_list.get_children():
		child.queue_free()

	if not GameData.player_airline or not GameData.airports:
		var empty_label = Label.new()
		empty_label.text = "Select a hub to see route opportunities"
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
		opportunities_list.add_child(empty_label)
		return
	
	if GameData.player_airline.hubs.is_empty():
		var empty_label = Label.new()
		empty_label.text = "You need a hub to see route opportunities. Purchase one in the Fleet tab."
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		opportunities_list.add_child(empty_label)
		return

	# Get best opportunities from player's hubs (more per hub for better coverage)
	var opportunities: Array[Dictionary] = []
	for hub in GameData.player_airline.hubs:
		var hub_opportunities = GameData.find_route_opportunities(hub, 15)
		opportunities.append_array(hub_opportunities)

	# Filter out routes player already operates
	var filtered_opportunities: Array[Dictionary] = []
	for opp in opportunities:
		var from = opp.get("from_airport", null)
		var to = opp.get("to_airport", null)
		if from and to and not _player_has_route(from, to):
			filtered_opportunities.append(opp)
	
	# Sort by profitability score
	filtered_opportunities.sort_custom(_sort_opportunities_by_score)

	# Limit to top opportunities
	var top_opportunities = filtered_opportunities.slice(0, min(MAX_OPPORTUNITIES, filtered_opportunities.size()))
	
	if top_opportunities.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No new route opportunities found. You may already be serving all high-demand routes."
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		opportunities_list.add_child(empty_label)
		return

	# Add opportunity items
	for opp in top_opportunities:
		var opp_item = create_opportunity_item(opp)
		opportunities_list.add_child(opp_item)


func _player_has_route(from_airport: Airport, to_airport: Airport) -> bool:
	"""Check if player already has a route between these airports"""
	return GameData.has_route_between(from_airport, to_airport, GameData.player_airline)

func _sort_opportunities_by_score(a: Dictionary, b: Dictionary) -> bool:
	"""Sort opportunities by profitability score (highest first)"""
	return a.get("profitability_score", 0.0) > b.get("profitability_score", 0.0)

func create_opportunity_item(opportunity: Dictionary) -> Control:
	"""Create an opportunity item card with detailed info"""
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

	# Opportunity info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	# Route name and cities
	var from_airport = opportunity.get("from_airport", null)
	var to_airport = opportunity.get("to_airport", null)
	
	var route_name = Label.new()
	if from_airport and to_airport:
		route_name.text = "%s → %s" % [from_airport.iata_code, to_airport.iata_code]
	else:
		route_name.text = "Unknown Route"
	route_name.add_theme_font_size_override("font_size", 14)
	route_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(route_name)
	
	# City names
	var city_label = Label.new()
	if from_airport and to_airport:
		city_label.text = "%s to %s" % [from_airport.city, to_airport.city]
	else:
		city_label.text = ""
	city_label.add_theme_font_size_override("font_size", 11)
	city_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	info_vbox.add_child(city_label)

	# Distance and recommended aircraft
	var distance_km: float = opportunity.get("distance_km", 0.0)
	var recommended_aircraft: String = _get_recommended_aircraft(distance_km)
	
	var details_row1 = Label.new()
	details_row1.text = "%.0f km | %s" % [distance_km, recommended_aircraft]
	details_row1.add_theme_font_size_override("font_size", 12)
	details_row1.add_theme_color_override("font_color", UITheme.get_text_secondary())
	info_vbox.add_child(details_row1)

	# Demand, competition, and competition level indicator
	var demand = opportunity.get("demand", 0.0)
	var competition = opportunity.get("competition", 0)
	var competition_text: String
	var competition_color: Color
	
	if competition == 0:
		competition_text = "No competition"
		competition_color = UITheme.PROFIT_COLOR
	elif competition == 1:
		competition_text = "1 competitor"
		competition_color = UITheme.WARNING_COLOR
	else:
		competition_text = "%d competitors" % competition
		competition_color = UITheme.LOSS_COLOR
	
	var details_row2 = HBoxContainer.new()
	details_row2.add_theme_constant_override("separation", 8)
	info_vbox.add_child(details_row2)
	
	# Q.2: Show demand with uncertainty (range vs exact based on knowledge)
	var demand_label = Label.new()
	if from_airport and to_airport:
		var demand_info = GameData.get_demand_display(from_airport, to_airport, demand)
		# Add confidence indicator icon
		var conf_icon = "●" if demand_info.is_exact else ("◐" if demand_info.confidence == "medium" else "○")
		demand_label.text = "%s %s" % [conf_icon, demand_info.display_text]
		# Use readable white text instead of confidence colors
		demand_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
		demand_label.tooltip_text = "Confidence: %s" % demand_info.confidence.capitalize()
	else:
		demand_label.text = "~%.0f pax/wk" % demand
		demand_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	demand_label.add_theme_font_size_override("font_size", 12)
	details_row2.add_child(demand_label)
	
	var comp_label = Label.new()
	comp_label.text = " | %s" % competition_text
	comp_label.add_theme_font_size_override("font_size", 12)
	comp_label.add_theme_color_override("font_color", competition_color)
	details_row2.add_child(comp_label)

	# Score badge with tooltip
	var score = opportunity.get("profitability_score", 0.0)
	var score_badge = Label.new()
	score_badge.text = "%.0f" % score
	score_badge.custom_minimum_size = Vector2(50, 32)
	score_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_badge.add_theme_font_size_override("font_size", 14)
	score_badge.tooltip_text = "Profitability Score (0-100)\nHigher = better opportunity"
	
	# Color based on score
	if score >= SCORE_EXCELLENT:
		score_badge.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	elif score >= SCORE_GOOD:
		score_badge.add_theme_color_override("font_color", UITheme.WARNING_COLOR)
	else:
		score_badge.add_theme_color_override("font_color", UITheme.get_text_secondary())
	
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = Color(0, 0, 0, 0.1)
	badge_style.set_corner_radius_all(6)
	badge_style.set_content_margin_all(8)
	score_badge.add_theme_stylebox_override("normal", badge_style)
	hbox.add_child(score_badge)

	# Create Route button (more actionable than "View")
	var create_btn = Button.new()
	create_btn.text = "Create Route"
	create_btn.custom_minimum_size = Vector2(100, 32)
	create_btn.add_theme_font_size_override("font_size", 12)
	var btn_style = UITheme.create_primary_button_style()
	create_btn.add_theme_stylebox_override("normal", btn_style)
	create_btn.pressed.connect(_on_opportunity_selected.bind(opportunity))
	hbox.add_child(create_btn)

	return item


func _get_recommended_aircraft(distance_km: float) -> String:
	"""Get recommended aircraft type based on route distance"""
	if distance_km <= REGIONAL_RANGE_KM:
		return "ATR 72-600"
	elif distance_km <= MEDIUM_HAUL_KM:
		return "737-800 / A320neo"
	else:
		return "A320neo"

func _update_competition() -> void:
	"""Update route competition list"""
	var competition_list = competition_card.get_node_or_null("MarginContainer/VBoxContainer/CompetitionList")
	if not competition_list:
		return

	# Clear existing items
	for child in competition_list.get_children():
		child.queue_free()

	if not GameData.player_airline:
		return

	# Find routes with competition (multiple airlines)
	var competitive_routes: Array[Dictionary] = []
	for route in GameData.player_airline.routes:
		var competing = GameData.simulation_engine.get_competing_routes(route) if GameData.simulation_engine else []
		if competing.size() > 1:  # More than just this route
			competitive_routes.append({
				"route": route,
				"competition_count": competing.size() - 1
			})

	# Add competition items
	for comp_data in competitive_routes:
		var comp_item = create_competition_item(comp_data)
		competition_list.add_child(comp_item)

func create_competition_item(comp_data: Dictionary) -> Control:
	"""Create a competition item card"""
	var route = comp_data.get("route", null)
	var comp_count = comp_data.get("competition_count", 0)
	
	if not route:
		return Control.new()

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

	# Route info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	var route_name = Label.new()
	route_name.text = route.get_display_name()
	route_name.add_theme_font_size_override("font_size", 14)
	route_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(route_name)

	var comp_label = Label.new()
	comp_label.text = "%d competitor(s) on this route" % comp_count
	comp_label.add_theme_font_size_override("font_size", 12)
	comp_label.add_theme_color_override("font_color", UITheme.WARNING_COLOR)
	info_vbox.add_child(comp_label)

	return item

func _on_opportunity_selected(opportunity: Dictionary) -> void:
	"""Handle opportunity selection"""
	route_opportunity_selected.emit(opportunity)


## ============================================================================
## Q.1: MARKET RESEARCH FUNCTIONS
## ============================================================================

func _update_research() -> void:
	"""Q.1: Update research card content"""
	if not research_airport_dropdown or not research_destination_dropdown:
		return
	
	# Populate airport dropdowns
	_populate_research_dropdowns()
	
	# Update purchased research list
	_update_purchased_research_list()
	
	# Update buy button state
	_update_research_button_state()


func _populate_research_dropdowns() -> void:
	"""Populate airport dropdowns for research selection"""
	research_airport_dropdown.clear()
	research_destination_dropdown.clear()
	
	if not GameData.player_airline or GameData.player_airline.hubs.is_empty():
		research_airport_dropdown.add_item("No hubs available")
		research_destination_dropdown.add_item("Select hub first")
		return
	
	# From dropdown: Player's hubs
	for hub in GameData.player_airline.hubs:
		research_airport_dropdown.add_item("%s (%s)" % [hub.city, hub.iata_code])
	
	# To dropdown: All airports (excluding selected hub)
	_update_destination_dropdown()


func _update_destination_dropdown() -> void:
	"""Update destination dropdown based on selected hub"""
	research_destination_dropdown.clear()
	
	var from_idx = research_airport_dropdown.selected
	if from_idx < 0 or not GameData.player_airline or from_idx >= GameData.player_airline.hubs.size():
		return
	
	var from_airport = GameData.player_airline.hubs[from_idx]
	
	# Add all airports except the selected hub
	for airport in GameData.airports:
		if airport == from_airport:
			continue
		
		# Show research status indicator
		var status = ""
		if GameData.is_route_researched(from_airport, airport):
			status = " ✓"
		elif GameData.is_route_learned(from_airport, airport):
			status = " 📖"
		
		research_destination_dropdown.add_item("%s (%s)%s" % [airport.city, airport.iata_code, status])


func _on_research_from_selected(_index: int) -> void:
	"""Handle from airport selection change"""
	_update_destination_dropdown()
	_update_research_preview()
	_update_research_button_state()


func _on_research_to_selected(_index: int) -> void:
	"""Handle to airport selection change"""
	_update_research_preview()
	_update_research_button_state()


func _get_selected_research_airports() -> Dictionary:
	"""Get currently selected airports for research"""
	var result = {"from": null, "to": null}
	
	if not GameData.player_airline or GameData.player_airline.hubs.is_empty():
		return result
	
	var from_idx = research_airport_dropdown.selected
	var to_idx = research_destination_dropdown.selected
	
	if from_idx < 0 or from_idx >= GameData.player_airline.hubs.size():
		return result
	
	result.from = GameData.player_airline.hubs[from_idx]
	
	# Find the to airport
	if to_idx >= 0:
		var airport_idx = 0
		for airport in GameData.airports:
			if airport == result.from:
				continue
			if airport_idx == to_idx:
				result.to = airport
				break
			airport_idx += 1
	
	return result


func _update_research_preview() -> void:
	"""Q.1: Update research preview based on selected route"""
	if not research_preview_label:
		return
	
	var airports = _get_selected_research_airports()
	if not airports.from or not airports.to:
		research_preview_label.text = "[i]Select a route to preview research value[/i]"
		return
	
	var from_airport: Airport = airports.from
	var to_airport: Airport = airports.to
	
	# Calculate actual demand data
	var distance = MarketAnalysis.calculate_great_circle_distance(from_airport, to_airport)
	var demand = MarketAnalysis.calculate_potential_demand(from_airport, to_airport, distance)
	
	# Check current knowledge status
	var is_researched = GameData.is_route_researched(from_airport, to_airport)
	var is_learned = GameData.is_route_learned(from_airport, to_airport)
	
	if is_researched:
		# Show purchased research data
		var data = GameData.get_research_data(from_airport, to_airport)
		research_preview_label.text = "[color=#66FF66]✓ Research Purchased[/color] [color=#888888](Week %d)[/color]\n\n" % data.week_purchased
		research_preview_label.text += "[b]Known Market Data:[/b]\n"
		research_preview_label.text += "• Demand: [b]%.0f pax/week[/b]\n" % data.exact_demand
		research_preview_label.text += "• Business travelers: [b]%.0f%%[/b]\n" % (data.business_ratio * 100)
		research_preview_label.text += "• Leisure travelers: [b]%.0f%%[/b]\n" % (data.leisure_ratio * 100)
		research_preview_label.text += "• Market trend: [b]%s[/b]" % data.growth_trend.capitalize()
		return
	
	if is_learned:
		# Calculate business/leisure split and trend for learned routes
		var business_ratio = _estimate_business_ratio(distance, from_airport, to_airport)
		var growth_trend = _estimate_growth_trend(from_airport, to_airport)
		
		# Find when route was started to calculate learning time
		var weeks_operated = _get_route_weeks_operated(from_airport, to_airport)
		
		research_preview_label.text = "[color=#66AAFF]📖 Learned Through Operation[/color]\n"
		if weeks_operated > 0:
			research_preview_label.text += "[color=#888888](After %d weeks of service)[/color]\n\n" % weeks_operated
		else:
			research_preview_label.text += "\n"
		
		research_preview_label.text += "[b]Known Market Data:[/b]\n"
		research_preview_label.text += "• Demand: [b]~%.0f pax/week[/b]\n" % demand
		research_preview_label.text += "• Business travelers: [b]~%.0f%%[/b]\n" % (business_ratio * 100)
		research_preview_label.text += "• Leisure travelers: [b]~%.0f%%[/b]\n" % ((1.0 - business_ratio) * 100)
		research_preview_label.text += "• Market trend: [b]%s[/b]\n\n" % growth_trend.capitalize()
		research_preview_label.text += "[color=#888888][i]Data from operational experience[/i][/color]"
		return
	
	# Show what research would reveal (route not yet known)
	var demand_info = GameData.get_demand_display(from_airport, to_airport, demand)
	
	research_preview_label.text = "[b]Current Knowledge:[/b]\n"
	research_preview_label.text += "Demand: [color=%s]%s[/color] (Confidence: %s)\n\n" % [
		demand_info.confidence_color, demand_info.display_text, demand_info.confidence.capitalize()
	]
	research_preview_label.text += "[b]Research would reveal:[/b]\n"
	research_preview_label.text += "• Exact weekly passenger demand\n"
	research_preview_label.text += "• Business vs leisure split\n"
	research_preview_label.text += "• Market growth trend"


func _estimate_business_ratio(distance: float, from_airport: Airport, to_airport: Airport) -> float:
	"""Estimate business/leisure ratio for learned routes (mirrors GameData calculation)"""
	var base_ratio: float
	
	if distance < 1500:
		base_ratio = 0.30  # Short-haul
	elif distance < 4000:
		base_ratio = 0.40  # Medium-haul
	else:
		base_ratio = 0.50  # Long-haul
	
	var avg_gdp = (from_airport.gdp_per_capita + to_airport.gdp_per_capita) / 2.0
	if avg_gdp > 40000:
		base_ratio += 0.10
	elif avg_gdp < 20000:
		base_ratio -= 0.10
	
	return clamp(base_ratio, 0.15, 0.70)


func _estimate_growth_trend(from_airport: Airport, to_airport: Airport) -> String:
	"""Estimate market growth trend for learned routes"""
	var avg_gdp = (from_airport.gdp_per_capita + to_airport.gdp_per_capita) / 2.0
	var avg_pax = (from_airport.annual_passengers + to_airport.annual_passengers) / 2.0
	
	if avg_gdp > 35000 and avg_pax < 50:
		return "growing"
	elif avg_gdp < 25000:
		return "stable"
	elif avg_pax > 80:
		return "mature"
	else:
		return "stable"


func _get_route_weeks_operated(from_airport: Airport, to_airport: Airport) -> int:
	"""Get how many weeks a route has been operated"""
	if not GameData.player_airline:
		return 0
	
	for route in GameData.player_airline.routes:
		if (route.from_airport == from_airport and route.to_airport == to_airport) or \
		   (route.from_airport == to_airport and route.to_airport == from_airport):
			if GameData.route_start_weeks.has(route.id):
				return GameData.current_week - GameData.route_start_weeks[route.id]
	
	return 0


func _update_research_button_state() -> void:
	"""Update buy button enabled/disabled state"""
	if not research_buy_button:
		return
	
	var airports = _get_selected_research_airports()
	
	# Disable if no valid selection
	if not airports.from or not airports.to:
		research_buy_button.disabled = true
		research_buy_button.text = "Select Route"
		return
	
	# Check if already researched (purchased)
	if GameData.is_route_researched(airports.from, airports.to):
		research_buy_button.disabled = true
		research_buy_button.text = "✓ Researched"
		return
	
	# Check if learned through operation
	if GameData.is_route_learned(airports.from, airports.to):
		research_buy_button.disabled = true
		research_buy_button.text = "📖 Learned"
		return
	
	# Disable if can't afford
	if not GameData.player_airline or GameData.player_airline.balance < GameData.MARKET_RESEARCH_COST:
		research_buy_button.disabled = true
		research_buy_button.text = "Can't Afford (€50K)"
		return
	
	# Enable purchase
	research_buy_button.disabled = false
	research_buy_button.text = "Buy Research (€50K)"


func _on_buy_research_pressed() -> void:
	"""Q.1: Handle buy research button press"""
	var airports = _get_selected_research_airports()
	
	if not airports.from or not airports.to:
		if UISoundManager:
			UISoundManager.play_error()
		return
	
	if GameData.purchase_market_research(airports.from, airports.to):
		# Play purchase sound for market research buy
		if UISoundManager:
			UISoundManager.play_purchase()
		
		# Refresh the panel
		refresh()
		
		# Show success feedback
		if research_preview_label:
			research_preview_label.text = "[color=#66FF66]✓ Research purchased![/color]\n"
			var data = GameData.get_research_data(airports.from, airports.to)
			research_preview_label.text += "Exact demand: [b]%.0f pax/week[/b]\n" % data.exact_demand
			research_preview_label.text += "Business: %.0f%% | Leisure: %.0f%% | Trend: %s" % [
				data.business_ratio * 100, data.leisure_ratio * 100, data.growth_trend.capitalize()
			]
	else:
		# Purchase failed (likely insufficient funds)
		if UISoundManager:
			UISoundManager.play_error()


func _update_purchased_research_list() -> void:
	"""Update list of purchased research reports"""
	if not research_list:
		return
	
	# Clear existing items
	for child in research_list.get_children():
		child.queue_free()
	
	if GameData.researched_routes.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No research purchased yet"
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", UITheme.get_text_muted())
		research_list.add_child(empty_label)
		return
	
	# Add items for each researched route
	for key in GameData.researched_routes:
		var data = GameData.researched_routes[key]
		var item = _create_research_item(data)
		research_list.add_child(item)


func _create_research_item(data: Dictionary) -> Control:
	"""Create a research report item"""
	var item = HBoxContainer.new()
	item.add_theme_constant_override("separation", 12)
	
	var route_label = Label.new()
	route_label.text = "%s ↔ %s" % [data.from_iata, data.to_iata]
	route_label.add_theme_font_size_override("font_size", 12)
	route_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	route_label.custom_minimum_size = Vector2(100, 0)
	item.add_child(route_label)
	
	var demand_label = Label.new()
	demand_label.text = "%.0f pax/wk" % data.exact_demand
	demand_label.add_theme_font_size_override("font_size", 12)
	demand_label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	demand_label.custom_minimum_size = Vector2(80, 0)
	item.add_child(demand_label)
	
	var split_label = Label.new()
	split_label.text = "%.0f%% biz" % (data.business_ratio * 100)
	split_label.add_theme_font_size_override("font_size", 12)
	split_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	item.add_child(split_label)
	
	var trend_label = Label.new()
	var trend_color: Color
	match data.growth_trend:
		"growing":
			trend_color = UITheme.PROFIT_COLOR
		"mature":
			trend_color = UITheme.WARNING_COLOR
		_:
			trend_color = UITheme.get_text_muted()
	trend_label.text = data.growth_trend.capitalize()
	trend_label.add_theme_font_size_override("font_size", 12)
	trend_label.add_theme_color_override("font_color", trend_color)
	item.add_child(trend_label)
	
	return item
