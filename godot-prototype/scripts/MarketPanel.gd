extends Control
class_name MarketPanel

## Market & Competitors Panel - Shows competitor airlines, expansion opportunities, hub network effects
## Pattern matches FleetManagementPanel.gd architecture

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer

# KPI labels
var kpi_routes_value: Label
var kpi_competitors_value: Label
var kpi_share_value: Label
var kpi_opportunity_value: Label

# Section containers
var competitor_cards_container: HFlowContainer
var opportunity_cards_container: VBoxContainer
var hub_network_container: VBoxContainer

func _ready() -> void:
	build_ui()

func build_ui() -> void:
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

	# Title
	var title = Label.new()
	title.text = "Market & Competitors"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	outer_vbox.add_child(title)

	# KPI row
	_create_kpi_row(outer_vbox)

	# Scrollable content
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)

	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 20)
	scroll_container.add_child(main_vbox)

	# Competitor Airlines Section
	_create_competitor_section(main_vbox)

	# Expansion Opportunities Section
	_create_opportunity_section(main_vbox)

	# Hub Network Effects Section
	_create_hub_network_section(main_vbox)

# ============================================================================
# KPI ROW
# ============================================================================

func _create_kpi_row(parent: VBoxContainer) -> void:
	var kpi_row = HBoxContainer.new()
	kpi_row.add_theme_constant_override("separation", 12)
	parent.add_child(kpi_row)

	var routes_kpi = _create_kpi_card("Your Routes", "0")
	kpi_routes_value = routes_kpi.get_node("VBox/Value")
	kpi_row.add_child(routes_kpi)

	var competitors_kpi = _create_kpi_card("Competitors", "0")
	kpi_competitors_value = competitors_kpi.get_node("VBox/Value")
	kpi_row.add_child(competitors_kpi)

	var share_kpi = _create_kpi_card("Market Share", "0%")
	kpi_share_value = share_kpi.get_node("VBox/Value")
	kpi_row.add_child(share_kpi)

	var opp_kpi = _create_kpi_card("Best Opportunity", "—")
	kpi_opportunity_value = opp_kpi.get_node("VBox/Value")
	kpi_row.add_child(opp_kpi)

func _create_kpi_card(title_text: String, value_text: String) -> PanelContainer:
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 70)
	card.add_theme_stylebox_override("panel", UITheme.create_kpi_card_style())

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	var title = Label.new()
	title.name = "Title"
	title.text = title_text
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", UITheme.get_text_muted())
	vbox.add_child(title)

	var value = Label.new()
	value.name = "Value"
	value.text = value_text
	value.add_theme_font_size_override("font_size", 18)
	value.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(value)

	return card

# ============================================================================
# SECTIONS
# ============================================================================

func _create_competitor_section(parent: VBoxContainer) -> void:
	var section = _create_section_panel("Competitor Airlines")
	parent.add_child(section)

	var content = section.get_node("Margin/VBox/Content")
	competitor_cards_container = HFlowContainer.new()
	competitor_cards_container.add_theme_constant_override("h_separation", 16)
	competitor_cards_container.add_theme_constant_override("v_separation", 16)
	content.add_child(competitor_cards_container)

func _create_opportunity_section(parent: VBoxContainer) -> void:
	var section = _create_section_panel("Expansion Opportunities")
	parent.add_child(section)

	var content = section.get_node("Margin/VBox/Content")

	var desc = Label.new()
	desc.text = "Best route opportunities from your hub airports"
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", UITheme.get_text_muted())
	content.add_child(desc)

	opportunity_cards_container = VBoxContainer.new()
	opportunity_cards_container.add_theme_constant_override("separation", 10)
	content.add_child(opportunity_cards_container)

func _create_hub_network_section(parent: VBoxContainer) -> void:
	var section = _create_section_panel("Hub Network Effects")
	parent.add_child(section)
	hub_network_container = section.get_node("Margin/VBox/Content")

func _create_section_panel(title_text: String) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UITheme.create_panel_style())

	var section_margin = MarginContainer.new()
	section_margin.name = "Margin"
	section_margin.add_theme_constant_override("margin_left", 20)
	section_margin.add_theme_constant_override("margin_right", 20)
	section_margin.add_theme_constant_override("margin_top", 16)
	section_margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(section_margin)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 12)
	section_margin.add_child(vbox)

	var title = Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(title)

	var sep = HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.2)
	vbox.add_child(sep)

	var content = VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 8)
	vbox.add_child(content)

	return panel

# ============================================================================
# COMPETITOR CARD
# ============================================================================

func _create_competitor_card(airline: Airline) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(280, 160)

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = UITheme.get_card_bg()
	card_style.set_corner_radius_all(12)
	card_style.set_content_margin_all(16)
	card_style.border_color = UITheme.get_panel_border()
	card_style.set_border_width_all(1)
	card_style.shadow_color = Color(0, 0, 0, 0.05)
	card_style.shadow_size = 2
	card.add_theme_stylebox_override("panel", card_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	# Top row: Name + Grade
	var top_row = HBoxContainer.new()
	vbox.add_child(top_row)

	var name_label = Label.new()
	name_label.text = airline.name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	top_row.add_child(name_label)

	# Grade badge
	var grade = airline.get_grade()
	var badge = PanelContainer.new()
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = Color(UITheme.get_grade_color(grade).r, UITheme.get_grade_color(grade).g, UITheme.get_grade_color(grade).b, 0.2)
	badge_style.set_corner_radius_all(10)
	badge_style.set_content_margin_all(4)
	badge_style.content_margin_left = 8
	badge_style.content_margin_right = 8
	badge.add_theme_stylebox_override("panel", badge_style)
	top_row.add_child(badge)

	var badge_label = Label.new()
	badge_label.text = grade
	badge_label.add_theme_font_size_override("font_size", 10)
	badge_label.add_theme_color_override("font_color", UITheme.get_grade_color(grade))
	badge.add_child(badge_label)

	# Code + country
	var code_label = Label.new()
	code_label.text = "%s | %s" % [airline.airline_code, airline.country]
	code_label.add_theme_font_size_override("font_size", 11)
	code_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	vbox.add_child(code_label)

	# Color swatch (airline branding)
	var swatch_row = HBoxContainer.new()
	swatch_row.add_theme_constant_override("separation", 4)
	vbox.add_child(swatch_row)

	for color in [airline.primary_color, airline.secondary_color, airline.accent_color]:
		var swatch = ColorRect.new()
		swatch.color = color
		swatch.custom_minimum_size = Vector2(20, 8)
		swatch_row.add_child(swatch)

	# Stats row
	var stats_row = HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 16)
	vbox.add_child(stats_row)

	var fleet_label = Label.new()
	fleet_label.text = "%s %d aircraft" % [UITheme.ICON_PLANE, airline.aircraft.size()]
	fleet_label.add_theme_font_size_override("font_size", 12)
	fleet_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	stats_row.add_child(fleet_label)

	var routes_label = Label.new()
	routes_label.text = "%s %d routes" % [UITheme.ICON_ARROW_RIGHT, airline.routes.size()]
	routes_label.add_theme_font_size_override("font_size", 12)
	routes_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	stats_row.add_child(routes_label)

	# Reputation bar
	var rep_row = HBoxContainer.new()
	rep_row.add_theme_constant_override("separation", 8)
	vbox.add_child(rep_row)

	var rep_label = Label.new()
	rep_label.text = "Rep"
	rep_label.custom_minimum_size.x = 30
	rep_label.add_theme_font_size_override("font_size", 11)
	rep_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	rep_row.add_child(rep_label)

	var rep_bar_bg = Panel.new()
	rep_bar_bg.custom_minimum_size = Vector2(0, 8)
	rep_bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rep_bg_style = StyleBoxFlat.new()
	rep_bg_style.bg_color = UITheme.get_panel_border()
	rep_bg_style.set_corner_radius_all(4)
	rep_bar_bg.add_theme_stylebox_override("panel", rep_bg_style)
	rep_row.add_child(rep_bar_bg)

	var rep_fill = ColorRect.new()
	rep_fill.color = UITheme.HUB_COLOR
	rep_fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	rep_fill.anchor_right = clamp(airline.reputation / 200.0, 0.0, 1.0)
	rep_fill.offset_right = 0
	rep_bar_bg.add_child(rep_fill)

	var rep_value = Label.new()
	rep_value.text = "%.0f" % airline.reputation
	rep_value.custom_minimum_size.x = 30
	rep_value.add_theme_font_size_override("font_size", 11)
	rep_value.add_theme_color_override("font_color", UITheme.HUB_COLOR)
	rep_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rep_row.add_child(rep_value)

	return card

# ============================================================================
# OPPORTUNITY CARD
# ============================================================================

func _create_opportunity_card(opp: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = UITheme.get_card_bg()
	card_style.set_corner_radius_all(12)
	card_style.set_content_margin_all(14)
	card_style.border_color = UITheme.get_panel_border()
	card_style.set_border_width_all(1)

	# Color left border by saturation
	var saturation_color = _get_saturation_color(opp.get("market_saturation", 0.0))
	card_style.border_color = saturation_color
	card_style.border_width_left = 4
	card.add_theme_stylebox_override("panel", card_style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	card.add_child(hbox)

	# Route name
	var from_airport: Airport = opp.get("from_airport")
	var to_airport: Airport = opp.get("to_airport")
	var route_name = "%s %s %s" % [
		from_airport.iata_code if from_airport else "???",
		UITheme.ICON_ARROW_RIGHT,
		to_airport.iata_code if to_airport else "???"
	]

	var name_vbox = VBoxContainer.new()
	name_vbox.custom_minimum_size.x = 120
	name_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(name_vbox)

	var name_label = Label.new()
	name_label.text = route_name
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	name_vbox.add_child(name_label)

	var distance_label = Label.new()
	distance_label.text = "%.0f km" % opp.get("distance_km", 0.0)
	distance_label.add_theme_font_size_override("font_size", 11)
	distance_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	name_vbox.add_child(distance_label)

	# Demand bar
	var demand_vbox = VBoxContainer.new()
	demand_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	demand_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(demand_vbox)

	var demand_header = Label.new()
	demand_header.text = "Demand: %.0f pax/wk" % opp.get("demand", 0.0)
	demand_header.add_theme_font_size_override("font_size", 11)
	demand_header.add_theme_color_override("font_color", UITheme.get_text_muted())
	demand_vbox.add_child(demand_header)

	var demand_bar_bg = Panel.new()
	demand_bar_bg.custom_minimum_size = Vector2(0, 10)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = UITheme.get_panel_border()
	bg_style.set_corner_radius_all(5)
	demand_bar_bg.add_theme_stylebox_override("panel", bg_style)
	demand_vbox.add_child(demand_bar_bg)

	var saturation = opp.get("market_saturation", 0.0)
	var demand_fill = ColorRect.new()
	demand_fill.color = _get_saturation_color(saturation)
	demand_fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	demand_fill.anchor_right = clamp(saturation, 0.0, 1.0)
	demand_fill.offset_right = 0
	demand_bar_bg.add_child(demand_fill)

	# Gap
	var gap_label = Label.new()
	gap_label.text = "Gap: %.0f" % opp.get("gap", 0.0)
	gap_label.custom_minimum_size.x = 80
	gap_label.add_theme_font_size_override("font_size", 12)
	gap_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	hbox.add_child(gap_label)

	# Competition
	var comp_count: int = opp.get("competition", 0)
	var comp_label = Label.new()
	comp_label.text = "%d comp." % comp_count
	comp_label.custom_minimum_size.x = 60
	comp_label.add_theme_font_size_override("font_size", 12)
	comp_label.add_theme_color_override("font_color", UITheme.WARNING_COLOR if comp_count > 2 else UITheme.get_text_secondary())
	hbox.add_child(comp_label)

	# Score badge
	var score: float = opp.get("profitability_score", 0.0)
	var score_badge = PanelContainer.new()
	var score_color = UITheme.PROFIT_COLOR if score >= 70 else (UITheme.WARNING_COLOR if score >= 40 else UITheme.LOSS_COLOR)
	var score_style = UITheme.create_badge_style(score_color)
	score_badge.add_theme_stylebox_override("panel", score_style)

	var score_label = Label.new()
	score_label.text = "%.0f" % score
	score_label.add_theme_font_size_override("font_size", 12)
	score_label.add_theme_color_override("font_color", score_color)
	score_badge.add_child(score_label)
	hbox.add_child(score_badge)

	return card

# ============================================================================
# HELPERS
# ============================================================================

func _get_saturation_color(saturation: float) -> Color:
	if saturation > 0.8:
		return UITheme.LOSS_COLOR  # Red - saturated
	elif saturation > 0.5:
		return UITheme.WARNING_COLOR  # Yellow - medium
	else:
		return UITheme.PROFIT_COLOR  # Green - opportunity

# ============================================================================
# REFRESH
# ============================================================================

func refresh() -> void:
	if not GameData.player_airline:
		return

	_update_kpis()
	_update_competitors()
	_update_opportunities()
	_update_hub_network()

func _update_kpis() -> void:
	var player = GameData.player_airline
	var total_routes_all: int = 0
	var competitor_count: int = 0

	for airline in GameData.airlines:
		total_routes_all += airline.routes.size()
		if airline.id != player.id:
			competitor_count += 1

	var player_routes = player.routes.size()
	var share = (float(player_routes) / total_routes_all * 100) if total_routes_all > 0 else 0.0

	if kpi_routes_value:
		kpi_routes_value.text = str(player_routes)
		kpi_routes_value.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)

	if kpi_competitors_value:
		kpi_competitors_value.text = str(competitor_count)
		kpi_competitors_value.add_theme_color_override("font_color", UITheme.get_text_primary())

	if kpi_share_value:
		kpi_share_value.text = "%.1f%%" % share
		kpi_share_value.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)

	# Best opportunity
	if kpi_opportunity_value and not player.hubs.is_empty():
		var airports_array: Array[Airport] = []
		for iata in GameData.airports:
			airports_array.append(GameData.airports[iata])

		var airlines_array: Array[Airline] = []
		for airline in GameData.airlines:
			airlines_array.append(airline)

		var opportunities = MarketAnalysis.find_best_opportunities(player.hubs[0], airports_array, airlines_array, 1)
		if not opportunities.is_empty():
			var best = opportunities[0]
			var to_airport: Airport = best.get("to_airport")
			kpi_opportunity_value.text = to_airport.iata_code if to_airport else "—"
			kpi_opportunity_value.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		else:
			kpi_opportunity_value.text = "—"

func _update_competitors() -> void:
	if not competitor_cards_container:
		return

	for child in competitor_cards_container.get_children():
		child.queue_free()

	var has_competitors = false
	for airline in GameData.airlines:
		if airline.id == GameData.player_airline.id:
			continue
		has_competitors = true
		var card = _create_competitor_card(airline)
		competitor_cards_container.add_child(card)

	if not has_competitors:
		var empty = Label.new()
		empty.text = "No competitor airlines"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", UITheme.get_text_muted())
		competitor_cards_container.add_child(empty)

func _update_opportunities() -> void:
	if not opportunity_cards_container:
		return

	for child in opportunity_cards_container.get_children():
		child.queue_free()

	var player = GameData.player_airline
	if player.hubs.is_empty():
		var empty = Label.new()
		empty.text = "Purchase a hub airport to see expansion opportunities"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", UITheme.get_text_muted())
		opportunity_cards_container.add_child(empty)
		return

	# Get opportunities from all hubs
	var all_opportunities: Array[Dictionary] = []

	var airports_array: Array[Airport] = []
	for iata in GameData.airports:
		airports_array.append(GameData.airports[iata])

	var airlines_array: Array[Airline] = []
	for airline in GameData.airlines:
		airlines_array.append(airline)

	for hub in player.hubs:
		var hub_opps = MarketAnalysis.find_best_opportunities(hub, airports_array, airlines_array, 3)
		for opp in hub_opps:
			all_opportunities.append(opp)

	# Sort all by profitability score and take top 5
	all_opportunities.sort_custom(func(a, b): return a.profitability_score > b.profitability_score)
	var top_count = min(all_opportunities.size(), 5)

	if top_count == 0:
		var empty = Label.new()
		empty.text = "No expansion opportunities found"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", UITheme.get_text_muted())
		opportunity_cards_container.add_child(empty)
		return

	for i in range(top_count):
		var card = _create_opportunity_card(all_opportunities[i])
		opportunity_cards_container.add_child(card)

func _update_hub_network() -> void:
	if not hub_network_container:
		return

	for child in hub_network_container.get_children():
		child.queue_free()

	var player = GameData.player_airline
	if player.hubs.is_empty():
		var empty = Label.new()
		empty.text = "No hubs to analyze"
		empty.add_theme_font_size_override("font_size", 13)
		empty.add_theme_color_override("font_color", UITheme.get_text_muted())
		hub_network_container.add_child(empty)
		return

	for hub in player.hubs:
		var analysis = MarketAnalysis.analyze_hub_network_effects(player, hub)

		# Hub header card
		var hub_card = PanelContainer.new()
		var hub_style = StyleBoxFlat.new()
		hub_style.bg_color = UITheme.get_card_bg()
		hub_style.set_corner_radius_all(10)
		hub_style.set_content_margin_all(14)
		hub_style.border_color = UITheme.HUB_COLOR
		hub_style.border_width_left = 4
		hub_card.add_theme_stylebox_override("panel", hub_style)
		hub_network_container.add_child(hub_card)

		var hub_vbox = VBoxContainer.new()
		hub_vbox.add_theme_constant_override("separation", 6)
		hub_card.add_child(hub_vbox)

		# Hub name
		var hub_name = Label.new()
		hub_name.text = "%s - %s" % [hub.iata_code, hub.name if "name" in hub else hub.iata_code]
		hub_name.add_theme_font_size_override("font_size", 14)
		hub_name.add_theme_color_override("font_color", UITheme.HUB_COLOR)
		hub_vbox.add_child(hub_name)

		# Hub stats row
		var stats_row = HBoxContainer.new()
		stats_row.add_theme_constant_override("separation", 20)
		hub_vbox.add_child(stats_row)

		var stat_items = [
			"Inbound: %d" % analysis.get("inbound_routes", 0),
			"Outbound: %d" % analysis.get("outbound_routes", 0),
			"Connections: %d" % analysis.get("potential_connections", 0),
			"High Quality: %d" % analysis.get("high_quality_connections", 0),
			"Est. Connecting Pax: %.0f/wk" % analysis.get("estimated_connecting_pax", 0.0),
		]

		for stat_text in stat_items:
			var stat = Label.new()
			stat.text = stat_text
			stat.add_theme_font_size_override("font_size", 12)
			stat.add_theme_color_override("font_color", UITheme.get_text_secondary())
			stats_row.add_child(stat)
