extends Node
class_name AIController

## AI decision-making controller for NPC airlines

enum AIPersonality {
	AGGRESSIVE,   # Expands fast, takes risks, low prices
	CONSERVATIVE, # Slow growth, careful spending, premium prices
	BALANCED      # Mix of both strategies
}

var controlled_airline: Airline
var personality: AIPersonality = AIPersonality.BALANCED
var decision_cooldown: int = 0  # Weeks until next major decision
var min_cash_reserve: float = 10000000.0  # Keep $10M minimum

# Personality-specific parameters
var expansion_threshold: float = 0.7  # How full routes need to be before expanding
var price_multiplier: float = 1.0    # Pricing strategy (0.8 = aggressive, 1.2 = premium)
var loan_willingness: float = 0.5    # How willing to take loans (0-1)
var risk_tolerance: float = 0.5      # Risk appetite (0-1)

func _init(airline: Airline, ai_personality: AIPersonality = AIPersonality.BALANCED):
	controlled_airline = airline
	personality = ai_personality
	apply_personality_settings()

func apply_personality_settings() -> void:
	"""Apply personality-specific parameters"""
	match personality:
		AIPersonality.AGGRESSIVE:
			expansion_threshold = 0.5
			price_multiplier = 0.85  # Undercut competition by 15%
			loan_willingness = 0.8
			risk_tolerance = 0.8
			min_cash_reserve = 5000000.0
		AIPersonality.CONSERVATIVE:
			expansion_threshold = 0.9
			price_multiplier = 1.15  # Premium pricing
			loan_willingness = 0.2
			risk_tolerance = 0.3
			min_cash_reserve = 30000000.0
		AIPersonality.BALANCED:
			expansion_threshold = 0.7
			price_multiplier = 1.0
			loan_willingness = 0.5
			risk_tolerance = 0.5
			min_cash_reserve = 15000000.0

func make_decisions(week: int) -> void:
	"""Main AI decision-making function called each week"""
	if not controlled_airline:
		return

	# Reduce cooldown
	if decision_cooldown > 0:
		decision_cooldown -= 1
		return

	# Check if we need emergency measures
	if controlled_airline.balance < min_cash_reserve * 0.5:
		handle_financial_crisis()
		return

	# Normal decision-making
	consider_loan()
	consider_aircraft_purchase()
	consider_route_expansion()
	adjust_pricing()

	# Set cooldown before next major decision (2-4 weeks)
	decision_cooldown = randi_range(2, 4)

func consider_loan() -> void:
	"""Decide whether to take out a loan"""
	# Skip if we already have too much debt
	if controlled_airline.total_debt > controlled_airline.balance * 2:
		return

	# Calculate if we need a loan
	var cash_available: float = controlled_airline.balance - min_cash_reserve

	# Want to buy aircraft but don't have cash?
	if cash_available < 50000000.0 and randf() < loan_willingness:
		var credit_limit: float = controlled_airline.get_credit_limit()

		if credit_limit > 20000000.0:
			# Take a loan for 50-70% of credit limit
			var loan_amount: float = credit_limit * randf_range(0.5, 0.7)
			var term: int = 52 * randi_range(2, 4)  # 2-4 years

			var loan: Loan = GameData.create_loan(controlled_airline, loan_amount, term)
			if loan:
				print("AI %s took loan: $%.0fM at %.1f%%" % [
					controlled_airline.name,
					loan_amount / 1000000.0,
					loan.interest_rate * 100
				])

func consider_aircraft_purchase() -> void:
	"""Decide whether to purchase aircraft"""
	# Count available (unassigned) aircraft
	var available_aircraft: int = 0
	for aircraft in controlled_airline.aircraft:
		if not aircraft.is_assigned:
			available_aircraft += 1

	# If we have available aircraft, don't buy more yet
	if available_aircraft > 0:
		return

	# Check if we can afford an aircraft
	var cash_available: float = controlled_airline.balance - min_cash_reserve

	# Find affordable aircraft
	var affordable_models: Array[AircraftModel] = []
	for model in GameData.aircraft_models:
		if model.price <= cash_available:
			affordable_models.append(model)

	if affordable_models.is_empty():
		return

	# Choose aircraft based on personality
	var chosen_model: AircraftModel = null

	match personality:
		AIPersonality.AGGRESSIVE:
			# Buy cheapest to maximize fleet size
			chosen_model = affordable_models[0]
			for model in affordable_models:
				if model.price < chosen_model.price:
					chosen_model = model

		AIPersonality.CONSERVATIVE:
			# Buy most expensive (best quality)
			chosen_model = affordable_models[0]
			for model in affordable_models:
				if model.price > chosen_model.price:
					chosen_model = model

		AIPersonality.BALANCED:
			# Buy mid-range
			affordable_models.sort_custom(func(a, b): return a.price < b.price)
			chosen_model = affordable_models[affordable_models.size() / 2]

	if chosen_model:
		var aircraft: AircraftInstance = GameData.purchase_aircraft(controlled_airline, chosen_model)
		if aircraft:
			print("AI %s purchased: %s (ID:%d) for $%.0fM" % [
				controlled_airline.name,
				chosen_model.get_display_name(),
				aircraft.id,
				chosen_model.price / 1000000.0
			])

func consider_route_expansion() -> void:
	"""Decide whether to create new routes"""
	# Check if we have available aircraft
	var available_aircraft: Array[AircraftInstance] = []
	for aircraft in controlled_airline.aircraft:
		if not aircraft.is_assigned:
			available_aircraft.append(aircraft)

	if available_aircraft.is_empty():
		return

	# Check current route performance
	var average_load_factor: float = calculate_average_load_factor()

	# Only expand if existing routes are doing well
	if average_load_factor < expansion_threshold and controlled_airline.routes.size() > 0:
		return

	# Find profitable route opportunities
	var best_route: Dictionary = find_best_route_opportunity(available_aircraft)

	if best_route.is_empty():
		return

	# Create the route
	create_ai_route(best_route.from_airport, best_route.to_airport, best_route.aircraft)

func calculate_average_load_factor() -> float:
	"""Calculate average load factor across all routes"""
	if controlled_airline.routes.is_empty():
		return 1.0  # Assume good if no routes

	var total_load: float = 0.0
	for route in controlled_airline.routes:
		var capacity: float = route.get_total_capacity() * route.frequency
		if capacity > 0:
			total_load += float(route.passengers_transported) / capacity

	return total_load / controlled_airline.routes.size()

func find_best_route_opportunity(available_aircraft: Array[AircraftInstance]) -> Dictionary:
	"""Find the most promising route to create"""
	var best_route: Dictionary = {}
	var best_score: float = 0.0

	# Get a sample of airports to consider (not all 47, that's too expensive)
	var airports_to_check: Array[Airport] = []
	var all_airports: Array[Airport] = GameData.airports.duplicate()
	all_airports.shuffle()
	airports_to_check = all_airports.slice(0, min(20, all_airports.size()))  # Check up to 20 random airports

	for from_airport in airports_to_check:
		for to_airport in airports_to_check:
			if from_airport == to_airport:
				continue

			# Check if we already have this route
			if has_route_between(from_airport, to_airport):
				continue

			# Calculate route potential
			var temp_route: Route = Route.new(from_airport, to_airport, controlled_airline.id)

			# Check if we have aircraft that can fly this
			var suitable_aircraft: AircraftInstance = null
			for aircraft in available_aircraft:
				if aircraft.model.can_fly_distance(temp_route.distance_km):
					suitable_aircraft = aircraft
					break

			if not suitable_aircraft:
				continue

			# Score the route
			var score: float = evaluate_route_potential(temp_route, from_airport, to_airport)

			if score > best_score:
				best_score = score
				best_route = {
					"from_airport": from_airport,
					"to_airport": to_airport,
					"aircraft": suitable_aircraft,
					"score": score
				}

	return best_route

func evaluate_route_potential(route: Route, from: Airport, to: Airport) -> float:
	"""Score a route's potential profitability"""
	var score: float = 0.0

	# Airport size matters
	score += from.size * 10
	score += to.size * 10

	# Population matters
	score += (from.population / 1000000.0) * 5
	score += (to.population / 1000000.0) * 5

	# Distance sweet spot (not too short, not too long)
	if route.distance_km >= 500 and route.distance_km <= 5000:
		score += 50
	elif route.distance_km > 5000:
		score += 20  # Long haul is riskier

	# Check competition on this route
	var competition_count: int = count_competition_on_route(from, to)
	score -= competition_count * 30  # Penalty for competition

	# Add randomness based on risk tolerance
	score += randf_range(-20, 20) * risk_tolerance

	return score

func count_competition_on_route(from: Airport, to: Airport) -> int:
	"""Count how many airlines already serve this route"""
	var count: int = 0
	for airline in GameData.airlines:
		if airline.id == controlled_airline.id:
			continue
		for route in airline.routes:
			if (route.from_airport == from and route.to_airport == to) or \
			   (route.from_airport == to and route.to_airport == from):
				count += 1
	return count

func has_route_between(from: Airport, to: Airport) -> bool:
	"""Check if AI already has a route between these airports"""
	for route in controlled_airline.routes:
		if (route.from_airport == from and route.to_airport == to) or \
		   (route.from_airport == to and route.to_airport == from):
			return true
	return false

func create_ai_route(from_airport: Airport, to_airport: Airport, aircraft: AircraftInstance) -> void:
	"""Create a new route for the AI airline"""
	var route: Route = Route.new(from_airport, to_airport, controlled_airline.id)

	# Assign aircraft
	route.assign_aircraft(aircraft)

	# Set capacity from aircraft
	route.capacity_economy = aircraft.model.capacity_economy
	route.capacity_business = aircraft.model.capacity_business
	route.capacity_first = aircraft.model.capacity_first
	route.frequency = 7  # Daily

	# Set quality
	route.service_quality = controlled_airline.service_quality
	route.aircraft_condition = aircraft.condition

	# Set pricing based on personality
	route.price_economy = route.calculate_base_price(route.distance_km, "economy") * price_multiplier
	route.price_business = route.calculate_base_price(route.distance_km, "business") * price_multiplier
	route.price_first = route.calculate_base_price(route.distance_km, "first") * price_multiplier

	# Add to airline
	controlled_airline.add_route(route)

	print("AI %s created route: %s (%.0fkm) with %s pricing" % [
		controlled_airline.name,
		route.get_display_name(),
		route.distance_km,
		"aggressive" if price_multiplier < 1.0 else ("premium" if price_multiplier > 1.0 else "standard")
	])

func adjust_pricing() -> void:
	"""Adjust prices on existing routes based on performance"""
	for route in controlled_airline.routes:
		var load_factor: float = 0.0
		var capacity: float = route.get_total_capacity() * route.frequency
		if capacity > 0:
			load_factor = float(route.passengers_transported) / capacity

		# If load factor too high, raise prices
		if load_factor > 0.95:
			route.price_economy *= 1.05
			route.price_business *= 1.05
			route.price_first *= 1.05

		# If load factor too low, lower prices
		elif load_factor < 0.5:
			route.price_economy *= 0.95
			route.price_business *= 0.95
			route.price_first *= 0.95

func handle_financial_crisis() -> void:
	"""Emergency measures when running low on cash"""
	print("AI %s in financial crisis! Balance: $%.0fM" % [
		controlled_airline.name,
		controlled_airline.balance / 1000000.0
	])

	# Try to get emergency loan
	var credit_limit: float = controlled_airline.get_credit_limit()
	if credit_limit > 5000000.0:
		var loan: Loan = GameData.create_loan(controlled_airline, credit_limit * 0.8, 52)
		if loan:
			print("AI %s took emergency loan: $%.0fM" % [
				controlled_airline.name,
				loan.principal / 1000000.0
			])

	# Lower all prices to try to increase revenue
	for route in controlled_airline.routes:
		route.price_economy *= 0.8
		route.price_business *= 0.8
		route.price_first *= 0.8

	decision_cooldown = 8  # Wait 8 weeks before next decision

func get_personality_name() -> String:
	"""Get human-readable personality name"""
	match personality:
		AIPersonality.AGGRESSIVE:
			return "Aggressive"
		AIPersonality.CONSERVATIVE:
			return "Conservative"
		AIPersonality.BALANCED:
			return "Balanced"
	return "Unknown"
