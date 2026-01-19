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
@export var capacity_economy: int = 0
@export var capacity_business: int = 0
@export var capacity_first: int = 0

# Pricing (per passenger)
@export var price_economy: float = 100.0
@export var price_business: float = 200.0
@export var price_first: float = 500.0

# Quality metrics
@export var service_quality: float = 50.0
@export var aircraft_condition: float = 100.0

# Statistics
var passengers_transported: int = 0
var revenue_generated: float = 0.0
var fuel_cost: float = 0.0
var weekly_profit: float = 0.0

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

func get_total_capacity() -> int:
	return capacity_economy + capacity_business + capacity_first

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
