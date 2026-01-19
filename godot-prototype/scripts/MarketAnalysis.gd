extends Node
class_name MarketAnalysis

## Analyzes market demand, supply, and identifies route opportunities

static func analyze_route_opportunity(from: Airport, to: Airport, airlines: Array[Airline]) -> Dictionary:
	"""
	Analyze a potential route and return opportunity metrics
	Returns: {
		demand: float,  # Total potential passengers per week
		supply: float,  # Current capacity being offered
		gap: float,  # Unmet demand (demand - supply)
		competition: int,  # Number of competitors
		profitability_score: float,  # 0-100 score
		market_saturation: float  # 0-1 (0=empty, 1=saturated)
	}
	"""
	var result: Dictionary = {
		"demand": 0.0,
		"supply": 0.0,
		"gap": 0.0,
		"competition": 0,
		"profitability_score": 0.0,
		"market_saturation": 0.0,
		"average_price": 0.0,
		"distance_km": 0.0
	}

	# Calculate distance
	var distance: float = calculate_great_circle_distance(from, to)
	result.distance_km = distance

	# Calculate potential demand
	var demand: float = calculate_potential_demand(from, to, distance)
	result.demand = demand

	# Calculate current supply and competition
	var supply_data: Dictionary = calculate_current_supply(from, to, airlines)
	result.supply = supply_data.total_capacity
	result.competition = supply_data.competitor_count
	result.average_price = supply_data.average_price

	# Calculate opportunity metrics
	result.gap = max(0.0, demand - result.supply)
	result.market_saturation = result.supply / demand if demand > 0 else 0.0
	result.profitability_score = calculate_profitability_score(result, distance)

	return result

static func calculate_potential_demand(from: Airport, to: Airport, distance_km: float) -> float:
	"""
	Calculate potential passenger demand based on:
	- Airport sizes and populations
	- Income levels
	- Distance (affects travel likelihood)
	- Economic relationship between cities
	"""
	# Base demand from population and airport size
	var from_factor: float = (from.population / 1000000.0) * (from.size / 12.0)
	var to_factor: float = (to.population / 1000000.0) * (to.size / 12.0)

	# Geometric mean gives balanced influence
	var population_demand: float = sqrt(from_factor * to_factor) * 500.0

	# Income level multiplier (higher income = more travel)
	var avg_income: float = (from.income_level + to.income_level) / 2.0
	var income_multiplier: float = 0.5 + (avg_income / 100.0)  # 0.5x to 1.4x

	# Distance impact on demand
	var distance_factor: float = get_distance_demand_factor(distance_km)

	# Business vs leisure split affects total demand
	var business_factor: float = 1.0
	if distance_km < 1000:
		business_factor = 1.3  # Short routes have more business travel
	elif distance_km > 8000:
		business_factor = 0.9  # Ultra-long routes have less frequent travel

	# Final demand calculation
	var total_demand: float = population_demand * income_multiplier * distance_factor * business_factor

	return max(50.0, total_demand)  # Minimum viable demand

static func get_distance_demand_factor(distance_km: float) -> float:
	"""Distance sweet spot: medium routes have highest demand per capita"""
	if distance_km < 500:
		return 0.6  # Too short, people drive/train
	elif distance_km < 1500:
		return 1.2  # Sweet spot for domestic flights
	elif distance_km < 3500:
		return 1.0  # Regional international
	elif distance_km < 8000:
		return 0.85  # Long haul
	else:
		return 0.7  # Ultra long haul

static func calculate_current_supply(from: Airport, to: Airport, airlines: Array[Airline]) -> Dictionary:
	"""Calculate total weekly capacity and competition on this route"""
	var total_capacity: float = 0.0
	var competitor_count: int = 0
	var total_price: float = 0.0
	var price_count: int = 0

	for airline in airlines:
		for route in airline.routes:
			# Check if same airport pair (bidirectional)
			var is_same_route: bool = (
				(route.from_airport == from and route.to_airport == to) or
				(route.from_airport == to and route.to_airport == from)
			)

			if is_same_route:
				competitor_count += 1
				var weekly_capacity: float = route.get_total_capacity() * route.frequency
				total_capacity += weekly_capacity

				# Calculate average price (weighted by class distribution)
				var avg_route_price: float = (
					route.price_economy * 0.7 +
					route.price_business * 0.25 +
					route.price_first * 0.05
				)
				total_price += avg_route_price
				price_count += 1

	return {
		"total_capacity": total_capacity,
		"competitor_count": competitor_count,
		"average_price": total_price / price_count if price_count > 0 else 0.0
	}

static func calculate_profitability_score(opportunity: Dictionary, distance_km: float) -> float:
	"""
	Score the profitability of a route opportunity (0-100)
	Higher score = better opportunity
	"""
	var score: float = 50.0  # Start neutral

	# Gap score: More unmet demand = higher score
	if opportunity.gap > 0:
		var gap_ratio: float = opportunity.gap / opportunity.demand
		score += gap_ratio * 40.0  # Up to +40 points

	# Competition penalty
	if opportunity.competition > 0:
		score -= min(opportunity.competition * 8.0, 30.0)  # Up to -30 points

	# Market saturation penalty
	if opportunity.market_saturation > 0.8:
		score -= (opportunity.market_saturation - 0.8) * 100.0  # Oversaturated

	# Distance profitability (medium routes most profitable)
	if distance_km >= 800 and distance_km <= 5000:
		score += 15.0  # Sweet spot bonus
	elif distance_km < 500:
		score -= 10.0  # Too short, low margins

	# Demand volume bonus (high absolute demand is valuable)
	if opportunity.demand > 2000:
		score += 10.0

	return clamp(score, 0.0, 100.0)

static func find_best_opportunities(player_base: Airport, all_airports: Array[Airport], airlines: Array[Airline], top_n: int = 10) -> Array[Dictionary]:
	"""Find the best route opportunities from a given base airport"""
	var opportunities: Array[Dictionary] = []

	for destination in all_airports:
		if destination == player_base:
			continue  # Skip same airport

		var analysis: Dictionary = analyze_route_opportunity(player_base, destination, airlines)
		analysis.from_airport = player_base
		analysis.to_airport = destination

		opportunities.append(analysis)

	# Sort by profitability score (descending)
	opportunities.sort_custom(func(a, b): return a.profitability_score > b.profitability_score)

	# Return top N
	return opportunities.slice(0, min(top_n, opportunities.size()))

static func get_recommended_pricing(demand: float, supply: float, distance_km: float, competition: int) -> Dictionary:
	"""Calculate recommended pricing for each class"""
	# Base price from distance
	var base_economy: float = 50.0 + (distance_km * 0.15)

	# Adjust for supply/demand balance
	var demand_multiplier: float = 1.0
	if supply > 0:
		var saturation: float = supply / demand
		if saturation < 0.7:
			demand_multiplier = 1.2  # High demand, can charge more
		elif saturation > 1.2:
			demand_multiplier = 0.85  # Oversupply, must discount

	# Competition adjustment
	var competition_penalty: float = max(0.85, 1.0 - (competition * 0.05))

	# Calculate prices
	var economy: float = base_economy * demand_multiplier * competition_penalty
	var business: float = economy * 2.5
	var first: float = economy * 5.0

	return {
		"economy": round(economy),
		"business": round(business),
		"first": round(first)
	}

static func calculate_great_circle_distance(from: Airport, to: Airport) -> float:
	"""Calculate great circle distance between two airports"""
	var lat1: float = deg_to_rad(from.latitude)
	var lon1: float = deg_to_rad(from.longitude)
	var lat2: float = deg_to_rad(to.latitude)
	var lon2: float = deg_to_rad(to.longitude)

	var dlat: float = lat2 - lat1
	var dlon: float = lon2 - lon1

	var a: float = sin(dlat/2) * sin(dlat/2) + cos(lat1) * cos(lat2) * sin(dlon/2) * sin(dlon/2)
	var c: float = 2 * atan2(sqrt(a), sqrt(1-a))
	var earth_radius_km: float = 6371.0

	return earth_radius_km * c
