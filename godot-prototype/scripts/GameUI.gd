extends Control

## Main game UI controller - Map-centric design

@onready var simulation_engine: Node = $SimulationEngine

# Top Panel
@onready var info_label: Label = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/InfoLabel
@onready var week_label: Label = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/WeekLabel
@onready var balance_label: Label = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/BalanceLabel
@onready var play_button: Button = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/PlayButton
@onready var step_button: Button = $MarginContainer/VBoxContainer/TopPanel/HBoxContainer/StepButton

# Map (Always Visible)
@onready var world_map: Control = $MarginContainer/VBoxContainer/MainArea/WorldMap

# Right Side Panels
@onready var airport_info: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/InfoPanel/VBoxContainer/AirportInfo

# Routes Tab
@onready var route_list: ItemList = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Routes/VBoxContainer/RouteList

# Fleet Tab
@onready var fleet_list: ItemList = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Fleet/VBoxContainer/FleetList
@onready var fleet_stats_label: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Fleet/VBoxContainer/FleetStatsPanel/FleetStats
@onready var aircraft_list: ItemList = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Fleet/VBoxContainer/AircraftList
@onready var aircraft_details: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Fleet/VBoxContainer/AircraftDetailsPanel/VBoxContainer/AircraftDetails
@onready var purchase_button: Button = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Fleet/VBoxContainer/AircraftDetailsPanel/VBoxContainer/PurchaseButton

# Financials Tab
@onready var weekly_stats_label: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/WeeklyStatsPanel/WeeklyStats
@onready var loans_list: ItemList = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/LoansList
@onready var loan_summary_label: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/LoanSummary
@onready var credit_info_label: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/LoanPanel/VBoxContainer/CreditInfo
@onready var amount_input: LineEdit = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/LoanPanel/VBoxContainer/AmountContainer/AmountInput
@onready var term_input: LineEdit = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/LoanPanel/VBoxContainer/TermContainer/TermInput
@onready var payment_preview: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/LoanPanel/VBoxContainer/PaymentPreview
@onready var apply_loan_button: Button = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/LoanPanel/VBoxContainer/ApplyButton
@onready var application_result: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances/VBoxContainer/ApplicationResult

# Market Tab
@onready var competitor_list: ItemList = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Market/VBoxContainer/CompetitorList
@onready var market_stats_label: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Market/VBoxContainer/MarketStatsPanel/MarketStats
@onready var competitor_detail: Label = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Market/VBoxContainer/CompetitorDetailPanel/CompetitorDetail
@onready var competing_routes_list: ItemList = $MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Market/VBoxContainer/CompetingRoutes

var selected_route: Route = null
var selected_aircraft_model_index: int = -1
var selected_competitor_index: int = -1

func _ready() -> void:
	print("GameUI: _ready() called")
	print("  aircraft_list node: ", aircraft_list)

	# Connect simulation signals
	if simulation_engine:
		simulation_engine.week_completed.connect(_on_week_completed)
		simulation_engine.route_simulated.connect(_on_route_simulated)
		simulation_engine.simulation_started.connect(_on_simulation_started)
		simulation_engine.simulation_paused.connect(_on_simulation_paused)

	# Connect map signals
	if world_map:
		world_map.airport_clicked.connect(_on_airport_clicked)
		world_map.airport_hovered.connect(_on_airport_hovered)
		world_map.route_created.connect(_on_route_created)

	# Connect button signals
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if step_button:
		step_button.pressed.connect(_on_step_button_pressed)
	if purchase_button:
		purchase_button.pressed.connect(_on_purchase_button_pressed)
	if apply_loan_button:
		apply_loan_button.pressed.connect(_on_apply_loan_pressed)

	# Connect list signals
	if route_list:
		route_list.item_selected.connect(_on_route_selected)
	if aircraft_list:
		aircraft_list.item_selected.connect(_on_aircraft_model_selected)
	if competitor_list:
		competitor_list.item_selected.connect(_on_competitor_selected)

	# Connect input signals for loan preview
	if amount_input:
		amount_input.text_changed.connect(_on_loan_input_changed)
	if term_input:
		term_input.text_changed.connect(_on_loan_input_changed)

	# Wait for game data (only if not already initialized)
	if not GameData.player_airline or GameData.aircraft_models.is_empty():
		print("GameUI: Waiting for GameData initialization...")
		await GameData.game_initialized
		print("GameUI: GameData initialized!")
	else:
		print("GameUI: GameData already initialized!")

	# Connect airline signals
	if GameData.player_airline:
		GameData.player_airline.balance_changed.connect(_on_balance_changed)
		GameData.player_airline.route_added.connect(_on_route_added)

	# Connect global signals
	GameData.aircraft_purchased.connect(_on_aircraft_purchased)
	GameData.loan_created.connect(_on_loan_created)

	print("GameUI: Calling update_all()...")
	# Initialize UI
	update_all()
	print("GameUI: _ready() complete!")

func update_all() -> void:
	"""Update all UI elements"""
	print("GameUI: update_all() called")
	update_top_panel()
	update_route_tab()
	update_fleet_tab()
	update_financials_tab()
	update_market_tab()
	print("GameUI: update_all() complete")

func update_top_panel() -> void:
	"""Update the top status bar"""
	if not GameData.player_airline:
		return

	if info_label:
		info_label.text = "%s | Grade: %s | Reputation: %.1f | Fleet: %d" % [
			GameData.player_airline.name,
			GameData.player_airline.get_grade(),
			GameData.player_airline.reputation,
			GameData.player_airline.aircraft.size()
		]

	if week_label:
		week_label.text = "Week: %d" % GameData.current_week

	if balance_label:
		balance_label.text = "Balance: $%s" % format_money(GameData.player_airline.balance)

func update_route_tab() -> void:
	"""Update Routes tab"""
	update_route_list()

func update_route_list() -> void:
	"""Update the route list display"""
	if not route_list or not GameData.player_airline:
		return

	route_list.clear()

	if GameData.player_airline.routes.is_empty():
		route_list.add_item("No routes created")
		return

	for route in GameData.player_airline.routes:
		var aircraft_info: String = ""
		if not route.assigned_aircraft.is_empty():
			aircraft_info = " [AC:%d]" % route.assigned_aircraft[0].id

		var profit_color: String = "+" if route.weekly_profit >= 0 else ""
		var route_text: String = "%s%s | %dpax | %s$%s" % [
			route.get_display_name(),
			aircraft_info,
			route.passengers_transported,
			profit_color,
			format_money(route.weekly_profit)
		]
		route_list.add_item(route_text)

func update_fleet_tab() -> void:
	"""Update Fleet tab"""
	print("GameUI: update_fleet_tab() called")
	populate_aircraft_list()
	update_fleet_list()
	update_fleet_stats()
	print("GameUI: update_fleet_tab() complete")

func populate_aircraft_list() -> void:
	"""Populate available aircraft for purchase"""
	print("populate_aircraft_list called")
	print("  aircraft_list exists: ", aircraft_list != null)
	print("  GameData.aircraft_models count: ", GameData.aircraft_models.size())

	if not aircraft_list:
		print("  ERROR: aircraft_list is null!")
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
		print("  Added: ", text)

func update_fleet_list() -> void:
	"""Update the fleet list display"""
	if not fleet_list or not GameData.player_airline:
		return

	fleet_list.clear()

	if GameData.player_airline.aircraft.is_empty():
		fleet_list.add_item("No aircraft owned")
		return

	for aircraft in GameData.player_airline.aircraft:
		var status_icon: String = "✓" if aircraft.is_assigned else "○"
		var text: String = "%s %s | ID:%d | %s | Condition:%.0f%%" % [
			status_icon,
			aircraft.model.get_display_name(),
			aircraft.id,
			aircraft.get_status(),
			aircraft.condition
		]
		fleet_list.add_item(text)

func update_fleet_stats() -> void:
	"""Update fleet statistics panel"""
	if not fleet_stats_label or not GameData.player_airline:
		return

	var total: int = GameData.player_airline.aircraft.size()
	var available: int = 0
	var assigned: int = 0
	var total_condition: float = 0.0

	for aircraft in GameData.player_airline.aircraft:
		if aircraft.is_assigned:
			assigned += 1
		else:
			available += 1
		total_condition += aircraft.condition

	var avg_condition: float = 100.0
	if total > 0:
		avg_condition = total_condition / total

	fleet_stats_label.text = "Total Aircraft: %d\nAvailable: %d\nAssigned: %d\nAvg Condition: %.1f%%" % [
		total,
		available,
		assigned,
		avg_condition
	]

func update_financials_tab() -> void:
	"""Update Financials tab"""
	update_weekly_stats()
	update_loans_list()
	update_loan_info()

func update_weekly_stats() -> void:
	"""Update weekly financial stats"""
	if not weekly_stats_label or not GameData.player_airline:
		return

	weekly_stats_label.text = "Revenue: $%s\nExpenses: $%s\nProfit: $%s\nBalance: $%s" % [
		format_money(GameData.player_airline.weekly_revenue),
		format_money(GameData.player_airline.weekly_expenses),
		format_money(GameData.player_airline.calculate_weekly_profit()),
		format_money(GameData.player_airline.balance)
	]

func update_loans_list() -> void:
	"""Update the active loans list display"""
	if not loans_list or not GameData.player_airline:
		return

	loans_list.clear()

	if GameData.player_airline.loans.is_empty():
		loans_list.add_item("No active loans")
		return

	for loan in GameData.player_airline.loans:
		var text: String = "Loan #%d: $%s @ %.1f%%\nPayment: $%s/wk | %d weeks left" % [
			loan.id,
			format_money(loan.remaining_balance),
			loan.interest_rate * 100,
			format_money(loan.weekly_payment),
			loan.weeks_remaining
		]
		loans_list.add_item(text)

func update_loan_info() -> void:
	"""Update loan credit limit and interest rate display"""
	if not GameData.player_airline:
		return

	var credit_limit: float = GameData.player_airline.get_credit_limit()
	var interest_rate: float = GameData.player_airline.get_interest_rate()

	if credit_info_label:
		credit_info_label.text = "Credit Limit: $%s\nInterest Rate: %.1f%%\nGrade: %s" % [
			format_money(credit_limit),
			interest_rate * 100,
			GameData.player_airline.get_grade()
		]

	if loan_summary_label:
		loan_summary_label.text = "Total Debt: $%s | Weekly Payments: $%s" % [
			format_money(GameData.player_airline.total_debt),
			format_money(GameData.player_airline.weekly_loan_payment)
		]

func update_market_tab() -> void:
	"""Update Market tab"""
	update_competitor_list()
	update_market_stats()

func update_competitor_list() -> void:
	"""Update the competitor airlines list"""
	if not competitor_list:
		return

	competitor_list.clear()

	for airline in GameData.airlines:
		if airline.id == GameData.player_airline.id:
			continue

		# Find AI controller for this airline
		var ai_personality: String = "Unknown"
		for ai in GameData.ai_controllers:
			if ai.controlled_airline.id == airline.id:
				ai_personality = ai.get_personality_name()
				break

		var text: String = "%s (%s) | %s\nGrade: %s | Fleet: %d | Routes: %d\nBalance: $%s | Debt: $%s" % [
			airline.name,
			airline.code,
			ai_personality,
			airline.get_grade(),
			airline.aircraft.size(),
			airline.routes.size(),
			format_money(airline.balance),
			format_money(airline.total_debt)
		]
		competitor_list.add_item(text)

func update_market_stats() -> void:
	"""Update market statistics"""
	if not market_stats_label:
		return

	var total_airlines: int = GameData.airlines.size()
	var total_routes: int = 0
	for airline in GameData.airlines:
		total_routes += airline.routes.size()

	var your_routes: int = GameData.player_airline.routes.size()
	var market_share: float = 0.0
	if total_routes > 0:
		market_share = (float(your_routes) / float(total_routes)) * 100.0

	market_stats_label.text = "Total Airlines: %d\nTotal Routes: %d\nYour Market Share: %.1f%%" % [
		total_airlines,
		total_routes,
		market_share
	]

# Event Handlers

func _on_airport_clicked(airport: Airport) -> void:
	"""Handle airport click"""
	if airport_info:
		airport_info.text = "%s\n%s, %s (%s)\n%s | %dM pax/year\n%d runways | %d slots/week\nGDP per capita: $%s" % [
			airport.get_display_name(),
			airport.city,
			airport.country,
			airport.region,
			airport.get_hub_name(),
			airport.annual_passengers,
			airport.runway_count,
			airport.max_slots_per_week,
			format_number(airport.gdp_per_capita)
		]

func _on_airport_hovered(airport: Airport) -> void:
	"""Handle airport hover"""
	pass

func _on_route_created(from_airport: Airport, to_airport: Airport) -> void:
	"""Handle route creation request"""
	if not GameData.player_airline:
		return

	# Check if there are any available aircraft
	var available_aircraft: Array[AircraftInstance] = []
	for aircraft in GameData.player_airline.aircraft:
		if not aircraft.is_assigned:
			available_aircraft.append(aircraft)

	if available_aircraft.is_empty():
		if airport_info:
			airport_info.text = "CANNOT CREATE ROUTE!\n\nNo available aircraft in your fleet.\n\nYou need to:\n1. Purchase an aircraft\n2. Assign it to this route"
		print("Cannot create route: No available aircraft")
		return

	# Create new route
	var route: Route = Route.new(from_airport, to_airport, GameData.player_airline.id)

	# Check if route is within aircraft range
	var suitable_aircraft: AircraftInstance = null
	for aircraft in available_aircraft:
		if aircraft.model.can_fly_distance(route.distance_km):
			suitable_aircraft = aircraft
			break

	if not suitable_aircraft:
		if airport_info:
			airport_info.text = "CANNOT CREATE ROUTE!\n\nRoute: %s\nDistance: %.0f km\n\nNone of your available aircraft can fly this distance.\n\nLongest range available: %.0f km" % [
				route.get_display_name(),
				route.distance_km,
				available_aircraft[0].model.range_km
			]
		print("Cannot create route: Distance exceeds aircraft range")
		return

	# Assign the first suitable aircraft
	route.assign_aircraft(suitable_aircraft)

	# Set capacity from aircraft model
	route.capacity_economy = suitable_aircraft.model.capacity_economy
	route.capacity_business = suitable_aircraft.model.capacity_business
	route.capacity_first = suitable_aircraft.model.capacity_first
	route.frequency = 7  # Daily

	# Set quality from airline and aircraft
	route.service_quality = GameData.player_airline.service_quality
	route.aircraft_condition = suitable_aircraft.condition

	# Set default pricing
	route.price_economy = route.calculate_base_price(route.distance_km, "economy")
	route.price_business = route.calculate_base_price(route.distance_km, "business")
	route.price_first = route.calculate_base_price(route.distance_km, "first")

	# Add to airline
	GameData.player_airline.add_route(route)

	# Refresh map
	if world_map:
		world_map.refresh_routes()

	# Update UI
	update_fleet_tab()
	update_route_tab()

	# Show success message
	if airport_info:
		airport_info.text = "ROUTE CREATED!\n\n%s\nDistance: %.0f km\nAircraft: %s (ID:%d)\nCapacity: %d passengers\nPrice: $%.0f (Economy)" % [
			route.get_display_name(),
			route.distance_km,
			suitable_aircraft.model.get_display_name(),
			suitable_aircraft.id,
			route.get_total_capacity(),
			route.price_economy
		]

	print("Created route: %s (%.0f km) with aircraft ID:%d" % [route.get_display_name(), route.distance_km, suitable_aircraft.id])

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
	update_all()

	if world_map:
		world_map.refresh_routes()

func _on_route_simulated(route: Route, passengers: int, revenue: float) -> void:
	"""Handle individual route simulation"""
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

func _on_aircraft_model_selected(index: int) -> void:
	"""Handle aircraft model selection"""
	selected_aircraft_model_index = index

	if purchase_button:
		purchase_button.disabled = false

	# Show aircraft info
	if index >= 0 and index < GameData.aircraft_models.size():
		var model: AircraftModel = GameData.aircraft_models[index]
		if aircraft_details:
			aircraft_details.text = "Aircraft: %s\n\nCapacity: %d passengers\n(%d Economy / %d Business / %d First)\n\nRange: %s km\nPrice: $%s\n\nAffordable: %s" % [
				model.get_display_name(),
				model.get_total_capacity(),
				model.capacity_economy,
				model.capacity_business,
				model.capacity_first,
				format_number(model.range_km),
				format_money(model.price),
				"Yes" if GameData.player_airline.balance >= model.price else "No (Need $%s more)" % format_money(model.price - GameData.player_airline.balance)
			]

func _on_purchase_button_pressed() -> void:
	"""Handle purchase button press"""
	if selected_aircraft_model_index < 0 or selected_aircraft_model_index >= GameData.aircraft_models.size():
		print("No aircraft selected")
		return

	var model: AircraftModel = GameData.aircraft_models[selected_aircraft_model_index]

	# Check balance
	if GameData.player_airline.balance < model.price:
		if aircraft_details:
			aircraft_details.text = "INSUFFICIENT FUNDS!\n\nAircraft: %s\nPrice: $%s\nYour balance: $%s\nShortfall: $%s" % [
				model.get_display_name(),
				format_money(model.price),
				format_money(GameData.player_airline.balance),
				format_money(model.price - GameData.player_airline.balance)
			]
		return

	# Purchase aircraft
	var aircraft: AircraftInstance = GameData.purchase_aircraft(GameData.player_airline, model)

	if aircraft:
		# Success feedback
		if aircraft_details:
			aircraft_details.text = "PURCHASED!\n\n%s\nAircraft ID: %d\nRemaining balance: $%s" % [
				model.get_display_name(),
				aircraft.id,
				format_money(GameData.player_airline.balance)
			]

func _on_aircraft_purchased(aircraft: AircraftInstance, airline: Airline) -> void:
	"""Handle aircraft purchase"""
	update_fleet_tab()
	update_top_panel()

func _on_loan_input_changed(new_text: String) -> void:
	"""Update loan payment preview when inputs change"""
	if not payment_preview or not GameData.player_airline:
		return

	var amount_text: String = amount_input.text.strip_edges()
	var term_text: String = term_input.text.strip_edges()

	if amount_text.is_empty() or term_text.is_empty():
		payment_preview.text = "Weekly Payment: $0"
		return

	var amount_millions: float = amount_text.to_float()
	var amount: float = amount_millions * 1000000.0
	var term: int = term_text.to_int()

	if amount <= 0 or term <= 0:
		payment_preview.text = "Weekly Payment: Invalid input"
		return

	# Calculate preview payment
	var interest_rate: float = GameData.player_airline.get_interest_rate()
	var weekly_interest_rate: float = interest_rate / 52.0
	var factor: float = pow(1 + weekly_interest_rate, term)
	var weekly_payment: float = amount * (weekly_interest_rate * factor) / (factor - 1)

	payment_preview.text = "Weekly Payment: $%s" % format_money(weekly_payment)

func _on_apply_loan_pressed() -> void:
	"""Handle loan application"""
	if not GameData.player_airline:
		return

	# Parse inputs
	var amount_text: String = amount_input.text.strip_edges()
	var term_text: String = term_input.text.strip_edges()

	if amount_text.is_empty() or term_text.is_empty():
		if application_result:
			application_result.text = "LOAN APPLICATION FAILED!\n\nPlease enter both amount and term."
		return

	var amount_millions: float = amount_text.to_float()
	var amount: float = amount_millions * 1000000.0
	var term: int = term_text.to_int()

	if amount <= 0 or term <= 0:
		if application_result:
			application_result.text = "LOAN APPLICATION FAILED!\n\nAmount and term must be positive numbers."
		return

	# Try to create loan
	var loan: Loan = GameData.create_loan(GameData.player_airline, amount, term)

	if loan:
		# Success
		if application_result:
			application_result.text = "✓ LOAN APPROVED!\n\nAmount: $%s\nTerm: %d weeks\nInterest Rate: %.1f%%\nWeekly Payment: $%s\n\nFunds have been added to your balance." % [
				format_money(loan.principal),
				loan.term_weeks,
				loan.interest_rate * 100,
				format_money(loan.weekly_payment)
			]

		# Clear inputs
		amount_input.text = ""
		term_input.text = ""
		payment_preview.text = "Weekly Payment: $0"
	else:
		# Failed
		if application_result:
			var credit_limit: float = GameData.player_airline.get_credit_limit()
			application_result.text = "✗ LOAN APPLICATION DENIED!\n\nRequested: $%s\nCredit Limit: $%s\n\nYou may be over your credit limit or unable to afford the payments." % [
				format_money(amount),
				format_money(credit_limit)
			]

func _on_loan_created(loan: Loan, airline: Airline) -> void:
	"""Handle loan created event"""
	update_financials_tab()
	update_top_panel()

func _on_competitor_selected(index: int) -> void:
	"""Handle competitor selection"""
	selected_competitor_index = index

	# Get competitor (skip player)
	var competitor_index: int = 0
	var selected_airline: Airline = null
	for airline in GameData.airlines:
		if airline.id == GameData.player_airline.id:
			continue
		if competitor_index == index:
			selected_airline = airline
			break
		competitor_index += 1

	if not selected_airline:
		return

	# Find AI controller
	var ai_personality: String = "Unknown"
	for ai in GameData.ai_controllers:
		if ai.controlled_airline.id == selected_airline.id:
			ai_personality = ai.get_personality_name()
			break

	# Show competitor details
	if competitor_detail:
		competitor_detail.text = "Airline: %s (%s)\nStrategy: %s\n\nGrade: %s\nReputation: %.1f\nBalance: $%s\nDebt: $%s\n\nFleet: %d aircraft\nRoutes: %d" % [
			selected_airline.name,
			selected_airline.code,
			ai_personality,
			selected_airline.get_grade(),
			selected_airline.reputation,
			format_money(selected_airline.balance),
			format_money(selected_airline.total_debt),
			selected_airline.aircraft.size(),
			selected_airline.routes.size()
		]

	# Show competing routes
	update_competing_routes(selected_airline)

func update_competing_routes(competitor: Airline) -> void:
	"""Show routes that compete with the selected airline"""
	if not competing_routes_list:
		return

	competing_routes_list.clear()

	# Find routes where you compete with this airline
	var competition_found: bool = false
	for your_route in GameData.player_airline.routes:
		for their_route in competitor.routes:
			# Check if same airport pair
			if (your_route.from_airport == their_route.from_airport and your_route.to_airport == their_route.to_airport) or \
			   (your_route.from_airport == their_route.to_airport and your_route.to_airport == their_route.from_airport):
				competition_found = true
				var text: String = "%s\nYou: %dpax @ $%s | Them: %dpax @ $%s" % [
					your_route.get_display_name(),
					your_route.passengers_transported,
					format_money(your_route.price_economy),
					their_route.passengers_transported,
					format_money(their_route.price_economy)
				]
				competing_routes_list.add_item(text)

	if not competition_found:
		competing_routes_list.add_item("No competing routes with this airline")

# Utility Functions

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

func format_number(num: int) -> String:
	"""Format large numbers with M/K suffixes"""
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	else:
		return str(num)
