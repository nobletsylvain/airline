extends Control
class_name DashboardUI

## Dashboard-style Game UI
## Layout: Top Bar | Sidebar + Main Content | Bottom Bar
## Based on Figma mockup design

signal tab_changed(tab_name: String)
signal purchase_hub_pressed()
signal buy_aircraft_pressed()
signal create_route_pressed()

# Layout constants
const SIDEBAR_WIDTH = 256
const HEADER_HEIGHT = 64
const BOTTOM_HEIGHT = 56

# Current active tab
var current_tab: String = "map"

# UI References
var sidebar: PanelContainer
var header: PanelContainer
var main_content: Control
var bottom_bar: PanelContainer

# Header elements
var money_label: Label
var reputation_label: Label
var date_label: Label
var speed_container: HBoxContainer

# Sidebar navigation buttons
var nav_buttons: Dictionary = {}

# Simulation engine reference
var simulation_engine: Node = null

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Use call_deferred to ensure proper sizing
	call_deferred("create_layout")

func create_layout() -> void:
	"""Create the main dashboard layout using anchor-based positioning"""

	# Main background
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = UITheme.BG_MAIN
	add_child(bg)

	# Create components in order (z-order)
	create_header()
	create_sidebar()
	create_main_content()
	create_bottom_bar()

	# Initial state - select first speed button
	if speed_container and speed_container.get_child_count() > 0:
		var first_btn = speed_container.get_child(0) as Button
		if first_btn:
			first_btn.button_pressed = true

func create_header() -> void:
	"""Create the top header bar - full width at top"""
	header = PanelContainer.new()
	header.name = "Header"
	add_child(header)

	# Anchor to top, full width
	header.anchor_left = 0
	header.anchor_top = 0
	header.anchor_right = 1
	header.anchor_bottom = 0
	header.offset_bottom = HEADER_HEIGHT

	var header_style = StyleBoxFlat.new()
	header_style.bg_color = UITheme.PANEL_BG_COLOR
	header_style.border_color = UITheme.PANEL_BORDER_COLOR
	header_style.border_width_bottom = 1
	header_style.shadow_color = Color(0, 0, 0, 0.08)
	header_style.shadow_size = 4
	header.add_theme_stylebox_override("panel", header_style)

	var header_margin = MarginContainer.new()
	header_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header_margin.add_theme_constant_override("margin_left", 24)
	header_margin.add_theme_constant_override("margin_right", 24)
	header_margin.add_theme_constant_override("margin_top", 8)
	header_margin.add_theme_constant_override("margin_bottom", 8)
	header.add_child(header_margin)

	var header_hbox = HBoxContainer.new()
	header_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header_hbox.add_theme_constant_override("separation", 24)
	header_margin.add_child(header_hbox)

	# Left: KPI stats
	create_header_stats(header_hbox)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	# Center: Speed controls
	create_speed_controls(header_hbox)

	# Spacer
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer2)

	# Right: Date/Time
	create_header_right(header_hbox)

func create_header_stats(parent: HBoxContainer) -> void:
	"""Create KPI stats in header"""
	# Money
	var money_container = create_stat_pill("$", "$10.0M", UITheme.PROFIT_COLOR)
	money_label = money_container.get_node("Value")
	parent.add_child(money_container)

	# Reputation
	var rep_container = create_stat_pill(UITheme.ICON_STAR, "50.0", UITheme.HUB_COLOR)
	reputation_label = rep_container.get_node("Value")
	parent.add_child(rep_container)

	# Grade badge
	var grade_container = create_grade_badge()
	parent.add_child(grade_container)

func create_stat_pill(icon: String, value: String, color: Color) -> HBoxContainer:
	"""Create a stat display pill"""
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 6)

	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 18)
	icon_label.add_theme_color_override("font_color", color)
	container.add_child(icon_label)

	var value_label = Label.new()
	value_label.name = "Value"
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	container.add_child(value_label)

	return container

func create_grade_badge() -> PanelContainer:
	"""Create grade badge"""
	var panel = PanelContainer.new()
	panel.name = "GradeBadge"
	panel.custom_minimum_size = Vector2(50, 28)

	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.GRADE_NEW_COLOR
	style.set_corner_radius_all(14)
	style.set_content_margin_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	label.name = "GradeLabel"
	label.text = "NEW"
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)

	return panel

func create_speed_controls(parent: HBoxContainer) -> void:
	"""Create simulation speed controls"""
	speed_container = HBoxContainer.new()
	speed_container.add_theme_constant_override("separation", 4)
	parent.add_child(speed_container)

	var speeds = [
		{"text": "⏸", "tooltip": "Pause (Space)", "level": 0},
		{"text": "1x", "tooltip": "Real-Time [1]", "level": 1},
		{"text": "10x", "tooltip": "Slow [2]", "level": 2},
		{"text": "50x", "tooltip": "Normal [3]", "level": 3},
		{"text": "200x", "tooltip": "Fast [4]", "level": 4},
		{"text": "MAX", "tooltip": "Max Speed [5]", "level": 5},
	]

	for speed in speeds:
		var btn = Button.new()
		btn.text = speed.text
		btn.tooltip_text = speed.tooltip
		btn.custom_minimum_size = Vector2(44, 32)
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
		btn.add_theme_color_override("font_hover_color", UITheme.TEXT_PRIMARY)
		btn.toggle_mode = true

		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.94, 0.94, 0.96)
		btn_style.set_corner_radius_all(6)
		btn_style.set_content_margin_all(6)
		btn.add_theme_stylebox_override("normal", btn_style)

		var btn_hover = StyleBoxFlat.new()
		btn_hover.bg_color = Color(0.88, 0.88, 0.92)
		btn_hover.set_corner_radius_all(6)
		btn_hover.set_content_margin_all(6)
		btn.add_theme_stylebox_override("hover", btn_hover)

		var btn_pressed = StyleBoxFlat.new()
		btn_pressed.bg_color = UITheme.PRIMARY_BLUE
		btn_pressed.set_corner_radius_all(6)
		btn_pressed.set_content_margin_all(6)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_color_override("font_pressed_color", UITheme.TEXT_WHITE)

		btn.pressed.connect(_on_speed_button_pressed.bind(speed.level))
		speed_container.add_child(btn)

func create_header_right(parent: HBoxContainer) -> void:
	"""Create right side of header (date, notifications)"""
	var right_container = HBoxContainer.new()
	right_container.add_theme_constant_override("separation", 16)
	parent.add_child(right_container)

	# Date/Time
	var date_container = VBoxContainer.new()
	date_container.add_theme_constant_override("separation", 0)
	right_container.add_child(date_container)

	date_label = Label.new()
	date_label.text = "Week 1"
	date_label.add_theme_font_size_override("font_size", 14)
	date_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	date_container.add_child(date_label)

	var year_label = Label.new()
	year_label.name = "YearLabel"
	year_label.text = "Year 1"
	year_label.add_theme_font_size_override("font_size", 11)
	year_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	year_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	date_container.add_child(year_label)

	# Notifications bell
	var notif_btn = Button.new()
	notif_btn.text = "🔔"
	notif_btn.custom_minimum_size = Vector2(36, 36)
	notif_btn.add_theme_font_size_override("font_size", 16)
	var notif_style = StyleBoxFlat.new()
	notif_style.bg_color = Color(0, 0, 0, 0)
	notif_btn.add_theme_stylebox_override("normal", notif_style)
	right_container.add_child(notif_btn)

func create_sidebar() -> void:
	"""Create the dark sidebar with navigation - left side"""
	sidebar = PanelContainer.new()
	sidebar.name = "Sidebar"
	add_child(sidebar)

	# Anchor to left side, from below header to above bottom bar
	sidebar.anchor_left = 0
	sidebar.anchor_top = 0
	sidebar.anchor_right = 0
	sidebar.anchor_bottom = 1
	sidebar.offset_top = HEADER_HEIGHT
	sidebar.offset_right = SIDEBAR_WIDTH
	sidebar.offset_bottom = -BOTTOM_HEIGHT

	var sidebar_style = StyleBoxFlat.new()
	sidebar_style.bg_color = UITheme.SIDEBAR_BG
	sidebar_style.border_color = UITheme.SIDEBAR_HOVER
	sidebar_style.border_width_right = 1
	sidebar.add_theme_stylebox_override("panel", sidebar_style)

	var sidebar_vbox = VBoxContainer.new()
	sidebar_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sidebar_vbox.add_theme_constant_override("separation", 0)
	sidebar.add_child(sidebar_vbox)

	# Logo
	create_sidebar_logo(sidebar_vbox)

	# Navigation
	create_sidebar_nav(sidebar_vbox)

	# Bottom settings
	create_sidebar_bottom(sidebar_vbox)

func create_sidebar_logo(parent: VBoxContainer) -> void:
	"""Create sidebar logo section"""
	var logo_panel = PanelContainer.new()
	var logo_style = StyleBoxFlat.new()
	logo_style.bg_color = Color(0, 0, 0, 0)
	logo_style.border_color = UITheme.SIDEBAR_HOVER
	logo_style.border_width_bottom = 1
	logo_style.set_content_margin_all(16)
	logo_panel.add_theme_stylebox_override("panel", logo_style)
	parent.add_child(logo_panel)

	var logo_hbox = HBoxContainer.new()
	logo_hbox.add_theme_constant_override("separation", 12)
	logo_panel.add_child(logo_hbox)

	# Icon
	var icon_panel = PanelContainer.new()
	icon_panel.custom_minimum_size = Vector2(36, 36)
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = UITheme.PRIMARY_BLUE
	icon_style.set_corner_radius_all(8)
	icon_panel.add_theme_stylebox_override("panel", icon_style)
	logo_hbox.add_child(icon_panel)

	var icon = Label.new()
	icon.text = UITheme.ICON_PLANE
	icon.add_theme_font_size_override("font_size", 16)
	icon.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_panel.add_child(icon)

	# Text
	var text_vbox = VBoxContainer.new()
	text_vbox.add_theme_constant_override("separation", -2)
	logo_hbox.add_child(text_vbox)

	var title = Label.new()
	title.text = "SKYTYCOON"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	text_vbox.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Airline Simulator"
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	text_vbox.add_child(subtitle)

func create_sidebar_nav(parent: VBoxContainer) -> void:
	"""Create sidebar navigation buttons"""
	var nav_margin = MarginContainer.new()
	nav_margin.add_theme_constant_override("margin_left", 12)
	nav_margin.add_theme_constant_override("margin_right", 12)
	nav_margin.add_theme_constant_override("margin_top", 16)
	nav_margin.add_theme_constant_override("margin_bottom", 16)
	nav_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(nav_margin)

	var nav_vbox = VBoxContainer.new()
	nav_vbox.add_theme_constant_override("separation", 4)
	nav_margin.add_child(nav_vbox)

	var nav_items = [
		{"id": "map", "label": "Live Radar", "icon": "📡"},
		{"id": "fleet", "label": "Fleet Management", "icon": UITheme.ICON_PLANE},
		{"id": "routes", "label": "Route Map", "icon": "🗺"},
		{"id": "finances", "label": "Finances", "icon": UITheme.ICON_MONEY},
		{"id": "market", "label": "Market", "icon": UITheme.ICON_ARROW_UP_RIGHT},
	]

	for item in nav_items:
		var btn = create_nav_button(item.id, item.label, item.icon)
		nav_vbox.add_child(btn)
		nav_buttons[item.id] = btn

	# Set initial active tab
	update_active_tab(current_tab)

func create_nav_button(id: String, label: String, icon: String) -> Button:
	"""Create a sidebar navigation button"""
	var btn = Button.new()
	btn.name = id
	btn.text = "  %s  %s" % [icon, label]
	btn.custom_minimum_size = Vector2(0, 44)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)

	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0, 0, 0, 0)
	normal_style.set_corner_radius_all(10)
	normal_style.set_content_margin_all(10)
	btn.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.SIDEBAR_HOVER
	hover_style.set_corner_radius_all(10)
	hover_style.set_content_margin_all(10)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)

	btn.pressed.connect(_on_nav_button_pressed.bind(id))

	return btn

func create_sidebar_bottom(parent: VBoxContainer) -> void:
	"""Create sidebar bottom section"""
	var bottom_panel = PanelContainer.new()
	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = Color(0, 0, 0, 0)
	bottom_style.border_color = UITheme.SIDEBAR_HOVER
	bottom_style.border_width_top = 1
	bottom_style.set_content_margin_all(12)
	bottom_panel.add_theme_stylebox_override("panel", bottom_style)
	parent.add_child(bottom_panel)

	var settings_btn = Button.new()
	settings_btn.text = "  ⚙  Settings"
	settings_btn.custom_minimum_size = Vector2(0, 44)
	settings_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	settings_btn.add_theme_font_size_override("font_size", 13)
	settings_btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0, 0, 0, 0)
	btn_style.set_corner_radius_all(10)
	btn_style.set_content_margin_all(10)
	settings_btn.add_theme_stylebox_override("normal", btn_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.SIDEBAR_HOVER
	hover_style.set_corner_radius_all(10)
	hover_style.set_content_margin_all(10)
	settings_btn.add_theme_stylebox_override("hover", hover_style)

	bottom_panel.add_child(settings_btn)

func create_main_content() -> void:
	"""Create main content area - fills space between sidebar and edges"""
	main_content = Control.new()
	main_content.name = "MainContent"
	add_child(main_content)

	# Anchor to fill space: right of sidebar, below header, above bottom bar
	main_content.anchor_left = 0
	main_content.anchor_top = 0
	main_content.anchor_right = 1
	main_content.anchor_bottom = 1
	main_content.offset_left = SIDEBAR_WIDTH
	main_content.offset_top = HEADER_HEIGHT
	main_content.offset_bottom = -BOTTOM_HEIGHT

	# Add a background
	var content_bg = ColorRect.new()
	content_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_bg.color = UITheme.BG_MAIN
	main_content.add_child(content_bg)

func create_bottom_bar() -> void:
	"""Create the bottom quick actions bar - full width at bottom"""
	bottom_bar = PanelContainer.new()
	bottom_bar.name = "BottomBar"
	add_child(bottom_bar)

	# Anchor to bottom, full width
	bottom_bar.anchor_left = 0
	bottom_bar.anchor_top = 1
	bottom_bar.anchor_right = 1
	bottom_bar.anchor_bottom = 1
	bottom_bar.offset_top = -BOTTOM_HEIGHT

	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = UITheme.PANEL_BG_COLOR
	bottom_style.border_color = UITheme.PANEL_BORDER_COLOR
	bottom_style.border_width_top = 1
	bottom_bar.add_theme_stylebox_override("panel", bottom_style)

	var bottom_margin = MarginContainer.new()
	bottom_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bottom_margin.add_theme_constant_override("margin_left", SIDEBAR_WIDTH + 16)
	bottom_margin.add_theme_constant_override("margin_right", 16)
	bottom_margin.add_theme_constant_override("margin_top", 8)
	bottom_margin.add_theme_constant_override("margin_bottom", 8)
	bottom_bar.add_child(bottom_margin)

	var bottom_hbox = HBoxContainer.new()
	bottom_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bottom_hbox.add_theme_constant_override("separation", 12)
	bottom_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	bottom_margin.add_child(bottom_hbox)

	# Quick action buttons with connections
	var actions = [
		{"text": "🏢 Purchase Hub", "signal": "purchase_hub_pressed"},
		{"text": "✈ Buy Aircraft", "signal": "buy_aircraft_pressed"},
		{"text": "➕ Create Route", "signal": "create_route_pressed"},
	]

	for action in actions:
		var btn = Button.new()
		btn.text = action.text
		btn.custom_minimum_size = Vector2(130, 36)
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
		btn.add_theme_color_override("font_hover_color", UITheme.TEXT_PRIMARY)
		btn.add_theme_color_override("font_pressed_color", UITheme.TEXT_PRIMARY)

		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.94, 0.94, 0.96)
		btn_style.set_corner_radius_all(8)
		btn_style.set_content_margin_all(8)
		btn.add_theme_stylebox_override("normal", btn_style)

		var btn_hover = StyleBoxFlat.new()
		btn_hover.bg_color = Color(0.88, 0.88, 0.92)
		btn_hover.set_corner_radius_all(8)
		btn_hover.set_content_margin_all(8)
		btn.add_theme_stylebox_override("hover", btn_hover)

		var btn_pressed_style = StyleBoxFlat.new()
		btn_pressed_style.bg_color = Color(0.82, 0.82, 0.88)
		btn_pressed_style.set_corner_radius_all(8)
		btn_pressed_style.set_content_margin_all(8)
		btn.add_theme_stylebox_override("pressed", btn_pressed_style)

		# Connect to the appropriate signal
		match action.signal:
			"purchase_hub_pressed":
				btn.pressed.connect(func(): purchase_hub_pressed.emit())
			"buy_aircraft_pressed":
				btn.pressed.connect(func(): buy_aircraft_pressed.emit())
			"create_route_pressed":
				btn.pressed.connect(func(): create_route_pressed.emit())

		bottom_hbox.add_child(btn)

func update_active_tab(tab_id: String) -> void:
	"""Update visual state of nav buttons"""
	current_tab = tab_id

	for id in nav_buttons:
		var btn: Button = nav_buttons[id]
		var is_active = (id == tab_id)

		if is_active:
			var active_style = StyleBoxFlat.new()
			active_style.bg_color = UITheme.PRIMARY_BLUE
			active_style.set_corner_radius_all(10)
			active_style.set_content_margin_all(10)
			btn.add_theme_stylebox_override("normal", active_style)
			btn.add_theme_stylebox_override("hover", active_style)
			btn.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
			btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
		else:
			var inactive_style = StyleBoxFlat.new()
			inactive_style.bg_color = Color(0, 0, 0, 0)
			inactive_style.set_corner_radius_all(10)
			inactive_style.set_content_margin_all(10)
			btn.add_theme_stylebox_override("normal", inactive_style)

			var hover_style = StyleBoxFlat.new()
			hover_style.bg_color = UITheme.SIDEBAR_HOVER
			hover_style.set_corner_radius_all(10)
			hover_style.set_content_margin_all(10)
			btn.add_theme_stylebox_override("hover", hover_style)
			btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)
			btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)

	tab_changed.emit(tab_id)

func _on_nav_button_pressed(tab_id: String) -> void:
	"""Handle nav button press"""
	update_active_tab(tab_id)

func _on_speed_button_pressed(speed_level: int) -> void:
	"""Handle speed button press"""
	# Update button states
	for i in range(speed_container.get_child_count()):
		var btn = speed_container.get_child(i) as Button
		if btn:
			btn.button_pressed = (i == speed_level)

	# Notify simulation engine if available
	if simulation_engine:
		simulation_engine.set_speed(speed_level)
		if speed_level > 0 and not simulation_engine.is_running:
			simulation_engine.start_simulation()
		elif speed_level == 0:
			simulation_engine.pause_simulation()

func update_stats() -> void:
	"""Update header stats from GameData"""
	if not GameData.player_airline:
		return

	# Money
	if money_label:
		var balance = GameData.player_airline.balance
		money_label.text = UITheme.format_money(balance)
		var profit = GameData.player_airline.calculate_weekly_profit()
		if profit >= 0:
			money_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		else:
			money_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)

	# Reputation
	if reputation_label:
		reputation_label.text = "%.1f" % GameData.player_airline.reputation

	# Date
	if date_label:
		date_label.text = "Week %d" % GameData.current_week

	# Year label - check header exists first
	if header:
		var year_label = header.get_node_or_null("MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/YearLabel")
		if year_label:
			var year = 1 + (GameData.current_week / 52)
			year_label.text = "Year %d" % year

	# Grade badge - find it properly
	_update_grade_badge()

func _update_grade_badge() -> void:
	"""Update the grade badge display"""
	if not GameData.player_airline or not header:
		return

	# Find grade badge in header hierarchy
	for child in header.get_children():
		var badge = _find_node_recursive(child, "GradeBadge")
		if badge:
			var grade = GameData.player_airline.get_grade()
			var grade_label = badge.get_node_or_null("GradeLabel")
			if grade_label:
				grade_label.text = grade

			# Update badge color
			var style = StyleBoxFlat.new()
			style.bg_color = UITheme.get_grade_color(grade)
			style.set_corner_radius_all(14)
			style.set_content_margin_all(6)
			badge.add_theme_stylebox_override("panel", style)
			break

func _find_node_recursive(node: Node, node_name: String) -> Node:
	"""Recursively find a node by name"""
	if node.name == node_name:
		return node
	for child in node.get_children():
		var found = _find_node_recursive(child, node_name)
		if found:
			return found
	return null

func get_main_content() -> Control:
	"""Get the main content area for embedding WorldMap, etc."""
	return main_content

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts"""
	if event is InputEventKey and event.pressed and not event.echo:
		var focus_owner = get_viewport().gui_get_focus_owner()
		var is_typing = focus_owner is LineEdit or focus_owner is TextEdit

		if not is_typing:
			match event.keycode:
				KEY_SPACE:
					if simulation_engine:
						if simulation_engine.is_running:
							_on_speed_button_pressed(0)
						else:
							_on_speed_button_pressed(3)
						get_viewport().set_input_as_handled()
				KEY_1:
					_on_speed_button_pressed(1)
					get_viewport().set_input_as_handled()
				KEY_2:
					_on_speed_button_pressed(2)
					get_viewport().set_input_as_handled()
				KEY_3:
					_on_speed_button_pressed(3)
					get_viewport().set_input_as_handled()
				KEY_4:
					_on_speed_button_pressed(4)
					get_viewport().set_input_as_handled()
				KEY_5:
					_on_speed_button_pressed(5)
					get_viewport().set_input_as_handled()
