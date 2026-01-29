extends Control

## Main game UI controller - Dashboard layout integration
## Bridges DashboardUI, WorldMap, and SimulationEngine

@onready var simulation_engine: Node = $SimulationEngine
@onready var dashboard_ui: DashboardUI = $DashboardUI
@onready var world_map: Control = $WorldMap

# Content panels for different tabs
var fleet_panel: Control = null
var routes_panel: Control = null
var finances_panel: Control = null
var market_panel: Control = null
var delegates_panel: Control = null
var country_relations_panel: Control = null

# Dialog references
var route_config_dialog: RouteConfigDialog = null
var route_opportunity_dialog: RouteOpportunityDialog = null
var hub_purchase_dialog: HubPurchaseDialog = null
var aircraft_purchase_dialog: AircraftPurchaseDialog = null
var aircraft_details_dialog: AircraftDetailsDialog = null  # N.2: Aircraft performance history
var passenger_flow_panel: PassengerFlowPanel = null  # Shows passenger flows from connected airports
var delegate_assignment_dialog: DelegateAssignmentDialog = null
var loan_dialog: LoanDialog = null
var audio_settings_panel: AudioSettingsPanel = null

# Pending route creation tracking (for buy aircraft flow)
var pending_route_from: Airport = null
var pending_route_to: Airport = null

# First route suggestion tracking
var first_route_suggestion_shown: bool = false
var first_route_celebration_shown: bool = false

# Feedback system (H.3-H.5)
var feedback_manager: FeedbackManager = null

# Tutorial system
var tutorial_overlay_layer: CanvasLayer = null
var tutorial_panel: Panel = null
var tutorial_title: Label = null
var tutorial_message: RichTextLabel = null
var tutorial_progress: Label = null
var tutorial_skip_button: Button = null
var tutorial_continue_button: Button = null
var tutorial_skip_dialog: ConfirmationDialog = null

func _ready() -> void:
	print("GameUI: _ready() called")

	# Wait for game data initialization
	if not GameData.player_airline or GameData.aircraft_models.is_empty():
		print("GameUI: Waiting for GameData initialization...")
		await GameData.game_initialized
		print("GameUI: GameData initialized!")

	# Setup simulation engine first
	setup_simulation_engine()
	
	# Create feedback manager (H.3-H.5: Daily/weekly summaries, price change notifications)
	setup_feedback_manager()

	# Create tutorial overlay early (before any awaits) to catch signals
	create_tutorial_overlay()

	# Create dialogs
	create_dialogs()

	# Connect signals
	connect_signals()

	# Setup dashboard UI (has await for deferred layout)
	setup_dashboard()

	# Setup world map
	setup_world_map()

	# Initial UI update
	update_all()
	
	# Check for first route suggestion after a short delay
	await get_tree().create_timer(1.0).timeout
	check_first_route_suggestion()
	
	# Set ambient audio to map view (art-bible 4.2)
	if AmbientAudioManager:
		AmbientAudioManager.set_scene(AmbientAudioManager.Scene.MAP)

	print("GameUI: _ready() complete!")

func setup_simulation_engine() -> void:
	"""Configure simulation engine"""
	if simulation_engine:
		GameData.simulation_engine = simulation_engine
		simulation_engine.week_completed.connect(_on_week_completed)
		simulation_engine.route_simulated.connect(_on_route_simulated)
		simulation_engine.simulation_started.connect(_on_simulation_started)
		simulation_engine.simulation_paused.connect(_on_simulation_paused)
		simulation_engine.speed_changed.connect(_on_speed_changed)


func setup_feedback_manager() -> void:
	"""Create and configure feedback manager (H.3-H.5)"""
	feedback_manager = FeedbackManager.new()
	feedback_manager.name = "FeedbackManager"
	add_child(feedback_manager)
	
	# Pass simulation engine reference
	if simulation_engine:
		feedback_manager.set_simulation_engine(simulation_engine)
	
	print("GameUI: FeedbackManager created")


func setup_dashboard() -> void:
	"""Configure dashboard UI and embed content"""
	if not dashboard_ui:
		push_error("DashboardUI not found!")
		return

	# Connect dashboard to simulation engine (also sets TimeSpeedPanel engine)
	dashboard_ui.set_simulation_engine(simulation_engine)

	# Connect tab change signal
	dashboard_ui.tab_changed.connect(_on_tab_changed)

	# Connect bottom bar button signals
	dashboard_ui.purchase_hub_pressed.connect(_on_purchase_hub_button_pressed)
	dashboard_ui.buy_aircraft_pressed.connect(_on_buy_aircraft_button_pressed)
	dashboard_ui.create_route_pressed.connect(_on_create_route_button_pressed)
	dashboard_ui.settings_pressed.connect(_on_settings_button_pressed)

	# Get main content area - wait a frame for deferred layout creation
	await get_tree().process_frame

	var main_content = dashboard_ui.get_main_content()
	if not main_content:
		push_error("DashboardUI main content not found!")
		return

	# Reparent WorldMap into main content
	if world_map:
		world_map.visible = true
		world_map.get_parent().remove_child(world_map)
		main_content.add_child(world_map)
		world_map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		print("WorldMap embedded into dashboard main content")

	# Create other content panels (hidden by default)
	create_content_panels(main_content)

func setup_world_map() -> void:
	"""Configure world map signals"""
	if world_map:
		world_map.airport_clicked.connect(_on_airport_clicked)
		world_map.airport_hovered.connect(_on_airport_hovered)
		world_map.route_created.connect(_on_route_created)
		world_map.route_clicked.connect(_on_route_clicked)
	
	# Add performance profiler in debug builds (F3 to toggle)
	if OS.is_debug_build():
		var ProfilerScript = load("res://scripts/debug/PerformanceProfiler.gd")
		if ProfilerScript:
			var profiler = ProfilerScript.new()
			add_child(profiler)

func create_content_panels(parent: Control) -> void:
	"""Create content panels for non-map tabs"""

	# Fleet Panel
	fleet_panel = create_fleet_panel()
	fleet_panel.visible = false
	parent.add_child(fleet_panel)

	# Routes Panel
	routes_panel = create_routes_panel()
	routes_panel.visible = false
	parent.add_child(routes_panel)

	# Finances Panel
	finances_panel = create_finances_panel()
	finances_panel.visible = false
	parent.add_child(finances_panel)

	# Market Panel
	market_panel = create_market_panel()
	market_panel.visible = false
	parent.add_child(market_panel)

	# Delegates Panel
	delegates_panel = create_delegates_panel()
	delegates_panel.visible = false
	parent.add_child(delegates_panel)

	# Country Relations Panel
	country_relations_panel = create_country_relations_panel()
	country_relations_panel.visible = false
	parent.add_child(country_relations_panel)

func create_fleet_panel() -> Control:
	"""Create fleet management panel using FleetManagementPanel"""
	var panel = FleetManagementPanel.new()
	panel.name = "FleetPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Connect purchase button to aircraft dialog
	panel.purchase_aircraft_pressed.connect(_on_buy_aircraft_button_pressed)
	
	# Connect aircraft selection to details dialog (N.2)
	panel.aircraft_selected.connect(_on_aircraft_selected)

	return panel

func create_routes_panel() -> Control:
	"""Create routes management panel with hub demand insights (O.1)"""
	var panel = PanelContainer.new()
	panel.name = "RoutesPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style = UITheme.create_panel_style()
	style.bg_color = UITheme.BG_MAIN
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	
	# Use horizontal split for routes list and demand panel
	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.add_theme_constant_override("separation", 24)
	margin.add_child(hbox)
	
	# Left side: Active routes list
	var left_vbox = VBoxContainer.new()
	left_vbox.name = "RoutesVBox"
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_theme_constant_override("separation", 12)
	hbox.add_child(left_vbox)

	# Title
	var title = Label.new()
	title.text = "Route Network"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	left_vbox.add_child(title)
	
	# Subtitle with route count
	var subtitle = Label.new()
	subtitle.name = "RoutesSubtitle"
	subtitle.text = "Click a route to edit settings"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	left_vbox.add_child(subtitle)
	
	# Empty state message (hidden when routes exist)
	var empty_message = Label.new()
	empty_message.name = "RoutesEmptyMessage"
	empty_message.text = "No routes created yet.\n\nClick on your hub airport on the map,\nthen select a destination to create a route."
	empty_message.add_theme_font_size_override("font_size", 13)
	empty_message.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	empty_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_vbox.add_child(empty_message)
	
	# Scrollable routes container
	var routes_scroll = ScrollContainer.new()
	routes_scroll.name = "RoutesScrollContainer"
	routes_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	routes_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left_vbox.add_child(routes_scroll)
	
	var routes_list = VBoxContainer.new()
	routes_list.name = "RoutesList"
	routes_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes_list.add_theme_constant_override("separation", 10)
	routes_scroll.add_child(routes_list)
	
	# Right side: Insights column (O.1, O.2)
	var right_vbox = VBoxContainer.new()
	right_vbox.name = "InsightsVBox"
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.custom_minimum_size = Vector2(340, 0)
	right_vbox.add_theme_constant_override("separation", 16)
	hbox.add_child(right_vbox)
	
	# Hub demand panel (O.1)
	var hub_demand_panel = HubDemandPanel.new()
	hub_demand_panel.name = "HubDemandPanel"
	hub_demand_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hub_demand_panel.destination_selected.connect(_on_hub_demand_destination_selected)
	right_vbox.add_child(hub_demand_panel)
	
	# Pain points panel (O.2)
	var pain_points_panel = PainPointsPanel.new()
	pain_points_panel.name = "PainPointsPanel"
	pain_points_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pain_points_panel.action_requested.connect(_on_pain_point_action_requested)
	pain_points_panel.route_edit_requested.connect(_on_pain_point_route_edit)
	right_vbox.add_child(pain_points_panel)

	return panel

func create_finances_panel() -> Control:
	"""Create finances panel using FinancesPanel"""
	var panel = FinancesPanel.new()
	panel.name = "FinancesPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Connect signals
	panel.loan_requested.connect(_on_loan_requested)
	panel.loan_payoff_requested.connect(_on_loan_payoff_requested)
	
	return panel

func create_market_panel() -> Control:
	"""Create market panel using MarketPanel"""
	var panel = MarketPanel.new()
	panel.name = "MarketPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Connect signals
	panel.route_opportunity_selected.connect(_on_market_opportunity_selected)
	
	return panel

func create_delegates_panel() -> Control:
	"""Create delegates management panel"""
	var panel = DelegatesPanel.new()
	panel.name = "DelegatesPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Connect signals
	panel.delegate_assignment_requested.connect(_on_delegate_assignment_requested)
	panel.task_cancelled.connect(_on_task_cancelled)

	return panel

func create_country_relations_panel() -> Control:
	"""Create country relations panel"""
	var panel = CountryRelationsPanel.new()
	panel.name = "CountryRelationsPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Connect signals
	panel.relationship_details_requested.connect(_on_relationship_details_requested)

	return panel

func create_dialogs() -> void:
	"""Create all dialog windows"""
	# Route configuration dialog
	route_config_dialog = RouteConfigDialog.new()
	add_child(route_config_dialog)
	route_config_dialog.route_configured.connect(_on_route_configured)
	route_config_dialog.buy_aircraft_requested.connect(_on_route_dialog_buy_aircraft)

	# Route opportunity dialog
	route_opportunity_dialog = RouteOpportunityDialog.new()
	add_child(route_opportunity_dialog)
	route_opportunity_dialog.route_selected.connect(_on_route_opportunity_selected)

	# Hub purchase dialog
	hub_purchase_dialog = HubPurchaseDialog.new()
	add_child(hub_purchase_dialog)
	hub_purchase_dialog.hub_purchased.connect(_on_hub_purchased)

	# Aircraft purchase dialog
	aircraft_purchase_dialog = AircraftPurchaseDialog.new()
	add_child(aircraft_purchase_dialog)
	aircraft_purchase_dialog.aircraft_purchased.connect(_on_aircraft_dialog_purchased)

	# Aircraft details dialog (N.2: performance history)
	aircraft_details_dialog = AircraftDetailsDialog.new()
	add_child(aircraft_details_dialog)
	aircraft_details_dialog.hide()  # Ensure hidden on startup
	
	# Passenger flow panel (shows flows from connected airports)
	passenger_flow_panel = PassengerFlowPanel.new()
	add_child(passenger_flow_panel)
	passenger_flow_panel.hide()
	passenger_flow_panel.connection_route_requested.connect(_on_passenger_flow_route_requested)

	# Delegate assignment dialog
	delegate_assignment_dialog = DelegateAssignmentDialog.new()
	add_child(delegate_assignment_dialog)
	delegate_assignment_dialog.delegate_assigned.connect(_on_delegate_assigned)

	# Loan dialog
	loan_dialog = LoanDialog.new()
	add_child(loan_dialog)
	loan_dialog.loan_created.connect(_on_loan_dialog_created)
	
	# Audio settings panel
	audio_settings_panel = AudioSettingsPanel.new()
	audio_settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	add_child(audio_settings_panel)

	print("Dialogs created")

func connect_signals() -> void:
	"""Connect all game signals"""
	# Connect GameData signals
	if GameData:
		GameData.first_route_created.connect(_on_first_route_created)
		if GameData.player_airline:
			GameData.player_airline.balance_changed.connect(_on_balance_changed)
			GameData.player_airline.route_added.connect(_on_route_added)

		GameData.aircraft_purchased.connect(_on_aircraft_purchased)
		GameData.loan_created.connect(_on_loan_created)

func _on_tab_changed(tab_name: String) -> void:
	"""Handle tab navigation"""
	print("Tab changed to: ", tab_name)

	# Hide all content panels
	if world_map:
		world_map.visible = false
	if fleet_panel:
		fleet_panel.visible = false
	if routes_panel:
		routes_panel.visible = false
	if finances_panel:
		finances_panel.visible = false
	if market_panel:
		market_panel.visible = false
	if delegates_panel:
		delegates_panel.visible = false
	if country_relations_panel:
		country_relations_panel.visible = false

	# Show selected panel
	match tab_name:
		"map":
			if world_map:
				world_map.visible = true
		"fleet":
			if fleet_panel:
				fleet_panel.visible = true
				update_fleet_panel()
		"routes":
			if routes_panel:
				routes_panel.visible = true
				update_routes_panel()
		"finances":
			if finances_panel:
				finances_panel.visible = true
				update_finances_panel()
		"market":
			if market_panel:
				market_panel.visible = true
				update_market_panel()
		"delegates":
			if delegates_panel:
				delegates_panel.visible = true
				if delegates_panel.has_method("update_delegates_info"):
					delegates_panel.update_delegates_info()
		"diplomacy", "relations":
			if country_relations_panel:
				country_relations_panel.visible = true
				if country_relations_panel.has_method("load_countries"):
					country_relations_panel.load_countries()

func update_all() -> void:
	"""Update all UI elements"""
	if dashboard_ui:
		dashboard_ui.update_stats()
	
	# Refresh panels with simulation-dependent data
	update_routes_panel()
	update_fleet_panel()
	update_finances_panel()
	update_market_panel()

func update_fleet_panel() -> void:
	"""Update fleet panel content"""
	if not fleet_panel or not GameData.player_airline:
		return

	# FleetManagementPanel has its own refresh method
	if fleet_panel is FleetManagementPanel:
		fleet_panel.refresh()

func update_routes_panel() -> void:
	"""Update routes panel content with clickable route cards"""
	if not routes_panel or not GameData.player_airline:
		return
	
	var routes = GameData.player_airline.routes
	
	# Update subtitle
	var subtitle = routes_panel.get_node_or_null("MarginContainer/HBoxContainer/RoutesVBox/RoutesSubtitle")
	if subtitle:
		if routes.is_empty():
			subtitle.text = "No active routes"
		else:
			subtitle.text = "%d active routes • Click to edit" % routes.size()
	
	# Toggle empty message visibility
	var empty_message = routes_panel.get_node_or_null("MarginContainer/HBoxContainer/RoutesVBox/RoutesEmptyMessage")
	var routes_scroll = routes_panel.get_node_or_null("MarginContainer/HBoxContainer/RoutesVBox/RoutesScrollContainer")
	
	if empty_message:
		empty_message.visible = routes.is_empty()
	if routes_scroll:
		routes_scroll.visible = not routes.is_empty()
	
	# Update routes list
	var routes_list = routes_panel.get_node_or_null("MarginContainer/HBoxContainer/RoutesVBox/RoutesScrollContainer/RoutesList")
	if routes_list:
		# Clear existing cards
		for child in routes_list.get_children():
			child.queue_free()
		
		# Create clickable card for each route
		for route in routes:
			var card = _create_route_card(route)
			routes_list.add_child(card)
	
	# Refresh hub demand panel (O.1)
	var hub_demand_panel = routes_panel.get_node_or_null("MarginContainer/HBoxContainer/InsightsVBox/HubDemandPanel")
	if hub_demand_panel and hub_demand_panel is HubDemandPanel:
		hub_demand_panel.refresh()
	
	# Refresh pain points panel (O.2)
	var pain_points_panel = routes_panel.get_node_or_null("MarginContainer/HBoxContainer/InsightsVBox/PainPointsPanel")
	if pain_points_panel and pain_points_panel is PainPointsPanel:
		pain_points_panel.refresh()


func _create_route_card(route: Route) -> Control:
	"""Create a clickable card for a route"""
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 70)
	card.set_meta("route_id", route.id)
	
	# Card style
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = UITheme.get_card_bg()
	card_style.set_corner_radius_all(10)
	card_style.set_content_margin_all(12)
	card_style.border_color = UITheme.get_panel_border()
	card_style.set_border_width_all(1)
	card.add_theme_stylebox_override("panel", card_style)
	
	# Hover style
	var hover_style = card_style.duplicate()
	hover_style.border_color = UITheme.PRIMARY_BLUE
	hover_style.set_border_width_all(2)
	
	# Make clickable
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.tooltip_text = "Click to edit route settings"
	
	card.mouse_entered.connect(func():
		card.add_theme_stylebox_override("panel", hover_style)
	)
	card.mouse_exited.connect(func():
		card.add_theme_stylebox_override("panel", card_style)
	)
	card.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_route_card_clicked(route)
	)
	
	# Content
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	card.add_child(hbox)
	
	# Route info (left)
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)
	
	# Route name
	var name_label = Label.new()
	name_label.text = route.get_display_name()
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(name_label)
	
	# Route stats
	var stats_hbox = HBoxContainer.new()
	stats_hbox.add_theme_constant_override("separation", 16)
	info_vbox.add_child(stats_hbox)
	
	var freq_label = Label.new()
	freq_label.text = "📅 %d/wk" % route.frequency
	freq_label.add_theme_font_size_override("font_size", 12)
	freq_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	stats_hbox.add_child(freq_label)
	
	var pax_label = Label.new()
	# Show local + connecting breakdown if connecting passengers exist
	if route.connecting_passengers > 0:
		pax_label.text = "👥 %d pax (%d+%d)" % [
			route.passengers_transported, 
			route.local_passengers, 
			route.connecting_passengers
		]
		pax_label.tooltip_text = "Total: %d (Local: %d + Connecting: %d)" % [
			route.passengers_transported, route.local_passengers, route.connecting_passengers
		]
	else:
		pax_label.text = "👥 %d pax" % route.passengers_transported
	pax_label.add_theme_font_size_override("font_size", 12)
	pax_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	stats_hbox.add_child(pax_label)
	
	var aircraft_count = route.assigned_aircraft.size()
	var aircraft_label = Label.new()
	aircraft_label.text = "✈ %d aircraft" % aircraft_count
	aircraft_label.add_theme_font_size_override("font_size", 12)
	aircraft_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	stats_hbox.add_child(aircraft_label)
	
	# Profit indicator (right)
	var profit_vbox = VBoxContainer.new()
	profit_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(profit_vbox)
	
	var profit_label = Label.new()
	var profit_color = UITheme.PROFIT_COLOR if route.weekly_profit >= 0 else UITheme.LOSS_COLOR
	profit_label.text = UITheme.format_money(route.weekly_profit, true)
	profit_label.add_theme_font_size_override("font_size", 14)
	profit_label.add_theme_color_override("font_color", profit_color)
	profit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	profit_vbox.add_child(profit_label)
	
	var per_week_label = Label.new()
	per_week_label.text = "/week"
	per_week_label.add_theme_font_size_override("font_size", 10)
	per_week_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	per_week_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	profit_vbox.add_child(per_week_label)
	
	# Edit icon
	var edit_icon = Label.new()
	edit_icon.text = "✎"
	edit_icon.add_theme_font_size_override("font_size", 16)
	edit_icon.add_theme_color_override("font_color", UITheme.get_text_muted())
	hbox.add_child(edit_icon)
	
	return card


func _on_route_card_clicked(route: Route) -> void:
	"""Handle route card click - open edit dialog"""
	if route and route_config_dialog:
		route_config_dialog.setup_edit_route(route)
		route_config_dialog.popup_centered()
		print("Opening route editor for: %s" % route.get_display_name())

func update_finances_panel() -> void:
	"""Update finances panel content"""
	if not finances_panel or not GameData.player_airline:
		return

	# FinancesPanel has its own refresh method
	if finances_panel is FinancesPanel:
		finances_panel.refresh()

func update_market_panel() -> void:
	"""Update market panel content"""
	if not market_panel:
		return

	# MarketPanel has its own refresh method
	if market_panel is MarketPanel:
		market_panel.refresh()

# Event Handlers

func _on_airport_clicked(airport: Airport) -> void:
	"""Handle airport click"""
	if not GameData.player_airline:
		return
	
	# Check if clicking on a player hub
	if GameData.player_airline.has_hub(airport):
		if route_opportunity_dialog:
			route_opportunity_dialog.show_for_hub(airport)
		return
	
	# Check if clicking on an airport we're connected to (for passenger flow visualization)
	var connecting_hub = _get_connecting_hub_for_airport(airport)
	if connecting_hub and passenger_flow_panel:
		passenger_flow_panel.show_for_airport(airport, connecting_hub)
		print("Showing passenger flows from: %s (via hub %s)" % [airport.iata_code, connecting_hub.iata_code])
		return

	print("Airport clicked: %s" % airport.iata_code)

func _on_airport_hovered(airport: Airport) -> void:
	pass

func _on_route_created(from_airport: Airport, to_airport: Airport) -> void:
	"""Handle route creation request"""
	if not GameData.player_airline:
		return

	if not GameData.player_airline.can_create_route_from(from_airport, to_airport):
		print("Cannot create route: %s is not a hub" % from_airport.iata_code)
		return

	var available_aircraft: Array[AircraftInstance] = []
	for aircraft in GameData.player_airline.aircraft:
		if not aircraft.is_assigned:
			available_aircraft.append(aircraft)

	if available_aircraft.is_empty():
		print("Cannot create route: No available aircraft")
		return

	if route_config_dialog:
		route_config_dialog.setup_route(from_airport, to_airport)
		route_config_dialog.popup_centered()

func _on_route_clicked(route: Route) -> void:
	"""Handle route click on map"""
	if not route or not GameData.player_airline:
		return

	if route.airline_id != GameData.player_airline.id:
		return

	if route_config_dialog:
		route_config_dialog.setup_edit_route(route)
		route_config_dialog.popup_centered()

func _on_route_opportunity_selected(from_airport: Airport, to_airport: Airport) -> void:
	"""Handle route selection from opportunity dialog"""
	if route_config_dialog:
		route_config_dialog.setup_route(from_airport, to_airport)
		route_config_dialog.popup_centered()

func _on_route_configured(config: Dictionary) -> void:
	"""Handle route configuration from dialog"""
	var from: Airport = config.get("from_airport")
	var to: Airport = config.get("to_airport")
	var aircraft: AircraftInstance = config.get("aircraft")
	var frequency: int = config.get("frequency", 7)
	var price_economy: float = config.get("price_economy", 100)
	var price_business: float = config.get("price_business", 200)
	var price_first: float = config.get("price_first", 500)
	var editing_route: Route = config.get("editing_route", null)

	if not from or not to or not aircraft:
		print("Error: Invalid route configuration")
		return

	var route: Route = null

	if editing_route:
		route = editing_route
		route.frequency = frequency
		
		# G.6: Price changes use pending system (take effect next day)
		# This creates clear cause-effect visibility for the player
		route.set_pending_prices(price_economy, price_business, price_first)

		# Update aircraft if changed
		var current_aircraft = route.assigned_aircraft[0] if not route.assigned_aircraft.is_empty() else null
		if aircraft != current_aircraft:
			for old_aircraft in route.assigned_aircraft:
				old_aircraft.is_assigned = false
			route.assigned_aircraft.clear()
			aircraft.is_assigned = true
			route.assigned_aircraft.append(aircraft)

		route.service_quality = GameData.player_airline.service_quality
		route.aircraft_condition = aircraft.condition
	else:
		route = GameData.create_route_for_airline(GameData.player_airline, from, to, aircraft)
		if not route:
			print("Failed to create route")
			return

		route.frequency = frequency
		# New routes: prices apply immediately (no pending delay for initial setup)
		route.price_economy = price_economy
		route.price_business = price_business
		route.price_first = price_first
		route.service_quality = GameData.player_airline.service_quality
		route.aircraft_condition = aircraft.condition

	if world_map:
		world_map.refresh_routes()

	update_all()

func _on_hub_purchased(airport: Airport) -> void:
	"""Handle hub purchase"""
	print("Hub purchased at %s" % airport.iata_code)
	if world_map:
		world_map.queue_redraw()
	update_all()

func _on_purchase_hub_button_pressed() -> void:
	"""Handle Purchase Hub button press from bottom bar"""
	print("Purchase Hub button pressed")
	if hub_purchase_dialog:
		hub_purchase_dialog.show_dialog()

func _on_buy_aircraft_button_pressed() -> void:
	"""Handle Buy Aircraft button press from bottom bar"""
	print("Buy Aircraft button pressed")
	if aircraft_purchase_dialog:
		aircraft_purchase_dialog.show_dialog()

func _on_aircraft_dialog_purchased(aircraft: AircraftInstance) -> void:
	"""Handle aircraft purchased from dialog"""
	print("Aircraft purchased from dialog: %s" % aircraft.model.get_display_name())
	update_all()
	
	# Check if we have a pending route creation to resume
	if pending_route_from and pending_route_to and route_config_dialog:
		# Small delay to let UI update
		await get_tree().create_timer(0.3).timeout
		_resume_route_creation_with_aircraft(aircraft)


func _on_route_dialog_buy_aircraft() -> void:
	"""Handle buy aircraft button pressed from route config dialog"""
	# Store the pending route info from the dialog
	if route_config_dialog:
		pending_route_from = route_config_dialog.from_airport
		pending_route_to = route_config_dialog.to_airport
		print("Storing pending route: %s → %s" % [
			pending_route_from.iata_code if pending_route_from else "null",
			pending_route_to.iata_code if pending_route_to else "null"
		])
	
	# Open aircraft purchase dialog
	if aircraft_purchase_dialog:
		aircraft_purchase_dialog.show_dialog()


func _resume_route_creation_with_aircraft(new_aircraft: AircraftInstance) -> void:
	"""Resume route creation flow after aircraft purchase"""
	if not pending_route_from or not pending_route_to:
		return
	
	print("Resuming route creation: %s → %s with new aircraft %s" % [
		pending_route_from.iata_code,
		pending_route_to.iata_code,
		new_aircraft.model.get_display_name()
	])
	
	# Reopen route config dialog
	route_config_dialog.setup_route(pending_route_from, pending_route_to)
	route_config_dialog.popup_centered()
	
	# Clear pending route
	pending_route_from = null
	pending_route_to = null


func _on_aircraft_selected(aircraft: AircraftInstance) -> void:
	"""Handle aircraft selection from fleet panel - show details dialog (N.2)"""
	if aircraft and aircraft_details_dialog:
		aircraft_details_dialog.show_aircraft(aircraft)


func _on_create_route_button_pressed() -> void:
	"""Handle Create Route button press from bottom bar"""
	print("Create Route button pressed")
	# Check if player has a hub to create routes from
	if not GameData.player_airline or GameData.player_airline.hubs.is_empty():
		print("Cannot create route: No hub airports")
		# Could show a message to the user here
		return

	# Show route opportunity dialog for the first hub
	var first_hub = GameData.player_airline.hubs[0]
	if route_opportunity_dialog:
		route_opportunity_dialog.show_for_hub(first_hub)


func _on_settings_button_pressed() -> void:
	"""Handle Settings button press from sidebar"""
	if audio_settings_panel:
		audio_settings_panel.show_panel()
		if UISoundManager:
			UISoundManager.play_click()

func _on_week_completed(week: int) -> void:
	"""Handle week simulation completion"""
	update_all()
	if world_map:
		world_map.refresh_routes()

func _on_route_simulated(route: Route, passengers: int, revenue: float) -> void:
	pass

func _on_simulation_started() -> void:
	pass

func _on_simulation_paused() -> void:
	pass

func _on_speed_changed(speed_level: int, _speed_name: String) -> void:
	pass

func _on_balance_changed(new_balance: float) -> void:
	update_all()

func _on_route_added(route: Route) -> void:
	update_all()

func _on_aircraft_purchased(aircraft: AircraftInstance, airline: Airline) -> void:
	"""Handle aircraft purchase - check for first route suggestion"""
	# Update UI
	update_all()
	
	# If this is player's first aircraft and they have a hub, suggest first route
	if airline == GameData.player_airline and airline.aircraft.size() == 1:
		if not airline.hubs.is_empty() and airline.routes.is_empty():
			# Wait a moment for UI to update, then suggest
			await get_tree().create_timer(0.5).timeout
			# Re-check conditions after delay (player might have created route)
			if airline.routes.is_empty() and not airline.aircraft.is_empty():
				check_first_route_suggestion()

func _on_loan_created(loan: Loan, airline: Airline) -> void:
	update_all()

# Utility Functions

func format_money(amount: float) -> String:
	var abs_amount: float = abs(amount)
	var sign: String = "-" if amount < 0 else ""

	if abs_amount >= 1000000000:
		return "%s%.2fB" % [sign, abs_amount / 1000000000.0]
	elif abs_amount >= 1000000:
		return "%s%.2fM" % [sign, abs_amount / 1000000.0]
	elif abs_amount >= 1000:
		return "%s%.2fK" % [sign, abs_amount / 1000.0]
	else:
		return "%s%.0f" % [sign, abs_amount]

# First Route Suggestion & Celebration

func check_first_route_suggestion() -> void:
	"""Check if player has aircraft and hub but no routes, then suggest first route"""
	if not GameData.player_airline:
		return
	
	# Prevent showing multiple suggestion dialogs
	if first_route_suggestion_shown:
		return
	
	# Only suggest if player has aircraft and hub but no routes
	if GameData.player_airline.aircraft.is_empty():
		return  # No aircraft yet
	
	if GameData.player_airline.hubs.is_empty():
		return  # No hub yet
	
	if GameData.player_airline.routes.size() > 0:
		return  # Already has routes
	
	# Find best first route opportunity
	var hub: Airport = GameData.player_airline.hubs[0]
	var opportunities: Array[Dictionary] = GameData.find_route_opportunities(hub, 3)
	
	if opportunities.is_empty():
		return
	
	# Get the best opportunity
	var best_opp: Dictionary = opportunities[0]
	var destination: Airport = best_opp.get("to_airport", null)
	if not destination:
		return  # Invalid opportunity data
	
	# Check if any aircraft can fly this route
	var distance: float = best_opp.get("distance_km", 0.0)
	if distance <= 0:
		return  # Invalid distance
	
	var can_fly: bool = false
	var compatible_aircraft: AircraftInstance = null
	for aircraft in GameData.player_airline.aircraft:
		if aircraft.model.can_fly_distance(distance) and not aircraft.is_assigned:
			can_fly = true
			compatible_aircraft = aircraft
			break
	
	if not can_fly:
		return  # No compatible aircraft
	
	# Mark as shown and display suggestion dialog
	first_route_suggestion_shown = true
	show_first_route_suggestion(hub, destination, best_opp, compatible_aircraft)

func show_first_route_suggestion(from: Airport, to: Airport, opportunity: Dictionary, aircraft: AircraftInstance) -> void:
	"""Show a dialog suggesting the player's first route"""
	var dialog = ConfirmationDialog.new()
	dialog.title = "Recommended First Route"
	
	var score: float = opportunity.get("profitability_score", 0)
	var demand: float = opportunity.get("demand", 0)
	var distance: float = opportunity.get("distance_km", 0)
	
	# Get estimated revenue (rough calculation)
	var pricing: Dictionary = GameData.get_recommended_pricing_for_route(from, to)
	if pricing.is_empty():
		pricing = {"economy": 100.0, "business": 250.0, "first": 500.0}  # Fallback pricing
	var estimated_weekly_revenue: float = demand * 0.7 * (pricing.get("economy", 100.0) * 0.7 + pricing.get("business", 250.0) * 0.25 + pricing.get("first", 500.0) * 0.05)
	
	# Use plain text (AcceptDialog doesn't support BBCode)
	var message: String = "Ready to launch your first route?\n\n"
	message += "%s → %s\n" % [from.iata_code, to.iata_code]
	message += "Distance: %.0f km\n\n" % distance
	message += "• Profitability Score: %.0f/100\n" % score
	message += "• Weekly Demand: %.0f passengers\n" % demand
	message += "• Estimated Revenue: €%s/week\n\n" % format_money(estimated_weekly_revenue)
	message += "This route is perfect for your %s!\n" % aircraft.model.get_display_name()
	message += "\nWould you like to create this route now?"
	
	dialog.dialog_text = message
	dialog.ok_button_text = "Create Route"
	dialog.get_cancel_button().text = "I'll choose myself"
	
	# Add to scene tree (use get_tree().root or add as child of this node)
	add_child(dialog)
	
	# Connect signals
	dialog.confirmed.connect(func():
		create_suggested_first_route(from, to, aircraft, pricing)
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	# Show dialog
	dialog.popup_centered()

func create_suggested_first_route(from: Airport, to: Airport, aircraft: AircraftInstance, pricing: Dictionary) -> void:
	"""Create the suggested first route with optimal settings"""
	var route: Route = GameData.create_route_for_airline(GameData.player_airline, from, to, aircraft)
	if route:
		# Set optimal frequency (daily for first route)
		route.frequency = 7
		print("Created suggested first route: %s" % route.get_display_name())

func _on_first_route_created(route: Route, airline: Airline) -> void:
	"""Celebrate when player creates their first route"""
	if airline != GameData.player_airline:
		return
	
	# Prevent showing multiple celebration dialogs
	if first_route_celebration_shown:
		return
	
	first_route_celebration_shown = true
	show_first_flight_celebration(route)

func show_first_flight_celebration(route: Route) -> void:
	"""Show celebration popup for first route"""
	var dialog = AcceptDialog.new()
	dialog.title = "🎉 First Flight!"
	
	# Calculate estimated weekly revenue
	var demand: float = MarketAnalysis.calculate_potential_demand(
		route.from_airport,
		route.to_airport,
		route.distance_km
	)
	var estimated_revenue: float = demand * 0.7 * (
		route.price_economy * 0.7 + 
		route.price_business * 0.25 + 
		route.price_first * 0.05
	)
	
	# Use plain text (AcceptDialog doesn't support BBCode)
	var message: String = "Congratulations!\n\n"
	message += "Your airline is now operational!\n\n"
	message += "%s → %s\n" % [route.from_airport.iata_code, route.to_airport.iata_code]
	message += "Distance: %.0f km\n" % route.distance_km
	message += "Frequency: %d flights/week\n\n" % route.frequency
	message += "Estimated Weekly Revenue: €%s\n\n" % format_money(estimated_revenue)
	message += "Start the simulation to see your first passengers fly!\n"
	message += "Your route will generate revenue each week."
	
	dialog.dialog_text = message
	dialog.ok_button_text = "Let's Fly!"
	
	# Add to scene tree (use get_tree().root or add as child of this node)
	add_child(dialog)
	
	# Connect signal
	dialog.confirmed.connect(func():
		dialog.queue_free()
	)
	
	# Show dialog
	dialog.popup_centered()

# Delegate System Handlers

func _on_delegate_assignment_requested(task_type: String, target: Dictionary) -> void:
	"""Handle delegate assignment request"""
	if delegate_assignment_dialog:
		delegate_assignment_dialog.show_for_task_type(task_type, target)

func _on_delegate_assigned(task_type: String, target_data: Dictionary) -> void:
	"""Handle delegate assignment confirmation"""
	if not GameData.player_airline:
		return
	
	# Get available delegate
	var available_delegates = GameData.player_airline.get_available_delegates()
	if available_delegates.is_empty():
		print("No available delegates")
		return
	
	var delegate = available_delegates[0]  # Use first available
	
	# Create task based on type
	var task: DelegateTask = null
	match task_type:
		"country":
			var country_code = target_data.get("code", "")
			if country_code.is_empty():
				return
			task = DelegateTask.new(
				GameData.next_delegate_task_id,
				GameData.player_airline.id,
				DelegateTask.TaskType.COUNTRY_RELATIONSHIP,
				4,  # 4 weeks duration
				GameData.current_week
			)
			task.target_country_code = country_code
			task.relationship_bonus = delegate.get_effectiveness() * 5.0  # 3-5 points
		
		"negotiation":
			var from_airport = target_data.get("from_airport", null)
			var to_airport = target_data.get("to_airport", null)
			if not from_airport or not to_airport:
				return
			task = DelegateTask.new(
				GameData.next_delegate_task_id,
				GameData.player_airline.id,
				DelegateTask.TaskType.ROUTE_NEGOTIATION,
				2,  # 2 weeks for negotiation
				GameData.current_week
			)
			task.target_route_from = from_airport.iata_code
			task.target_route_to = to_airport.iata_code
			task.difficulty_reduction = delegate.get_effectiveness() * 20.0  # 12-20 point reduction
		
		"campaign":
			var location = target_data.get("location", "")
			var cost = target_data.get("cost", 0.0)
			if location.is_empty():
				return
			task = DelegateTask.new(
				GameData.next_delegate_task_id,
				GameData.player_airline.id,
				DelegateTask.TaskType.CAMPAIGN,
				4,  # 4 weeks
				GameData.current_week
			)
			task.campaign_location = location
			task.campaign_cost = cost
			task.reputation_bonus = delegate.get_effectiveness() * 2.0  # 1.2-2.0 reputation
	
	if task:
		GameData.next_delegate_task_id += 1
		
		# Assign delegate to task
		if GameData.player_airline.assign_delegate_to_task(delegate, task):
			# Deduct campaign cost if applicable
			if task.task_type == DelegateTask.TaskType.CAMPAIGN:
				GameData.player_airline.deduct_balance(task.campaign_cost)
			
			print("Delegate assigned: %s to %s" % [delegate.name, task.get_task_type_string()])
			
			# Update delegates panel
			if delegates_panel and delegates_panel.has_method("update_delegates_info"):
				delegates_panel.update_delegates_info()

func _on_task_cancelled(task_id: int) -> void:
	"""Handle task cancellation"""
	if not GameData.player_airline:
		return
	
	# Find task by ID
	var task: DelegateTask = null
	for t in GameData.player_airline.delegate_tasks:
		if t.id == task_id:
			task = t
			break
	
	if task:
		if GameData.player_airline.cancel_delegate_task(task):
			print("Task cancelled: %d" % task_id)
			
			# Update delegates panel
			if delegates_panel and delegates_panel.has_method("update_delegates_info"):
				delegates_panel.update_delegates_info()

func _on_relationship_details_requested(country_code: String) -> void:
	"""Handle relationship details request"""
	print("Relationship details requested for: %s" % country_code)
	# TODO: Show detailed relationship dialog
	# For now, just print

# Finance Panel Handlers

func _on_loan_requested() -> void:
	"""Handle loan request from finances panel"""
	if loan_dialog and GameData.player_airline:
		loan_dialog.show_for_airline(GameData.player_airline)

func _on_loan_payoff_requested(loan: Loan) -> void:
	"""Handle loan payoff request"""
	if not GameData.player_airline:
		return
	
	var payoff_amount = loan.remaining_balance
	if GameData.player_airline.balance >= payoff_amount:
		# Confirm payoff
		var confirm_dialog = ConfirmationDialog.new()
		confirm_dialog.title = "Pay Off Loan"
		confirm_dialog.dialog_text = "Pay off this loan for %s?" % UITheme.format_money(payoff_amount)
		confirm_dialog.ok_button_text = "Pay Off"
		confirm_dialog.get_cancel_button().text = "Cancel"
		get_tree().root.add_child(confirm_dialog)
		confirm_dialog.confirmed.connect(func():
			GameData.player_airline.deduct_balance(payoff_amount)
			loan.pay_off_early()
			GameData.player_airline.update_debt_totals()
			print("Loan paid off: $%.0f" % payoff_amount)
			
			# Refresh finances panel
			if finances_panel is FinancesPanel:
				finances_panel.refresh()
			
			confirm_dialog.queue_free()
		)
		confirm_dialog.canceled.connect(func(): confirm_dialog.queue_free())
		confirm_dialog.popup_centered()
	else:
		# Show error
		var error_dialog = AcceptDialog.new()
		error_dialog.title = "Insufficient Funds"
		error_dialog.dialog_text = "You need %s to pay off this loan, but only have %s" % [
			UITheme.format_money(payoff_amount),
			UITheme.format_money(GameData.player_airline.balance)
		]
		get_tree().root.add_child(error_dialog)
		error_dialog.popup_centered()
		error_dialog.confirmed.connect(func(): error_dialog.queue_free())

func _on_loan_dialog_created(loan: Loan) -> void:
	"""Handle loan creation from loan dialog"""
	print("Loan created: $%.0f" % loan.principal)
	
	# Refresh finances panel
	if finances_panel is FinancesPanel:
		finances_panel.refresh()

# Market Panel Handlers

func _on_market_opportunity_selected(opportunity: Dictionary) -> void:
	"""Handle market opportunity selection - opens route creation dialog directly"""
	var from_airport = opportunity.get("from_airport", null)
	var to_airport = opportunity.get("to_airport", null)
	
	if from_airport and to_airport and route_config_dialog:
		# Open route config dialog directly for this opportunity
		route_config_dialog.setup_route(from_airport, to_airport)
		route_config_dialog.popup_centered()
		print("Opening route creation for opportunity: %s → %s" % [from_airport.iata_code, to_airport.iata_code])


func _on_hub_demand_destination_selected(hub: Airport, destination: Airport) -> void:
	"""Handle destination selection from hub demand panel (O.1) - opens route creation dialog"""
	if hub and destination and route_config_dialog:
		# Open route config dialog for this hub-destination pair
		route_config_dialog.setup_route(hub, destination)
		route_config_dialog.popup_centered()
		print("Opening route creation from demand panel: %s → %s" % [hub.iata_code, destination.iata_code])


func _on_pain_point_action_requested(route: Route, action_type: String) -> void:
	"""Handle pain point action button clicks (O.2)"""
	if not route:
		return
	
	print("Pain point action: %s on route %s" % [action_type, route.get_display_name()])
	
	match action_type:
		"add_capacity":
			# Open aircraft purchase dialog or show a message
			_on_buy_aircraft_button_pressed()
			print("Suggestion: Purchase more aircraft to add capacity to %s" % route.get_display_name())
		
		"lower_price":
			# Calculate recommended price and apply it
			var market_pricing = GameData.get_recommended_pricing_for_route(
				route.from_airport, route.to_airport
			)
			# Set price to market rate
			route.set_pending_prices(
				market_pricing.economy,
				market_pricing.business,
				market_pricing.first
			)
			print("Queued price reduction for %s: Economy €%.0f → €%.0f" % [
				route.get_display_name(), route.price_economy, market_pricing.economy
			])
			update_routes_panel()
		
		"add_frequency":
			# Increase frequency by 1 (if possible)
			if route.frequency < 14:  # Max 2x daily
				route.frequency += 1
				print("Increased frequency on %s to %d flights/week" % [
					route.get_display_name(), route.frequency
				])
				update_routes_panel()
			else:
				print("Route %s already at maximum frequency" % route.get_display_name())
		
		"review_route":
			# Open route config dialog for editing
			if route_config_dialog:
				route_config_dialog.setup_edit_route(route)
				route_config_dialog.popup_centered()
		
		_:
			print("Unknown action type: %s" % action_type)


func _on_pain_point_route_edit(route: Route) -> void:
	"""Handle pain point row click - open full route editor (O.2)"""
	if route and route_config_dialog:
		route_config_dialog.setup_edit_route(route)
		route_config_dialog.popup_centered()
		print("Opening route editor from pain point: %s" % route.get_display_name())


func _get_connecting_hub_for_airport(airport: Airport) -> Airport:
	"""Check if the given airport is connected to any of the player's hubs.
	Returns the connecting hub if found, null otherwise."""
	if not GameData.player_airline:
		return null
	
	# Check each player route to see if this airport is a destination from a hub
	for route in GameData.player_airline.routes:
		# Check if route connects a hub to this airport
		if route.from_airport == airport:
			# Airport is origin - check if destination is a hub
			if GameData.player_airline.has_hub(route.to_airport):
				return route.to_airport
		elif route.to_airport == airport:
			# Airport is destination - check if origin is a hub
			if GameData.player_airline.has_hub(route.from_airport):
				return route.from_airport
	
	return null


func _on_passenger_flow_route_requested(hub: Airport, destination: Airport) -> void:
	"""Handle route creation request from passenger flow panel"""
	if not hub or not destination:
		return
	
	if route_config_dialog:
		route_config_dialog.setup_route(hub, destination)
		route_config_dialog.popup_centered()
		print("Creating route from passenger flow: %s → %s" % [hub.iata_code, destination.iata_code])


# Tutorial System

func create_tutorial_overlay() -> void:
	"""Create tutorial UI overlay"""
	tutorial_overlay_layer = CanvasLayer.new()
	tutorial_overlay_layer.name = "TutorialOverlay"
	tutorial_overlay_layer.layer = 100
	add_child(tutorial_overlay_layer)

	tutorial_panel = Panel.new()
	tutorial_panel.name = "TutorialPanel"
	tutorial_panel.custom_minimum_size = Vector2(600, 300)
	tutorial_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	tutorial_panel.position = Vector2(20, 80)
	tutorial_panel.size = Vector2(600, 300)
	tutorial_overlay_layer.add_child(tutorial_panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 10)
	tutorial_panel.add_child(vbox)

	tutorial_progress = Label.new()
	tutorial_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_progress.add_theme_font_size_override("font_size", 12)
	tutorial_progress.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	vbox.add_child(tutorial_progress)

	tutorial_title = Label.new()
	tutorial_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_title.add_theme_font_size_override("font_size", 24)
	tutorial_title.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	vbox.add_child(tutorial_title)

	tutorial_message = RichTextLabel.new()
	tutorial_message.bbcode_enabled = true
	tutorial_message.fit_content = false
	tutorial_message.custom_minimum_size = Vector2(0, 120)
	tutorial_message.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tutorial_message.add_theme_font_size_override("normal_font_size", 14)
	vbox.add_child(tutorial_message)

	var button_box = HBoxContainer.new()
	button_box.alignment = BoxContainer.ALIGNMENT_CENTER
	button_box.add_theme_constant_override("separation", 20)
	vbox.add_child(button_box)

	tutorial_skip_button = Button.new()
	tutorial_skip_button.text = "Skip Tutorial"
	tutorial_skip_button.custom_minimum_size = Vector2(150, 40)
	tutorial_skip_button.pressed.connect(_on_tutorial_skip_pressed)
	button_box.add_child(tutorial_skip_button)

	tutorial_continue_button = Button.new()
	tutorial_continue_button.text = "Continue"
	tutorial_continue_button.custom_minimum_size = Vector2(150, 40)
	tutorial_continue_button.pressed.connect(_on_tutorial_continue_pressed)
	button_box.add_child(tutorial_continue_button)

	tutorial_skip_dialog = ConfirmationDialog.new()
	tutorial_skip_dialog.title = "Skip Tutorial?"
	tutorial_skip_dialog.dialog_text = "Are you sure you want to skip the tutorial?"
	tutorial_skip_dialog.confirmed.connect(_on_tutorial_skip_confirmed)
	tutorial_overlay_layer.add_child(tutorial_skip_dialog)

	tutorial_panel.visible = false

	if GameData.tutorial_manager:
		GameData.tutorial_manager.tutorial_step_started.connect(_on_tutorial_step_started_ui)
		GameData.tutorial_manager.tutorial_completed.connect(_on_tutorial_completed_ui)

func _on_tutorial_step_started_ui(step: TutorialStep) -> void:
	if not tutorial_panel:
		return

	tutorial_panel.visible = true
	if tutorial_title:
		tutorial_title.text = step.title
	if tutorial_message:
		tutorial_message.text = step.message
	if tutorial_progress and GameData.tutorial_manager:
		var current = GameData.tutorial_manager.current_step_index + 1
		var total = GameData.tutorial_manager.tutorial_steps.size()
		tutorial_progress.text = "Step %d of %d" % [current, total]

	if tutorial_continue_button:
		tutorial_continue_button.visible = step.step_type != TutorialStep.StepType.WAIT_FOR_ACTION

func _on_tutorial_completed_ui() -> void:
	if tutorial_panel:
		tutorial_panel.visible = false

func _on_tutorial_continue_pressed() -> void:
	if GameData.tutorial_manager:
		GameData.tutorial_manager.complete_current_step()

func _on_tutorial_skip_pressed() -> void:
	if tutorial_skip_dialog:
		tutorial_skip_dialog.popup_centered()

func _on_tutorial_skip_confirmed() -> void:
	if GameData.tutorial_manager:
		GameData.tutorial_manager.skip_tutorial()
	if tutorial_panel:
		tutorial_panel.visible = false
