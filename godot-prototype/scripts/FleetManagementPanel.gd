extends Control
class_name FleetManagementPanel

## Fleet Management Panel - Shows aircraft grouped by status
## Displays In Flight, Boarding, Maintenance, Idle, Delivery sections
## Includes Fleet Comparison tab for side-by-side aircraft analysis (N.1)

signal purchase_aircraft_pressed()
signal aircraft_selected(aircraft: AircraftInstance)

## Tab indices
const TAB_FLEET_STATUS := 0
const TAB_FLEET_COMPARISON := 1

# UI Elements
var tab_buttons: Dictionary = {}  # TAB_* -> Button
var content_container: Control
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var header_hbox: HBoxContainer
var purchase_button: Button
var search_field: LineEdit

# Fleet Comparison panel (N.1)
var comparison_panel: FleetComparisonPanel

# Status sections (collapsible)
var status_sections: Dictionary = {}  # Status -> VBoxContainer

# Track current tab
var current_tab: int = TAB_FLEET_STATUS

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

	# Tab bar for Fleet Status / Fleet Comparison (N.1)
	create_tab_bar(outer_vbox)
	
	# Content container (holds both views)
	content_container = Control.new()
	content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_vbox.add_child(content_container)
	
	# Fleet Status content (the original content)
	var status_content = VBoxContainer.new()
	status_content.name = "FleetStatusContent"
	status_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status_content.add_theme_constant_override("separation", 16)
	content_container.add_child(status_content)

	# Header row with title and purchase button
	create_header(status_content)

	# Search/filter row (future enhancement)
	create_search_bar(status_content)

	# Scrollable content
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	status_content.add_child(scroll_container)

	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 20)
	scroll_container.add_child(main_vbox)

	# Create status sections
	create_status_sections()
	
	# Fleet Comparison content (N.1)
	comparison_panel = FleetComparisonPanel.new()
	comparison_panel.name = "FleetComparisonContent"
	comparison_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	comparison_panel.visible = false
	content_container.add_child(comparison_panel)


func create_tab_bar(parent: VBoxContainer) -> void:
	"""Create prominent tab buttons for switching between Fleet Status and Fleet Comparison"""
	var tab_container = HBoxContainer.new()
	tab_container.add_theme_constant_override("separation", 12)
	parent.add_child(tab_container)
	
	# Fleet Status button
	var status_btn = _create_tab_button("✈  Fleet Status", TAB_FLEET_STATUS, true)
	tab_buttons[TAB_FLEET_STATUS] = status_btn
	tab_container.add_child(status_btn)
	
	# Fleet Comparison button - more prominent with accent color
	var comparison_btn = _create_tab_button("📊  Compare Aircraft", TAB_FLEET_COMPARISON, false)
	tab_buttons[TAB_FLEET_COMPARISON] = comparison_btn
	tab_container.add_child(comparison_btn)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_container.add_child(spacer)


func _create_tab_button(text: String, tab_id: int, is_active: bool) -> Button:
	"""Create a styled tab button"""
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(180, 44)
	btn.add_theme_font_size_override("font_size", 15)
	btn.toggle_mode = true
	btn.button_pressed = is_active
	btn.pressed.connect(_on_tab_button_pressed.bind(tab_id))
	
	_style_tab_button(btn, tab_id, is_active)
	return btn


func _style_tab_button(btn: Button, tab_id: int, is_active: bool) -> void:
	"""Style a tab button based on active state and tab type"""
	var style = StyleBoxFlat.new()
	
	if is_active:
		# Active tab - solid background
		if tab_id == TAB_FLEET_COMPARISON:
			style.bg_color = UITheme.PRIMARY_BLUE
		else:
			style.bg_color = UITheme.get_card_bg()
		style.border_color = UITheme.PRIMARY_BLUE if tab_id == TAB_FLEET_COMPARISON else UITheme.get_panel_border()
		style.set_border_width_all(2)
	else:
		# Inactive tab
		if tab_id == TAB_FLEET_COMPARISON:
			# Comparison button stands out even when inactive
			style.bg_color = Color(UITheme.PRIMARY_BLUE.r, UITheme.PRIMARY_BLUE.g, UITheme.PRIMARY_BLUE.b, 0.15)
			style.border_color = UITheme.PRIMARY_BLUE
			style.set_border_width_all(2)
		else:
			style.bg_color = UITheme.get_panel_bg()
			style.border_color = UITheme.get_panel_border()
			style.set_border_width_all(1)
	
	style.set_corner_radius_all(10)
	style.set_content_margin_all(12)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("pressed", style)
	
	# Hover style
	var hover_style = style.duplicate()
	hover_style.bg_color = hover_style.bg_color.lightened(0.1)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	# Text color
	if is_active:
		btn.add_theme_color_override("font_color", UITheme.TEXT_WHITE if tab_id == TAB_FLEET_COMPARISON else UITheme.get_text_primary())
	else:
		btn.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE if tab_id == TAB_FLEET_COMPARISON else UITheme.get_text_secondary())
	
	btn.add_theme_color_override("font_hover_color", btn.get_theme_color("font_color"))


func _on_tab_button_pressed(tab_id: int) -> void:
	"""Handle tab button press"""
	current_tab = tab_id
	
	# Update all button styles
	for tid in tab_buttons:
		var btn: Button = tab_buttons[tid]
		btn.button_pressed = (tid == current_tab)
		_style_tab_button(btn, tid, tid == current_tab)
	
	# Show/hide content
	_update_tab_visibility()


func _update_tab_visibility() -> void:
	"""Update content visibility based on current tab"""
	var status_content = content_container.get_node_or_null("FleetStatusContent")
	var comparison_content = content_container.get_node_or_null("FleetComparisonContent")
	
	if status_content:
		status_content.visible = (current_tab == TAB_FLEET_STATUS)
	if comparison_content:
		comparison_content.visible = (current_tab == TAB_FLEET_COMPARISON)
		if current_tab == TAB_FLEET_COMPARISON and comparison_panel:
			comparison_panel.refresh()

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
	# Use status int value to avoid spaces in name
	section.name = "Section_%d" % status
	section.add_theme_constant_override("separation", 12)

	# Section header
	var header = HBoxContainer.new()
	header.name = "Header"
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
		var route_name = _get_route_display_name(aircraft.assigned_route_id)
		route_label.text = "✈ %s" % route_name
		route_label.add_theme_font_size_override("font_size", 11)
		route_label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
		vbox.add_child(route_label)
	
	# Performance badge (N.2) - only show if aircraft has history
	if not aircraft.revenue_history.is_empty():
		var perf_hbox = HBoxContainer.new()
		perf_hbox.add_theme_constant_override("separation", 6)
		vbox.add_child(perf_hbox)
		
		var perf_badge = Label.new()
		# Use comparative badge against entire fleet
		var all_aircraft = GameData.player_airline.aircraft if GameData.player_airline else []
		var badge_text = aircraft.get_comparative_badge(all_aircraft)
		perf_badge.text = badge_text
		perf_badge.add_theme_font_size_override("font_size", 10)
		var badge_color = aircraft.get_comparative_badge_color(badge_text)
		perf_badge.add_theme_color_override("font_color", badge_color)
		
		var badge_style = StyleBoxFlat.new()
		badge_style.bg_color = Color(badge_color.r, badge_color.g, badge_color.b, 0.15)
		badge_style.set_corner_radius_all(4)
		badge_style.set_content_margin_all(4)
		perf_badge.add_theme_stylebox_override("normal", badge_style)
		perf_hbox.add_child(perf_badge)

	# Make card clickable with hover effect (N.2: click for performance details)
	card.tooltip_text = "Click to view performance details"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Store original style for hover effect
	var hover_style = card_style.duplicate()
	hover_style.border_color = UITheme.PRIMARY_BLUE
	hover_style.set_border_width_all(2)
	
	card.mouse_entered.connect(func():
		card.add_theme_stylebox_override("panel", hover_style)
	)
	card.mouse_exited.connect(func():
		card.add_theme_stylebox_override("panel", card_style)
	)
	
	card.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			aircraft_selected.emit(aircraft)
	)

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
	
	# Refresh comparison panel if it's visible
	if current_tab == TAB_FLEET_COMPARISON and comparison_panel:
		comparison_panel.refresh()

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
		var cards_container = section.get_node_or_null("CardsContainer")
		var empty_label = section.get_node_or_null("EmptyLabel")
		var count_label = section.get_node_or_null("Header/CountLabel")

		if not cards_container or not empty_label:
			continue

		# Clear existing cards
		for child in cards_container.get_children():
			child.queue_free()

		# Add aircraft cards
		var aircraft_for_status = grouped.get(status, [])
		if count_label:
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


func _get_route_display_name(route_id: int) -> String:
	"""Get the display name for a route by ID"""
	if GameData.player_airline:
		for route in GameData.player_airline.routes:
			if route.id == route_id:
				return route.get_display_name()
	return "Unknown Route"
