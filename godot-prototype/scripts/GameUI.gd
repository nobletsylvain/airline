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

# Dialog references
var route_config_dialog: RouteConfigDialog = null
var route_opportunity_dialog: RouteOpportunityDialog = null
var hub_purchase_dialog: HubPurchaseDialog = null

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

	# Setup simulation engine
	setup_simulation_engine()

	# Setup dashboard UI
	setup_dashboard()

	# Setup world map
	setup_world_map()

	# Create dialogs
	create_dialogs()

	# Create tutorial overlay
	create_tutorial_overlay()

	# Connect signals
	connect_signals()

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

	# Connect dashboard to simulation engine
	dashboard_ui.simulation_engine = simulation_engine

	# Connect tab change signal
	dashboard_ui.tab_changed.connect(_on_tab_changed)

	# Get main content area
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
	"""Create fleet management panel"""
	var panel = PanelContainer.new()
	panel.name = "FleetPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style = UITheme.create_panel_style()
	style.bg_color = UITheme.BG_MAIN
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Fleet Management"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	vbox.add_child(title)

	# Fleet content will be populated dynamically
	var content = Label.new()
	content.name = "FleetContent"
	content.text = "Your fleet will be displayed here.\n\nPurchase aircraft from the market to grow your fleet."
	content.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	vbox.add_child(content)

	return panel

func create_routes_panel() -> Control:
	"""Create routes management panel"""
	var panel = PanelContainer.new()
	panel.name = "RoutesPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style = UITheme.create_panel_style()
	style.bg_color = UITheme.BG_MAIN
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Route Network"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	vbox.add_child(title)

	var content = Label.new()
	content.name = "RoutesContent"
	content.text = "Your routes will be displayed here.\n\nClick on the map to create new routes."
	content.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	vbox.add_child(content)

	return panel

func create_finances_panel() -> Control:
	"""Create finances panel"""
	var panel = PanelContainer.new()
	panel.name = "FinancesPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style = UITheme.create_panel_style()
	style.bg_color = UITheme.BG_MAIN
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "Financial Overview"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	vbox.add_child(title)

	var content = Label.new()
	content.name = "FinancesContent"
	content.text = "Financial data will be displayed here."
	content.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	vbox.add_child(content)

	return panel

func create_market_panel() -> Control:
	"""Create market panel"""
	var panel = PanelContainer.new()
	panel.name = "MarketPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var style = UITheme.create_panel_style()
	style.bg_color = UITheme.BG_MAIN
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "Market & Competitors"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	vbox.add_child(title)

	var content = Label.new()
	content.name = "MarketContent"
	content.text = "Market data and competitors will be displayed here."
	content.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	vbox.add_child(content)

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

func update_all() -> void:
	"""Update all UI elements"""
	if dashboard_ui:
		dashboard_ui.update_stats()

func update_fleet_panel() -> void:
	"""Update fleet panel content"""
	if not fleet_panel or not GameData.player_airline:
		return

	var content = fleet_panel.get_node_or_null("MarginContainer/VBoxContainer/FleetContent")
	if content and content is Label:
		var aircraft = GameData.player_airline.aircraft
		if aircraft.is_empty():
			content.text = "No aircraft in your fleet yet.\n\nPurchase aircraft to start operations."
		else:
			var text = "Total Aircraft: %d\n\n" % aircraft.size()
			for ac in aircraft:
				var status = "In Flight" if ac.is_assigned else "Available"
				text += "%s [#%d] - %s - Condition: %.0f%%\n" % [
					ac.model.get_display_name(),
					ac.id,
					status,
					ac.condition
				]
			content.text = text

func update_routes_panel() -> void:
	"""Update routes panel content"""
	if not routes_panel or not GameData.player_airline:
		return

	var content = routes_panel.get_node_or_null("MarginContainer/VBoxContainer/RoutesContent")
	if content and content is Label:
		var routes = GameData.player_airline.routes
		if routes.is_empty():
			content.text = "No routes created yet.\n\nClick on your hub airport on the map,\nthen select a destination to create a route."
		else:
			var text = "Active Routes: %d\n\n" % routes.size()
			for route in routes:
				var profit_sign = "+" if route.weekly_profit >= 0 else ""
				text += "%s\n  %d flights/wk | %d pax | %s$%s/wk\n\n" % [
					route.get_display_name(),
					route.frequency,
					route.passengers_transported,
					profit_sign,
					format_money(route.weekly_profit)
				]
			content.text = text

func update_finances_panel() -> void:
	"""Update finances panel content"""
	if not finances_panel or not GameData.player_airline:
		return

	var content = finances_panel.get_node_or_null("MarginContainer/VBoxContainer/FinancesContent")
	if content and content is Label:
		var airline = GameData.player_airline
		var profit = airline.calculate_weekly_profit()
		var profit_sign = "+" if profit >= 0 else ""

		content.text = """Balance: $%s

Weekly Summary:
  Revenue: $%s
  Expenses: $%s
  Profit: %s$%s

Loans:
  Total Debt: $%s
  Weekly Payments: $%s
  Credit Limit: $%s

Grade: %s
Reputation: %.1f""" % [
			format_money(airline.balance),
			format_money(airline.weekly_revenue),
			format_money(airline.weekly_expenses),
			profit_sign,
			format_money(profit),
			format_money(airline.total_debt),
			format_money(airline.weekly_loan_payment),
			format_money(airline.get_credit_limit()),
			airline.get_grade(),
			airline.reputation
		]

func update_market_panel() -> void:
	"""Update market panel content"""
	if not market_panel:
		return

	var content = market_panel.get_node_or_null("MarginContainer/VBoxContainer/MarketContent")
	if content and content is Label:
		var text = "Competitor Airlines:\n\n"
		for airline in GameData.airlines:
			if airline.id == GameData.player_airline.id:
				continue
			text += "%s (%s)\n  Grade: %s | Fleet: %d | Routes: %d\n\n" % [
				airline.name,
				airline.airline_code,
				airline.get_grade(),
				airline.aircraft.size(),
				airline.routes.size()
			]
		content.text = text

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

	if world_map:
		world_map.refresh_routes()

	update_all()

func _on_hub_purchased(airport: Airport) -> void:
	"""Handle hub purchase"""
	print("Hub purchased at %s" % airport.iata_code)
	if world_map:
		world_map.queue_redraw()
	update_all()

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
