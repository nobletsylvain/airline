extends Control
class_name DashboardUI

## Dashboard-style Game UI
## Layout: Top Bar | Sidebar + Main Content | Bottom Bar
## Based on Figma mockup design

signal tab_changed(tab_name: String)

# Layout constants
const SIDEBAR_WIDTH = 256
const HEADER_HEIGHT = 64
const BOTTOM_HEIGHT = 48

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

# Content panels (swap based on tab)
var content_panels: Dictionary = {}

# Simulation engine reference
var simulation_engine: Node = null

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	create_layout()

func create_layout() -> void:
	"""Create the main dashboard layout"""
	# Main background
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = UITheme.BG_MAIN
	add_child(bg)

	# Create main structure
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)

	# Top Header Bar
	create_header(main_vbox)

	# Middle section (Sidebar + Content)
	var middle_hbox = HBoxContainer.new()
	middle_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle_hbox.add_theme_constant_override("separation", 0)
	main_vbox.add_child(middle_hbox)

	# Sidebar
	create_sidebar(middle_hbox)

	# Main Content Area
	create_main_content(middle_hbox)

	# Bottom Bar (Quick Actions)
	create_bottom_bar(main_vbox)

func create_header(parent: VBoxContainer) -> void:
	"""Create the top header bar"""
	header = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, HEADER_HEIGHT)

	var header_style = StyleBoxFlat.new()
	header_style.bg_color = UITheme.PANEL_BG_COLOR
	header_style.border_color = UITheme.PANEL_BORDER_COLOR
	header_style.border_width_bottom = 1
	header_style.shadow_color = Color(0, 0, 0, 0.05)
	header_style.shadow_size = 4
	header.add_theme_stylebox_override("panel", header_style)
	parent.add_child(header)

	var header_margin = MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 24)
	header_margin.add_theme_constant_override("margin_right", 24)
	header_margin.add_theme_constant_override("margin_top", 12)
	header_margin.add_theme_constant_override("margin_bottom", 12)
	header.add_child(header_margin)

	var header_hbox = HBoxContainer.new()
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

	# Right: Date/Time + User
	create_header_right(header_hbox)

func create_header_stats(parent: HBoxContainer) -> void:
	"""Create KPI stats in header"""
	# Money
	var money_container = create_stat_pill("$", "0", UITheme.PROFIT_COLOR)
	money_label = money_container.get_node("Value")
	parent.add_child(money_container)

	# Reputation
	var rep_container = create_stat_pill(UITheme.ICON_STAR, "0", UITheme.HUB_COLOR)
	reputation_label = rep_container.get_node("Value")
	parent.add_child(rep_container)

	# Grade badge
	var grade_container = create_grade_badge()
	parent.add_child(grade_container)

func create_stat_pill(icon: String, value: String, color: Color) -> HBoxContainer:
	"""Create a stat display pill"""
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 8)

	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 16)
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
	panel.custom_minimum_size = Vector2(48, 32)

	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.GRADE_NEW_COLOR
	style.set_corner_radius_all(16)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	label.name = "GradeLabel"
	label.text = "NEW"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
		btn.custom_minimum_size = Vector2(48, 32)
		btn.add_theme_font_size_override("font_size", 12)
		btn.toggle_mode = true

		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.95, 0.95, 0.97)
		btn_style.set_corner_radius_all(6)
		btn_style.set_content_margin_all(8)
		btn.add_theme_stylebox_override("normal", btn_style)

		var btn_pressed = StyleBoxFlat.new()
		btn_pressed.bg_color = UITheme.PRIMARY_BLUE
		btn_pressed.set_corner_radius_all(6)
		btn_pressed.set_content_margin_all(8)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_color_override("font_pressed_color", UITheme.TEXT_WHITE)

		btn.pressed.connect(_on_speed_button_pressed.bind(speed.level))
		speed_container.add_child(btn)

func create_header_right(parent: HBoxContainer) -> void:
	"""Create right side of header (date, notifications, user)"""
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

	var time_label = Label.new()
	time_label.text = "Year 1"
	time_label.add_theme_font_size_override("font_size", 11)
	time_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	date_container.add_child(time_label)

	# Notifications bell
	var notif_btn = Button.new()
	notif_btn.text = "🔔"
	notif_btn.custom_minimum_size = Vector2(40, 40)
	notif_btn.add_theme_font_size_override("font_size", 18)
	var notif_style = StyleBoxFlat.new()
	notif_style.bg_color = Color(0, 0, 0, 0)
	notif_btn.add_theme_stylebox_override("normal", notif_style)
	right_container.add_child(notif_btn)

func create_sidebar(parent: HBoxContainer) -> void:
	"""Create the dark sidebar with navigation"""
	sidebar = PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(SIDEBAR_WIDTH, 0)

	var sidebar_style = StyleBoxFlat.new()
	sidebar_style.bg_color = UITheme.SIDEBAR_BG
	sidebar_style.border_color = UITheme.SIDEBAR_HOVER
	sidebar_style.border_width_right = 1
	sidebar.add_theme_stylebox_override("panel", sidebar_style)
	parent.add_child(sidebar)

	var sidebar_vbox = VBoxContainer.new()
	sidebar_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	logo_style.set_content_margin_all(20)
	logo_panel.add_theme_stylebox_override("panel", logo_style)
	parent.add_child(logo_panel)

	var logo_hbox = HBoxContainer.new()
	logo_hbox.add_theme_constant_override("separation", 12)
	logo_panel.add_child(logo_hbox)

	# Icon
	var icon_panel = Panel.new()
	icon_panel.custom_minimum_size = Vector2(40, 40)
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = UITheme.PRIMARY_BLUE
	icon_style.set_corner_radius_all(10)
	icon_panel.add_theme_stylebox_override("panel", icon_style)
	logo_hbox.add_child(icon_panel)

	var icon = Label.new()
	icon.text = UITheme.ICON_PLANE
	icon.rotation_degrees = -45
	icon.pivot_offset = Vector2(10, 10)
	icon.add_theme_font_size_override("font_size", 18)
	icon.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	icon_panel.add_child(icon)

	# Text
	var text_vbox = VBoxContainer.new()
	text_vbox.add_theme_constant_override("separation", 0)
	logo_hbox.add_child(text_vbox)

	var title = Label.new()
	title.text = "SKYTYCOON"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	text_vbox.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "TYCOON"
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	text_vbox.add_child(subtitle)

func create_sidebar_nav(parent: VBoxContainer) -> void:
	"""Create sidebar navigation buttons"""
	var nav_margin = MarginContainer.new()
	nav_margin.add_theme_constant_override("margin_left", 12)
	nav_margin.add_theme_constant_override("margin_right", 12)
	nav_margin.add_theme_constant_override("margin_top", 20)
	nav_margin.add_theme_constant_override("margin_bottom", 20)
	nav_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(nav_margin)

	var nav_vbox = VBoxContainer.new()
	nav_vbox.add_theme_constant_override("separation", 4)
	nav_margin.add_child(nav_vbox)

	var nav_items = [
		{"id": "map", "label": "World Map", "icon": "🗺"},
		{"id": "fleet", "label": "Fleet", "icon": UITheme.ICON_PLANE},
		{"id": "routes", "label": "Routes", "icon": UITheme.ICON_ARROW_RIGHT},
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
	btn.text = "  %s   %s" % [icon, label]
	btn.custom_minimum_size = Vector2(0, 48)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)

	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0, 0, 0, 0)
	normal_style.set_corner_radius_all(12)
	normal_style.set_content_margin_all(12)
	btn.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.SIDEBAR_HOVER
	hover_style.set_corner_radius_all(12)
	hover_style.set_content_margin_all(12)
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
	settings_btn.text = "  ⚙   Settings"
	settings_btn.custom_minimum_size = Vector2(0, 48)
	settings_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	settings_btn.add_theme_font_size_override("font_size", 14)
	settings_btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0, 0, 0, 0)
	btn_style.set_corner_radius_all(12)
	btn_style.set_content_margin_all(12)
	settings_btn.add_theme_stylebox_override("normal", btn_style)
	bottom_panel.add_child(settings_btn)

func create_main_content(parent: HBoxContainer) -> void:
	"""Create main content area (placeholder for WorldMap, etc)"""
	main_content = Control.new()
	main_content.name = "MainContent"
	main_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(main_content)

	# This will be populated by the scene that uses this layout

func create_bottom_bar(parent: VBoxContainer) -> void:
	"""Create the bottom quick actions bar"""
	bottom_bar = PanelContainer.new()
	bottom_bar.custom_minimum_size = Vector2(0, BOTTOM_HEIGHT)

	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = UITheme.PANEL_BG_COLOR
	bottom_style.border_color = UITheme.PANEL_BORDER_COLOR
	bottom_style.border_width_top = 1
	bottom_bar.add_theme_stylebox_override("panel", bottom_style)
	parent.add_child(bottom_bar)

	var bottom_margin = MarginContainer.new()
	bottom_margin.add_theme_constant_override("margin_left", 16)
	bottom_margin.add_theme_constant_override("margin_right", 16)
	bottom_bar.add_child(bottom_margin)

	var bottom_hbox = HBoxContainer.new()
	bottom_hbox.add_theme_constant_override("separation", 16)
	bottom_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_margin.add_child(bottom_hbox)

	# Quick action buttons
	var actions = ["Purchase Hub", "Buy Aircraft", "Create Route"]
	for action in actions:
		var btn = Button.new()
		btn.text = action
		btn.custom_minimum_size = Vector2(120, 32)
		btn.add_theme_font_size_override("font_size", 12)

		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.95, 0.95, 0.97)
		btn_style.set_corner_radius_all(6)
		btn_style.set_content_margin_all(8)
		btn.add_theme_stylebox_override("normal", btn_style)
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
			active_style.set_corner_radius_all(12)
			active_style.set_content_margin_all(12)
			btn.add_theme_stylebox_override("normal", active_style)
			btn.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
		else:
			var inactive_style = StyleBoxFlat.new()
			inactive_style.bg_color = Color(0, 0, 0, 0)
			inactive_style.set_corner_radius_all(12)
			inactive_style.set_content_margin_all(12)
			btn.add_theme_stylebox_override("normal", inactive_style)
			btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)

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
		money_label.add_theme_color_override("font_color", UITheme.get_profit_color(profit))

	# Reputation
	if reputation_label:
		reputation_label.text = "%.1f" % GameData.player_airline.reputation

	# Date
	if date_label:
		date_label.text = "Week %d" % GameData.current_week

	# Grade badge
	var grade_badge = get_node_or_null("VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/GradeBadge")
	if grade_badge:
		var grade = GameData.player_airline.get_grade()
		var grade_label = grade_badge.get_node_or_null("GradeLabel")
		if grade_label:
			grade_label.text = grade
		var panel_style = grade_badge.get_theme_stylebox("panel") as StyleBoxFlat
		if panel_style:
			panel_style.bg_color = UITheme.get_grade_color(grade)

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
