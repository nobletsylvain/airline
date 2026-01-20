extends PanelContainer
class_name FleetCard

## Visual card component for displaying aircraft information

signal aircraft_selected(aircraft: AircraftInstance)
signal aircraft_assign_requested(aircraft: AircraftInstance)

var aircraft: AircraftInstance = null
var is_selected: bool = false

# UI Elements
var model_label: Label = null
var status_label: Label = null
var condition_bar: ProgressBar = null
var condition_label: Label = null
var details_label: Label = null

func _init() -> void:
	custom_minimum_size = Vector2(0, 70)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void:
	_setup_ui()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _setup_ui() -> void:
	"""Create the card UI layout"""
	_update_style()

	# Main container
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	# Left side: Icon area
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(40, 40)
	hbox.add_child(icon_container)

	# Draw aircraft icon
	icon_container.draw.connect(_draw_aircraft_icon.bind(icon_container))

	# Middle: Info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)

	# Top row: Model name + Status
	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	info_vbox.add_child(top_row)

	model_label = Label.new()
	model_label.name = "ModelLabel"
	model_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UITheme.style_label(model_label, UITheme.FONT_SIZE_BODY, UITheme.TEXT_PRIMARY)
	top_row.add_child(model_label)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	UITheme.style_label(status_label, UITheme.FONT_SIZE_SMALL, UITheme.TEXT_SECONDARY)
	top_row.add_child(status_label)

	# Details row
	details_label = Label.new()
	details_label.name = "DetailsLabel"
	UITheme.style_label(details_label, UITheme.FONT_SIZE_SMALL, UITheme.TEXT_MUTED)
	info_vbox.add_child(details_label)

	# Right side: Condition bar
	var condition_vbox = VBoxContainer.new()
	condition_vbox.custom_minimum_size = Vector2(80, 0)
	condition_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(condition_vbox)

	condition_label = Label.new()
	condition_label.name = "ConditionLabel"
	condition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UITheme.style_label(condition_label, UITheme.FONT_SIZE_TINY, UITheme.TEXT_MUTED)
	condition_vbox.add_child(condition_label)

	condition_bar = ProgressBar.new()
	condition_bar.name = "ConditionBar"
	condition_bar.custom_minimum_size = Vector2(0, 8)
	condition_bar.show_percentage = false
	condition_bar.max_value = 100.0

	var bar_bg = UITheme.create_progress_bar_style(false)
	condition_bar.add_theme_stylebox_override("background", bar_bg)
	condition_vbox.add_child(condition_bar)

func _draw_aircraft_icon(container: Control) -> void:
	"""Draw a simple aircraft icon"""
	var center = container.size / 2
	var icon_color = UITheme.TEXT_SECONDARY

	if aircraft:
		if aircraft.is_assigned:
			icon_color = UITheme.PLAYER_ROUTE_COLOR
		elif aircraft.condition < 50:
			icon_color = UITheme.WARNING_COLOR

	# Draw simple plane shape
	var points = PackedVector2Array([
		center + Vector2(15, 0),   # Nose
		center + Vector2(-5, -10), # Left wing
		center + Vector2(-10, 0),  # Tail
		center + Vector2(-5, 10),  # Right wing
	])
	container.draw_colored_polygon(points, icon_color)

func set_aircraft(ac: AircraftInstance) -> void:
	"""Update the card with aircraft data"""
	aircraft = ac
	if not aircraft:
		return

	# Model name with ID
	model_label.text = "%s [#%d]" % [aircraft.model.get_display_name(), aircraft.id]

	# Status badge styling
	if aircraft.is_assigned:
		status_label.text = "  In Flight  "
		status_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
		var badge_style = UITheme.create_badge_style(UITheme.PROFIT_COLOR)
		badge_style.bg_color = UITheme.PROFIT_COLOR
		status_label.add_theme_stylebox_override("normal", badge_style)
	else:
		status_label.text = "  Available  "
		status_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
		var badge_style = UITheme.create_badge_style(UITheme.TEXT_MUTED)
		badge_style.bg_color = UITheme.TEXT_MUTED
		status_label.add_theme_stylebox_override("normal", badge_style)

	# Details
	var config = aircraft.configuration
	details_label.text = "Cap: %d | Range: %dkm" % [
		config.economy + config.business + config.first_class,
		aircraft.model.range_km
	]

	# Condition
	var condition = aircraft.condition
	condition_label.text = "Condition"
	condition_bar.value = condition

	# Color condition bar
	var condition_color = UITheme.get_condition_color(condition)
	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = condition_color
	bar_fill.set_corner_radius_all(4)
	condition_bar.add_theme_stylebox_override("fill", bar_fill)

	# Update style
	_update_style()

	# Force icon redraw
	var icon_container = get_node_or_null("MarginContainer/HBoxContainer/Control")
	if icon_container:
		icon_container.queue_redraw()

func set_selected(selected: bool) -> void:
	"""Set selection state"""
	is_selected = selected
	_update_style()

func _update_style() -> void:
	"""Update the card's visual style"""
	var style = StyleBoxFlat.new()

	if is_selected:
		style.bg_color = UITheme.CARD_SELECTED_BG
	else:
		style.bg_color = UITheme.CARD_BG_COLOR

	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)

	# Border based on assignment status
	if aircraft:
		if aircraft.is_assigned:
			style.border_color = UITheme.PLAYER_ROUTE_COLOR
			style.border_width_left = 3
		elif aircraft.condition < 50:
			style.border_color = UITheme.WARNING_COLOR
			style.border_width_left = 3
		else:
			style.border_color = UITheme.PANEL_BORDER_COLOR
			style.set_border_width_all(1)
	else:
		style.border_color = UITheme.PANEL_BORDER_COLOR
		style.set_border_width_all(1)

	add_theme_stylebox_override("panel", style)

func _on_mouse_entered() -> void:
	"""Handle mouse hover"""
	if not is_selected:
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = UITheme.CARD_HOVER_BG
		hover_style.set_corner_radius_all(6)
		hover_style.set_content_margin_all(8)
		hover_style.border_color = UITheme.PANEL_BORDER_COLOR.lightened(0.2)
		hover_style.set_border_width_all(1)
		add_theme_stylebox_override("panel", hover_style)

func _on_mouse_exited() -> void:
	"""Handle mouse exit"""
	if not is_selected:
		_update_style()

func _gui_input(event: InputEvent) -> void:
	"""Handle input events"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				# Double click to assign
				aircraft_assign_requested.emit(aircraft)
			else:
				# Single click to select
				aircraft_selected.emit(aircraft)
			accept_event()
