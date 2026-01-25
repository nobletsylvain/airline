extends Control
class_name RelationshipIndicator

## Reusable component for displaying country relationship visually
## Shows relationship score as a colored bar (-100 to +100)

# UI Elements
var relationship_bar: ProgressBar
var relationship_label: Label
var relationship_value: float = 0.0

func _ready() -> void:
	build_ui()
	# Update display with any value that was set before _ready()
	if relationship_value != 0.0:
		_update_display()

func build_ui() -> void:
	"""Build the relationship indicator UI"""
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)

	# Relationship bar
	relationship_bar = ProgressBar.new()
	relationship_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	relationship_bar.custom_minimum_size = Vector2(0, 16)
	relationship_bar.max_value = 200.0  # -100 to +100
	relationship_bar.value = 100.0  # Center (neutral)
	relationship_bar.show_percentage = false

	# Style the bar
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = UITheme.get_panel_border()
	bg_style.set_corner_radius_all(4)
	relationship_bar.add_theme_stylebox_override("background", bg_style)

	hbox.add_child(relationship_bar)

	# Relationship label
	relationship_label = Label.new()
	relationship_label.custom_minimum_size = Vector2(60, 0)
	relationship_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	relationship_label.add_theme_font_size_override("font_size", 11)
	hbox.add_child(relationship_label)

func set_relationship(value: float) -> void:
	"""Set relationship value (-100 to +100)"""
	relationship_value = clamp(value, -100.0, 100.0)
	# Update display if UI is ready, otherwise it will update in _ready()
	if relationship_bar and relationship_label:
		_update_display()

func _update_display() -> void:
	"""Update the visual display"""
	# Ensure UI is built before updating
	if not relationship_bar or not relationship_label:
		return
	
	# Set bar value (0-200 range, where 100 is neutral)
	relationship_bar.value = 100.0 + relationship_value

	# Set label text
	var relationship_text: String
	if relationship_value >= 50:
		relationship_text = "Allied"
	elif relationship_value >= 20:
		relationship_text = "Friendly"
	elif relationship_value >= 5:
		relationship_text = "Warm"
	elif relationship_value >= -5:
		relationship_text = "Neutral"
	elif relationship_value >= -20:
		relationship_text = "Cold"
	elif relationship_value >= -50:
		relationship_text = "Hostile"
	else:
		relationship_text = "War"

	relationship_label.text = "%s (%+.0f)" % [relationship_text, relationship_value]

	# Color the bar
	var bar_color: Color
	if relationship_value > 0:
		# Positive (green gradient)
		var intensity = relationship_value / 100.0
		bar_color = Color.WHITE.lerp(UITheme.PROFIT_COLOR, intensity)
	else:
		# Negative (red gradient)
		var intensity = abs(relationship_value) / 100.0
		bar_color = Color.WHITE.lerp(UITheme.LOSS_COLOR, intensity)

	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = bar_color
	fill_style.set_corner_radius_all(4)
	relationship_bar.add_theme_stylebox_override("fill", fill_style)

	# Update label color
	if relationship_value > 20:
		relationship_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
	elif relationship_value < -20:
		relationship_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
	else:
		relationship_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
