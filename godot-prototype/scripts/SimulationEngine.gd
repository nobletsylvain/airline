extends Node

## Handles the weekly simulation cycle

@export var simulation_speed: float = 1.0  # 1.0 = normal, 2.0 = 2x speed
@export var auto_simulate: bool = false

var is_running: bool = false
var time_accumulator: float = 0.0
var week_duration: float = 5.0  # 5 seconds per week in real-time

signal simulation_started()
signal simulation_paused()
signal week_completed(week_number: int)
signal route_simulated(route: Route, passengers: int, revenue: float)

func _ready() -> void:
	set_process(false)

func start_simulation() -> void:
	is_running = true
	set_process(true)
	simulation_started.emit()
	print("Simulation started")

func pause_simulation() -> void:
	is_running = false
	set_process(false)
	simulation_paused.emit()
	print("Simulation paused")

func _process(delta: float) -> void:
	if not is_running:
		return

	time_accumulator += delta * simulation_speed

	if time_accumulator >= week_duration:
		time_accumulator = 0.0
		simulate_week()

func simulate_week() -> void:
	"""Run a full week simulation"""
	GameData.current_week += 1
	print("\n=== Week %d Simulation ===" % GameData.current_week)

	# Reset weekly stats for all airlines
	for airline in GameData.airlines:
		airline.reset_weekly_stats()

	# Simulate each route
	for airline in GameData.airlines:
		for route in airline.routes:
			simulate_route(route, airline)

	# Calculate airline financials
	for airline in GameData.airlines:
		calculate_airline_finances(airline)

	week_completed.emit(GameData.current_week)
	print("=== Week %d Complete ===" % GameData.current_week)

func simulate_route(route: Route, airline: Airline) -> void:
	"""Simulate passenger demand and revenue for a route"""
	if not route.from_airport or not route.to_airport:
		return

	# Calculate demand based on airport characteristics
	var base_demand: float = calculate_demand(route)

	# Apply quality multiplier
	var quality_multiplier: float = route.get_quality_score() / 100.0
	quality_multiplier = clamp(quality_multiplier, 0.3, 1.5)

	# Calculate actual passengers per class
	var total_capacity: int = route.get_total_capacity() * route.frequency

	# Simplified passenger allocation
	var economy_demand: int = int(base_demand * 0.7 * quality_multiplier)
	var business_demand: int = int(base_demand * 0.25 * quality_multiplier)
	var first_demand: int = int(base_demand * 0.05 * quality_multiplier)

	# Cap by capacity
	var economy_passengers: int = mini(economy_demand, route.capacity_economy * route.frequency)
	var business_passengers: int = mini(business_demand, route.capacity_business * route.frequency)
	var first_passengers: int = mini(first_demand, route.capacity_first * route.frequency)

	# Calculate revenue
	var economy_revenue: float = economy_passengers * route.price_economy
	var business_revenue: float = business_passengers * route.price_business
	var first_revenue: float = first_passengers * route.price_first
	var total_revenue: float = economy_revenue + business_revenue + first_revenue

	# Calculate costs
	var fuel_cost: float = calculate_fuel_cost(route)
	var crew_cost: float = calculate_crew_cost(route)
	var maintenance_cost: float = calculate_maintenance_cost(route)
	var airport_fees: float = calculate_airport_fees(route, economy_passengers + business_passengers + first_passengers)

	var total_costs: float = fuel_cost + crew_cost + maintenance_cost + airport_fees

	# Update route stats
	route.passengers_transported = economy_passengers + business_passengers + first_passengers
	route.revenue_generated = total_revenue
	route.fuel_cost = fuel_cost
	route.weekly_profit = total_revenue - total_costs

	# Update airline stats
	airline.weekly_revenue += total_revenue
	airline.weekly_expenses += total_costs
	airline.total_revenue += total_revenue
	airline.total_expenses += total_costs

	# Degrade aircraft condition
	for aircraft in route.assigned_aircraft:
		aircraft.degrade_condition(0.5 * route.frequency)  # Small degradation per flight

	route_simulated.emit(route, route.passengers_transported, total_revenue)

	print("  Route %s: %d pax, $%.0f revenue, $%.0f profit" % [
		route.get_display_name(),
		route.passengers_transported,
		total_revenue,
		route.weekly_profit
	])

func calculate_demand(route: Route) -> float:
	"""Calculate base passenger demand for a route"""
	var from_multiplier: float = route.from_airport.get_demand_multiplier()
	var to_multiplier: float = route.to_airport.get_demand_multiplier()

	# Base demand influenced by both airports
	var base: float = (from_multiplier + to_multiplier) * 50.0

	# Distance penalty (very long routes have less demand)
	var distance_factor: float = 1.0
	if route.distance_km > 10000:
		distance_factor = 0.7
	elif route.distance_km > 5000:
		distance_factor = 0.85

	return base * distance_factor

func calculate_fuel_cost(route: Route) -> float:
	"""Calculate fuel cost for a route"""
	var oil_price_per_gallon: float = 3.0  # Simplified
	var fuel_burn_rate: float = 800.0  # Gallons per hour (simplified average)
	return route.flight_duration_hours * fuel_burn_rate * oil_price_per_gallon * route.frequency

func calculate_crew_cost(route: Route) -> float:
	"""Calculate crew costs"""
	var base_crew_cost: float = 2000.0  # Per flight
	return base_crew_cost * route.frequency

func calculate_maintenance_cost(route: Route) -> float:
	"""Calculate maintenance costs"""
	var cost_per_flight_hour: float = 500.0
	return route.flight_duration_hours * cost_per_flight_hour * route.frequency

func calculate_airport_fees(route: Route, passengers: int) -> float:
	"""Calculate airport landing and passenger fees"""
	var landing_fee: float = 5000.0  # Per landing
	var passenger_fee: float = 10.0  # Per passenger
	return (landing_fee * route.frequency) + (passenger_fee * passengers)

func calculate_airline_finances(airline: Airline) -> void:
	"""Update airline balance based on weekly performance"""
	var weekly_profit: float = airline.calculate_weekly_profit()
	airline.add_balance(weekly_profit)

	# Update reputation based on performance
	if weekly_profit > 0:
		airline.reputation += 0.5
	else:
		airline.reputation -= 0.2

	airline.reputation = max(0.0, airline.reputation)

	print("  Airline %s: Revenue=$%.0f, Expenses=$%.0f, Profit=$%.0f, Balance=$%.0f" % [
		airline.name,
		airline.weekly_revenue,
		airline.weekly_expenses,
		weekly_profit,
		airline.balance
	])

func run_single_week() -> void:
	"""Manually trigger a single week simulation"""
	simulate_week()
