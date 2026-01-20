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

## ========================================
## HUB NETWORK EFFECTS (Phase 1.2)
## ========================================

static func find_connecting_routes(origin: Airport, destination: Airport, airline: Airline) -> Array[Dictionary]:
	"""
	Find all possible connections from origin to destination through airline's hubs
	Returns array of connection dictionaries with structure:
	{
		first_leg: Route,  # origin → hub
		second_leg: Route,  # hub → destination
		hub: Airport,  # connecting hub
		total_distance: float,
		connection_quality: float  # 0-100 score
	}
	"""
	var connections: Array[Dictionary] = []

	# For each route from origin
	for first_route in airline.routes:
		# Must originate from origin airport
		if first_route.from_airport != origin:
			continue

		var hub: Airport = first_route.to_airport

		# Hub must be in airline's hub list (for creating second leg)
		if not airline.has_hub(hub):
			continue

		# Look for routes from this hub to destination
		for second_route in airline.routes:
			if second_route.from_airport == hub and second_route.to_airport == destination:
				# Found a connection!
				var total_distance: float = first_route.distance_km + second_route.distance_km
				var quality: float = calculate_connection_quality(first_route, second_route, hub)

				connections.append({
					"first_leg": first_route,
					"second_leg": second_route,
					"hub": hub,
					"total_distance": total_distance,
					"connection_quality": quality
				})

	return connections

static func calculate_connection_quality(first_leg: Route, second_leg: Route, hub: Airport) -> float:
	"""
	Calculate connection quality score (0-100)
	Higher = better connection

	Factors:
	- Layover time compatibility (frequency-based approximation)
	- Hub size (smaller hubs = easier connections, less congestion)
	- Distance efficiency (total distance vs direct distance)
	"""
	var score: float = 50.0  # Start neutral

	# 1. Frequency score (higher frequency = more connection opportunities)
	var min_frequency: int = min(first_leg.frequency, second_leg.frequency)
	if min_frequency >= 7:  # Daily on both legs
		score += 20.0
	elif min_frequency >= 3:  # 3+ times per week
		score += 10.0
	elif min_frequency == 1:  # Once per week (risky)
		score -= 10.0

	# 2. Hub congestion penalty (mega hubs are crowded, harder to connect)
	match hub.hub_tier:
		1:  # Mega hub
			score -= 15.0  # Crowded, long walking distances
		2:  # Major hub
			score -= 5.0  # Some congestion
		3:  # Regional hub
			score += 5.0  # Good balance
		4:  # Small airport
			score += 10.0  # Easy connections, but less frequent flights

	# 3. Distance efficiency (penalize very indirect routes)
	# Calculate if this connection makes geographic sense
	var direct_distance: float = calculate_great_circle_distance(
		first_leg.from_airport,
		second_leg.to_airport
	)
	var total_connection_distance: float = first_leg.distance_km + second_leg.distance_km

	if direct_distance > 0:
		var efficiency_ratio: float = direct_distance / total_connection_distance
		if efficiency_ratio > 0.85:  # Nearly direct
			score += 15.0
		elif efficiency_ratio > 0.70:  # Reasonable detour
			score += 5.0
		elif efficiency_ratio < 0.50:  # Very indirect (backtracking)
			score -= 20.0

	return clamp(score, 0.0, 100.0)

static func calculate_connecting_passenger_demand(
	origin: Airport,
	destination: Airport,
	connection: Dictionary,
	direct_demand: float
) -> float:
	"""
	Calculate potential connecting passengers through a hub

	Args:
		origin: Starting airport
		destination: Final destination
		connection: Connection dictionary from find_connecting_routes()
		direct_demand: Direct demand for origin→destination route (if exists)

	Returns:
		Weekly connecting passengers who would use this connection
	"""
	# Base connecting demand is a fraction of what direct demand would be
	# People prefer direct flights, so connecting is always secondary
	var base_connecting_demand: float = calculate_potential_demand(origin, destination, 0.0)

	# Connection appeal factor (0.0 to 1.0)
	# High quality connection = more people willing to connect
	# Low quality = very few people willing to connect
	var quality_factor: float = connection.connection_quality / 100.0

	# Direct flight penalty
	# If direct flight exists with capacity, very few people will connect
	var direct_competition_factor: float = 1.0
	if direct_demand > 0:
		# Significantly reduce connecting demand if direct option exists
		direct_competition_factor = 0.15  # Only 15% would consider connecting

	# Distance penalty
	# Long connections are less attractive
	var distance_penalty: float = 1.0
	if connection.total_distance > 10000:  # Very long connection
		distance_penalty = 0.6
	elif connection.total_distance > 6000:  # Long connection
		distance_penalty = 0.8

	# Calculate final connecting demand
	var connecting_pax: float = base_connecting_demand * quality_factor * direct_competition_factor * distance_penalty

	# Minimum threshold - very low quality connections won't attract passengers
	if connection.connection_quality < 30.0:
		connecting_pax *= 0.3  # Severely limit poor connections

	return max(0.0, connecting_pax)

static func analyze_hub_network_effects(airline: Airline, hub: Airport) -> Dictionary:
	"""
	Analyze the network effects of a hub
	Shows how routes from this hub create synergies

	Returns: {
		hub: Airport,
		inbound_routes: int,  # Routes ending at hub
		outbound_routes: int,  # Routes starting from hub
		potential_connections: int,  # Number of possible O-D pairs
		high_quality_connections: int,  # Connections with quality > 70
		estimated_connecting_pax: float  # Weekly connecting passengers
	}
	"""
	var analysis: Dictionary = {
		"hub": hub,
		"inbound_routes": 0,
		"outbound_routes": 0,
		"potential_connections": 0,
		"high_quality_connections": 0,
		"estimated_connecting_pax": 0.0,
		"connection_details": []  # Array of connection opportunities
	}

	# Find all routes TO this hub (inbound - bringing passengers)
	var routes_to_hub: Array[Route] = []
	for route in airline.routes:
		if route.to_airport == hub:
			routes_to_hub.append(route)

	# Find all routes FROM this hub (outbound - distributing passengers)
	var routes_from_hub: Array[Route] = []
	for route in airline.routes:
		if route.from_airport == hub:
			routes_from_hub.append(route)

	analysis.inbound_routes = routes_to_hub.size()
	analysis.outbound_routes = routes_from_hub.size()

	# Check all possible connections through this hub
	# Connection = inbound route (origin→hub) + outbound route (hub→destination)
	for inbound_route in routes_to_hub:
		for outbound_route in routes_from_hub:
			var origin: Airport = inbound_route.from_airport
			var destination: Airport = outbound_route.to_airport

			# Skip if origin = destination (pointless connection)
			if origin == destination:
				continue

			analysis.potential_connections += 1

			# Calculate connection quality
			var quality: float = calculate_connection_quality(inbound_route, outbound_route, hub)

			if quality > 70.0:
				analysis.high_quality_connections += 1

			# Build connection dictionary
			var connection: Dictionary = {
				"first_leg": inbound_route,
				"second_leg": outbound_route,
				"hub": hub,
				"total_distance": inbound_route.distance_km + outbound_route.distance_km,
				"connection_quality": quality
			}

			# Calculate distance for direct route (for comparison)
			var direct_distance: float = calculate_great_circle_distance(origin, destination)

			# Estimate connecting passengers
			# (Assume no direct competition for now - can be enhanced later)
			var connecting_pax: float = calculate_connecting_passenger_demand(
				origin,
				destination,
				connection,
				0.0  # No direct demand
			)

			analysis.estimated_connecting_pax += connecting_pax

			# Store connection details for display
			if quality > 50.0 and connecting_pax > 5.0:  # Only store meaningful connections
				analysis.connection_details.append({
					"from": origin.iata_code,
					"via": hub.iata_code,
					"to": destination.iata_code,
					"quality": quality,
					"weekly_pax": connecting_pax,
					"first_leg_frequency": inbound_route.frequency,
					"second_leg_frequency": outbound_route.frequency
				})

	# Sort connection details by passenger count (descending)
	analysis.connection_details.sort_custom(func(a, b): return a.weekly_pax > b.weekly_pax)

	return analysis
