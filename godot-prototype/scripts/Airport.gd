extends Resource
class_name Airport

## Represents an airport in the game

@export var iata_code: String = ""
@export var name: String = ""
@export var city: String = ""
@export var country: String = ""
@export var latitude: float = 0.0
@export var longitude: float = 0.0
@export var position_2d: Vector2 = Vector2.ZERO  # Screen position on map
@export var size: int = 1  # 1-12 (small to large hub)
@export var population: int = 0
@export var income_level: int = 0  # 0-100

# Airline-specific data
var slot_assignments: Dictionary = {}  # airline_id -> slots_used
var bases: Dictionary = {}  # airline_id -> base_scale

func _init(p_iata: String = "", p_name: String = "", p_city: String = "", p_country: String = "") -> void:
	iata_code = p_iata
	name = p_name
	city = p_city
	country = p_country

func get_demand_multiplier() -> float:
	"""Calculate demand multiplier based on size and population"""
	var base_multiplier: float = 1.0 + (size * 0.1)
	var pop_multiplier: float = 1.0 + (population / 1000000.0) * 0.5
	return base_multiplier * pop_multiplier

func get_display_name() -> String:
	return "%s (%s)" % [name, iata_code]
