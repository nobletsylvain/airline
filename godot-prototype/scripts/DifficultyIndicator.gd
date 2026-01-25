extends Control
class_name DifficultyIndicator

## Reusable component for displaying difficulty visually
## Shows difficulty score (0-100) as a colored bar

# UI Elements
var difficulty_bar: ProgressBar
var difficulty_label: Label
var difficulty_value: float = 0.0

func _ready() -> void:
	build_ui()
	# Update display with any value that was set before _ready()
	if difficulty_value != 0.0:
		_update_display()

func build_ui() -> void:
	"""Build the difficulty indicator UI"""
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)

	# Difficulty bar
	difficulty_bar = ProgressBar.new()
	difficulty_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	difficulty_bar.custom_minimum_size = Vector2(0, 16)
	difficulty_bar.max_value = 100.0
	difficulty_bar.show_percentage = false

	# Style the bar
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = UITheme.get_panel_border()
	bg_style.set_corner_radius_all(4)
	difficulty_bar.add_theme_stylebox_override("background", bg_style)

	hbox.add_child(difficulty_bar)

	# Difficulty label
	difficulty_label = Label.new()
	difficulty_label.custom_minimum_size = Vector2(50, 0)
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	difficulty_label.add_theme_font_size_override("font_size", 11)
	hbox.add_child(difficulty_label)

func set_difficulty(value: float) -> void:
	"""Set difficulty value (0-100)"""
	difficulty_value = clamp(value, 0.0, 100.0)
	# Update display if UI is ready, otherwise it will update in _ready()
	if difficulty_bar and difficulty_label:
		_update_display()

func _update_display() -> void:
	"""Update the visual display"""
	# Ensure UI is built before updating
	if not difficulty_bar or not difficulty_label:
		return
	
	difficulty_bar.value = difficulty_value
	difficulty_label.text = "%.0f" % difficulty_value

	# Color code based on difficulty
	var bar_color: Color
	if difficulty_value < 30:
		bar_color = UITheme.PROFIT_COLOR  # Green - Easy
	elif difficulty_value < 60:
		bar_color = UITheme.WARNING_COLOR  # Yellow - Medium
	else:
		bar_color = UITheme.ERROR_COLOR  # Red - Hard

	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = bar_color
	fill_style.set_corner_radius_all(4)
	difficulty_bar.add_theme_stylebox_override("fill", fill_style)

	# Update label color
	difficulty_label.add_theme_color_override("font_color", bar_color)
