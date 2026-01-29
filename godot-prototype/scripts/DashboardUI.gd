extends Control
class_name DashboardUI

## Dashboard-style Game UI
## Layout: Top Bar | Sidebar + Main Content | Bottom Bar
## Based on Figma mockup design

signal tab_changed(tab_name: String)
signal purchase_hub_pressed()
signal buy_aircraft_pressed()
signal create_route_pressed()
signal settings_pressed()

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
var content_bg: ColorRect
var main_bg: ColorRect

# Header elements
var money_label: Label
var reputation_label: Label
var date_label: Label
var speed_container: HBoxContainer
var time_speed_panel: TimeSpeedPanel

# Sidebar navigation buttons
var nav_buttons: Dictionary = {}

# Simulation engine reference
var simulation_engine: Node = null

# Animation tracking
var _previous_balance: float = -1.0  # Track for cash animation
var _previous_reputation: float = -1.0  # Track for reputation animation

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Register for theme changes
	UITheme.register_theme_callback(_on_theme_changed)
	# Use call_deferred to ensure proper sizing
	call_deferred("create_layout")

func _exit_tree() -> void:
	# Unregister theme callback when removed from tree
	UITheme.unregister_theme_callback(_on_theme_changed)

func create_layout() -> void:
	"""Create the main dashboard layout using anchor-based positioning"""

	# Main background
	main_bg = ColorRect.new()
	main_bg.name = "MainBackground"
	main_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_bg.color = UITheme.get_bg_main()
	add_child(main_bg)

	# Create components in order (z-order)
	create_header()
	create_sidebar()
	create_main_content()
	create_bottom_bar()
	create_floating_time_panel()  # Add last so it's on top

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

	# Use theme-aware header style
	header.add_theme_stylebox_override("panel", UITheme.create_header_style())

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
	header_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	header_margin.add_child(header_hbox)

	# Left: KPI stats
	create_header_stats(header_hbox)

func create_header_stats(parent: HBoxContainer) -> void:
	"""Create KPI stats in header"""
	# Money
	var money_container = create_stat_pill(UITheme.ICON_MONEY, "€10.0M", UITheme.PROFIT_COLOR)
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
	value_label.add_theme_color_override("font_color", UITheme.get_text_primary())
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
	sidebar.z_index = 10  # Ensure sidebar is above content

	var sidebar_style = StyleBoxFlat.new()
	sidebar_style.bg_color = UITheme.SIDEBAR_BG
	sidebar_style.border_color = UITheme.SIDEBAR_HOVER
	sidebar_style.border_width_right = 1
	sidebar_style.set_content_margin_all(0)  # Ensure no extra margins clip content
	sidebar.add_theme_stylebox_override("panel", sidebar_style)

	var sidebar_vbox = VBoxContainer.new()
	sidebar_vbox.name = "SidebarVBox"
	sidebar_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_vbox.add_theme_constant_override("separation", 0)
	sidebar.add_child(sidebar_vbox)
	
	print("[DashboardUI] Creating sidebar. Size: %s" % sidebar.size)

	# Logo
	create_sidebar_logo(sidebar_vbox)
	print("[DashboardUI] Sidebar logo created")

	# Navigation
	create_sidebar_nav(sidebar_vbox)
	print("[DashboardUI] Sidebar nav created with %d buttons" % nav_buttons.size())
	for btn_id in nav_buttons:
		var btn = nav_buttons[btn_id]
		print("  - Button '%s': text='%s', visible=%s" % [btn_id, btn.text, btn.visible])

	# Bottom settings
	create_sidebar_bottom(sidebar_vbox)
	print("[DashboardUI] Sidebar complete. VBox children: %d" % sidebar_vbox.get_child_count())
	for i in range(sidebar_vbox.get_child_count()):
		var child = sidebar_vbox.get_child(i)
		print("  - Child %d: %s (type: %s, visible: %s)" % [i, child.name, child.get_class(), child.visible])

func create_sidebar_logo(parent: VBoxContainer) -> void:
	"""Create sidebar logo section"""
	var logo_panel = PanelContainer.new()
	logo_panel.name = "LogoPanel"
	logo_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var logo_style = StyleBoxFlat.new()
	logo_style.bg_color = Color(0, 0, 0, 0)
	logo_style.border_color = UITheme.SIDEBAR_HOVER
	logo_style.border_width_bottom = 1
	logo_style.set_content_margin_all(16)
	logo_panel.add_theme_stylebox_override("panel", logo_style)
	parent.add_child(logo_panel)

	var logo_hbox = HBoxContainer.new()
	logo_hbox.name = "LogoHBox"
	logo_hbox.add_theme_constant_override("separation", 12)
	logo_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	nav_margin.name = "NavMargin"
	nav_margin.add_theme_constant_override("margin_left", 12)
	nav_margin.add_theme_constant_override("margin_right", 12)
	nav_margin.add_theme_constant_override("margin_top", 16)
	nav_margin.add_theme_constant_override("margin_bottom", 16)
	nav_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(nav_margin)

	var nav_vbox = VBoxContainer.new()
	nav_vbox.name = "NavVBox"
	nav_vbox.add_theme_constant_override("separation", 4)
	nav_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nav_margin.add_child(nav_vbox)

	# PROTOTYPE SIMPLIFICATION (S.3, S.4): Delegates and Diplomacy tabs hidden
	# These features are out of scope for prototype testing per prototype-scope.md
	var nav_items = [
		{"id": "map", "label": "Live Radar", "icon": "📡"},
		{"id": "fleet", "label": "Fleet Management", "icon": UITheme.ICON_PLANE},
		{"id": "routes", "label": "Route Map", "icon": "🗺"},
		{"id": "finances", "label": "Finances", "icon": UITheme.ICON_MONEY},
		{"id": "market", "label": "Market", "icon": UITheme.ICON_ARROW_UP_RIGHT},
		# NOTE: Tabs below disabled for prototype (S.3, S.4) - uncomment to re-enable
		#{"id": "delegates", "label": "Delegates", "icon": "👥"},
		#{"id": "diplomacy", "label": "Diplomacy", "icon": "🌍"},
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
	btn.custom_minimum_size = Vector2(200, 44)  # Ensure button has minimum width
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)
	btn.visible = true  # Explicitly visible
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

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
	
	# Add button hover/press animations (art-bible 5.1)
	if UIAnimations:
		UIAnimations.setup_button_animations(btn)

	return btn

func create_sidebar_bottom(parent: VBoxContainer) -> void:
	"""Create sidebar bottom section with theme toggle and settings"""
	var bottom_panel = PanelContainer.new()
	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = Color(0, 0, 0, 0)
	bottom_style.border_color = UITheme.SIDEBAR_HOVER
	bottom_style.border_width_top = 1
	bottom_style.set_content_margin_all(12)
	bottom_panel.add_theme_stylebox_override("panel", bottom_style)
	parent.add_child(bottom_panel)

	var bottom_vbox = VBoxContainer.new()
	bottom_vbox.add_theme_constant_override("separation", 4)
	bottom_panel.add_child(bottom_vbox)

	# Theme toggle button
	var theme_btn = Button.new()
	theme_btn.name = "ThemeToggleButton"
	theme_btn.text = "  %s  Light Mode" % UITheme.ICON_SUN if not UITheme.is_dark_mode() else "  %s  Dark Mode" % UITheme.ICON_MOON
	theme_btn.custom_minimum_size = Vector2(0, 44)
	theme_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	theme_btn.add_theme_font_size_override("font_size", 13)
	theme_btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)
	theme_btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)

	var theme_btn_style = StyleBoxFlat.new()
	theme_btn_style.bg_color = Color(0, 0, 0, 0)
	theme_btn_style.set_corner_radius_all(10)
	theme_btn_style.set_content_margin_all(10)
	theme_btn.add_theme_stylebox_override("normal", theme_btn_style)

	var theme_hover_style = StyleBoxFlat.new()
	theme_hover_style.bg_color = UITheme.SIDEBAR_HOVER
	theme_hover_style.set_corner_radius_all(10)
	theme_hover_style.set_content_margin_all(10)
	theme_btn.add_theme_stylebox_override("hover", theme_hover_style)

	theme_btn.pressed.connect(_on_theme_toggle_pressed)
	
	# Add button animation
	if UIAnimations:
		UIAnimations.setup_button_animations(theme_btn)
	
	bottom_vbox.add_child(theme_btn)

	# Settings button
	var settings_btn = Button.new()
	settings_btn.text = "  ⚙  Settings"
	settings_btn.custom_minimum_size = Vector2(0, 44)
	settings_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	settings_btn.add_theme_font_size_override("font_size", 13)
	settings_btn.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)
	settings_btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)

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

	# Add button animation
	if UIAnimations:
		UIAnimations.setup_button_animations(settings_btn)
	
	# Connect to settings signal
	settings_btn.pressed.connect(func(): settings_pressed.emit())

	bottom_vbox.add_child(settings_btn)

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
	content_bg = ColorRect.new()
	content_bg.name = "ContentBackground"
	content_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_bg.color = UITheme.get_bg_main()
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

	# Use theme-aware bottom bar style
	bottom_bar.add_theme_stylebox_override("panel", UITheme.create_bottom_bar_style())

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
		btn.add_theme_color_override("font_color", UITheme.get_text_primary())
		btn.add_theme_color_override("font_hover_color", UITheme.get_text_primary())
		btn.add_theme_color_override("font_pressed_color", UITheme.get_text_primary())

		# Use theme-aware button styles
		btn.add_theme_stylebox_override("normal", UITheme.create_button_style())
		btn.add_theme_stylebox_override("hover", UITheme.create_button_hover_style())

		var btn_pressed_style = StyleBoxFlat.new()
		btn_pressed_style.bg_color = UITheme.get_hover_color()
		btn_pressed_style.set_corner_radius_all(8)
		btn_pressed_style.set_content_margin_all(8)
		btn.add_theme_stylebox_override("pressed", btn_pressed_style)
		
		# Add button hover/press animations (art-bible 5.1)
		if UIAnimations:
			UIAnimations.setup_button_animations(btn)

		# Connect to the appropriate signal
		match action.signal:
			"purchase_hub_pressed":
				btn.pressed.connect(func(): purchase_hub_pressed.emit())
			"buy_aircraft_pressed":
				btn.pressed.connect(func(): buy_aircraft_pressed.emit())
			"create_route_pressed":
				btn.pressed.connect(func(): create_route_pressed.emit())

		bottom_hbox.add_child(btn)

func create_floating_time_panel() -> void:
	"""Create the floating TimeSpeedPanel that overlays the map - draggable"""
	time_speed_panel = TimeSpeedPanel.new()
	time_speed_panel.name = "TimeSpeedPanel"
	add_child(time_speed_panel)

	# Use absolute positioning for draggable panel (no anchors)
	time_speed_panel.anchor_left = 0
	time_speed_panel.anchor_top = 0
	time_speed_panel.anchor_right = 0
	time_speed_panel.anchor_bottom = 0

	# Position will be set in _position_time_panel after layout is ready
	call_deferred("_position_time_panel")

	# Connect to simulation engine if available
	if simulation_engine:
		time_speed_panel.set_simulation_engine(simulation_engine)

func _position_time_panel() -> void:
	"""Position the time panel at top-right after layout is ready"""
	if not time_speed_panel:
		return

	# Get viewport size to calculate position
	var viewport_size = get_viewport_rect().size

	# Position at top-right corner with margin
	var panel_width = 500  # Approximate panel width
	var margin_right = 16
	var margin_top = HEADER_HEIGHT + 16

	time_speed_panel.position = Vector2(
		viewport_size.x - panel_width - margin_right,
		margin_top
	)

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
	"""Handle speed button press - delegates to TimeSpeedPanel"""
	if time_speed_panel:
		time_speed_panel._set_speed_level(speed_level - 1)  # TimeSpeedPanel uses 0-4 indices

func set_simulation_engine(engine: Node) -> void:
	"""Set the simulation engine reference"""
	simulation_engine = engine
	if time_speed_panel:
		time_speed_panel.set_simulation_engine(engine)

func update_stats() -> void:
	"""Update header stats from GameData with animations"""
	if not GameData.player_airline:
		return

	# Money - animate changes
	if money_label:
		var balance = GameData.player_airline.balance
		var profit = GameData.player_airline.calculate_weekly_profit()
		
		# Set color based on profit
		if profit >= 0:
			money_label.add_theme_color_override("font_color", UITheme.PROFIT_COLOR)
		else:
			money_label.add_theme_color_override("font_color", UITheme.LOSS_COLOR)
		
		# Animate if balance changed (and not first update)
		if _previous_balance >= 0 and abs(balance - _previous_balance) > 0.01:
			if UIAnimations:
				UIAnimations.animate_money(money_label, _previous_balance, balance)
			else:
				money_label.text = UITheme.format_money(balance)
		else:
			money_label.text = UITheme.format_money(balance)
		
		_previous_balance = balance

	# Reputation - animate changes
	if reputation_label:
		var reputation = GameData.player_airline.reputation
		
		# Animate if reputation changed (and not first update)
		if _previous_reputation >= 0 and abs(reputation - _previous_reputation) > 0.01:
			if UIAnimations:
				var tween = UIAnimations.animate_value(reputation_label, _previous_reputation, reputation, "", "")
				# Fix display format after animation completes
				var final_rep: float = reputation  # Capture for lambda
				tween.finished.connect(func(): reputation_label.text = "%.1f" % final_rep)
			else:
				reputation_label.text = "%.1f" % reputation
		else:
			reputation_label.text = "%.1f" % reputation
		
		_previous_reputation = reputation

	# Update TimeSpeedPanel date display
	if time_speed_panel:
		time_speed_panel.update_time_display()

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
	"""Handle keyboard shortcuts - speed controls are handled by TimeSpeedPanel"""
	if event is InputEventKey and event.pressed and not event.echo:
		var focus_owner = get_viewport().gui_get_focus_owner()
		var is_typing = focus_owner is LineEdit or focus_owner is TextEdit

		if not is_typing:
			match event.keycode:
				KEY_T:
					# T key toggles theme
					_on_theme_toggle_pressed()
					get_viewport().set_input_as_handled()

func _on_theme_toggle_pressed() -> void:
	"""Handle theme toggle button press"""
	UITheme.toggle_theme()

func _on_theme_changed() -> void:
	"""Called when theme is changed - update UI colors"""
	print("Theme changed to: %s" % ("Dark" if UITheme.is_dark_mode() else "Light"))

	# Update backgrounds
	if main_bg:
		main_bg.color = UITheme.get_bg_main()
	if content_bg:
		content_bg.color = UITheme.get_bg_main()

	# Update header style
	if header:
		header.add_theme_stylebox_override("panel", UITheme.create_header_style())

	# Update bottom bar style
	if bottom_bar:
		bottom_bar.add_theme_stylebox_override("panel", UITheme.create_bottom_bar_style())

	# Update header text colors
	if reputation_label:
		reputation_label.add_theme_color_override("font_color", UITheme.get_text_primary())

	# TimeSpeedPanel handles its own theming

	# Update bottom bar buttons
	if bottom_bar:
		var bottom_margin = bottom_bar.get_node_or_null("MarginContainer")
		if bottom_margin:
			var bottom_hbox = bottom_margin.get_node_or_null("HBoxContainer")
			if bottom_hbox:
				for child in bottom_hbox.get_children():
					if child is Button:
						child.add_theme_color_override("font_color", UITheme.get_text_primary())
						child.add_theme_color_override("font_hover_color", UITheme.get_text_primary())
						child.add_theme_stylebox_override("normal", UITheme.create_button_style())
						child.add_theme_stylebox_override("hover", UITheme.create_button_hover_style())

	# Update theme toggle button text
	var theme_btn = _find_node_recursive(sidebar, "ThemeToggleButton") as Button
	if theme_btn:
		theme_btn.text = "  %s  Dark Mode" % UITheme.ICON_MOON if UITheme.is_dark_mode() else "  %s  Light Mode" % UITheme.ICON_SUN
