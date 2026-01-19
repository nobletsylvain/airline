extends Resource
class_name AircraftInstance

## Instance of an aircraft owned by an airline

@export var id: int = 0
@export var model: AircraftModel
@export var airline_id: int = 0
@export var condition: float = 100.0  # 0-100, affects quality
@export var is_assigned: bool = false
@export var assigned_route_id: int = -1

func _init(p_id: int = 0, p_model: AircraftModel = null, p_airline_id: int = 0) -> void:
	id = p_id
	model = p_model
	airline_id = p_airline_id
	condition = 100.0

func degrade_condition(amount: float) -> void:
	condition = max(0.0, condition - amount)

func repair(amount: float) -> void:
	condition = min(100.0, condition + amount)

func get_display_name() -> String:
	if model:
		return "%s %s (ID: %d)" % [model.manufacturer, model.model_name, id]
	return "Unknown Aircraft"

func get_status() -> String:
	if is_assigned:
		return "Assigned"
	return "Available"
