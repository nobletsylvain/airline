extends Control
class_name FleetManagementPanel

## Fleet Management Panel - Shows aircraft grouped by status
## Displays In Flight, Boarding, Maintenance, Idle, Delivery sections

signal purchase_aircraft_pressed()
signal aircraft_selected(aircraft: AircraftInstance)

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var header_hbox: HBoxContainer
var purchase_button: Button
var search_field: LineEdit

# Status sections (collapsible)
var status_sections: Dictionary = {}  # Status -> VBoxContainer

func _ready() -> void:
	build_ui()

func build_ui() -> void:
	"""Build the fleet management panel UI"""
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

	# Header row with title and purchase button
	create_header(outer_vbox)

	# Search/filter row (future enhancement)
	create_search_bar(outer_vbox)

	# Scrollable content
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)

	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 20)
	scroll_container.add_child(main_vbox)

	# Create status sections
	create_status_sections()

func create_header(parent: VBoxContainer) -> void:
	"""Create header with title and purchase button"""
	header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 16)
	parent.add_child(header_hbox)

	# Title
	var title = Label.new()
	title.text = "Fleet Management"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	header_hbox.add_child(title)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	# Purchase Aircraft button
	purchase_button = Button.new()
	purchase_button.text = "+ Purchase Aircraft"
	purchase_button.custom_minimum_size = Vector2(180, 40)
	purchase_button.add_theme_font_size_override("font_size", 14)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = UITheme.PRIMARY_BLUE
	btn_style.set_corner_radius_all(8)
	btn_style.set_content_margin_all(10)
	purchase_button.add_theme_stylebox_override("normal", btn_style)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = UITheme.PRIMARY_BLUE.lightened(0.1)
	btn_hover.set_corner_radius_all(8)
	btn_hover.set_content_margin_all(10)
	purchase_button.add_theme_stylebox_override("hover", btn_hover)

	purchase_button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	purchase_button.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
	purchase_button.pressed.connect(func(): purchase_aircraft_pressed.emit())
	header_hbox.add_child(purchase_button)

func create_search_bar(parent: VBoxContainer) -> void:
	"""Create search/filter bar"""
	var search_hbox = HBoxContainer.new()
	search_hbox.add_theme_constant_override("separation", 12)
	parent.add_child(search_hbox)

	# Search field
	search_field = LineEdit.new()
	search_field.placeholder_text = "Search aircraft..."
	search_field.custom_minimum_size = Vector2(250, 36)
	search_field.add_theme_font_size_override("font_size", 13)

	var search_style = StyleBoxFlat.new()
	search_style.bg_color = UITheme.get_panel_bg()
	search_style.set_corner_radius_all(6)
	search_style.set_content_margin_all(8)
	search_style.border_color = UITheme.get_panel_border()
	search_style.set_border_width_all(1)
	search_field.add_theme_stylebox_override("normal", search_style)
	search_field.text_changed.connect(_on_search_changed)
	search_hbox.add_child(search_field)

	# Fleet summary label
	var summary_spacer = Control.new()
	summary_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_hbox.add_child(summary_spacer)

	var summary_label = Label.new()
	summary_label.name = "FleetSummary"
	summary_label.add_theme_font_size_override("font_size", 13)
	summary_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	search_hbox.add_child(summary_label)

func create_status_sections() -> void:
	"""Create collapsible sections for each status"""
	# Order: In Flight, Boarding, Maintenance, Idle, Delivery
	var status_order = [
		AircraftInstance.Status.IN_FLIGHT,
		AircraftInstance.Status.BOARDING,
		AircraftInstance.Status.MAINTENANCE,
		AircraftInstance.Status.IDLE,
		AircraftInstance.Status.DELIVERY
	]

	for status in status_order:
		var section = create_status_section(status)
		main_vbox.add_child(section)
		status_sections[status] = section

func create_status_section(status: AircraftInstance.Status) -> VBoxContainer:
	"""Create a section for a specific status"""
	var section = VBoxContainer.new()
	section.name = "Section_%s" % AircraftInstance.STATUS_NAMES[status]
	section.add_theme_constant_override("separation", 12)

	# Section header
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	section.add_child(header)

	# Status badge
	var badge = create_status_badge(status)
	header.add_child(badge)

	# Count label
	var count_label = Label.new()
	count_label.name = "CountLabel"
	count_label.text = "(0)"
	count_label.add_theme_font_size_override("font_size", 14)
	count_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	header.add_child(count_label)

	# Separator line
	var separator = HSeparator.new()
	separator.modulate = Color(1, 1, 1, 0.3)
	section.add_child(separator)

	# Aircraft cards container (horizontal flow)
	var cards_flow = HFlowContainer.new()
	cards_flow.name = "CardsContainer"
	cards_flow.add_theme_constant_override("h_separation", 16)
	cards_flow.add_theme_constant_override("v_separation", 16)
	section.add_child(cards_flow)

	# Empty state label
	var empty_label = Label.new()
	empty_label.name = "EmptyLabel"
	empty_label.text = "No aircraft"
	empty_label.add_theme_font_size_override("font_size", 13)
	empty_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	empty_label.visible = true
	section.add_child(empty_label)

	return section

func create_status_badge(status: AircraftInstance.Status) -> PanelContainer:
	"""Create a status badge with icon and text"""
	var badge = PanelContainer.new()

	var style = StyleBoxFlat.new()
	style.bg_color = AircraftInstance.STATUS_COLORS[status]
	style.set_corner_radius_all(12)
	style.set_content_margin_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	badge.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	label.text = AircraftInstance.STATUS_NAMES[status]
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	badge.add_child(label)

	return badge

func create_aircraft_card(aircraft: AircraftInstance) -> PanelContainer:
	"""Create a card for an individual aircraft"""
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(280, 140)
	card.set_meta("aircraft_id", aircraft.id)

	# Card style
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = UITheme.get_panel_bg()
	card_style.set_corner_radius_all(12)
	card_style.set_content_margin_all(16)
	card_style.border_color = UITheme.get_panel_border()
	card_style.set_border_width_all(1)
	card.add_theme_stylebox_override("panel", card_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	# Top row: Model name and menu button
	var top_row = HBoxContainer.new()
	vbox.add_child(top_row)

	var model_label = Label.new()
	model_label.text = aircraft.model.get_display_name() if aircraft.model else "Unknown"
	model_label.add_theme_font_size_override("font_size", 14)
	model_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	model_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(model_label)

	# Registration number
	var reg_label = Label.new()
	reg_label.text = "N%03dSK" % aircraft.id  # Fake registration
	reg_label.add_theme_font_size_override("font_size", 11)
	reg_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	vbox.add_child(reg_label)

	# Condition bar
	var condition_row = create_stat_row("Condition", aircraft.condition, aircraft.get_condition_color())
	vbox.add_child(condition_row)

	# Capacity info
	var capacity_label = Label.new()
	if aircraft.configuration:
		capacity_label.text = "%dY / %dC / %dF" % [
			aircraft.configuration.economy_seats,
			aircraft.configuration.business_seats,
			aircraft.configuration.first_seats
		]
	else:
		capacity_label.text = "%d seats" % aircraft.get_total_capacity()
	capacity_label.add_theme_font_size_override("font_size", 11)
	capacity_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	vbox.add_child(capacity_label)

	# Assigned route (if any)
	if aircraft.is_assigned and aircraft.assigned_route_id >= 0:
		var route_label = Label.new()
		route_label.text = "Route #%d" % aircraft.assigned_route_id
		route_label.add_theme_font_size_override("font_size", 11)
		route_label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
		vbox.add_child(route_label)

	# Make card clickable
	card.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			aircraft_selected.emit(aircraft)
	)
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	return card

func create_stat_row(label_text: String, value: float, color: Color) -> HBoxContainer:
	"""Create a row with label and progress bar"""
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 70
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", UITheme.get_text_muted())
	row.add_child(label)

	# Progress bar background
	var bar_bg = Panel.new()
	bar_bg.custom_minimum_size = Vector2(100, 8)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	bg_style.set_corner_radius_all(4)
	bar_bg.add_theme_stylebox_override("panel", bg_style)
	row.add_child(bar_bg)

	# Progress bar fill
	var bar_fill = ColorRect.new()
	bar_fill.color = color
	bar_fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	bar_fill.anchor_right = value / 100.0
	bar_fill.offset_right = 0
	bar_bg.add_child(bar_fill)

	# Make fill rounded
	var fill_clip = bar_bg  # For now, simple rect

	# Value label
	var value_label = Label.new()
	value_label.text = "%d%%" % int(value)
	value_label.custom_minimum_size.x = 35
	value_label.add_theme_font_size_override("font_size", 11)
	value_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	return row

func refresh() -> void:
	"""Refresh the fleet display with current data"""
	if not GameData.player_airline:
		return

	var aircraft_list = GameData.player_airline.aircraft

	# Group aircraft by status
	var grouped: Dictionary = {}
	for status in AircraftInstance.Status.values():
		grouped[status] = []

	for aircraft in aircraft_list:
		var status = aircraft.get_status()
		grouped[status].append(aircraft)

	# Update each section
	for status in status_sections:
		var section = status_sections[status]
		var cards_container = section.get_node("CardsContainer")
		var empty_label = section.get_node("EmptyLabel")
		var count_label = section.get_node("CountLabel")

		# Clear existing cards
		for child in cards_container.get_children():
			child.queue_free()

		# Add aircraft cards
		var aircraft_for_status = grouped.get(status, [])
		count_label.text = "(%d)" % aircraft_for_status.size()

		if aircraft_for_status.is_empty():
			empty_label.visible = true
			cards_container.visible = false
		else:
			empty_label.visible = false
			cards_container.visible = true
			for aircraft in aircraft_for_status:
				var card = create_aircraft_card(aircraft)
				cards_container.add_child(card)

	# Update summary
	update_fleet_summary()

func update_fleet_summary() -> void:
	"""Update the fleet summary label"""
	if not GameData.player_airline:
		return

	var total = GameData.player_airline.aircraft.size()
	var assigned = 0
	var maintenance_needed = 0

	for aircraft in GameData.player_airline.aircraft:
		if aircraft.is_assigned:
			assigned += 1
		if aircraft.needs_maintenance():
			maintenance_needed += 1

	var summary_label = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/FleetSummary")
	if summary_label:
		var text = "%d aircraft total" % total
		if assigned > 0:
			text += " | %d assigned" % assigned
		if maintenance_needed > 0:
			text += " | %d need maintenance" % maintenance_needed
		summary_label.text = text

func _on_search_changed(new_text: String) -> void:
	"""Handle search text change - filter aircraft"""
	# TODO: Implement search filtering
	pass
