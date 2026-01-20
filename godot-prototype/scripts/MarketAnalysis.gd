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
	Calculate total bidirectional passenger demand
	This is the sum of outbound demand (from → to) and inbound demand (to → from)
	"""
	var bidirectional: Dictionary = calculate_bidirectional_demand(from, to, distance_km)
	return bidirectional.total_demand

static func calculate_bidirectional_demand(from: Airport, to: Airport, distance_km: float) -> Dictionary:
	"""
	Calculate bidirectional demand with separate business and tourist components
	Returns: {
		outbound_business: float,
		outbound_tourist: float,
		inbound_business: float,
		inbound_tourist: float,
		outbound_total: float,
		inbound_total: float,
		total_demand: float
	}
	"""
	# Calculate outbound demand (from → to)
	var outbound_business: float = calculate_directional_business_demand(from, to, distance_km)
	var outbound_tourist: float = calculate_directional_tourist_demand(from, to, distance_km)
	var outbound_total: float = outbound_business + outbound_tourist

	# Calculate inbound demand (to → from) - reverse direction
	var inbound_business: float = calculate_directional_business_demand(to, from, distance_km)
	var inbound_tourist: float = calculate_directional_tourist_demand(to, from, distance_km)
	var inbound_total: float = inbound_business + inbound_tourist

	return {
		"outbound_business": outbound_business,
		"outbound_tourist": outbound_tourist,
		"inbound_business": inbound_business,
		"inbound_tourist": inbound_tourist,
		"outbound_total": outbound_total,
		"inbound_total": inbound_total,
		"total_demand": outbound_total + inbound_total
	}

static func calculate_directional_business_demand(from: Airport, to: Airport, distance_km: float) -> float:
	"""Calculate business traveler demand FROM one airport TO another (directional)"""
	# Business demand driven by:
	# 1. Origin economic strength (GDP per capita)
	# 2. Destination business importance (hub tier, passenger volume)
	# 3. Distance (business travel peaks at medium distances)

	# Origin economic factor (wealthy cities generate more business travel)
	var origin_gdp_factor: float = from.gdp_per_capita / 50000.0  # Normalized around $50k
	var origin_business: float = origin_gdp_factor * from.annual_passengers * 0.8

	# Destination attractiveness for business
	var dest_hub_factor: float = get_hub_business_factor(to.hub_tier)
	var dest_business: float = to.annual_passengers * dest_hub_factor * 0.5

	# Combined business demand (asymmetric - origin weighted more)
	var base_business: float = (origin_business * 0.7 + dest_business * 0.3) * 2.0

	# Distance factor for business travel
	var distance_factor: float = get_business_distance_factor(distance_km)

	return max(10.0, base_business * distance_factor)

static func calculate_directional_tourist_demand(from: Airport, to: Airport, distance_km: float) -> float:
	"""Calculate tourist/leisure traveler demand FROM one airport TO another (directional)"""
	# Tourist demand driven by:
	# 1. Origin population/wealth (ability to travel)
	# 2. Destination tourism attractiveness
	# 3. Distance (tourists prefer medium-long haul)

	# Origin tourist generation (wealthy populations travel more)
	var origin_wealth_factor: float = from.gdp_per_capita / 50000.0
	var origin_tourist_gen: float = from.annual_passengers * origin_wealth_factor * 0.6

	# Destination tourism attractiveness
	var dest_tourism: float = get_tourism_attractiveness(to)

	# Combined tourist demand (destination weighted heavily)
	var base_tourist: float = (origin_tourist_gen * 0.4 + dest_tourism * 0.6) * 2.5

	# Distance factor for tourism (different from business)
	var distance_factor: float = get_tourist_distance_factor(distance_km)

	return max(15.0, base_tourist * distance_factor)

static func get_hub_business_factor(hub_tier: int) -> float:
	"""Business importance multiplier by hub tier"""
	match hub_tier:
		1: return 2.5  # Mega hubs are major business centers
		2: return 2.0  # Major hubs
		3: return 1.3  # Regional hubs
		4: return 0.8  # Small airports
		_: return 1.0

static func get_tourism_attractiveness(airport: Airport) -> float:
	"""Calculate tourism attractiveness of destination"""
	# Base on passenger volume and region
	var base: float = airport.annual_passengers * 1.2

	# Regional tourism multipliers (simplified - can be expanded)
	var region_multiplier: float = 1.0
	match airport.region:
		"Middle East": region_multiplier = 1.4  # Dubai, etc.
		"Europe": region_multiplier = 1.3  # High tourism
		"Asia": region_multiplier = 1.2  # Growing tourism
		"Oceania": region_multiplier = 1.3  # Australia, NZ
		"North America": region_multiplier = 1.1  # Mixed
		_: region_multiplier = 1.0

	# Tier bonus (mega hubs attract tourists)
	var tier_bonus: float = 1.0
	if airport.hub_tier == 1:
		tier_bonus = 1.5
	elif airport.hub_tier == 2:
		tier_bonus = 1.2

	return base * region_multiplier * tier_bonus

static func get_business_distance_factor(distance_km: float) -> float:
	"""Business travel distance preference (peaks at medium distances)"""
	if distance_km < 300:
		return 0.4  # Too short, drive/train instead
	elif distance_km < 1500:
		return 1.5  # Perfect for business day trips
	elif distance_km < 3500:
		return 1.2  # Regional business travel
	elif distance_km < 8000:
		return 0.9  # Long haul business (less frequent)
	else:
		return 0.6  # Ultra long haul (rare business travel)

static func get_tourist_distance_factor(distance_km: float) -> float:
	"""Tourist travel distance preference (different from business)"""
	if distance_km < 800:
		return 0.5  # Too short for tourism flights
	elif distance_km < 2500:
		return 1.0  # Regional tourism
	elif distance_km < 6000:
		return 1.3  # International tourism sweet spot
	elif distance_km < 12000:
		return 1.1  # Long haul tourism
	else:
		return 0.8  # Ultra long haul (exotic destinations)

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
