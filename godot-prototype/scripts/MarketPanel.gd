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
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 12)
	competitors_card.get_node("MarginContainer").add_child(content_vbox)

	var description = Label.new()
	description.text = "Other airlines operating in the market"
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", UITheme.get_text_secondary())
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_vbox.add_child(description)

	competitors_list = VBoxContainer.new()
	competitors_list.add_theme_constant_override("separation", 8)
	content_vbox.add_child(competitors_list)

func create_opportunities_card(parent: VBoxContainer) -> void:
	"""Create market opportunities card"""
	opportunities_card = create_market_card("Route Opportunities", parent)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 12)
	opportunities_card.get_node("MarginContainer").add_child(content_vbox)

	var description = Label.new()
	description.text = "High-potential routes with strong profitability scores"
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", UITheme.get_text_secondary())
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_vbox.add_child(description)

	opportunities_list = VBoxContainer.new()
	opportunities_list.add_theme_constant_override("separation", 8)
	content_vbox.add_child(opportunities_list)

func create_competition_card(parent: VBoxContainer) -> void:
	"""Create route competition card"""
	competition_card = create_market_card("Route Competition", parent)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 12)
	competition_card.get_node("MarginContainer").add_child(content_vbox)

	var description = Label.new()
	description.text = "Routes with multiple airlines competing for passengers"
	description.add_theme_font_size_override("font_size", 12)
	description.add_theme_color_override("font_color", UITheme.get_text_secondary())
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_vbox.add_child(description)

	# Competition list will be populated dynamically
	var competition_list = VBoxContainer.new()
	competition_list.name = "CompetitionList"
	competition_list.add_theme_constant_override("separation", 8)
	content_vbox.add_child(competition_list)

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
		return

	# Get best opportunities from player's hubs
	var opportunities: Array[Dictionary] = []
	for hub in GameData.player_airline.hubs:
		var hub_opportunities = GameData.find_route_opportunities(hub, 5)
		opportunities.append_array(hub_opportunities)

	# Sort by profitability score
	opportunities.sort_custom(_sort_opportunities_by_score)

	# Limit to top 10
	var top_opportunities = opportunities.slice(0, min(10, opportunities.size()))

	# Add opportunity items
	for opp in top_opportunities:
		var opp_item = create_opportunity_item(opp)
		opportunities_list.add_child(opp_item)

func _sort_opportunities_by_score(a: Dictionary, b: Dictionary) -> bool:
	"""Sort opportunities by profitability score (highest first)"""
	return a.get("profitability_score", 0.0) > b.get("profitability_score", 0.0)

func create_opportunity_item(opportunity: Dictionary) -> Control:
	"""Create an opportunity item card"""
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

	var route_name = Label.new()
	var from_airport = opportunity.get("from_airport", null)
	var to_airport = opportunity.get("to_airport", null)
	if from_airport and to_airport:
		route_name.text = "%s → %s" % [from_airport.iata_code, to_airport.iata_code]
	else:
		route_name.text = "Unknown Route"
	route_name.add_theme_font_size_override("font_size", 14)
	route_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(route_name)

	var opp_details = Label.new()
	var score = opportunity.get("profitability_score", 0.0)
	var demand = opportunity.get("demand", 0.0)
	var competition = opportunity.get("competition", 0)
	opp_details.text = "Score: %.0f | Demand: %.0f pax/wk | Competition: %d" % [score, demand, competition]
	opp_details.add_theme_font_size_override("font_size", 12)
	opp_details.add_theme_color_override("font_color", UITheme.get_text_secondary())
	info_vbox.add_child(opp_details)

	# Score badge
	var score_badge = Label.new()
	score_badge.text = "%.0f" % score
	score_badge.custom_minimum_size = Vector2(50, 32)
	score_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_badge.add_theme_font_size_override("font_size", 14)
	
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

	# View button
	var view_btn = Button.new()
	view_btn.text = "View"
	view_btn.custom_minimum_size = Vector2(80, 32)
	view_btn.add_theme_font_size_override("font_size", 12)
	var btn_style = UITheme.create_secondary_button_style()
	view_btn.add_theme_stylebox_override("normal", btn_style)
	view_btn.pressed.connect(_on_opportunity_selected.bind(opportunity))
	hbox.add_child(view_btn)

	return item

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
