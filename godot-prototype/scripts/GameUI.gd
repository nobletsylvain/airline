extends Control

## Main game UI controller - Dashboard layout integration
## Bridges DashboardUI, Globe3D, and SimulationEngine

@onready var simulation_engine: Node = $SimulationEngine
@onready var dashboard_ui: DashboardUI = $DashboardUI
@onready var world_map: Control = $WorldMap  # Legacy 2D map (hidden, kept as fallback)

# 3D Globe visualization (replaces WorldMap as primary map view)
var globe_3d: Globe3D = null

# Content panels for different tabs
var fleet_panel: Control = null
var routes_panel: Control = null
var finances_panel: Control = null
var market_panel: Control = null

# Dialog references
var route_config_dialog: RouteConfigDialog = null
var route_opportunity_dialog: RouteOpportunityDialog = null
var hub_purchase_dialog: HubPurchaseDialog = null
var aircraft_purchase_dialog: AircraftPurchaseDialog = null

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

	# Create tutorial overlay early (before any awaits) to catch signals
	create_tutorial_overlay()

	# Create dialogs
	create_dialogs()

	# Connect signals
	connect_signals()

	# Setup dashboard UI (has await for deferred layout)
	setup_dashboard()

	# Setup globe (3D) and legacy world map signals
	setup_globe()
	setup_world_map()

	# Initial UI update
	update_all()

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

	# Get main content area - wait a frame for deferred layout creation
	await get_tree().process_frame

	var main_content = dashboard_ui.get_main_content()
	if not main_content:
		push_error("DashboardUI main content not found!")
		return

	# Hide legacy WorldMap (kept for potential fallback)
	if world_map:
		world_map.visible = false

	# Create 3D Globe and embed into main content
	globe_3d = Globe3D.new()
	globe_3d.name = "Globe3D"
	globe_3d.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_content.add_child(globe_3d)
	print("Globe3D embedded into dashboard main content")

	# Create other content panels (hidden by default)
	create_content_panels(main_content)

func setup_globe() -> void:
	"""Configure Globe3D signals"""
	if globe_3d:
		globe_3d.airport_clicked.connect(_on_airport_clicked)
		globe_3d.airport_hovered.connect(_on_airport_hovered)
		globe_3d.route_created.connect(_on_route_created)
		globe_3d.route_clicked.connect(_on_route_clicked)
		print("Globe3D signals connected")

func setup_world_map() -> void:
	"""Configure legacy world map signals (fallback)"""
	if world_map and world_map.visible:
		world_map.airport_clicked.connect(_on_airport_clicked)
		world_map.airport_hovered.connect(_on_airport_hovered)
		world_map.route_created.connect(_on_route_created)
		world_map.route_clicked.connect(_on_route_clicked)

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

func create_fleet_panel() -> Control:
	"""Create fleet management panel using FleetManagementPanel"""
	var panel = FleetManagementPanel.new()
	panel.name = "FleetPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Connect purchase button to aircraft dialog
	panel.purchase_aircraft_pressed.connect(_on_buy_aircraft_button_pressed)

	return panel

func create_routes_panel() -> Control:
	"""Create route network panel using RouteNetworkPanel"""
	var panel = RouteNetworkPanel.new()
	panel.name = "RoutesPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.create_route_pressed.connect(_on_create_route_button_pressed)
	panel.route_selected.connect(_on_route_clicked)
	return panel

func create_finances_panel() -> Control:
	"""Create financial overview panel using FinancialPanel"""
	var panel = FinancialPanel.new()
	panel.name = "FinancesPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return panel

func create_market_panel() -> Control:
	"""Create market & competitors panel using MarketPanel"""
	var panel = MarketPanel.new()
	panel.name = "MarketPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return panel

func create_dialogs() -> void:
	"""Create all dialog windows"""
	# Route configuration dialog
	route_config_dialog = RouteConfigDialog.new()
	add_child(route_config_dialog)
	route_config_dialog.route_configured.connect(_on_route_configured)

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

	print("Dialogs created")

func connect_signals() -> void:
	"""Connect game data signals"""
	if GameData.player_airline:
		GameData.player_airline.balance_changed.connect(_on_balance_changed)
		GameData.player_airline.route_added.connect(_on_route_added)

	GameData.aircraft_purchased.connect(_on_aircraft_purchased)
	GameData.loan_created.connect(_on_loan_created)

func _on_tab_changed(tab_name: String) -> void:
	"""Handle tab navigation"""
	print("Tab changed to: ", tab_name)

	# Hide all content panels
	if globe_3d:
		globe_3d.visible = false
	if fleet_panel:
		fleet_panel.visible = false
	if routes_panel:
		routes_panel.visible = false
	if finances_panel:
		finances_panel.visible = false
	if market_panel:
		market_panel.visible = false

	# Show selected panel
	match tab_name:
		"map":
			if globe_3d:
				globe_3d.visible = true
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

func update_all() -> void:
	"""Update all UI elements"""
	if dashboard_ui:
		dashboard_ui.update_stats()

func update_fleet_panel() -> void:
	"""Update fleet panel content"""
	if not fleet_panel or not GameData.player_airline:
		return

	# FleetManagementPanel has its own refresh method
	if fleet_panel is FleetManagementPanel:
		fleet_panel.refresh()

func update_routes_panel() -> void:
	"""Update routes panel content"""
	if not routes_panel or not GameData.player_airline:
		return
	if routes_panel is RouteNetworkPanel:
		routes_panel.refresh()

func update_finances_panel() -> void:
	"""Update finances panel content"""
	if not finances_panel or not GameData.player_airline:
		return
	if finances_panel is FinancialPanel:
		finances_panel.refresh()

func update_market_panel() -> void:
	"""Update market panel content"""
	if not market_panel or not GameData.player_airline:
		return
	if market_panel is MarketPanel:
		market_panel.refresh()

# Event Handlers

func _on_airport_clicked(airport: Airport) -> void:
	"""Handle airport click"""
	# Check if clicking on a player hub
	if GameData.player_airline and GameData.player_airline.has_hub(airport):
		if route_opportunity_dialog:
			route_opportunity_dialog.show_for_hub(airport)
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
		route.price_economy = price_economy
		route.price_business = price_business
		route.price_first = price_first

		if aircraft != route.assigned_aircraft[0]:
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
		route.price_economy = price_economy
		route.price_business = price_business
		route.price_first = price_first
		route.service_quality = GameData.player_airline.service_quality
		route.aircraft_condition = aircraft.condition

	if globe_3d:
		globe_3d.refresh_routes()

	update_all()

func _on_hub_purchased(airport: Airport) -> void:
	"""Handle hub purchase"""
	print("Hub purchased at %s" % airport.iata_code)
	if globe_3d:
		globe_3d.marker_manager.rebuild_markers()
		globe_3d.refresh_routes()
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

func _on_week_completed(week: int) -> void:
	"""Handle week simulation completion"""
	update_all()
	if globe_3d:
		globe_3d.refresh_routes()

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
	update_all()

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
