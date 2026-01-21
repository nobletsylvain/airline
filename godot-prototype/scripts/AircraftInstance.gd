extends Resource
class_name AircraftInstance

## Instance of an aircraft owned by an airline

enum Status {
	IDLE,           # Available, not assigned to any route
	IN_FLIGHT,      # Currently flying a route
	BOARDING,       # At gate, passengers boarding
	MAINTENANCE,    # Undergoing maintenance
	DELIVERY        # Ordered, awaiting delivery
}

# Status colors for UI
const STATUS_COLORS: Dictionary = {
	Status.IDLE: Color(0.5, 0.5, 0.5),        # Gray
	Status.IN_FLIGHT: Color(0.2, 0.8, 0.3),   # Green
	Status.BOARDING: Color(0.3, 0.6, 0.9),    # Blue
	Status.MAINTENANCE: Color(0.9, 0.4, 0.2), # Orange/Red
	Status.DELIVERY: Color(0.6, 0.4, 0.8)     # Purple
}

const STATUS_NAMES: Dictionary = {
	Status.IDLE: "Idle",
	Status.IN_FLIGHT: "In Flight",
	Status.BOARDING: "Boarding",
	Status.MAINTENANCE: "Maintenance",
	Status.DELIVERY: "Delivery"
}

@export var id: int = 0
@export var model: AircraftModel
@export var configuration: AircraftConfiguration  # Customizable seat layout
@export var airline_id: int = 0
@export var condition: float = 100.0  # 0-100, affects quality
@export var is_assigned: bool = false
@export var assigned_route_id: int = -1
@export var current_status: Status = Status.IDLE
@export var maintenance_due_hours: float = 500.0  # Hours until maintenance needed
@export var delivery_hours_remaining: float = 0.0  # Hours until delivery (if on order)

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

func get_status() -> Status:
	"""Get current aircraft status"""
	return current_status

func get_status_name() -> String:
	"""Get human-readable status name"""
	return STATUS_NAMES.get(current_status, "Unknown")

func get_status_color() -> Color:
	"""Get status color for UI"""
	return STATUS_COLORS.get(current_status, Color.WHITE)

func set_status(new_status: Status) -> void:
	"""Set aircraft status"""
	current_status = new_status

func needs_maintenance() -> bool:
	"""Check if aircraft needs maintenance soon"""
	return condition < 70.0 or maintenance_due_hours <= 0

func get_condition_color() -> Color:
	"""Get color based on condition percentage"""
	if condition >= 80:
		return Color(0.2, 0.8, 0.3)  # Green
	elif condition >= 50:
		return Color(0.9, 0.7, 0.2)  # Yellow/Orange
	else:
		return Color(0.9, 0.3, 0.2)  # Red

# Capacity accessors that use the configuration
func get_economy_capacity() -> int:
	return configuration.economy_seats if configuration else 0

func get_business_capacity() -> int:
	return configuration.business_seats if configuration else 0

func get_first_capacity() -> int:
	return configuration.first_seats if configuration else 0

func get_total_capacity() -> int:
	return configuration.get_total_seats() if configuration else 0
