extends Control

## Main game UI controller

@onready var world_map: Control = $MarginContainer/VBoxContainer/WorldMap
@onready var simulation_engine: Node = $SimulationEngine
@onready var info_label: Label = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/InfoLabel
@onready var week_label: Label = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/WeekLabel
@onready var balance_label: Label = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/BalanceLabel
@onready var route_list: ItemList = $MarginContainer/VBoxContainer/BottomPanel/HBoxContainer/RoutePanel/RouteList
@onready var airport_info: Label = $MarginContainer/VBoxContainer/BottomPanel/HBoxContainer/AirportInfo
@onready var play_button: Button = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/PlayButton
@onready var step_button: Button = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/StepButton
@onready var aircraft_panel: VBoxContainer = $MarginContainer/VBoxContainer/BottomPanel/HBoxContainer/AircraftPanel
@onready var aircraft_list: ItemList = $MarginContainer/VBoxContainer/BottomPanel/HBoxContainer/AircraftPanel/AircraftList

var selected_route: Route = null

func _ready() -> void:
	# Connect signals
	if simulation_engine:
		simulation_engine.week_completed.connect(_on_week_completed)
		simulation_engine.route_simulated.connect(_on_route_simulated)
		simulation_engine.simulation_started.connect(_on_simulation_started)
		simulation_engine.simulation_paused.connect(_on_simulation_paused)

	if world_map:
		world_map.airport_clicked.connect(_on_airport_clicked)
		world_map.airport_hovered.connect(_on_airport_hovered)
		world_map.route_created.connect(_on_route_created)

	# Connect button signals
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if step_button:
		step_button.pressed.connect(_on_step_button_pressed)

	if route_list:
		route_list.item_selected.connect(_on_route_selected)

	# Wait for game data
	await GameData.game_initialized

	# Connect airline signals
	if GameData.player_airline:
		GameData.player_airline.balance_changed.connect(_on_balance_changed)
		GameData.player_airline.route_added.connect(_on_route_added)

	update_ui()
	populate_aircraft_list()

func update_ui() -> void:
	"""Update all UI elements"""
	if not GameData.player_airline:
		return

	# Update top panel
	if week_label:
		week_label.text = "Week: %d" % GameData.current_week

	if balance_label:
		balance_label.text = "Balance: $%s" % format_money(GameData.player_airline.balance)

	if info_label:
		info_label.text = "%s | Grade: %s | Reputation: %.1f" % [
			GameData.player_airline.name,
			GameData.player_airline.get_grade(),
			GameData.player_airline.reputation
		]

	# Update route list
	update_route_list()

func update_route_list() -> void:
	"""Update the route list display"""
	if not route_list or not GameData.player_airline:
		return

	route_list.clear()

	for route in GameData.player_airline.routes:
		var route_text: String = "%s | %d pax | $%s profit" % [
			route.get_display_name(),
			route.passengers_transported,
			format_money(route.weekly_profit)
		]
		route_list.add_item(route_text)

func populate_aircraft_list() -> void:
	"""Populate available aircraft for purchase"""
	if not aircraft_list:
		return

	aircraft_list.clear()

	for model in GameData.aircraft_models:
		var text: String = "%s %s - Cap: %d - Range: %dkm - $%s" % [
			model.manufacturer,
			model.model_name,
			model.get_total_capacity(),
			model.range_km,
			format_money(model.price)
		]
		aircraft_list.add_item(text)

func format_money(amount: float) -> String:
	"""Format money with thousands separators"""
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

func _on_airport_clicked(airport: Airport) -> void:
	"""Handle airport click"""
	if airport_info:
		airport_info.text = "Selected: %s\nCity: %s, %s\nSize: %d | Population: %s" % [
			airport.get_display_name(),
			airport.city,
			airport.country,
			airport.size,
			format_number(airport.population)
		]

func _on_airport_hovered(airport: Airport) -> void:
	"""Handle airport hover"""
	# Could show tooltip
	pass

func _on_route_created(from_airport: Airport, to_airport: Airport) -> void:
	"""Handle route creation request"""
	if not GameData.player_airline:
		return

	# Create new route
	var route: Route = Route.new(from_airport, to_airport, GameData.player_airline.id)

	# Set default pricing
	route.price_economy = route.calculate_base_price(route.distance_km, "economy")
	route.price_business = route.calculate_base_price(route.distance_km, "business")
	route.price_first = route.calculate_base_price(route.distance_km, "first")

	# Set default capacity (assuming 737-800)
	route.capacity_economy = 162
	route.capacity_business = 12
	route.capacity_first = 0
	route.frequency = 7  # Daily

	# Set quality from airline
	route.service_quality = GameData.player_airline.service_quality

	# Add to airline
	GameData.player_airline.add_route(route)

	# Refresh map
	if world_map:
		world_map.refresh_routes()

	print("Created route: %s (%.0f km)" % [route.get_display_name(), route.distance_km])

func _on_route_added(route: Route) -> void:
	"""Handle new route added to airline"""
	update_route_list()

func _on_play_button_pressed() -> void:
	"""Toggle simulation play/pause"""
	if simulation_engine.is_running:
		simulation_engine.pause_simulation()
	else:
		simulation_engine.start_simulation()

func _on_step_button_pressed() -> void:
	"""Run a single week simulation"""
	simulation_engine.run_single_week()

func _on_simulation_started() -> void:
	if play_button:
		play_button.text = "Pause"

func _on_simulation_paused() -> void:
	if play_button:
		play_button.text = "Play"

func _on_week_completed(week: int) -> void:
	"""Handle week simulation completion"""
	update_ui()

	if world_map:
		world_map.refresh_routes()

func _on_route_simulated(route: Route, passengers: int, revenue: float) -> void:
	"""Handle individual route simulation"""
	# Could show animation or notification
	pass

func _on_balance_changed(new_balance: float) -> void:
	"""Handle airline balance change"""
	if balance_label:
		balance_label.text = "Balance: $%s" % format_money(new_balance)

func _on_route_selected(index: int) -> void:
	"""Handle route selection from list"""
	if index < 0 or index >= GameData.player_airline.routes.size():
		return

	selected_route = GameData.player_airline.routes[index]

	# Show route details
	if airport_info:
		airport_info.text = "Route: %s\nDistance: %.0f km\nFrequency: %d/week\nPassengers: %d\nRevenue: $%s\nProfit: $%s" % [
			selected_route.get_display_name(),
			selected_route.distance_km,
			selected_route.frequency,
			selected_route.passengers_transported,
			format_money(selected_route.revenue_generated),
			format_money(selected_route.weekly_profit)
		]

func format_number(num: int) -> String:
	"""Format large numbers with M/K suffixes"""
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	else:
		return str(num)
