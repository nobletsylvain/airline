extends Resource
class_name AircraftConfiguration

## Represents a customizable seat configuration for an aircraft

@export var total_seats: int = 0
@export var economy_seats: int = 0
@export var business_seats: int = 0
@export var first_seats: int = 0

# Configuration constraints based on aircraft size
@export var max_total_seats: int = 0
@export var min_economy_seats: int = 0
@export var max_first_seats: int = 0  # Physical limit on first class
@export var max_business_seats: int = 0  # Physical limit on business class

func _init(
	p_max_total: int = 0,
	p_min_economy: int = 0,
	p_max_first: int = 0,
	p_max_business: int = 0
) -> void:
	max_total_seats = p_max_total
	min_economy_seats = p_min_economy
	max_first_seats = p_max_first
	max_business_seats = p_max_business

	# Set default configuration (all economy)
	economy_seats = max_total_seats
	business_seats = 0
	first_seats = 0
	total_seats = max_total_seats

func set_configuration(economy: int, business: int, first: int) -> bool:
	"""Validate and set a new configuration"""
	# Validate constraints
	if economy < min_economy_seats:
		return false

	if first > max_first_seats:
		return false

	if business > max_business_seats:
		return false

	var new_total: int = economy + business + first
	if new_total > max_total_seats:
		return false

	# Apply configuration
	economy_seats = economy
	business_seats = business
	first_seats = first
	total_seats = new_total
	return true

func get_total_seats() -> int:
	return economy_seats + business_seats + first_seats

func get_utilization_percent() -> float:
	"""Calculate how much of the aircraft capacity is being used"""
	if max_total_seats == 0:
		return 0.0
	return (get_total_seats() / float(max_total_seats)) * 100.0

func duplicate_config() -> AircraftConfiguration:
	"""Create a copy of this configuration"""
	var new_config: AircraftConfiguration = AircraftConfiguration.new(
		max_total_seats,
		min_economy_seats,
		max_first_seats,
		max_business_seats
	)
	new_config.set_configuration(economy_seats, business_seats, first_seats)
	return new_config

func get_config_summary() -> String:
	"""Get a human-readable summary"""
	return "Y:%d | J:%d | F:%d (Total: %d/%d - %.0f%%)" % [
		economy_seats,
		business_seats,
		first_seats,
		get_total_seats(),
		max_total_seats,
		get_utilization_percent()
	]

func get_class_ratio() -> Dictionary:
	"""Get the ratio of each class"""
	var total: int = get_total_seats()
	if total == 0:
		return {"economy": 0.0, "business": 0.0, "first": 0.0}

	return {
		"economy": economy_seats / float(total),
		"business": business_seats / float(total),
		"first": first_seats / float(total)
	}
