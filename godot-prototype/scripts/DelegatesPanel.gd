extends Control
class_name DelegatesPanel

## Delegates Management Panel - Manage delegate assignments and tasks
## Shows available delegates, active tasks, and allows assignment

signal delegate_assignment_requested(task_type: String, target: Dictionary)
signal task_cancelled(task_id: int)

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var header_hbox: HBoxContainer
var delegates_summary_label: Label
var active_tasks_vbox: VBoxContainer
var available_delegates_vbox: VBoxContainer
var assign_button: Button

# Data
var active_tasks: Array[Dictionary] = []
var available_count: int = 0
var total_count: int = 0

func _ready() -> void:
	build_ui()
	update_delegates_info()

func build_ui() -> void:
	"""Build the delegates panel UI"""
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Main container with margin
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var outer_vbox = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 16)
	margin.add_child(outer_vbox)

	# Header row
	create_header(outer_vbox)

	# Scrollable content
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)

	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 20)
	scroll_container.add_child(main_vbox)

	# Delegates summary section
	create_summary_section()

	# Active tasks section
	create_active_tasks_section()

	# Available delegates section
	create_available_delegates_section()

func create_header(parent: VBoxContainer) -> void:
	"""Create header with title - Figma-inspired design"""
	header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 16)
	parent.add_child(header_hbox)

	# Title section with subtitle
	var title_vbox = VBoxContainer.new()
	title_vbox.add_theme_constant_override("separation", 4)
	header_hbox.add_child(title_vbox)

	var title = Label.new()
	title.text = "Delegates Management"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	title_vbox.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Manage your diplomatic staff and strategic assignments"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_secondary())
	title_vbox.add_child(subtitle)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	# Enhanced button with icon and shadow
	assign_button = Button.new()
	assign_button.text = "  + Assign Delegate"
	assign_button.custom_minimum_size = Vector2(200, 44)
	assign_button.add_theme_font_size_override("font_size", 14)

	# Primary button with gradient effect and shadow
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = UITheme.PRIMARY_BLUE
	btn_style.set_corner_radius_all(10)
	btn_style.set_content_margin_all(12)
	btn_style.shadow_color = Color(0.231, 0.510, 0.965, 0.3)  # Blue shadow
	btn_style.shadow_size = 8
	btn_style.shadow_offset = Vector2(0, 4)
	assign_button.add_theme_stylebox_override("normal", btn_style)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = UITheme.PRIMARY_BLUE_DARK
	btn_hover.set_corner_radius_all(10)
	btn_hover.set_content_margin_all(12)
	btn_hover.shadow_color = Color(0.231, 0.510, 0.965, 0.4)
	btn_hover.shadow_size = 12
	btn_hover.shadow_offset = Vector2(0, 6)
	assign_button.add_theme_stylebox_override("hover", btn_hover)

	assign_button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	assign_button.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
	assign_button.pressed.connect(_on_assign_button_pressed)
	header_hbox.add_child(assign_button)

func create_summary_section() -> void:
	"""Create delegates summary panel"""
	var panel = create_section_panel("Delegates Summary")
	main_vbox.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	delegates_summary_label = Label.new()
	delegates_summary_label.add_theme_font_size_override("font_size", 14)
	delegates_summary_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	vbox.add_child(delegates_summary_label)

	var breakdown_label = Label.new()
	breakdown_label.name = "BreakdownLabel"
	breakdown_label.add_theme_font_size_override("font_size", 12)
	breakdown_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	vbox.add_child(breakdown_label)

func create_active_tasks_section() -> void:
	"""Create active tasks section"""
	var panel = create_section_panel("Active Tasks")
	main_vbox.add_child(panel)

	active_tasks_vbox = VBoxContainer.new()
	active_tasks_vbox.add_theme_constant_override("separation", 8)
	panel.add_child(active_tasks_vbox)

	# Empty state
	var empty_label = Label.new()
	empty_label.name = "EmptyTasksLabel"
	empty_label.text = "No active tasks. Assign delegates to improve relationships, negotiate routes, or run campaigns."
	empty_label.add_theme_font_size_override("font_size", 12)
	empty_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	active_tasks_vbox.add_child(empty_label)

func create_available_delegates_section() -> void:
	"""Create available delegates section"""
	var panel = create_section_panel("Available Delegates")
	main_vbox.add_child(panel)

	available_delegates_vbox = VBoxContainer.new()
	available_delegates_vbox.add_theme_constant_override("separation", 8)
	panel.add_child(available_delegates_vbox)

func create_section_panel(title: String) -> PanelContainer:
	"""Create a styled section panel - Figma-inspired with rounded corners and shadow"""
	var panel = PanelContainer.new()
	
	# Enhanced panel style with shadow and rounded corners
	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.get_panel_bg()
	style.border_color = UITheme.get_panel_border()
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)  # More rounded like Figma
	style.set_content_margin_all(20)
	style.shadow_color = Color(0, 0, 0, 0.05)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_all", 0)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(title_label)

	return panel

func update_delegates_info() -> void:
	"""Update delegates information from GameData"""
	if not GameData.player_airline:
		return

	var airline = GameData.player_airline
	
	# Get actual delegate data
	total_count = airline.get_total_delegates()
	available_count = airline.get_available_delegate_count()
	
	# Update active tasks list from airline
	active_tasks.clear()
	for task in airline.delegate_tasks:
		var task_dict = {
			"id": task.id,
			"type": task.get_task_type_string(),
			"target": _get_task_target_string(task),
			"progress": task.get_progress_percent(),
			"weeks_remaining": task.weeks_remaining,
			"level": _get_task_level(task)
		}
		active_tasks.append(task_dict)

	# Update summary
	if delegates_summary_label:
		delegates_summary_label.text = "%d / %d Delegates Available" % [available_count, total_count]

	# Update breakdown
	var breakdown_label = get_node_or_null("ScrollContainer/MainVBox/PanelContainer[0]/MarginContainer/VBoxContainer/BreakdownLabel")
	if breakdown_label:
		var grade = airline.get_grade()
		var base_delegates = 3
		var grade_bonus = 0  # Can add grade-based bonus later
		breakdown_label.text = "Base: %d | Grade Bonus: +%d | Total: %d" % [base_delegates, grade_bonus, total_count]

	# Update assign button
	if assign_button:
		assign_button.disabled = (available_count <= 0)

	# Refresh task list
	refresh_active_tasks()

func _get_task_target_string(task: DelegateTask) -> String:
	"""Get target string for task display"""
	match task.task_type:
		DelegateTask.TaskType.COUNTRY_RELATIONSHIP:
			var country = GameData.get_country_by_code(task.target_country_code)
			return country.name if country else task.target_country_code
		DelegateTask.TaskType.ROUTE_NEGOTIATION:
			return "%s → %s" % [task.target_route_from, task.target_route_to]
		DelegateTask.TaskType.CAMPAIGN:
			return task.campaign_location
		_:
			return "Unknown"

func _get_task_level(task: DelegateTask) -> int:
	"""Get task level/effectiveness"""
	for delegate in GameData.player_airline.delegates:
		if delegate.current_task == task:
			return delegate.level
	return 1

func refresh_active_tasks() -> void:
	"""Refresh the active tasks list"""
	# Clear existing task cards (except empty label)
	for child in active_tasks_vbox.get_children():
		if child.name != "EmptyTasksLabel":
			child.queue_free()

	# Show/hide empty state
	var empty_label = active_tasks_vbox.get_node_or_null("EmptyTasksLabel")
	if empty_label:
		empty_label.visible = active_tasks.is_empty()

	# Create task cards
	for task in active_tasks:
		var card = create_task_card(task)
		active_tasks_vbox.add_child(card)

func create_task_card(task: Dictionary) -> Control:
	"""Create a card for displaying a delegate task - Figma-inspired design"""
	var card = PanelContainer.new()
	
	# Enhanced card style with hover effect
	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.get_card_bg()
	style.border_color = UITheme.get_panel_border()
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	style.shadow_color = Color(0, 0, 0, 0.05)
	style.shadow_size = 2
	card.add_theme_stylebox_override("panel", style)
	
	# Add hover effect
	card.mouse_entered.connect(_on_task_card_hover.bind(card, true))
	card.mouse_exited.connect(_on_task_card_hover.bind(card, false))

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	# Task icon
	var icon_label = Label.new()
	icon_label.text = _get_task_icon(task.get("type", ""))
	icon_label.add_theme_font_size_override("font_size", 20)
	icon_label.custom_minimum_size = Vector2(32, 32)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_label)

	# Task info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	var task_name = Label.new()
	task_name.text = task.get("description", "Unknown Task")
	task_name.add_theme_font_size_override("font_size", 14)
	task_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(task_name)

	var task_details = Label.new()
	task_details.text = _get_task_details(task)
	task_details.add_theme_font_size_override("font_size", 12)
	task_details.add_theme_color_override("font_color", UITheme.get_text_secondary())
	info_vbox.add_child(task_details)

	# Progress/Level indicator - Enhanced badge style
	if task.has("level"):
		var level_label = Label.new()
		level_label.text = "Level %d" % task.get("level", 0)
		level_label.add_theme_font_size_override("font_size", 11)
		level_label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
		
		# Enhanced badge with better styling
		var badge_style = StyleBoxFlat.new()
		badge_style.bg_color = Color(0.231, 0.510, 0.965, 0.15)  # Blue with transparency
		badge_style.set_corner_radius_all(9999)  # Fully rounded
		badge_style.set_content_margin_all(6)
		badge_style.content_margin_left = 10
		badge_style.content_margin_right = 10
		badge_style.border_color = Color(0.231, 0.510, 0.965, 0.3)
		badge_style.set_border_width_all(1)
		level_label.add_theme_stylebox_override("normal", badge_style)
		hbox.add_child(level_label)

	# Cancel button
	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(80, 32)
	cancel_btn.add_theme_font_size_override("font_size", 12)
	var cancel_style = UITheme.create_secondary_button_style()
	cancel_btn.add_theme_stylebox_override("normal", cancel_style)
	cancel_btn.pressed.connect(_on_cancel_task.bind(task.get("id", -1)))
	hbox.add_child(cancel_btn)

	return card

func _get_task_icon(task_type: String) -> String:
	"""Get icon for task type"""
	match task_type:
		"country":
			return "🌍"
		"negotiation":
			return "🤝"
		"campaign":
			return "📢"
		_:
			return "📋"

func _get_task_details(task: Dictionary) -> String:
	"""Get details string for task"""
	var type = task.get("type", "")
	match type:
		"country":
			return "Improving relationship with %s" % task.get("target_name", "Unknown")
		"negotiation":
			return "Negotiating route: %s → %s" % [
				task.get("from_airport", "?"),
				task.get("to_airport", "?")
			]
		"campaign":
			return "Campaign in %s" % task.get("location", "Unknown")
		_:
			return "Active task"

func _on_assign_button_pressed() -> void:
	"""Handle assign delegate button press"""
	# Emit signal to open assignment dialog
	delegate_assignment_requested.emit("", {})

func _on_cancel_task(task_id: int) -> void:
	"""Handle task cancellation"""
	if task_id >= 0:
		task_cancelled.emit(task_id)

func add_task(task: Dictionary) -> void:
	"""Add a new task to the list"""
	active_tasks.append(task)
	refresh_active_tasks()
	update_delegates_info()

func remove_task(task_id: int) -> void:
	"""Remove a task from the list"""
	active_tasks = active_tasks.filter(func(t): return t.get("id", -1) != task_id)
	refresh_active_tasks()
	update_delegates_info()

func _on_task_card_hover(card: PanelContainer, is_hover: bool) -> void:
	"""Handle card hover effect"""
	var style = StyleBoxFlat.new()
	if is_hover:
		style.bg_color = UITheme.get_card_hover()
		style.shadow_color = Color(0, 0, 0, 0.1)
		style.shadow_size = 4
	else:
		style.bg_color = UITheme.get_card_bg()
		style.shadow_color = Color(0, 0, 0, 0.05)
		style.shadow_size = 2
	
	style.border_color = UITheme.get_panel_border()
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	card.add_theme_stylebox_override("panel", style)
