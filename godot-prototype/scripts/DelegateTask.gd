extends Resource
class_name DelegateTask

## Represents a task assigned to a delegate

enum TaskType {
	COUNTRY_RELATIONSHIP,
	ROUTE_NEGOTIATION,
	CAMPAIGN
}

@export var id: int = 0
@export var airline_id: int = 0
@export var delegate_id: int = 0
@export var task_type: TaskType = TaskType.COUNTRY_RELATIONSHIP
@export var creation_week: int = 0
@export var duration_weeks: int = 4  # Default 4 weeks
@export var weeks_remaining: int = 4
@export var progress: float = 0.0  # 0.0 to 1.0

# Task-specific data
@export var target_country_code: String = ""  # For country relationship
@export var target_route_from: String = ""  # For route negotiation
@export var target_route_to: String = ""
@export var campaign_location: String = ""  # For campaigns
@export var campaign_cost: float = 0.0

# Results
@export var relationship_bonus: float = 0.0  # For country tasks
@export var difficulty_reduction: float = 0.0  # For negotiation tasks
@export var reputation_bonus: float = 0.0  # For campaign tasks

func _init(
	p_id: int = 0,
	p_airline_id: int = 0,
	p_task_type: TaskType = TaskType.COUNTRY_RELATIONSHIP,
	p_duration: int = 4,
	p_creation_week: int = 0
) -> void:
	id = p_id
	airline_id = p_airline_id
	task_type = p_task_type
	duration_weeks = p_duration
	weeks_remaining = p_duration
	creation_week = p_creation_week
	progress = 0.0

func advance_week() -> void:
	"""Advance task by one week"""
	if weeks_remaining > 0:
		weeks_remaining -= 1
		progress = 1.0 - (float(weeks_remaining) / float(duration_weeks))

func is_completed() -> bool:
	"""Check if task is completed"""
	return weeks_remaining <= 0 or progress >= 1.0

func get_progress_percent() -> float:
	"""Get progress as percentage"""
	return progress * 100.0

func get_task_type_string() -> String:
	"""Get task type as string"""
	match task_type:
		TaskType.COUNTRY_RELATIONSHIP:
			return "Country Relationship"
		TaskType.ROUTE_NEGOTIATION:
			return "Route Negotiation"
		TaskType.CAMPAIGN:
			return "Campaign"
		_:
			return "Unknown"
