extends Resource
class_name TutorialStep

## Represents a single step in the tutorial

enum StepType {
	MESSAGE,           # Show a message dialog
	HIGHLIGHT_UI,      # Highlight a UI element
	WAIT_FOR_ACTION,   # Wait for player to perform action
	AUTO_ACTION,       # Automatically perform action
	REWARD             # Give player a reward
}

@export var step_id: String = ""
@export var title: String = ""
@export var message: String = ""
@export var step_type: StepType = StepType.MESSAGE

# For HIGHLIGHT_UI
@export var ui_element_path: String = ""  # Node path to highlight
@export var highlight_message: String = ""

# For WAIT_FOR_ACTION
@export var required_action: String = ""  # e.g., "purchase_aircraft", "create_route"
@export var action_hint: String = ""

# For AUTO_ACTION
@export var auto_action_callback: String = ""  # Method name to call

# For REWARD
@export var reward_money: float = 0.0
@export var reward_message: String = ""

# Completion tracking
var is_completed: bool = false
var skippable: bool = false

func _init(
	p_id: String = "",
	p_title: String = "",
	p_message: String = "",
	p_type: StepType = StepType.MESSAGE
) -> void:
	step_id = p_id
	title = p_title
	message = p_message
	step_type = p_type

func mark_completed() -> void:
	is_completed = true

func is_action_step() -> bool:
	return step_type == StepType.WAIT_FOR_ACTION

func get_summary() -> String:
	return "%s: %s" % [title, message.substr(0, 50)]
