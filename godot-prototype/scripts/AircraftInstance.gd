extends Resource
class_name AircraftInstance

## Instance of an aircraft owned by an airline

@export var id: int = 0
@export var model: AircraftModel
@export var configuration: AircraftConfiguration  # Customizable seat layout
@export var airline_id: int = 0
@export var condition: float = 100.0  # 0-100, affects quality
@export var is_assigned: bool = false
@export var assigned_route_id: int = -1

func _init(p_id: int = 0, p_model: AircraftModel = null, p_airline_id: int = 0, p_config: AircraftConfiguration = null) -> void:
	id = p_id
	model = p_model
	airline_id = p_airline_id
	condition = 100.0

	# Use provided configuration or create default
	if p_config:
		configuration = p_config
	elif p_model:
		configuration = p_model.get_default_configuration()
	else:
		configuration = AircraftConfiguration.new()

func degrade_condition(amount: float) -> void:
	condition = max(0.0, condition - amount)

func repair(amount: float) -> void:
	condition = min(100.0, condition + amount)

func get_display_name() -> String:
	if model:
		return "%s %s (ID: %d)" % [model.manufacturer, model.model_name, id]
	return "Unknown Aircraft"

func get_full_display_name() -> String:
	"""Get display name with configuration info"""
	if model and configuration:
		return "%s %s [%s] (ID: %d)" % [
			model.manufacturer,
			model.model_name,
			configuration.get_config_summary(),
			id
		]
	return get_display_name()

func get_status() -> String:
	if is_assigned:
		return "Assigned"
	return "Available"

# Capacity accessors that use the configuration
func get_economy_capacity() -> int:
	return configuration.economy_seats if configuration else 0

func get_business_capacity() -> int:
	return configuration.business_seats if configuration else 0

func get_first_capacity() -> int:
	return configuration.first_seats if configuration else 0

func get_total_capacity() -> int:
	return configuration.get_total_seats() if configuration else 0
