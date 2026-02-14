extends Node

## Handles the weekly simulation cycle

# Speed presets: maps game hours to real seconds
# Real-time: 1 game hour = 60 real seconds (1 week = 2.8 hours)
# Slow: 1 game hour = 10 real seconds (1 week = 28 minutes)
# Normal: 1 game hour = 2 real seconds (1 week = 5.6 minutes)
# Fast: 1 game hour = 0.5 real seconds (1 week = 84 seconds)
# Very Fast: 1 game hour = 0.1 real seconds (1 week = 16.8 seconds)

enum SpeedLevel { PAUSED, REAL_TIME, SLOW, NORMAL, FAST, VERY_FAST }

# Seconds per game hour for each speed level
const SPEED_PRESETS: Dictionary = {
	SpeedLevel.PAUSED: 0.0,
	SpeedLevel.REAL_TIME: 60.0,    # 1 hour = 1 minute real time
	SpeedLevel.SLOW: 10.0,         # 1 hour = 10 seconds
	SpeedLevel.NORMAL: 2.0,        # 1 hour = 2 seconds
	SpeedLevel.FAST: 0.5,          # 1 hour = 0.5 seconds
	SpeedLevel.VERY_FAST: 0.1,     # 1 hour = 0.1 seconds
}

const SPEED_NAMES: Dictionary = {
	SpeedLevel.PAUSED: "Paused",
	SpeedLevel.REAL_TIME: "Real-Time",
	SpeedLevel.SLOW: "Slow",
	SpeedLevel.NORMAL: "Normal",
	SpeedLevel.FAST: "Fast",
	SpeedLevel.VERY_FAST: "Very Fast",
}

@export var auto_simulate: bool = false

var is_running: bool = false
var time_accumulator: float = 0.0  # Accumulates in game hours
var current_speed_level: SpeedLevel = SpeedLevel.NORMAL
var seconds_per_hour: float = 2.0  # Current speed setting

signal simulation_started()
signal simulation_paused()
signal speed_changed(speed_level: SpeedLevel, speed_name: String)
signal week_completed(week_number: int)
signal route_simulated(route: Route, passengers: int, revenue: float)

func _ready() -> void:
	set_process(false)
	set_speed(SpeedLevel.NORMAL)

func start_simulation() -> void:
	is_running = true
	set_process(true)
	simulation_started.emit()
	print("Simulation started at %s speed" % get_speed_name())

func pause_simulation() -> void:
	is_running = false
	set_process(false)
	simulation_paused.emit()
	print("Simulation paused")

func toggle_pause() -> void:
	if is_running:
		pause_simulation()
	else:
		start_simulation()

func set_speed(level: SpeedLevel) -> void:
	"""Set simulation speed to a preset level"""
	current_speed_level = level
	seconds_per_hour = SPEED_PRESETS[level]
	speed_changed.emit(level, SPEED_NAMES[level])
	print("Speed set to: %s (%.1f sec/hour)" % [SPEED_NAMES[level], seconds_per_hour])

func increase_speed() -> void:
	"""Increase speed to next level"""
	var next_level: int = mini(current_speed_level + 1, SpeedLevel.VERY_FAST)
	set_speed(next_level as SpeedLevel)

func decrease_speed() -> void:
	"""Decrease speed to previous level"""
	var prev_level: int = maxi(current_speed_level - 1, SpeedLevel.PAUSED)
	set_speed(prev_level as SpeedLevel)

func get_speed_name() -> String:
	return SPEED_NAMES[current_speed_level]

func get_current_week_hour() -> float:
	"""Get current hour within the week (0-168)"""
	return time_accumulator

func _process(delta: float) -> void:
	if not is_running or current_speed_level == SpeedLevel.PAUSED:
		return

	# Convert real seconds to game hours based on speed
	var hours_elapsed: float = delta / seconds_per_hour
	time_accumulator += hours_elapsed

	# Update GameData with current hour (for live time display)
	GameData.current_hour = time_accumulator

	# Check if a week has passed (168 hours)
	if time_accumulator >= 168.0:
		time_accumulator = fmod(time_accumulator, 168.0)
		GameData.current_hour = time_accumulator
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

	# Process AI decisions
	process_ai_decisions()

	# Update objectives after simulation
	if GameData.objective_system:
		GameData.objective_system.check_objectives_from_game_state()

	# Notify tutorial of simulation
	if GameData.tutorial_manager:
		GameData.tutorial_manager.on_action_performed("run_simulation")

	week_completed.emit(GameData.current_week)
	print("=== Week %d Complete ===" % GameData.current_week)

func simulate_route(route: Route, airline: Airline) -> void:
	"""Simulate passenger demand and revenue for a route"""
	if not route.from_airport or not route.to_airport:
		return

	# Calculate base market demand (total passengers on this route across ALL airlines)
	var base_demand: float = calculate_demand(route)

	# Find competing routes (same airport pair from any airline)
	var competing_routes: Array[Dictionary] = get_competing_routes(route)

	# Calculate market share for this route
	var market_share: float = calculate_market_share(route, airline, competing_routes)

	# Apply market share to demand
	var route_demand: float = base_demand * market_share

	# === HUB NETWORK EFFECTS: Add connecting passengers ===
	var connecting_passengers: float = calculate_connecting_passengers_for_route(route, airline)
	route_demand += connecting_passengers

	# Apply quality multiplier
	var quality_multiplier: float = route.get_quality_score() / 100.0
	quality_multiplier = clamp(quality_multiplier, 0.3, 1.5)

	# Calculate actual passengers per class
	var total_capacity: int = route.get_total_capacity() * route.frequency

	# Calculate realistic passenger class distribution
	var class_distribution: Dictionary = calculate_class_distribution(route, airline)

	# Apply class distribution to demand (after market share split)
	var economy_demand: int = int(route_demand * class_distribution.economy * quality_multiplier)
	var business_demand: int = int(route_demand * class_distribution.business * quality_multiplier)
	var first_demand: int = int(route_demand * class_distribution.first * quality_multiplier)

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
	"""Calculate base passenger demand for a route using market analysis"""
	# Use the new market analysis system
	var distance: float = route.distance_km
	var demand: float = MarketAnalysis.calculate_potential_demand(
		route.from_airport,
		route.to_airport,
		distance
	)

	return demand

func calculate_class_distribution(route: Route, airline: Airline) -> Dictionary:
	"""
	Calculate realistic passenger class distribution based on:
	- Route distance (long haul = more business/first)
	- Pricing (expensive economy = shift to lower demand)
	- Airline reputation (high rep = more premium passengers)
	- Income levels of airports
	"""
	var distance: float = route.distance_km

	# Base distribution by distance
	var economy_ratio: float = 0.70
	var business_ratio: float = 0.25
	var first_ratio: float = 0.05

	# Long haul routes have more premium passengers
	if distance > 6000:
		economy_ratio = 0.60
		business_ratio = 0.32
		first_ratio = 0.08
	elif distance > 3000:
		economy_ratio = 0.65
		business_ratio = 0.28
		first_ratio = 0.07
	elif distance < 1000:
		# Short haul is mostly economy
		economy_ratio = 0.80
		business_ratio = 0.18
		first_ratio = 0.02

	# Adjust for airline reputation (high reputation attracts premium passengers)
	if airline.reputation > 100:
		var rep_bonus: float = min((airline.reputation - 100) / 200.0, 0.15)
		business_ratio += rep_bonus
		first_ratio += rep_bonus * 0.5
		economy_ratio -= rep_bonus * 1.5

	# Adjust for airport income levels (using GDP per capita)
	# Normalize GDP to 0-100 scale (gdp_per_capita / 1000)
	var from_income: float = route.from_airport.gdp_per_capita / 1000.0
	var to_income: float = route.to_airport.gdp_per_capita / 1000.0
	var avg_income: float = (from_income + to_income) / 2.0
	if avg_income > 70:
		# High income cities = more premium travel
		var income_bonus: float = (avg_income - 70) / 100.0
		business_ratio += income_bonus * 0.1
		first_ratio += income_bonus * 0.05
		economy_ratio -= income_bonus * 0.15

	# Normalize to ensure sum = 1.0
	var total: float = economy_ratio + business_ratio + first_ratio
	economy_ratio /= total
	business_ratio /= total
	first_ratio /= total

	return {
		"economy": economy_ratio,
		"business": business_ratio,
		"first": first_ratio
	}

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

	# Process loan payments
	var loan_payments: float = airline.process_loan_payments()
	if loan_payments > 0:
		airline.deduct_balance(loan_payments)
		airline.weekly_expenses += loan_payments
		print("  Loan payments: $%.0f" % loan_payments)

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

func process_ai_decisions() -> void:
	"""Process AI decision-making for all AI airlines"""
	for ai_controller in GameData.ai_controllers:
		ai_controller.make_decisions(GameData.current_week)

func get_competing_routes(route: Route) -> Array[Dictionary]:
	"""Find all routes operating between the same airports (including this one)"""
	var competing: Array[Dictionary] = []

	for airline in GameData.airlines:
		for other_route in airline.routes:
			# Check if same airport pair (bidirectional)
			if (other_route.from_airport == route.from_airport and other_route.to_airport == route.to_airport) or \
			   (other_route.from_airport == route.to_airport and other_route.to_airport == route.from_airport):
				competing.append({
					"route": other_route,
					"airline": airline
				})

	return competing

func calculate_market_share(route: Route, airline: Airline, competing_routes: Array[Dictionary]) -> float:
	"""Calculate this route's market share based on price, quality, and reputation"""
	if competing_routes.is_empty():
		return 1.0  # No competition = 100% market share

	# Calculate competitiveness score for this route
	var this_score: float = calculate_route_competitiveness(route, airline)

	# Calculate scores for all competing routes
	var total_score: float = 0.0
	for competitor in competing_routes:
		var comp_score: float = calculate_route_competitiveness(competitor.route, competitor.airline)
		total_score += comp_score

	# Market share is proportional to competitiveness score
	if total_score > 0:
		return this_score / total_score
	else:
		return 1.0 / competing_routes.size()  # Equal split if no scores

func calculate_route_competitiveness(route: Route, airline: Airline) -> float:
	"""Calculate how competitive a route is (higher = better)"""
	var score: float = 100.0

	# Price competitiveness (lower price = higher score)
	var avg_price: float = (route.price_economy + route.price_business + route.price_first) / 3.0
	var price_factor: float = 1.0 / max(avg_price, 1.0)  # Inverse of price
	score += price_factor * 50000.0  # Scale it appropriately

	# Service quality
	score += route.get_quality_score() * 2.0

	# Airline reputation
	score += airline.reputation * 1.5

	# Frequency bonus (more flights = more convenient)
	score += route.frequency * 5.0

	return max(score, 1.0)  # Ensure positive score

func calculate_connecting_passengers_for_route(route: Route, airline: Airline) -> float:
	"""
	Calculate connecting passengers that use this route as part of a connection
	This route can be either:
	1. First leg (origin→hub): Passengers connecting FROM this route TO other routes
	2. Second leg (hub→destination): Passengers connecting TO this route FROM other routes

	Returns total weekly connecting passengers
	"""
	var total_connecting_pax: float = 0.0

	# Case 1: This route is the FIRST LEG (origin→hub)
	# Look for routes from destination (hub) to other places
	if airline.has_hub(route.to_airport):
		# Route ends at a hub - check for onward connections
		var hub: Airport = route.to_airport

		for second_leg in airline.routes:
			# Must start from same hub
			if second_leg.from_airport != hub:
				continue

			# Must go somewhere different than where we came from
			if second_leg.to_airport == route.from_airport:
				continue

			# Calculate connecting passengers for origin→hub→destination
			var connection: Dictionary = {
				"first_leg": route,
				"second_leg": second_leg,
				"hub": hub,
				"total_distance": route.distance_km + second_leg.distance_km,
				"connection_quality": MarketAnalysis.calculate_connection_quality(route, second_leg, hub)
			}

			# Check if direct competition exists
			var direct_demand: float = 0.0
			for other_airline in GameData.airlines:
				for other_route in other_airline.routes:
					if (other_route.from_airport == route.from_airport and other_route.to_airport == second_leg.to_airport):
						# Direct route exists
						direct_demand = calculate_demand(other_route)
						break

			var connecting_pax: float = MarketAnalysis.calculate_connecting_passenger_demand(
				route.from_airport,
				second_leg.to_airport,
				connection,
				direct_demand
			)

			total_connecting_pax += connecting_pax

	# Case 2: This route is the SECOND LEG (hub→destination)
	# Look for routes to origin (hub) from other places
	if airline.has_hub(route.from_airport):
		# Route starts from a hub - check for inbound connections
		var hub: Airport = route.from_airport

		for first_leg in airline.routes:
			# Must end at same hub
			if first_leg.to_airport != hub:
				continue

			# Must come from somewhere different than where we're going
			if first_leg.from_airport == route.to_airport:
				continue

			# Calculate connecting passengers for origin→hub→destination
			var connection: Dictionary = {
				"first_leg": first_leg,
				"second_leg": route,
				"hub": hub,
				"total_distance": first_leg.distance_km + route.distance_km,
				"connection_quality": MarketAnalysis.calculate_connection_quality(first_leg, route, hub)
			}

			# Check if direct competition exists
			var direct_demand: float = 0.0
			for other_airline in GameData.airlines:
				for other_route in other_airline.routes:
					if (other_route.from_airport == first_leg.from_airport and other_route.to_airport == route.to_airport):
						# Direct route exists
						direct_demand = calculate_demand(other_route)
						break

			var connecting_pax: float = MarketAnalysis.calculate_connecting_passenger_demand(
				first_leg.from_airport,
				route.to_airport,
				connection,
				direct_demand
			)

			total_connecting_pax += connecting_pax

	return total_connecting_pax
