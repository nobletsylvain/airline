extends Resource
class_name Route

## Represents a flight route/link between two airports

@export var id: int = 0
@export var from_airport: Airport
@export var to_airport: Airport
@export var airline_id: int = 0
@export var distance_km: float = 0.0
@export var flight_duration_hours: float = 0.0

# Flight configuration
@export var frequency: int = 1  # Flights per week

# Note: Capacities are now calculated from assigned aircraft configurations
# These are deprecated but kept for backward compatibility
@export var _deprecated_capacity_economy: int = 0
@export var _deprecated_capacity_business: int = 0
@export var _deprecated_capacity_first: int = 0

# Pricing (per passenger) - active prices used in simulation
@export var price_economy: float = 100.0
@export var price_business: float = 200.0
@export var price_first: float = 500.0

# Pending prices (G.6) - applied on next day tick for cause-effect visibility
# null means no pending change; value means change queued for tomorrow
var pending_price_economy: Variant = null  # float or null
var pending_price_business: Variant = null  # float or null
var pending_price_first: Variant = null  # float or null

# Quality metrics
@export var service_quality: float = 50.0
@export var aircraft_condition: float = 100.0

# Statistics
var passengers_transported: int = 0
var local_passengers: int = 0       # Direct point-to-point passengers
var connecting_passengers: int = 0  # Passengers connecting through hub
var revenue_generated: float = 0.0
var local_revenue: float = 0.0       # Revenue from local passengers
var connecting_revenue: float = 0.0  # Revenue from connecting passengers
var weekly_profit: float = 0.0
var previous_weekly_profit: float = 0.0  # K.2: For trend tracking

# Cost breakdown (K.1: for route details display)
var fuel_cost: float = 0.0
var crew_cost: float = 0.0
var maintenance_cost: float = 0.0
var airport_fees: float = 0.0
var total_costs: float = 0.0


func get_profit_margin() -> float:
	"""K.2: Calculate profit margin as percentage of revenue"""
	if revenue_generated <= 0:
		return 0.0
	return (weekly_profit / revenue_generated) * 100.0


func get_profit_trend() -> String:
	"""K.2: Get profit trend indicator (↑ improving, ↓ declining, → stable)"""
	var diff: float = weekly_profit - previous_weekly_profit
	var threshold: float = abs(weekly_profit) * 0.05  # 5% change threshold
	
	if diff > threshold:
		return "↑"
	elif diff < -threshold:
		return "↓"
	else:
		return "→"


func get_profit_trend_color() -> Color:
	"""K.2: Get color for profit trend"""
	var trend: String = get_profit_trend()
	if trend == "↑":
		return Color(0.4, 1.0, 0.4)  # Green
	elif trend == "↓":
		return Color(1.0, 0.4, 0.4)  # Red
	else:
		return Color(0.8, 0.8, 0.8)  # Gray

# Assigned aircraft
var assigned_aircraft: Array[AircraftInstance] = []

func _init(p_from: Airport = null, p_to: Airport = null, p_airline_id: int = 0) -> void:
	from_airport = p_from
	to_airport = p_to
	airline_id = p_airline_id

	if from_airport and to_airport:
		distance_km = calculate_distance()
		flight_duration_hours = distance_km / 800.0  # Assuming 800 km/h cruise

func calculate_distance() -> float:
	"""Calculate great circle distance between airports"""
	if not from_airport or not to_airport:
		return 0.0

	var lat1: float = deg_to_rad(from_airport.latitude)
	var lon1: float = deg_to_rad(from_airport.longitude)
	var lat2: float = deg_to_rad(to_airport.latitude)
	var lon2: float = deg_to_rad(to_airport.longitude)

	var dlat: float = lat2 - lat1
	var dlon: float = lon2 - lon1

	var a: float = sin(dlat/2) * sin(dlat/2) + cos(lat1) * cos(lat2) * sin(dlon/2) * sin(dlon/2)
	var c: float = 2 * atan2(sqrt(a), sqrt(1-a))
	var earth_radius_km: float = 6371.0

	return earth_radius_km * c

func get_economy_capacity() -> int:
	"""Get total economy capacity from assigned aircraft"""
	var total: int = 0
	for aircraft in assigned_aircraft:
		total += aircraft.get_economy_capacity()
	return total

func get_business_capacity() -> int:
	"""Get total business capacity from assigned aircraft"""
	var total: int = 0
	for aircraft in assigned_aircraft:
		total += aircraft.get_business_capacity()
	return total

func get_first_capacity() -> int:
	"""Get total first capacity from assigned aircraft"""
	var total: int = 0
	for aircraft in assigned_aircraft:
		total += aircraft.get_first_capacity()
	return total

func get_total_capacity() -> int:
	"""Get total capacity from assigned aircraft"""
	var total: int = 0
	for aircraft in assigned_aircraft:
		total += aircraft.get_total_capacity()
	return total

# Backward compatibility properties
var capacity_economy: int:
	get: return get_economy_capacity()

var capacity_business: int:
	get: return get_business_capacity()

var capacity_first: int:
	get: return get_first_capacity()

func calculate_base_price(distance: float, passenger_class: String) -> float:
	"""Calculate base price based on distance and class"""
	var base_price: float = 50.0 + (distance * 0.15)

	match passenger_class:
		"business":
			return base_price * 2.5
		"first":
			return base_price * 5.0
		_:  # economy
			return base_price

func get_quality_score() -> float:
	"""Overall route quality"""
	return (service_quality + aircraft_condition) / 2.0

func assign_aircraft(aircraft: AircraftInstance) -> void:
	if aircraft not in assigned_aircraft:
		assigned_aircraft.append(aircraft)
		aircraft.is_assigned = true
		aircraft.assigned_route_id = id

func get_display_name() -> String:
	if from_airport and to_airport:
		return "%s → %s" % [from_airport.iata_code, to_airport.iata_code]
	return "Unknown Route"


## ============================================================================
## PENDING PRICE SYSTEM (G.6)
## Prices set by player take effect next day for cause-effect visibility
## ============================================================================

func set_pending_price_economy(new_price: float) -> void:
	"""Queue an economy price change for next day"""
	if new_price != price_economy:
		pending_price_economy = new_price
		print("Route %s: Economy price change queued: €%.0f → €%.0f (effective tomorrow)" % [
			get_display_name(), price_economy, new_price
		])
	else:
		pending_price_economy = null  # Cancel pending if same as current


func set_pending_price_business(new_price: float) -> void:
	"""Queue a business price change for next day"""
	if new_price != price_business:
		pending_price_business = new_price
	else:
		pending_price_business = null


func set_pending_price_first(new_price: float) -> void:
	"""Queue a first class price change for next day"""
	if new_price != price_first:
		pending_price_first = new_price
	else:
		pending_price_first = null


func set_pending_prices(economy: float, business: float, first: float) -> void:
	"""Queue all price changes for next day"""
	set_pending_price_economy(economy)
	set_pending_price_business(business)
	set_pending_price_first(first)


func apply_pending_prices() -> bool:
	"""Apply any pending price changes. Called on day tick. Returns true if prices changed."""
	var changed: bool = false
	
	if pending_price_economy != null:
		var old_price: float = price_economy
		price_economy = pending_price_economy
		pending_price_economy = null
		changed = true
		print("Route %s: Economy price now €%.0f (was €%.0f)" % [
			get_display_name(), price_economy, old_price
		])
	
	if pending_price_business != null:
		price_business = pending_price_business
		pending_price_business = null
		changed = true
	
	if pending_price_first != null:
		price_first = pending_price_first
		pending_price_first = null
		changed = true
	
	return changed


func has_pending_price_changes() -> bool:
	"""Check if any price changes are pending"""
	return (pending_price_economy != null or 
			pending_price_business != null or 
			pending_price_first != null)


func get_pending_price_economy() -> float:
	"""Get pending economy price, or current if none pending"""
	if pending_price_economy != null:
		return pending_price_economy
	return price_economy


func get_pending_price_business() -> float:
	"""Get pending business price, or current if none pending"""
	if pending_price_business != null:
		return pending_price_business
	return price_business


func get_pending_price_first() -> float:
	"""Get pending first price, or current if none pending"""
	if pending_price_first != null:
		return pending_price_first
	return price_first


func get_price_change_summary() -> String:
	"""Get human-readable summary of pending changes for UI"""
	if not has_pending_price_changes():
		return ""
	
	var changes: Array[String] = []
	if pending_price_economy != null:
		changes.append("Economy: €%.0f → €%.0f" % [price_economy, pending_price_economy])
	if pending_price_business != null:
		changes.append("Business: €%.0f → €%.0f" % [price_business, pending_price_business])
	if pending_price_first != null:
		changes.append("First: €%.0f → €%.0f" % [price_first, pending_price_first])
	
	return "Price changes from tomorrow: " + ", ".join(changes)
