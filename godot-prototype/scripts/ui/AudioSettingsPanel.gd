## AudioSettingsPanel.gd
## Audio settings panel with volume controls and enable toggles.
## Access via Settings button in sidebar.
extends PanelContainer
class_name AudioSettingsPanel

signal settings_changed
signal closed

# UI Elements
var master_slider: HSlider
var master_label: Label
var ui_enabled_check: CheckBox
var ui_slider: HSlider
var ui_label: Label
var ambient_enabled_check: CheckBox
var ambient_slider: HSlider
var ambient_label: Label

# Settings state
var _master_volume: float = 0.8
var _ui_volume: float = 0.5
var _ui_enabled: bool = false  # Off by default
var _ambient_volume: float = 0.7
var _ambient_enabled: bool = false  # Off by default

const SETTINGS_PATH := "user://audio_settings.cfg"


func _ready() -> void:
	_build_ui()
	_load_settings()
	_apply_settings()
	hide()


func _build_ui() -> void:
	"""Build the settings panel UI"""
	custom_minimum_size = Vector2(350, 280)
	
	# Panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.14, 0.18, 0.98)
	panel_style.border_color = Color(0.3, 0.5, 0.8, 0.8)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.set_content_margin_all(16)
	add_theme_stylebox_override("panel", panel_style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)
	
	# Header
	var header = Label.new()
	header.text = "⚙ Audio Settings"
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(header)
	
	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Master Volume
	var master_row = _create_slider_row("Master Volume", 0.8)
	master_slider = master_row.slider
	master_label = master_row.label
	master_slider.value_changed.connect(_on_master_changed)
	vbox.add_child(master_row.container)
	
	# UI Sounds
	var ui_row = _create_toggle_slider_row("UI Sounds", false, 0.5)
	ui_enabled_check = ui_row.checkbox
	ui_slider = ui_row.slider
	ui_label = ui_row.label
	ui_enabled_check.toggled.connect(_on_ui_enabled_changed)
	ui_slider.value_changed.connect(_on_ui_volume_changed)
	vbox.add_child(ui_row.container)
	
	# Ambient
	var ambient_row = _create_toggle_slider_row("Ambient", false, 0.7)
	ambient_enabled_check = ambient_row.checkbox
	ambient_slider = ambient_row.slider
	ambient_label = ambient_row.label
	ambient_enabled_check.toggled.connect(_on_ambient_enabled_changed)
	ambient_slider.value_changed.connect(_on_ambient_volume_changed)
	vbox.add_child(ambient_row.container)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 8
	vbox.add_child(spacer)
	
	# Buttons
	var button_row = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	button_row.add_theme_constant_override("separation", 8)
	vbox.add_child(button_row)
	
	var apply_btn = Button.new()
	apply_btn.text = "Apply"
	apply_btn.custom_minimum_size = Vector2(80, 32)
	apply_btn.pressed.connect(_on_apply_pressed)
	button_row.add_child(apply_btn)
	
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(80, 32)
	close_btn.pressed.connect(_on_close_pressed)
	button_row.add_child(close_btn)


func _create_slider_row(label_text: String, default_value: float) -> Dictionary:
	"""Create a row with label + slider + value label"""
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 100
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	hbox.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = default_value
	slider.custom_minimum_size.x = 140
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = "%d%%" % int(default_value * 100)
	value_label.custom_minimum_size.x = 45
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	hbox.add_child(value_label)
	
	return {"container": hbox, "slider": slider, "label": value_label}


func _create_toggle_slider_row(label_text: String, default_enabled: bool, default_value: float) -> Dictionary:
	"""Create a row with checkbox + slider + value label"""
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	
	var checkbox = CheckBox.new()
	checkbox.text = label_text
	checkbox.button_pressed = default_enabled
	checkbox.custom_minimum_size.x = 100
	checkbox.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	hbox.add_child(checkbox)
	
	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = default_value
	slider.custom_minimum_size.x = 140
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = "%d%%" % int(default_value * 100)
	value_label.custom_minimum_size.x = 45
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	hbox.add_child(value_label)
	
	return {"container": hbox, "checkbox": checkbox, "slider": slider, "label": value_label}


# =============================================================================
# EVENT HANDLERS
# =============================================================================

func _on_master_changed(value: float) -> void:
	_master_volume = value
	master_label.text = "%d%%" % int(value * 100)
	_apply_master_volume()


func _on_ui_enabled_changed(enabled: bool) -> void:
	_ui_enabled = enabled
	ui_slider.editable = enabled
	if UISoundManager:
		UISoundManager.set_enabled(enabled)


func _on_ui_volume_changed(value: float) -> void:
	_ui_volume = value
	ui_label.text = "%d%%" % int(value * 100)
	if UISoundManager:
		UISoundManager.set_volume(value)


func _on_ambient_enabled_changed(enabled: bool) -> void:
	_ambient_enabled = enabled
	ambient_slider.editable = enabled
	if AmbientAudioManager:
		AmbientAudioManager.set_enabled(enabled)


func _on_ambient_volume_changed(value: float) -> void:
	_ambient_volume = value
	ambient_label.text = "%d%%" % int(value * 100)
	if AmbientAudioManager:
		AmbientAudioManager.set_volume(value)


func _on_apply_pressed() -> void:
	_save_settings()
	settings_changed.emit()
	if UISoundManager:
		UISoundManager.play_click()


func _on_close_pressed() -> void:
	_save_settings()
	if UIAnimations:
		UIAnimations.panel_close(self, func(): hide())
	else:
		hide()
	closed.emit()


# =============================================================================
# SETTINGS PERSISTENCE
# =============================================================================

func _apply_master_volume() -> void:
	"""Apply master volume to the Master audio bus"""
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(_master_volume))


func _apply_settings() -> void:
	"""Apply all settings to audio systems"""
	_apply_master_volume()
	
	if UISoundManager:
		UISoundManager.set_enabled(_ui_enabled)
		UISoundManager.set_volume(_ui_volume)
	
	if AmbientAudioManager:
		AmbientAudioManager.set_enabled(_ambient_enabled)
		AmbientAudioManager.set_volume(_ambient_volume)


func _save_settings() -> void:
	"""Save audio settings to file"""
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", _master_volume)
	config.set_value("audio", "ui_enabled", _ui_enabled)
	config.set_value("audio", "ui_volume", _ui_volume)
	config.set_value("audio", "ambient_enabled", _ambient_enabled)
	config.set_value("audio", "ambient_volume", _ambient_volume)
	
	var err = config.save(SETTINGS_PATH)
	if err != OK:
		push_warning("AudioSettingsPanel: Failed to save settings")


func _load_settings() -> void:
	"""Load audio settings from file"""
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		_master_volume = config.get_value("audio", "master_volume", 0.8)
		_ui_enabled = config.get_value("audio", "ui_enabled", false)
		_ui_volume = config.get_value("audio", "ui_volume", 0.5)
		_ambient_enabled = config.get_value("audio", "ambient_enabled", false)
		_ambient_volume = config.get_value("audio", "ambient_volume", 0.7)
		
		# Update UI to match loaded values
		if master_slider:
			master_slider.value = _master_volume
			master_label.text = "%d%%" % int(_master_volume * 100)
		if ui_enabled_check:
			ui_enabled_check.button_pressed = _ui_enabled
			ui_slider.value = _ui_volume
			ui_slider.editable = _ui_enabled
			ui_label.text = "%d%%" % int(_ui_volume * 100)
		if ambient_enabled_check:
			ambient_enabled_check.button_pressed = _ambient_enabled
			ambient_slider.value = _ambient_volume
			ambient_slider.editable = _ambient_enabled
			ambient_label.text = "%d%%" % int(_ambient_volume * 100)


# =============================================================================
# PUBLIC API
# =============================================================================

func show_panel() -> void:
	"""Show the settings panel with animation"""
	_load_settings()
	_apply_settings()
	
	# Update UI to match current values
	if master_slider:
		master_slider.value = _master_volume
	if ui_slider:
		ui_slider.value = _ui_volume
		ui_enabled_check.button_pressed = _ui_enabled
	if ambient_slider:
		ambient_slider.value = _ambient_volume
		ambient_enabled_check.button_pressed = _ambient_enabled
	
	show()
	if UIAnimations:
		UIAnimations.panel_open(self)
