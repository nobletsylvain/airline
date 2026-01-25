extends Resource
class_name Delegate

## Represents a delegate (diplomatic staff member) for an airline

@export var id: int = 0
@export var airline_id: int = 0
@export var name: String = ""
@export var level: int = 1  # 1-5, affects effectiveness
@export var specialization: String = "general"  # "diplomacy", "negotiation", "campaign"

# Current assignment
var current_task: DelegateTask = null
var is_available: bool = true

# Statistics
var tasks_completed: int = 0
var total_effectiveness: float = 0.0

func _init(p_id: int = 0, p_airline_id: int = 0, p_name: String = "", p_level: int = 1) -> void:
	id = p_id
	airline_id = p_airline_id
	name = p_name
	level = p_level
	is_available = true

func assign_task(task: DelegateTask) -> bool:
	"""Assign a task to this delegate"""
	if not is_available or current_task != null:
		return false
	
	current_task = task
	is_available = false
	task.delegate_id = id
	return true

func complete_task() -> void:
	"""Complete current task"""
	if current_task:
		tasks_completed += 1
		total_effectiveness += get_effectiveness()
		current_task = null
		is_available = true

func cancel_task() -> void:
	"""Cancel current task"""
	if current_task:
		current_task = null
		is_available = true

func get_effectiveness() -> float:
	"""Get delegate effectiveness based on level"""
	return 0.5 + (level * 0.1)  # 0.6 to 1.0

func get_bonus_for_task_type(task_type: String) -> float:
	"""Get effectiveness bonus for specific task type"""
	if specialization == task_type or specialization == "general":
		return 1.0
	return 0.8  # 20% penalty for mismatched specialization
