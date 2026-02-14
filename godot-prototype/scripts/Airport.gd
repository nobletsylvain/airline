extends Resource
class_name Airport

## Represents an airport in the game with realistic data

# Basic Info
@export var iata_code: String = ""
@export var name: String = ""
@export var city: String = ""
@export var country: String = ""
@export var region: String = ""  # North America, Europe, Asia, etc.

# Geographic Data
@export var latitude: float = 0.0
@export var longitude: float = 0.0
@export var position_2d: Vector2 = Vector2.ZERO  # Screen position on map
@export var elevation: int = 0  # Meters above sea level

# Airport Characteristics
@export var hub_tier: int = 4  # 1=Mega Hub, 2=Major Hub, 3=Regional Hub, 4=Small Airport
@export var annual_passengers: int = 0  # Annual passenger traffic (millions)
@export var runway_count: int = 1  # Number of runways
@export var max_slots_per_week: int = 168  # Maximum flight slots per week (24/7)

# Economic Data
@export var gdp_per_capita: int = 50000  # Local GDP per capita (USD)
@export var landing_fee: float = 5000.0  # Base landing fee (USD)
@export var passenger_fee: float = 10.0  # Fee per passenger (USD)
@export var base_establishment_cost: float = 10000000.0  # Cost to establish a base ($10M default)

# Operational Data
var slot_assignments: Dictionary = {}  # airline_id -> slots_used
var bases: Dictionary = {}  # airline_id -> base_scale (0.0-1.0)
var current_weekly_slots: int = 0  # Currently used slots this week

func _init(p_iata: String = "", p_name: String = "", p_city: String = "", p_country: String = "") -> void:
	iata_code = p_iata
	name = p_name
	city = p_city
	country = p_country

func get_demand_multiplier() -> float:
	"""Calculate demand multiplier based on hub tier and passenger traffic"""
	var hub_multiplier: float = 1.0
	match hub_tier:
		1: hub_multiplier = 2.5  # Mega hub (100M+ passengers)
		2: hub_multiplier = 2.0  # Major hub (50-100M passengers)
		3: hub_multiplier = 1.5  # Regional hub (20-50M passengers)
		4: hub_multiplier = 1.0  # Small airport (<20M passengers)

	# Passenger traffic multiplier (in millions)
	var traffic_multiplier: float = 1.0 + (annual_passengers / 50.0) * 0.5

	# Economic multiplier (wealthier areas = more demand)
	var economic_multiplier: float = 1.0 + (gdp_per_capita / 100000.0) * 0.3

	return hub_multiplier * traffic_multiplier * economic_multiplier

func get_capacity_per_week() -> int:
	"""Calculate theoretical weekly passenger capacity"""
	# Rough estimate: each slot can handle ~150 passengers average
	return max_slots_per_week * 150

func has_available_slots(slots_needed: int) -> bool:
	"""Check if airport has available slots"""
	return (current_weekly_slots + slots_needed) <= max_slots_per_week

func reserve_slots(airline_id: int, slots: int) -> bool:
	"""Reserve slots for an airline"""
	if not has_available_slots(slots):
		return false

	if airline_id not in slot_assignments:
		slot_assignments[airline_id] = 0

	slot_assignments[airline_id] += slots
	current_weekly_slots += slots
	return true

func release_slots(airline_id: int, slots: int) -> void:
	"""Release slots from an airline"""
	if airline_id in slot_assignments:
		slot_assignments[airline_id] = max(0, slot_assignments[airline_id] - slots)
		current_weekly_slots = max(0, current_weekly_slots - slots)

func is_hub() -> bool:
	"""Check if this is a hub airport (tier 1-3)"""
	return hub_tier <= 3

func is_mega_hub() -> bool:
	"""Check if this is a mega hub (tier 1)"""
	return hub_tier == 1

func get_hub_name() -> String:
	"""Get hub tier name"""
	match hub_tier:
		1: return "Mega Hub"
		2: return "Major Hub"
		3: return "Regional Hub"
		4: return "Regional Airport"
		_: return "Airport"

func get_display_name() -> String:
	return "%s (%s)" % [name, iata_code]

func get_full_info() -> String:
	"""Get detailed airport information"""
	return "%s (%s)\n%s, %s\n%s | %dM pax/year | %d runways" % [
		name,
		iata_code,
		city,
		country,
		get_hub_name(),
		annual_passengers,
		runway_count
	]

func calculate_total_fees(passengers: int, frequency: int) -> float:
	"""Calculate total fees for operating at this airport"""
	var total_landing: float = landing_fee * frequency
	var total_passenger: float = passenger_fee * passengers
	return total_landing + total_passenger
