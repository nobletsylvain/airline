extends PanelContainer
class_name RouteCard

## Visual card component for displaying route information

signal route_selected(route: Route)
signal route_edit_requested(route: Route)

var route: Route = null
var is_selected: bool = false

# UI Elements
var route_label: Label = null
var aircraft_label: Label = null
var load_bar: ProgressBar = null
var profit_label: Label = null
var frequency_label: Label = null

func _init() -> void:
	custom_minimum_size = Vector2(0, UITheme.CARD_MIN_HEIGHT)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void:
	_setup_ui()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _setup_ui() -> void:
	"""Create the card UI layout"""
	# Apply card style
	_update_style()

	# Main container
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	# Top row: Route name + Aircraft
	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	vbox.add_child(top_row)

	# Route name (bold, larger)
	route_label = Label.new()
	route_label.name = "RouteLabel"
	route_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UITheme.style_label(route_label, UITheme.FONT_SIZE_HEADER, UITheme.TEXT_PRIMARY)
	top_row.add_child(route_label)

	# Aircraft info
	aircraft_label = Label.new()
	aircraft_label.name = "AircraftLabel"
	UITheme.style_label(aircraft_label, UITheme.FONT_SIZE_SMALL, UITheme.TEXT_SECONDARY)
	top_row.add_child(aircraft_label)

	# Middle row: Load bar with percentage
	var load_row = HBoxContainer.new()
	load_row.add_theme_constant_override("separation", 8)
	vbox.add_child(load_row)

	# Load bar
	load_bar = ProgressBar.new()
	load_bar.name = "LoadBar"
	load_bar.custom_minimum_size = Vector2(0, 16)
	load_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_bar.show_percentage = false
	load_bar.max_value = 100.0

	# Style the progress bar
	var bar_bg = UITheme.create_progress_bar_style(false)
	var bar_fill = UITheme.create_progress_bar_style(true)
	load_bar.add_theme_stylebox_override("background", bar_bg)
	load_bar.add_theme_stylebox_override("fill", bar_fill)
	load_row.add_child(load_bar)

	# Load percentage label
	var load_label = Label.new()
	load_label.name = "LoadLabel"
	load_label.custom_minimum_size = Vector2(45, 0)
	UITheme.style_label(load_label, UITheme.FONT_SIZE_SMALL, UITheme.TEXT_SECONDARY)
	load_row.add_child(load_label)

	# Bottom row: Frequency + Profit
	var bottom_row = HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 8)
	vbox.add_child(bottom_row)

	# Frequency
	frequency_label = Label.new()
	frequency_label.name = "FrequencyLabel"
	frequency_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UITheme.style_label(frequency_label, UITheme.FONT_SIZE_SMALL, UITheme.TEXT_MUTED)
	bottom_row.add_child(frequency_label)

	# Profit (right-aligned, colored)
	profit_label = Label.new()
	profit_label.name = "ProfitLabel"
	profit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	UITheme.style_label(profit_label, UITheme.FONT_SIZE_BODY, UITheme.TEXT_PRIMARY)
	bottom_row.add_child(profit_label)

func set_route(r: Route) -> void:
	"""Update the card with route data"""
	route = r
	if not route:
		return

	# Route name
	route_label.text = route.get_display_name()

	# Aircraft info
	if not route.assigned_aircraft.is_empty():
		var aircraft = route.assigned_aircraft[0]
		aircraft_label.text = "✈ " + aircraft.model.model_name
	else:
		aircraft_label.text = "No aircraft"
		aircraft_label.add_theme_color_override("font_color", UITheme.WARNING_COLOR)

	# Calculate load factor
	var load_factor: float = 0.0
	if route.get_total_capacity() > 0 and route.frequency > 0:
		load_factor = (route.passengers_transported / float(route.get_total_capacity() * route.frequency)) * 100
		load_factor = clamp(load_factor, 0, 100)

	# Update load bar
	load_bar.value = load_factor

	# Color the load bar fill based on load factor
	var load_color = UITheme.get_load_factor_color(load_factor)
	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = load_color
	bar_fill.set_corner_radius_all(4)
	load_bar.add_theme_stylebox_override("fill", bar_fill)

	# Load percentage label
	var load_label: Label = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer2/LoadLabel")
	if not load_label:
		load_label = load_bar.get_parent().get_node_or_null("LoadLabel")
	if load_label:
		load_label.text = "%.0f%%" % load_factor
		load_label.add_theme_color_override("font_color", load_color)

	# Frequency
	frequency_label.text = "%d flights/wk | %d pax" % [route.frequency, route.passengers_transported]

	# Profit (with color)
	var profit = route.weekly_profit
	var profit_color = UITheme.get_profit_color(profit)
	var profit_sign = "+" if profit >= 0 else ""
	profit_label.text = "%s%s/wk" % [profit_sign, UITheme.format_money(profit)]
	profit_label.add_theme_color_override("font_color", profit_color)

	# Update card style with profit-colored border
	_update_style()

func set_selected(selected: bool) -> void:
	"""Set selection state"""
	is_selected = selected
	_update_style()

func _update_style() -> void:
	"""Update the card's visual style"""
	var profit = route.weekly_profit if route else 0.0
	var style = UITheme.create_card_style(is_selected, profit)
	add_theme_stylebox_override("panel", style)

func _on_mouse_entered() -> void:
	"""Handle mouse hover"""
	if not is_selected:
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = UITheme.CARD_HOVER_BG
		hover_style.set_corner_radius_all(UITheme.CARD_BORDER_RADIUS)
		hover_style.set_content_margin_all(UITheme.CARD_PADDING)
		if route and route.weekly_profit != 0:
			hover_style.border_color = UITheme.get_profit_color(route.weekly_profit)
			hover_style.border_width_left = 4
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
				# Double click to edit
				route_edit_requested.emit(route)
			else:
				# Single click to select
				route_selected.emit(route)
			accept_event()
