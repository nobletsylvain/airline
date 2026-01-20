extends CanvasLayer
class_name TutorialOverlay

## UI overlay for displaying tutorial steps

# Tutorial panel nodes (to be created in scene)
@onready var tutorial_panel: Panel = $TutorialPanel
@onready var step_title: Label = $TutorialPanel/VBoxContainer/TitleLabel
@onready var step_message: RichTextLabel = $TutorialPanel/VBoxContainer/MessageLabel
@onready var progress_label: Label = $TutorialPanel/VBoxContainer/ProgressLabel
@onready var button_container: HBoxContainer = $TutorialPanel/VBoxContainer/ButtonContainer
@onready var continue_button: Button = $TutorialPanel/VBoxContainer/ButtonContainer/ContinueButton
@onready var skip_button: Button = $TutorialPanel/VBoxContainer/ButtonContainer/SkipButton

# Confirmation dialog
@onready var confirm_dialog: ConfirmationDialog = $ConfirmationDialog

# Highlight overlay
@onready var highlight_control: Control = $HighlightOverlay

var tutorial_manager: TutorialManager = null
var current_highlighted_node: Control = null

func _ready() -> void:
	# Initially hidden
	hide_tutorial_panel()

	# Connect button signals
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)
	if confirm_dialog:
		confirm_dialog.confirmed.connect(_on_skip_confirmed)

	# Connect to GameData tutorial manager when ready
	if GameData.tutorial_manager:
		setup_tutorial_manager(GameData.tutorial_manager)
	else:
		# Wait for GameData to initialize
		await get_tree().process_frame
		if GameData.tutorial_manager:
			setup_tutorial_manager(GameData.tutorial_manager)

func setup_tutorial_manager(manager: TutorialManager) -> void:
	"""Connect to tutorial manager signals"""
	tutorial_manager = manager

	tutorial_manager.tutorial_step_started.connect(_on_tutorial_step_started)
	tutorial_manager.tutorial_step_completed.connect(_on_tutorial_step_completed)
	tutorial_manager.tutorial_completed.connect(_on_tutorial_completed)
	tutorial_manager.highlight_ui_element.connect(_on_highlight_ui_element)
	tutorial_manager.clear_ui_highlights.connect(_on_clear_ui_highlights)

	print("TutorialOverlay: Connected to TutorialManager")

func _on_tutorial_step_started(step: TutorialStep) -> void:
	"""Display new tutorial step"""
	if not tutorial_panel:
		return

	# Show panel
	show_tutorial_panel()

	# Update content
	if step_title:
		step_title.text = step.title

	if step_message:
		step_message.text = step.message

	# Update progress
	if progress_label and tutorial_manager:
		var current_index: int = tutorial_manager.current_step_index + 1
		var total: int = tutorial_manager.tutorial_steps.size()
		progress_label.text = "Step %d / %d" % [current_index, total]

	# Handle button visibility based on step type
	if continue_button:
		match step.step_type:
			TutorialStep.StepType.WAIT_FOR_ACTION:
				continue_button.visible = false  # Wait for player action
			_:
				continue_button.visible = true  # Show for MESSAGE, HIGHLIGHT_UI, REWARD

	# Always show skip button (unless tutorial is almost done)
	if skip_button:
		skip_button.visible = current_index < tutorial_manager.tutorial_steps.size() - 1

func _on_tutorial_step_completed(_step: TutorialStep) -> void:
	"""Step completed"""
	# Could show animation or brief feedback here
	pass

func _on_tutorial_completed() -> void:
	"""Tutorial finished"""
	hide_tutorial_panel()
	clear_highlight()
	print("Tutorial overlay: Tutorial completed!")

func _on_continue_pressed() -> void:
	"""Continue button clicked"""
	if tutorial_manager:
		tutorial_manager.complete_current_step()

func _on_skip_pressed() -> void:
	"""Skip button clicked - show confirmation"""
	if confirm_dialog:
		confirm_dialog.dialog_text = "Are you sure you want to skip the tutorial?\n\nYou'll still receive the $50M starting bonus!"
		confirm_dialog.popup_centered()
	else:
		# Fallback if no dialog
		_on_skip_confirmed()

func _on_skip_confirmed() -> void:
	"""User confirmed skip"""
	if tutorial_manager:
		tutorial_manager.skip_tutorial()
	hide_tutorial_panel()
	clear_highlight()

func show_tutorial_panel() -> void:
	"""Show the tutorial panel"""
	if tutorial_panel:
		tutorial_panel.visible = true

func hide_tutorial_panel() -> void:
	"""Hide the tutorial panel"""
	if tutorial_panel:
		tutorial_panel.visible = false

func _on_highlight_ui_element(node_path: String, message: String) -> void:
	"""Highlight a UI element"""
	clear_highlight()

	# Try to find the node
	var target_node: Node = get_node_or_null("/" + node_path)

	if target_node and target_node is Control:
		current_highlighted_node = target_node
		# Could add visual highlight here (border, glow, arrow, etc.)
		print("TutorialOverlay: Highlighting %s - %s" % [node_path, message])

		# For now, just log it
		# In a full implementation, you'd:
		# 1. Create a highlight rect around the target
		# 2. Add an arrow or glow effect
		# 3. Temporarily disable other UI interactions

func _on_clear_ui_highlights() -> void:
	"""Remove all UI highlights"""
	clear_highlight()

func clear_highlight() -> void:
	"""Clear current highlight"""
	current_highlighted_node = null
	# Remove visual highlight effects

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts"""
	if not tutorial_manager or not tutorial_manager.is_active():
		return

	# Enter/Space to continue (if continue button visible)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			if continue_button and continue_button.visible:
				_on_continue_pressed()
				get_viewport().set_input_as_handled()

		# ESC to open skip confirmation
		elif event.keycode == KEY_ESCAPE:
			if skip_button and skip_button.visible:
				_on_skip_pressed()
				get_viewport().set_input_as_handled()
