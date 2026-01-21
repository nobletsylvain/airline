extends PanelContainer
class_name TimeSpeedPanel

## Time and Speed Control Panel
## Displays date/time and simulation speed controls
## Based on mockup design with modern styling

signal speed_changed(level: int)
signal play_pause_pressed()

# UI Elements
var date_label: Label
var day_label: Label
var time_label: Label
var speed_buttons: Array[Button] = []
var play_button: Button
var fast_forward_btn: Button
var max_speed_btn: Button

# State
var current_speed: int = 0  # 0 = paused, 1-5 = speed levels
var is_playing: bool = false

# Simulation engine reference
var simulation_engine: Node = null

# Constants
const SPEED_LABELS = ["1x", "2x", "3x", "4x", "5x"]
const SPEED_LEVELS = [1, 2, 3, 4, 5]  # Maps to simulation engine speeds

func _ready() -> void:
	build_ui()
	update_time_display()

func build_ui() -> void:
	"""Build the time/speed panel UI"""
	# Panel styling - dark semi-transparent
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.09, 0.16, 0.95)  # Dark blue-gray
	panel_style.set_corner_radius_all(16)
	panel_style.set_content_margin_all(20)
	panel_style.border_color = Color(0.2, 0.25, 0.35, 0.5)
	panel_style.set_border_width_all(1)
	add_theme_stylebox_override("panel", panel_style)

	# Main horizontal layout
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 40)
	add_child(hbox)

	# Left side: Date/Time display
	create_date_section(hbox)

	# Vertical separator
	var separator = VSeparator.new()
	separator.add_theme_constant_override("separation", 2)
	separator.modulate = Color(0.3, 0.35, 0.45, 0.5)
	hbox.add_child(separator)

	# Right side: Speed controls
	create_speed_section(hbox)

func create_date_section(parent: HBoxContainer) -> void:
	"""Create the date/time display section"""
	var date_vbox = VBoxContainer.new()
	date_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(date_vbox)

	# "DATE" label with calendar icon
	var date_header = HBoxContainer.new()
	date_header.add_theme_constant_override("separation", 6)
	date_vbox.add_child(date_header)

	var calendar_icon = Label.new()
	calendar_icon.text = "📅"
	calendar_icon.add_theme_font_size_override("font_size", 12)
	date_header.add_child(calendar_icon)

	var date_title = Label.new()
	date_title.text = "DATE"
	date_title.add_theme_font_size_override("font_size", 11)
	date_title.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	date_header.add_child(date_title)

	# Main date display
	date_label = Label.new()
	date_label.text = "January 1, 1990"
	date_label.add_theme_font_size_override("font_size", 22)
	date_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	date_vbox.add_child(date_label)

	# Day and time row
	var day_time_hbox = HBoxContainer.new()
	day_time_hbox.add_theme_constant_override("separation", 12)
	date_vbox.add_child(day_time_hbox)

	# Day of week
	day_label = Label.new()
	day_label.text = "Monday"
	day_label.add_theme_font_size_override("font_size", 14)
	day_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	day_time_hbox.add_child(day_label)

	# Time badge
	var time_badge = PanelContainer.new()
	var time_style = StyleBoxFlat.new()
	time_style.bg_color = Color(0.15, 0.18, 0.25, 0.8)
	time_style.set_corner_radius_all(8)
	time_style.set_content_margin_all(6)
	time_style.content_margin_left = 10
	time_style.content_margin_right = 10
	time_badge.add_theme_stylebox_override("panel", time_style)
	day_time_hbox.add_child(time_badge)

	var time_hbox = HBoxContainer.new()
	time_hbox.add_theme_constant_override("separation", 6)
	time_badge.add_child(time_hbox)

	var clock_icon = Label.new()
	clock_icon.text = "🕐"
	clock_icon.add_theme_font_size_override("font_size", 14)
	time_hbox.add_child(clock_icon)

	time_label = Label.new()
	time_label.text = "00:00"
	time_label.add_theme_font_size_override("font_size", 16)
	time_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	time_hbox.add_child(time_label)

func create_speed_section(parent: HBoxContainer) -> void:
	"""Create the speed control section"""
	var speed_vbox = VBoxContainer.new()
	speed_vbox.add_theme_constant_override("separation", 12)
	parent.add_child(speed_vbox)

	# Speed multiplier buttons row
	var speed_row = HBoxContainer.new()
	speed_row.add_theme_constant_override("separation", 4)
	speed_vbox.add_child(speed_row)

	for i in range(SPEED_LABELS.size()):
		var btn = create_speed_button(SPEED_LABELS[i], i)
		speed_row.add_child(btn)
		speed_buttons.append(btn)

	# Play controls row
	var play_row = HBoxContainer.new()
	play_row.add_theme_constant_override("separation", 8)
	play_row.alignment = BoxContainer.ALIGNMENT_CENTER
	speed_vbox.add_child(play_row)

	# Large play/pause button
	play_button = Button.new()
	play_button.text = "▶"
	play_button.custom_minimum_size = Vector2(56, 56)
	play_button.add_theme_font_size_override("font_size", 24)
	_update_play_button_style()
	play_button.pressed.connect(_on_play_pressed)
	play_row.add_child(play_button)

	# Fast forward button
	fast_forward_btn = create_control_button("▷", "Normal speed")
	fast_forward_btn.pressed.connect(_on_fast_forward_pressed)
	play_row.add_child(fast_forward_btn)

	# Double fast forward
	var double_ff_btn = create_control_button("▷▷", "Fast")
	double_ff_btn.pressed.connect(_on_double_ff_pressed)
	play_row.add_child(double_ff_btn)

	# Max speed button
	max_speed_btn = create_control_button("▷▷▷▷", "Max speed")
	max_speed_btn.pressed.connect(_on_max_speed_pressed)
	play_row.add_child(max_speed_btn)

func create_speed_button(text: String, index: int) -> Button:
	"""Create a speed multiplier button"""
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(44, 32)
	btn.add_theme_font_size_override("font_size", 12)
	btn.toggle_mode = true

	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.18, 0.25, 0.8)
	normal_style.set_corner_radius_all(6)
	normal_style.set_content_margin_all(6)
	btn.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.2, 0.24, 0.32, 0.9)
	hover_style.set_corner_radius_all(6)
	hover_style.set_content_margin_all(6)
	btn.add_theme_stylebox_override("hover", hover_style)

	# Green when pressed/active (matches mockup)
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = UITheme.PROFIT_COLOR  # Green
	pressed_style.set_corner_radius_all(6)
	pressed_style.set_content_margin_all(6)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	btn.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
	btn.add_theme_color_override("font_pressed_color", UITheme.TEXT_WHITE)

	btn.pressed.connect(_on_speed_button_pressed.bind(index))
	return btn

func create_control_button(text: String, tooltip: String) -> Button:
	"""Create a playback control button"""
	var btn = Button.new()
	btn.text = text
	btn.tooltip_text = tooltip
	btn.custom_minimum_size = Vector2(40, 40)
	btn.add_theme_font_size_override("font_size", 14)

	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0, 0, 0, 0)
	normal_style.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.2, 0.24, 0.32, 0.6)
	hover_style.set_corner_radius_all(20)
	btn.add_theme_stylebox_override("hover", hover_style)

	btn.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)

	return btn

func _on_speed_button_pressed(index: int) -> void:
	"""Handle speed button press"""
	current_speed = SPEED_LEVELS[index]

	# Update button states
	for i in range(speed_buttons.size()):
		speed_buttons[i].button_pressed = (i == index)

	# If not playing, start playing
	if not is_playing:
		_start_simulation()

	speed_changed.emit(current_speed)

	# Update simulation engine
	if simulation_engine:
		simulation_engine.set_speed(current_speed)

func _on_play_pressed() -> void:
	"""Handle play/pause button press"""
	if is_playing:
		_pause_simulation()
	else:
		_start_simulation()

	play_pause_pressed.emit()

func _on_fast_forward_pressed() -> void:
	"""Set to normal speed (1x)"""
	_set_speed_level(0)

func _on_double_ff_pressed() -> void:
	"""Set to fast speed (3x)"""
	_set_speed_level(2)

func _on_max_speed_pressed() -> void:
	"""Set to max speed (5x)"""
	_set_speed_level(4)

func _set_speed_level(index: int) -> void:
	"""Set speed to a specific level"""
	if index >= 0 and index < speed_buttons.size():
		_on_speed_button_pressed(index)

func _start_simulation() -> void:
	"""Start the simulation"""
	is_playing = true
	play_button.text = "⏸"
	_update_play_button_style()

	if simulation_engine:
		if current_speed == 0:
			current_speed = 3  # Default to 3x
			_set_speed_level(2)
		simulation_engine.start_simulation()

func _pause_simulation() -> void:
	"""Pause the simulation"""
	is_playing = false
	play_button.text = "▶"
	_update_play_button_style()

	if simulation_engine:
		simulation_engine.pause_simulation()

func _update_play_button_style() -> void:
	"""Update play button appearance based on state"""
	if is_playing:
		# Dark style when showing pause button
		var pause_style = StyleBoxFlat.new()
		pause_style.bg_color = Color(0.2, 0.24, 0.32, 1.0)
		pause_style.set_corner_radius_all(28)
		play_button.add_theme_stylebox_override("normal", pause_style)

		var pause_hover = StyleBoxFlat.new()
		pause_hover.bg_color = Color(0.25, 0.30, 0.40, 1.0)
		pause_hover.set_corner_radius_all(28)
		play_button.add_theme_stylebox_override("hover", pause_hover)
	else:
		# Orange/Amber style when showing play button
		var play_style = StyleBoxFlat.new()
		play_style.bg_color = Color("#f59e0b")  # Amber/Orange
		play_style.set_corner_radius_all(28)
		play_button.add_theme_stylebox_override("normal", play_style)

		var play_hover = StyleBoxFlat.new()
		play_hover.bg_color = Color("#d97706")  # Darker amber
		play_hover.set_corner_radius_all(28)
		play_button.add_theme_stylebox_override("hover", play_hover)

	play_button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	play_button.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)

func update_time_display() -> void:
	"""Update the date/time display from GameData"""
	if not date_label:
		return

	# Calculate date from week number - Game starts in 1990
	var week = GameData.current_week
	var year = 1990 + (week / 52)
	var week_in_year = week % 52

	# Convert week to approximate date
	var month_names = ["January", "February", "March", "April", "May", "June",
					   "July", "August", "September", "October", "November", "December"]
	var day_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

	# Approximate month and day from week
	var month_index = int(week_in_year / 4.33) % 12
	var day_of_month = ((week_in_year % 4) * 7) + 1
	day_of_month = clamp(day_of_month, 1, 28)  # Keep in safe range

	date_label.text = "%s %d, %d" % [month_names[month_index], day_of_month, year]
	day_label.text = day_names[week_in_year % 7]

	# Time based on simulation progress (if available)
	if simulation_engine and simulation_engine.has_method("get_week_progress"):
		var progress = simulation_engine.get_week_progress()
		var hours = int(progress * 24 * 7) % 24
		var minutes = int(progress * 24 * 60 * 7) % 60
		time_label.text = "%02d:%02d" % [hours, minutes]
	else:
		# Show current time of day based on week progress
		var hours = 8 + (week % 12)  # Vary between 8:00 and 20:00
		var minutes = (week * 13) % 60
		time_label.text = "%02d:%02d" % [hours, minutes]

func set_simulation_engine(engine: Node) -> void:
	"""Set the simulation engine reference"""
	simulation_engine = engine

	if simulation_engine:
		if simulation_engine.has_signal("simulation_started"):
			simulation_engine.simulation_started.connect(func():
				is_playing = true
				play_button.text = "⏸"
			)
		if simulation_engine.has_signal("simulation_paused"):
			simulation_engine.simulation_paused.connect(func():
				is_playing = false
				play_button.text = "▶"
			)
		if simulation_engine.has_signal("week_completed"):
			simulation_engine.week_completed.connect(func(_week): update_time_display())

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts"""
	if event is InputEventKey and event.pressed and not event.echo:
		var focus_owner = get_viewport().gui_get_focus_owner()
		var is_typing = focus_owner is LineEdit or focus_owner is TextEdit

		if not is_typing:
			match event.keycode:
				KEY_SPACE:
					_on_play_pressed()
					get_viewport().set_input_as_handled()
				KEY_1:
					_set_speed_level(0)
					get_viewport().set_input_as_handled()
				KEY_2:
					_set_speed_level(1)
					get_viewport().set_input_as_handled()
				KEY_3:
					_set_speed_level(2)
					get_viewport().set_input_as_handled()
				KEY_4:
					_set_speed_level(3)
					get_viewport().set_input_as_handled()
				KEY_5:
					_set_speed_level(4)
					get_viewport().set_input_as_handled()
