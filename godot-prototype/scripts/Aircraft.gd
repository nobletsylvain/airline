extends Resource
class_name AircraftModel

## Represents an aircraft model (e.g., Boeing 737, Airbus A320)

@export var model_name: String = ""
@export var manufacturer: String = ""

# Aircraft specifications
@export var range_km: int = 0  # Maximum range in kilometers
@export var speed_kmh: int = 800  # Cruise speed
@export var fuel_burn: float = 0.0  # Fuel burn per hour
@export var price: float = 0.0  # Purchase price
@export var runway_requirement: int = 0  # Minimum runway length in meters

# Configurable capacity - stored as template constraints
@export var max_total_seats: int = 0  # Maximum possible seats
@export var min_economy_seats: int = 0  # Minimum economy required (structural)
@export var max_first_seats: int = 0  # Maximum first class physically possible
@export var max_business_seats: int = 0  # Maximum business class physically possible

# Default configuration (for backward compatibility and AI airlines)
@export var default_economy: int = 0
@export var default_business: int = 0
@export var default_first: int = 0

func _init(
	p_name: String = "",
	p_manufacturer: String = "",
	p_max_seats: int = 0,
	p_range: int = 0,
	p_price: float = 0.0,
	p_min_economy: int = 0,
	p_max_first: int = 0,
	p_max_business: int = 0
) -> void:
	model_name = p_name
	manufacturer = p_manufacturer
	max_total_seats = p_max_seats
	range_km = p_range
	price = p_price
	min_economy_seats = p_min_economy
	max_first_seats = p_max_first
	max_business_seats = p_max_business

	# Set sensible defaults (all economy if not specified)
	default_economy = p_max_seats
	default_business = 0
	default_first = 0

func set_default_configuration(economy: int, business: int, first: int) -> void:
	"""Set the default seat configuration for this model"""
	default_economy = economy
	default_business = business
	default_first = first

func get_total_capacity() -> int:
	"""Get maximum capacity of this aircraft model"""
	return max_total_seats

func get_default_configuration() -> AircraftConfiguration:
	"""Create a configuration object with default settings"""
	var config: AircraftConfiguration = AircraftConfiguration.new(
		max_total_seats,
		min_economy_seats,
		max_first_seats,
		max_business_seats
	)
	config.set_configuration(default_economy, default_business, default_first)
	return config

func can_fly_distance(distance_km: float) -> bool:
	return distance_km <= range_km

func get_display_name() -> String:
	return "%s %s" % [manufacturer, model_name]
