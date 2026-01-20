extends PanelContainer
class_name Sidebar

## Dark sidebar navigation component
## Based on Figma mockup design

signal tab_changed(tab_name: String)

# Navigation items
var nav_items: Array[Dictionary] = [
	{"id": "dashboard", "label": "Dashboard", "icon": "D"},
	{"id": "fleet", "label": "Fleet", "icon": UITheme.ICON_PLANE},
	{"id": "routes", "label": "Routes", "icon": UITheme.ICON_ARROW_RIGHT},
	{"id": "finances", "label": "Finances", "icon": UITheme.ICON_MONEY},
	{"id": "market", "label": "Market", "icon": UITheme.ICON_ARROW_UP_RIGHT},
]

var active_tab: String = "dashboard"
var nav_buttons: Dictionary = {}

# UI elements
var logo_container: VBoxContainer
var nav_container: VBoxContainer
var settings_button: Button

func _ready() -> void:
	create_sidebar()

func create_sidebar() -> void:
	"""Build the sidebar UI"""
	# Panel style
	add_theme_stylebox_override("panel", UITheme.create_sidebar_style())
	custom_minimum_size = Vector2(UITheme.SIDEBAR_WIDTH, 0)

	# Main container
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(main_vbox)

	# Logo section
	create_logo_section(main_vbox)

	# Navigation section
	create_nav_section(main_vbox)

	# Bottom section (settings)
	create_bottom_section(main_vbox)

func create_logo_section(parent: VBoxContainer) -> void:
	"""Create the logo/branding section"""
	logo_container = VBoxContainer.new()
	logo_container.add_theme_constant_override("separation", 4)

	# Logo panel with padding
	var logo_panel = PanelContainer.new()
	var logo_style = StyleBoxFlat.new()
	logo_style.bg_color = Color(0, 0, 0, 0)
	logo_style.border_color = UITheme.SIDEBAR_HOVER
	logo_style.border_width_bottom = 1
	logo_style.set_content_margin_all(24)
	logo_panel.add_theme_stylebox_override("panel", logo_style)
	parent.add_child(logo_panel)

	var logo_hbox = HBoxContainer.new()
	logo_hbox.add_theme_constant_override("separation", 12)
	logo_panel.add_child(logo_hbox)

	# Logo icon (rotated plane in blue box)
	var icon_panel = Panel.new()
	icon_panel.custom_minimum_size = Vector2(40, 40)
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = UITheme.PRIMARY_BLUE
	icon_style.set_corner_radius_all(10)
	icon_panel.add_theme_stylebox_override("panel", icon_style)
	logo_hbox.add_child(icon_panel)

	var icon_label = Label.new()
	icon_label.text = UITheme.ICON_PLANE
	icon_label.rotation_degrees = -45
	icon_label.add_theme_font_size_override("font_size", 20)
	icon_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_panel.add_child(icon_label)

	# Logo text
	var text_vbox = VBoxContainer.new()
	text_vbox.add_theme_constant_override("separation", 0)
	logo_hbox.add_child(text_vbox)

	var title_label = Label.new()
	title_label.text = "SKYTYCOON"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	text_vbox.add_child(title_label)

	var subtitle_label = Label.new()
	subtitle_label.text = "TYCOON"
	subtitle_label.add_theme_font_size_override("font_size", 10)
	subtitle_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	subtitle_label.uppercase = true
	text_vbox.add_child(subtitle_label)

func create_nav_section(parent: VBoxContainer) -> void:
	"""Create the navigation buttons section"""
	nav_container = VBoxContainer.new()
	nav_container.add_theme_constant_override("separation", 4)
	nav_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Padding container
	var padding = MarginContainer.new()
	padding.add_theme_constant_override("margin_left", 12)
	padding.add_theme_constant_override("margin_right", 12)
	padding.add_theme_constant_override("margin_top", 24)
	padding.add_theme_constant_override("margin_bottom", 24)
	padding.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(padding)
	padding.add_child(nav_container)

	# Create nav buttons
	for item in nav_items:
		var button = create_nav_button(item.id, item.label, item.icon)
		nav_container.add_child(button)
		nav_buttons[item.id] = button

	# Set initial active state
	update_active_tab(active_tab)

func create_nav_button(id: String, label: String, icon: String) -> Button:
	"""Create a navigation button"""
	var button = Button.new()
	button.name = id
	button.custom_minimum_size = Vector2(0, 48)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Text with icon
	button.text = "  %s  %s" % [icon, label]
	button.add_theme_font_size_override("font_size", 15)

	# Normal style (inactive)
	var normal_style = UITheme.create_sidebar_button_style(false)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)

	# Hover style
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.SIDEBAR_HOVER
	hover_style.set_corner_radius_all(12)
	hover_style.set_content_margin_all(12)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)

	# Pressed style
	var pressed_style = UITheme.create_sidebar_button_style(true)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_color_override("font_pressed_color", UITheme.TEXT_WHITE)

	# Connect signal
	button.pressed.connect(_on_nav_button_pressed.bind(id))

	return button

func create_bottom_section(parent: VBoxContainer) -> void:
	"""Create the bottom settings section"""
	var bottom_panel = PanelContainer.new()
	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = Color(0, 0, 0, 0)
	bottom_style.border_color = UITheme.SIDEBAR_HOVER
	bottom_style.border_width_top = 1
	bottom_style.set_content_margin_all(16)
	bottom_panel.add_theme_stylebox_override("panel", bottom_style)
	parent.add_child(bottom_panel)

	settings_button = Button.new()
	settings_button.text = "  %s  Settings" % UITheme.ICON_CIRCLE
	settings_button.custom_minimum_size = Vector2(0, 48)
	settings_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	settings_button.add_theme_font_size_override("font_size", 15)
	settings_button.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)

	var normal_style = UITheme.create_sidebar_button_style(false)
	settings_button.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.SIDEBAR_HOVER
	hover_style.set_corner_radius_all(12)
	hover_style.set_content_margin_all(12)
	settings_button.add_theme_stylebox_override("hover", hover_style)
	settings_button.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)

	bottom_panel.add_child(settings_button)

func _on_nav_button_pressed(tab_id: String) -> void:
	"""Handle navigation button press"""
	if tab_id != active_tab:
		update_active_tab(tab_id)
		tab_changed.emit(tab_id)

func update_active_tab(tab_id: String) -> void:
	"""Update the visual state of navigation buttons"""
	active_tab = tab_id

	for id in nav_buttons:
		var button: Button = nav_buttons[id]
		var is_active = (id == tab_id)

		if is_active:
			# Active style
			var active_style = UITheme.create_sidebar_button_style(true)
			button.add_theme_stylebox_override("normal", active_style)
			button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
		else:
			# Inactive style
			var inactive_style = UITheme.create_sidebar_button_style(false)
			button.add_theme_stylebox_override("normal", inactive_style)
			button.add_theme_color_override("font_color", UITheme.SIDEBAR_TEXT)

func set_active_tab(tab_id: String) -> void:
	"""Programmatically set the active tab"""
	update_active_tab(tab_id)
