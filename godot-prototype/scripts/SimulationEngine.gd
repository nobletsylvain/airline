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

## ============================================================================
## PRICE ELASTICITY PARAMETERS (G.2)
## Hypothesis values - adjust during playtesting
## ============================================================================

# Elasticity factor: how sensitive demand is to price changes
# 1.0 = unit elastic (10% price increase = 10% demand decrease)
# 1.2 = elastic (leisure market - more price sensitive)
# 0.8 = inelastic (business routes - less price sensitive)
const ELASTICITY_FACTOR_DEFAULT: float = 1.2  # Hypothesis: elastic leisure market

# Baseline price per km for calculating "fair" price
# Regional turboprop routes: ~€0.15/km is competitive baseline
const BASELINE_PRICE_PER_KM: float = 0.15

# Minimum base price (even for very short routes)
const BASELINE_PRICE_MINIMUM: float = 50.0

# Elasticity bounds to prevent extreme swings
const ELASTICITY_MULTIPLIER_MIN: float = 0.3  # Price at 3x baseline = 30% demand
const ELASTICITY_MULTIPLIER_MAX: float = 2.0  # Price at 0.5x baseline = cap at 200%

@export var auto_simulate: bool = false

var is_running: bool = false
var time_accumulator: float = 0.0  # Accumulates in game hours (0-168 per week)
var current_speed_level: SpeedLevel = SpeedLevel.NORMAL
var seconds_per_hour: float = 2.0  # Current speed setting

# Day tracking for pending price system (G.6)
# Week has 7 days, each day = 24 hours
var current_day_in_week: int = 0  # 0-6 (Monday=0, Sunday=6)

signal simulation_started()
signal simulation_paused()
signal speed_changed(speed_level: SpeedLevel, speed_name: String)
signal week_completed(week_number: int)
signal day_completed(day_number: int)  # G.6: Signal for day tick
signal route_simulated(route: Route, passengers: int, revenue: float)
signal pending_prices_applied(routes_changed: int)  # G.6: Signal when prices update

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
	var old_hour: float = time_accumulator
	time_accumulator += hours_elapsed

	# Update GameData with current hour (for live time display)
	GameData.current_hour = time_accumulator

	# === DAY TICK (G.6): Check if a new day has started ===
	# Each day = 24 hours, days are 0-6 (Monday-Sunday)
	var old_day: int = int(old_hour / 24.0)
	var new_day: int = int(time_accumulator / 24.0)
	
	# Day changed within the week (not crossing week boundary)
	if new_day > old_day and new_day < 7:
		current_day_in_week = new_day
		process_day_tick(new_day)

	# Check if a week has passed (168 hours)
	if time_accumulator >= 168.0:
		time_accumulator = fmod(time_accumulator, 168.0)
		GameData.current_hour = time_accumulator
		current_day_in_week = 0  # Reset to Monday
		
		# Apply pending prices at week start (new Monday)
		process_day_tick(0)
		
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
	process_delegate_tasks()

	# Update objectives after simulation
	if GameData.objective_system:
		GameData.objective_system.check_objectives_from_game_state()

	# Notify tutorial of simulation
	if GameData.tutorial_manager:
		GameData.tutorial_manager.on_action_performed("run_simulation")

	week_completed.emit(GameData.current_week)
	print("=== Week %d Complete ===" % GameData.current_week)


## ============================================================================
## DAY TICK PROCESSING (G.6)
## Handles daily events like applying pending price changes
## ============================================================================

func process_day_tick(day: int) -> void:
	"""Process daily events - called at start of each new day (24-hour boundary)"""
	var day_names: Array[String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	var day_name: String = day_names[day] if day < day_names.size() else "Day %d" % day
	
	print("\n--- %s (Day %d of Week %d) ---" % [day_name, day + 1, GameData.current_week + 1])
	
	# Apply any pending price changes
	var routes_changed: int = apply_all_pending_prices()
	
	if routes_changed > 0:
		print("Applied price changes to %d route(s)" % routes_changed)
		pending_prices_applied.emit(routes_changed)
	
	# Emit day completed signal
	day_completed.emit(day)


func apply_all_pending_prices() -> int:
	"""Apply pending price changes across all airlines' routes. Returns count of changed routes."""
	var changed_count: int = 0
	
	for airline in GameData.airlines:
		for route in airline.routes:
			if route.has_pending_price_changes():
				if route.apply_pending_prices():
					changed_count += 1
	
	return changed_count


func get_current_day_name() -> String:
	"""Get the name of the current day in the week"""
	var day_names: Array[String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	if current_day_in_week >= 0 and current_day_in_week < day_names.size():
		return day_names[current_day_in_week]
	return "Unknown"


func get_hours_until_next_day() -> float:
	"""Get hours remaining until the next day tick"""
	var current_hour_in_day: float = fmod(time_accumulator, 24.0)
	return 24.0 - current_hour_in_day


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

	# === PRICE ELASTICITY (G.2): Adjust demand based on pricing ===
	var elasticity_factor: float = get_elasticity_factor_for_route(route)
	var elasticity_data: Dictionary = calculate_price_elasticity(route, elasticity_factor)
	var elasticity_multiplier: float = elasticity_data.multiplier
	
	# Debug: Show demand BEFORE elasticity
	var demand_before_elasticity: float = route_demand
	
	# Apply elasticity to demand
	route_demand *= elasticity_multiplier
	
	# Debug: Show elasticity impact
	print("    [Elasticity] %s: base_demand=%.0f, market_share=%.2f, demand_before=%.0f, multiplier=%.2f, demand_after=%.0f" % [
		route.get_display_name(),
		base_demand,
		market_share,
		demand_before_elasticity,
		elasticity_multiplier,
		route_demand
	])
	print("    [Pricing] price=€%.0f, baseline=€%.0f, deviation=%.0f%%" % [
		route.price_economy,
		elasticity_data.baseline_price,
		elasticity_data.price_deviation_pct
	])
	
	# Store elasticity data on route for UI display
	route.set_meta("elasticity_multiplier", elasticity_multiplier)
	route.set_meta("baseline_price", elasticity_data.baseline_price)
	route.set_meta("is_overpriced", elasticity_data.is_overpriced)
	route.set_meta("price_deviation_pct", elasticity_data.price_deviation_pct)

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
	
	# Debug: Cost breakdown
	print("    [Costs] fuel=€%.0f, crew=€%.0f, mx=€%.0f, airport=€%.0f, TOTAL=€%.0f" % [
		fuel_cost, crew_cost, maintenance_cost, airport_fees, total_costs
	])

	# Update route stats
	route.passengers_transported = economy_passengers + business_passengers + first_passengers
	route.revenue_generated = total_revenue
	route.fuel_cost = fuel_cost
	route.weekly_profit = total_revenue - total_costs
	
	# Debug: Show final passenger calculation
	var load_factor: float = float(route.passengers_transported) / float(total_capacity) * 100.0 if total_capacity > 0 else 0.0
	print("    [Final] passengers=%d/%d capacity (%.0f%% LF), revenue=€%.0f, profit=€%.0f" % [
		route.passengers_transported,
		total_capacity,
		load_factor,
		total_revenue,
		route.weekly_profit
	])

	# Update airline stats
	airline.weekly_revenue += total_revenue
	airline.weekly_expenses += total_costs
	airline.total_revenue += total_revenue
	airline.total_expenses += total_costs

	# Degrade aircraft condition
	for aircraft in route.assigned_aircraft:
		aircraft.degrade_condition(0.5 * route.frequency)  # Small degradation per flight

	route_simulated.emit(route, route.passengers_transported, total_revenue)

	# Debug output with elasticity info
	var price_status: String = "fair"
	if elasticity_data.is_overpriced:
		price_status = "+%.0f%% overpriced" % elasticity_data.price_deviation_pct
	elif elasticity_data.price_deviation_pct < -5:
		price_status = "%.0f%% discount" % abs(elasticity_data.price_deviation_pct)
	
	print("  Route %s: %d pax, $%.0f revenue, $%.0f profit (price: €%.0f, baseline: €%.0f, %s, demand x%.2f)" % [
		route.get_display_name(),
		route.passengers_transported,
		total_revenue,
		route.weekly_profit,
		route.price_economy,
		elasticity_data.baseline_price,
		price_status,
		elasticity_multiplier
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


## ============================================================================
## PRICE ELASTICITY (G.2)
## ============================================================================

func calculate_price_elasticity(route: Route, elasticity_factor: float = ELASTICITY_FACTOR_DEFAULT) -> Dictionary:
	"""
	Calculate price elasticity multiplier for a route.
	
	Formula: elasticity_multiplier = (baseline_price / actual_price) ^ elasticity_factor
	
	Returns: {
		multiplier: float,  # Demand multiplier (0.3 to 2.0)
		baseline_price: float,  # Calculated fair price
		actual_price: float,  # Current route economy price
		price_ratio: float,  # baseline / actual
		is_overpriced: bool,  # Price above baseline
		price_deviation_pct: float  # How much above/below baseline (%)
	}
	"""
	# Calculate baseline "fair" price based on distance
	# Regional routes: €0.15/km base + minimum floor
	var baseline_price: float = max(
		BASELINE_PRICE_MINIMUM,
		route.distance_km * BASELINE_PRICE_PER_KM
	)
	
	# Get actual economy price (primary driver of volume)
	var actual_price: float = route.price_economy
	
	# Safety: prevent division by zero
	if actual_price <= 0:
		actual_price = baseline_price
	
	# Calculate price ratio (baseline / actual)
	var price_ratio: float = baseline_price / actual_price
	
	# Calculate elasticity multiplier
	# If actual_price > baseline: ratio < 1, multiplier < 1 (fewer passengers)
	# If actual_price < baseline: ratio > 1, multiplier > 1 (more passengers)
	var multiplier: float = pow(price_ratio, elasticity_factor)
	
	# Clamp to prevent extreme values
	multiplier = clamp(multiplier, ELASTICITY_MULTIPLIER_MIN, ELASTICITY_MULTIPLIER_MAX)
	
	# Calculate deviation percentage for UI display
	var price_deviation_pct: float = ((actual_price - baseline_price) / baseline_price) * 100.0
	
	return {
		"multiplier": multiplier,
		"baseline_price": baseline_price,
		"actual_price": actual_price,
		"price_ratio": price_ratio,
		"is_overpriced": actual_price > baseline_price,
		"price_deviation_pct": price_deviation_pct,
		"elasticity_factor": elasticity_factor
	}


func get_elasticity_factor_for_route(route: Route) -> float:
	"""
	Get the appropriate elasticity factor for a route.
	
	Can be customized based on:
	- Route distance (short = more elastic, long-haul business = less elastic)
	- Time of day (future: business hours less elastic)
	- Competitor presence
	
	For prototype: return default elasticity factor.
	"""
	# PROTOTYPE: Use uniform elasticity factor
	# Future enhancement: vary by route characteristics
	var factor: float = ELASTICITY_FACTOR_DEFAULT
	
	# Short regional routes are more price-sensitive (leisure travelers)
	if route.distance_km < 800:
		factor = 1.4  # More elastic
	elif route.distance_km > 3000:
		factor = 1.0  # Less elastic (business travelers on long-haul)
	
	return factor

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
	"""Calculate fuel cost for a route based on aircraft daily operating cost.
	Uses aircraft's daily_cost metadata which includes fuel + crew + maintenance reserve.
	"""
	# Get aircraft daily cost from metadata (set by DataLoader from JSON)
	var daily_cost: float = 3500.0  # Default fallback
	if not route.assigned_aircraft.is_empty():
		var aircraft = route.assigned_aircraft[0]
		daily_cost = aircraft.model.get_meta("daily_cost", 3500.0)
	
	# Calculate weekly operating cost based on utilization
	# Aircraft flies route.frequency times per week, each flight uses flight_duration_hours
	# Daily cost covers ~8-10 hours of operation, so scale by actual flight hours
	var flight_hours_per_week: float = route.flight_duration_hours * route.frequency * 2  # Round trip
	var hours_per_day: float = 8.0  # Assumed daily utilization capacity
	var days_equivalent: float = flight_hours_per_week / hours_per_day
	
	return daily_cost * days_equivalent


func calculate_crew_cost(route: Route) -> float:
	"""Calculate crew costs - included in daily_cost, so minimal extra here"""
	# Crew cost is already factored into daily_cost
	# Only add per-flight allowances/per diems
	var per_diem_per_flight: float = 150.0  # Crew allowances
	return per_diem_per_flight * route.frequency


func calculate_maintenance_cost(route: Route) -> float:
	"""Calculate maintenance costs - included in daily_cost reserve"""
	# Maintenance reserve is in daily_cost, but add cycle-based wear
	var cost_per_cycle: float = 50.0  # Per takeoff/landing cycle
	return cost_per_cycle * route.frequency


func calculate_airport_fees(route: Route, passengers: int) -> float:
	"""Calculate airport landing and passenger fees"""
	# Use actual airport fees if available, but scale to realistic ATR 72 levels
	# JSON values are for large aircraft - divide by 10 for regional turboprops
	var landing_fee: float = 300.0  # Default per landing for ATR 72
	var passenger_fee: float = 5.0   # Per passenger
	
	if route.from_airport:
		# Scale down JSON values (designed for widebodies) to regional turboprop levels
		var json_landing = route.from_airport.landing_fee if route.from_airport.landing_fee > 0 else 3000.0
		landing_fee = json_landing / 10.0  # €8000 → €800
		
		var json_pax_fee = route.from_airport.passenger_fee if route.from_airport.passenger_fee > 0 else 50.0
		passenger_fee = json_pax_fee / 3.0  # €15 → €5
	
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

func process_delegate_tasks() -> void:
	"""Process delegate tasks for all airlines"""
	for airline in GameData.airlines:
		airline.process_delegate_tasks()

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
