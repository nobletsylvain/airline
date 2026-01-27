extends Control
class_name MarketPanel

## Market Analysis Panel - Display competitors, market opportunities, route competition

signal route_opportunity_selected(opportunity: Dictionary)

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var competitors_card: PanelContainer
var opportunities_card: PanelContainer
var competition_card: PanelContainer

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

	# Limit to top 15
	var top_opportunities = filtered_opportunities.slice(0, min(15, filtered_opportunities.size()))
	
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
	if not GameData.player_airline:
		return false
	
	for route in GameData.player_airline.routes:
		# Check both directions
		if (route.from_airport == from_airport and route.to_airport == to_airport) or \
		   (route.from_airport == to_airport and route.to_airport == from_airport):
			return true
	
	return false

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
	
	var demand_label = Label.new()
	demand_label.text = "~%.0f pax/wk" % demand
	demand_label.add_theme_font_size_override("font_size", 12)
	demand_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
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
	if score >= 70:
		score_badge.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	elif score >= 50:
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
	if distance_km <= 1500:
		return "ATR 72-600"
	elif distance_km <= 4000:
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
