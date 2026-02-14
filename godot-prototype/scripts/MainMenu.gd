extends Control
class_name MainMenu

## Main Menu - SkyTycoon Landing Page
## Based on Figma mockup with cinematic background and animated menu

signal new_game_requested(settings: Dictionary)
signal load_game_requested(save_id: String)
signal options_requested
signal quit_requested

# UI References
var background: ColorRect
var gradient_overlay: ColorRect
var logo_container: VBoxContainer
var menu_container: VBoxContainer
var version_label: Label

# Menu buttons
var new_game_button: Button
var load_game_button: Button
var options_button: Button
var quit_button: Button

# New Game Dialog
var new_game_dialog: Control
var airline_name_input: LineEdit
var hub_selector: OptionButton
var difficulty_selector: OptionButton
var start_button: Button
var cancel_button: Button

# Animation
var menu_buttons: Array[Button] = []
var animation_timer: float = 0.0
var buttons_visible: bool = false

func _ready() -> void:
	create_ui()
	animate_intro()

func _process(delta: float) -> void:
	animation_timer += delta

	# Subtle background animation (gradient shift)
	if gradient_overlay and gradient_overlay.material:
		var shift = sin(animation_timer * 0.5) * 0.05
		gradient_overlay.material.set_shader_parameter("shift", shift)

func create_ui() -> void:
	"""Build the main menu UI programmatically"""
	# Full screen container
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background (dark with gradient)
	background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = UITheme.BG_DARK
	add_child(background)

	# Gradient overlay (left dark to right transparent)
	gradient_overlay = ColorRect.new()
	gradient_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(gradient_overlay)

	# Create gradient shader
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	uniform float shift = 0.0;
	void fragment() {
		float grad = UV.x * 0.8 + shift;
		COLOR = vec4(0.0, 0.0, 0.0, 1.0 - grad);
	}
	"""
	var material = ShaderMaterial.new()
	material.shader = shader
	gradient_overlay.material = material

	# Vignette effect
	var vignette = ColorRect.new()
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	var vignette_shader = Shader.new()
	vignette_shader.code = """
	shader_type canvas_item;
	void fragment() {
		vec2 center = vec2(0.5, 0.5);
		float dist = distance(UV, center);
		float vignette = smoothstep(0.4, 0.9, dist);
		COLOR = vec4(0.0, 0.0, 0.0, vignette * 0.5);
	}
	"""
	var vignette_material = ShaderMaterial.new()
	vignette_material.shader = vignette_shader
	vignette.material = vignette_material

	# Main content container (left side)
	var content = VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	content.offset_left = 64
	content.offset_top = -200
	content.offset_right = 500
	content.offset_bottom = 200
	content.add_theme_constant_override("separation", 0)
	add_child(content)

	# Logo/Title section
	logo_container = VBoxContainer.new()
	logo_container.add_theme_constant_override("separation", 8)
	logo_container.modulate.a = 0  # Start invisible for animation
	content.add_child(logo_container)

	# Subtitle with plane icon
	var subtitle_row = HBoxContainer.new()
	subtitle_row.add_theme_constant_override("separation", 12)
	logo_container.add_child(subtitle_row)

	var plane_icon = Label.new()
	plane_icon.text = UITheme.ICON_PLANE
	plane_icon.rotation_degrees = -45
	plane_icon.add_theme_font_size_override("font_size", 32)
	plane_icon.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	subtitle_row.add_child(plane_icon)

	var subtitle = Label.new()
	subtitle.text = "AIRLINE MANAGEMENT SIM"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE_LIGHT)
	subtitle.uppercase = true
	subtitle_row.add_child(subtitle)

	# Main title
	var title_row = HBoxContainer.new()
	logo_container.add_child(title_row)

	var title_sky = Label.new()
	title_sky.text = "Sky"
	title_sky.add_theme_font_size_override("font_size", 72)
	title_sky.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	title_row.add_child(title_sky)

	var title_tycoon = Label.new()
	title_tycoon.text = "Tycoon"
	title_tycoon.add_theme_font_size_override("font_size", 72)
	title_tycoon.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	title_row.add_child(title_tycoon)

	# Tagline
	var tagline = Label.new()
	tagline.text = "Build your fleet. Manage routes. Conquer the skies."
	tagline.add_theme_font_size_override("font_size", 16)
	tagline.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	logo_container.add_child(tagline)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 48)
	content.add_child(spacer)

	# Menu buttons container
	menu_container = VBoxContainer.new()
	menu_container.add_theme_constant_override("separation", 16)
	content.add_child(menu_container)

	# Create menu buttons
	new_game_button = create_menu_button("Start New Game")
	new_game_button.pressed.connect(_on_new_game_pressed)
	menu_buttons.append(new_game_button)

	load_game_button = create_menu_button("Load Game")
	load_game_button.pressed.connect(_on_load_game_pressed)
	menu_buttons.append(load_game_button)

	options_button = create_menu_button("Options")
	options_button.pressed.connect(_on_options_pressed)
	menu_buttons.append(options_button)

	quit_button = create_menu_button("Quit")
	quit_button.pressed.connect(_on_quit_pressed)
	menu_buttons.append(quit_button)

	for btn in menu_buttons:
		menu_container.add_child(btn)
		btn.modulate.a = 0  # Start invisible for animation

	# Version label (bottom left)
	version_label = Label.new()
	version_label.text = "v1.0.0-alpha | Build 2026.01.20"
	version_label.add_theme_font_size_override("font_size", 12)
	version_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	version_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	version_label.offset_left = 64
	version_label.offset_bottom = -32
	version_label.modulate.a = 0
	add_child(version_label)

	# Create new game dialog (hidden initially)
	create_new_game_dialog()

func create_menu_button(text: String) -> Button:
	"""Create a styled menu button"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(280, 56)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)

	# Style
	var normal_style = UITheme.create_menu_button_style()
	button.add_theme_stylebox_override("normal", normal_style)

	# Hover style
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(1, 1, 1, 0.1)
	hover_style.border_color = UITheme.PRIMARY_BLUE
	hover_style.set_border_width_all(1)
	hover_style.set_corner_radius_all(8)
	hover_style.set_content_margin_all(16)
	button.add_theme_stylebox_override("hover", hover_style)

	# Pressed style
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = UITheme.PRIMARY_BLUE
	pressed_style.set_corner_radius_all(8)
	pressed_style.set_content_margin_all(16)
	button.add_theme_stylebox_override("pressed", pressed_style)

	return button

func create_new_game_dialog() -> void:
	"""Create the new game configuration dialog"""
	new_game_dialog = Panel.new()
	new_game_dialog.set_anchors_preset(Control.PRESET_CENTER)
	new_game_dialog.custom_minimum_size = Vector2(500, 450)
	new_game_dialog.offset_left = -250
	new_game_dialog.offset_top = -225
	new_game_dialog.offset_right = 250
	new_game_dialog.offset_bottom = 225
	new_game_dialog.add_theme_stylebox_override("panel", UITheme.create_menu_panel_style())
	new_game_dialog.visible = false
	add_child(new_game_dialog)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 32
	vbox.offset_top = 32
	vbox.offset_right = -32
	vbox.offset_bottom = -32
	vbox.add_theme_constant_override("separation", 24)
	new_game_dialog.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "START NEW AIRLINE"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Separator
	var sep = HSeparator.new()
	sep.add_theme_color_override("separator", Color(1, 1, 1, 0.2))
	vbox.add_child(sep)

	# Airline Name
	var name_container = VBoxContainer.new()
	name_container.add_theme_constant_override("separation", 8)
	vbox.add_child(name_container)

	var name_label = Label.new()
	name_label.text = "Airline Name"
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	name_container.add_child(name_label)

	airline_name_input = LineEdit.new()
	airline_name_input.placeholder_text = "e.g. SkyHigh Airways"
	airline_name_input.text = "Global Wings"
	airline_name_input.custom_minimum_size = Vector2(0, 44)
	airline_name_input.add_theme_font_size_override("font_size", 16)

	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(1, 1, 1, 0.05)
	input_style.border_color = Color(1, 1, 1, 0.1)
	input_style.set_border_width_all(1)
	input_style.set_corner_radius_all(8)
	input_style.set_content_margin_all(12)
	airline_name_input.add_theme_stylebox_override("normal", input_style)
	name_container.add_child(airline_name_input)

	# Hub Airport
	var hub_container = VBoxContainer.new()
	hub_container.add_theme_constant_override("separation", 8)
	vbox.add_child(hub_container)

	var hub_label = Label.new()
	hub_label.text = "Hub Airport"
	hub_label.add_theme_font_size_override("font_size", 14)
	hub_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	hub_container.add_child(hub_label)

	hub_selector = OptionButton.new()
	hub_selector.custom_minimum_size = Vector2(0, 44)
	hub_selector.add_theme_font_size_override("font_size", 16)
	hub_selector.add_item("London Heathrow (LHR)", 0)
	hub_selector.add_item("New York JFK (JFK)", 1)
	hub_selector.add_item("Dubai International (DXB)", 2)
	hub_selector.add_item("Tokyo Haneda (HND)", 3)
	hub_selector.add_item("Singapore Changi (SIN)", 4)
	hub_selector.add_item("Paris CDG (CDG)", 5)
	hub_selector.add_item("Frankfurt (FRA)", 6)
	hub_container.add_child(hub_selector)

	# Difficulty
	var diff_container = VBoxContainer.new()
	diff_container.add_theme_constant_override("separation", 8)
	vbox.add_child(diff_container)

	var diff_label = Label.new()
	diff_label.text = "Starting Budget"
	diff_label.add_theme_font_size_override("font_size", 14)
	diff_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	diff_container.add_child(diff_label)

	difficulty_selector = OptionButton.new()
	difficulty_selector.custom_minimum_size = Vector2(0, 44)
	difficulty_selector.add_theme_font_size_override("font_size", 16)
	difficulty_selector.add_item("Easy ($500M)", 0)
	difficulty_selector.add_item("Medium ($100M)", 1)
	difficulty_selector.add_item("Hard ($10M)", 2)
	difficulty_selector.select(1)  # Default to medium
	diff_container.add_child(difficulty_selector)

	# Spacer
	var button_spacer = Control.new()
	button_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(button_spacer)

	# Buttons
	var button_row = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 16)
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(button_row)

	cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.custom_minimum_size = Vector2(150, 48)
	cancel_button.add_theme_font_size_override("font_size", 16)
	cancel_button.add_theme_stylebox_override("normal", UITheme.create_secondary_button_style())
	cancel_button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	cancel_button.pressed.connect(_on_cancel_new_game)
	button_row.add_child(cancel_button)

	start_button = Button.new()
	start_button.text = "Take Off"
	start_button.custom_minimum_size = Vector2(150, 48)
	start_button.add_theme_font_size_override("font_size", 16)
	start_button.add_theme_stylebox_override("normal", UITheme.create_primary_button_style())
	start_button.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	start_button.pressed.connect(_on_start_game)
	button_row.add_child(start_button)

func animate_intro() -> void:
	"""Animate the intro sequence"""
	# Logo fade in
	var tween = create_tween()
	tween.tween_property(logo_container, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)

	# Staggered button fade in
	await get_tree().create_timer(0.3).timeout

	for i in range(menu_buttons.size()):
		var btn = menu_buttons[i]
		var btn_tween = create_tween()
		btn_tween.tween_property(btn, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)
		btn_tween.parallel().tween_property(btn, "position:x", btn.position.x, 0.4).from(btn.position.x - 50).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.1).timeout

	# Version label
	await get_tree().create_timer(0.2).timeout
	var ver_tween = create_tween()
	ver_tween.tween_property(version_label, "modulate:a", 1.0, 0.5)

	buttons_visible = true

func _on_new_game_pressed() -> void:
	"""Show new game dialog"""
	new_game_dialog.visible = true
	# Animate in
	new_game_dialog.modulate.a = 0
	new_game_dialog.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.tween_property(new_game_dialog, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(new_game_dialog, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)

func _on_cancel_new_game() -> void:
	"""Hide new game dialog"""
	var tween = create_tween()
	tween.tween_property(new_game_dialog, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): new_game_dialog.visible = false)

func _on_start_game() -> void:
	"""Start a new game with selected settings"""
	var hub_codes = ["LHR", "JFK", "DXB", "HND", "SIN", "CDG", "FRA"]
	var budgets = [500_000_000, 100_000_000, 10_000_000]

	var settings = {
		"airline_name": airline_name_input.text if airline_name_input.text.length() > 0 else "Global Wings",
		"hub_code": hub_codes[hub_selector.selected],
		"starting_budget": budgets[difficulty_selector.selected],
		"difficulty": difficulty_selector.selected
	}

	print("Starting new game with settings: ", settings)

	# Store settings in GameData for the game to use
	if GameData:
		GameData.new_game_settings = settings

	# Transition to game scene
	transition_to_game()

func transition_to_game() -> void:
	"""Fade out and load the game scene"""
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished

	# Load game scene
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_load_game_pressed() -> void:
	"""Open load game dialog"""
	# For now, just start a new game (TODO: implement save/load)
	transition_to_game()

func _on_options_pressed() -> void:
	"""Open options dialog"""
	options_requested.emit()

func _on_quit_pressed() -> void:
	"""Quit the game"""
	quit_requested.emit()

func _input(event: InputEvent) -> void:
	"""Handle keyboard input"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if new_game_dialog and new_game_dialog.visible:
				_on_cancel_new_game()
		elif event.keycode == KEY_ENTER:
			if new_game_dialog and new_game_dialog.visible:
				_on_start_game()
