extends Resource
class_name AircraftModel

## Represents an aircraft model (e.g., Boeing 737, Airbus A320)

@export var model_name: String = ""
@export var manufacturer: String = ""
@export var capacity_economy: int = 0
@export var capacity_business: int = 0
@export var capacity_first: int = 0
@export var range_km: int = 0  # Maximum range in kilometers
@export var speed_kmh: int = 800  # Cruise speed
@export var fuel_burn: float = 0.0  # Fuel burn per hour
@export var price: float = 0.0  # Purchase price
@export var runway_requirement: int = 0  # Minimum runway length in meters

func _init(
	p_name: String = "",
	p_manufacturer: String = "",
	p_economy: int = 0,
	p_business: int = 0,
	p_first: int = 0,
	p_range: int = 0,
	p_price: float = 0.0
) -> void:
	model_name = p_name
	manufacturer = p_manufacturer
	capacity_economy = p_economy
	capacity_business = p_business
	capacity_first = p_first
	range_km = p_range
	price = p_price

func get_total_capacity() -> int:
	return capacity_economy + capacity_business + capacity_first

func can_fly_distance(distance_km: float) -> bool:
	return distance_km <= range_km

func get_display_name() -> String:
	return "%s %s" % [manufacturer, model_name]
