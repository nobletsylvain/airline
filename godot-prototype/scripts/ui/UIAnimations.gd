## UIAnimations.gd
## Autoload singleton for art-bible compliant UI animations.
## Reference: art-bible.md Section 5.1 - Animation Principles
##
## Usage:
##   UIAnimations.panel_open(dialog)
##   UIAnimations.panel_close(dialog, callback)
##   UIAnimations.animate_value(label, old_val, new_val, "€")
##   UIAnimations.button_press(button)
extends Node
class_name UIAnimationsClass


# =============================================================================
# ART-BIBLE TIMING CONSTANTS (Section 5.1)
# =============================================================================

const BUTTON_STATE := 0.15       # 150ms ease-out
const PANEL_OPEN := 0.25         # 250ms ease-in-out
const PAGE_TRANSITION := 0.4     # 400ms ease-in-out
const DATA_UPDATE := 0.2         # 200ms ease-out
const CAMERA_MOVE := 0.5         # 500ms ease-out
const ALERT := 0.3               # 300ms ease-out with overshoot

# Scale factors for animations
const PANEL_SCALE_START := Vector2(0.95, 0.95)
const BUTTON_PRESS_SCALE := Vector2(0.95, 0.95)
const BUTTON_HOVER_SCALE := Vector2(1.02, 1.02)


# =============================================================================
# PANEL ANIMATIONS (Control nodes)
# =============================================================================

func panel_open(panel: Control) -> Tween:
	"""Animate panel opening — scale 0.95→1.0 + fade in (250ms)"""
	# Ensure panel is visible
	panel.visible = true
	
	# Set initial state
	panel.modulate.a = 0.0
	panel.scale = PANEL_SCALE_START
	
	# Set pivot to center for scale animation
	panel.pivot_offset = panel.size / 2.0
	
	# Create animation
	var tween = panel.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(panel, "modulate:a", 1.0, PANEL_OPEN)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, PANEL_OPEN)
	
	return tween


func panel_close(panel: Control, on_complete: Callable = Callable()) -> Tween:
	"""Animate panel closing — reverse of open, calls optional callback"""
	# Set pivot to center for scale animation
	panel.pivot_offset = panel.size / 2.0
	
	# Create animation
	var tween = panel.create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_property(panel, "modulate:a", 0.0, PANEL_OPEN)
	tween.parallel().tween_property(panel, "scale", PANEL_SCALE_START, PANEL_OPEN)
	
	# Call completion callback if provided
	if on_complete.is_valid():
		tween.tween_callback(on_complete)
	else:
		# Default: hide panel after animation
		tween.tween_callback(func(): panel.visible = false)
	
	return tween


# =============================================================================
# DIALOG ANIMATIONS (Window nodes like ConfirmationDialog)
# =============================================================================

func dialog_open(dialog: Window) -> Tween:
	"""Animate dialog opening — slide in from above (250ms)
	Note: Windows don't support modulate/scale, so we only animate position"""
	# Store target position
	var target_pos: Vector2i = dialog.position
	
	# Set initial state - start slightly above
	dialog.position = target_pos - Vector2i(0, 30)
	
	# Create animation
	var tween = dialog.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(dialog, "position", target_pos, PANEL_OPEN)
	
	return tween


func dialog_close(dialog: Window, on_complete: Callable = Callable()) -> Tween:
	"""Animate dialog closing — slide out upward (150ms)"""
	var start_pos: Vector2i = dialog.position
	var end_pos: Vector2i = start_pos - Vector2i(0, 20)
	
	# Create animation
	var tween = dialog.create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_property(dialog, "position", end_pos, PANEL_OPEN * 0.6)
	
	# Call completion callback or hide
	if on_complete.is_valid():
		tween.tween_callback(on_complete)
	else:
		tween.tween_callback(func(): dialog.hide())
	
	# Reset position for next open
	tween.tween_callback(func(): dialog.position = start_pos)
	
	return tween


func page_transition_out(panel: Control) -> Tween:
	"""Animate panel fading out for page transitions (400ms)"""
	var tween = panel.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(panel, "modulate:a", 0.0, PAGE_TRANSITION)
	return tween


func page_transition_in(panel: Control) -> Tween:
	"""Animate panel fading in for page transitions (400ms)"""
	panel.modulate.a = 0.0
	panel.visible = true
	var tween = panel.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(panel, "modulate:a", 1.0, PAGE_TRANSITION)
	return tween


# =============================================================================
# VALUE ANIMATIONS
# =============================================================================

func animate_value(label: Label, from: float, to: float, prefix: String = "", suffix: String = "") -> Tween:
	"""Animate numeric value change with smooth interpolation (200ms)"""
	var tween = label.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_method(
		func(val: float): label.text = prefix + _format_number(val) + suffix,
		from, to, DATA_UPDATE
	)
	return tween


func animate_money(label: Label, from: float, to: float, use_sign: bool = false) -> Tween:
	"""Animate money value change with € prefix (200ms)"""
	var tween = label.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_method(
		func(val: float): label.text = _format_money(val, use_sign),
		from, to, DATA_UPDATE
	)
	return tween


func pulse_value(label: Label, color: Color = Color.WHITE) -> Tween:
	"""Quick pulse effect on a label to draw attention"""
	var original_color = label.get_theme_color("font_color")
	var tween = label.create_tween()
	tween.tween_property(label, "scale", Vector2(1.1, 1.1), DATA_UPDATE * 0.4)
	tween.parallel().tween_property(label, "modulate", color.lightened(0.5), DATA_UPDATE * 0.4)
	tween.tween_property(label, "scale", Vector2.ONE, DATA_UPDATE * 0.6)
	tween.parallel().tween_property(label, "modulate", Color.WHITE, DATA_UPDATE * 0.6)
	return tween


# =============================================================================
# BUTTON ANIMATIONS
# =============================================================================

func button_press(button: Control) -> Tween:
	"""Button press feedback — quick scale punch (150ms)"""
	# Ensure pivot is centered
	button.pivot_offset = button.size / 2.0
	
	var tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", BUTTON_PRESS_SCALE, BUTTON_STATE * 0.4)
	tween.tween_property(button, "scale", Vector2.ONE, BUTTON_STATE * 0.6)
	return tween


func button_hover_enter(button: Control) -> Tween:
	"""Button hover enter — slight scale up (150ms)"""
	# Ensure pivot is centered
	button.pivot_offset = button.size / 2.0
	
	# Kill any existing scale tween to prevent conflicts
	_kill_property_tweens(button, "scale")
	
	var tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "scale", BUTTON_HOVER_SCALE, BUTTON_STATE)
	return tween


func button_hover_exit(button: Control) -> Tween:
	"""Button hover exit — return to normal scale (150ms)"""
	# Kill any existing scale tween to prevent conflicts
	_kill_property_tweens(button, "scale")
	
	var tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "scale", Vector2.ONE, BUTTON_STATE)
	return tween


func setup_button_animations(button: Button) -> void:
	"""Convenience method to connect all button animation signals"""
	# Ensure pivot is centered (call deferred to get correct size)
	button.resized.connect(func(): button.pivot_offset = button.size / 2.0)
	button.pivot_offset = button.size / 2.0
	
	button.mouse_entered.connect(func(): button_hover_enter(button))
	button.mouse_exited.connect(func(): button_hover_exit(button))
	button.pressed.connect(func(): button_press(button))


# =============================================================================
# ALERT / NOTIFICATION ANIMATIONS
# =============================================================================

func alert_appear(control: Control) -> Tween:
	"""Alert appearance with overshoot (300ms)"""
	control.modulate.a = 0.0
	control.scale = Vector2(0.8, 0.8)
	control.pivot_offset = control.size / 2.0
	control.visible = true
	
	var tween = control.create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)  # Overshoot
	tween.tween_property(control, "modulate:a", 1.0, ALERT)
	tween.parallel().tween_property(control, "scale", Vector2.ONE, ALERT)
	return tween


func alert_dismiss(control: Control) -> Tween:
	"""Alert dismissal (300ms)"""
	var tween = control.create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(control, "modulate:a", 0.0, ALERT * 0.5)
	tween.parallel().tween_property(control, "scale", Vector2(0.9, 0.9), ALERT * 0.5)
	tween.tween_callback(func(): control.visible = false)
	return tween


# =============================================================================
# TOOLTIP ANIMATIONS
# =============================================================================

func tooltip_show(control: Control) -> Tween:
	"""Tooltip fade in (150ms)"""
	control.modulate.a = 0.0
	control.visible = true
	var tween = control.create_tween()
	tween.tween_property(control, "modulate:a", 1.0, BUTTON_STATE)
	return tween


func tooltip_hide(control: Control) -> Tween:
	"""Tooltip fade out (150ms)"""
	var tween = control.create_tween()
	tween.tween_property(control, "modulate:a", 0.0, BUTTON_STATE)
	tween.tween_callback(func(): control.visible = false)
	return tween


# =============================================================================
# TAB / PAGE ANIMATIONS
# =============================================================================

func tab_switch(old_panel: Control, new_panel: Control) -> void:
	"""Animate switching between tab panels"""
	if old_panel:
		old_panel.modulate.a = 1.0
		var out_tween = old_panel.create_tween()
		out_tween.tween_property(old_panel, "modulate:a", 0.0, PAGE_TRANSITION * 0.5)
		out_tween.tween_callback(func(): old_panel.visible = false)
	
	if new_panel:
		new_panel.visible = true
		new_panel.modulate.a = 0.0
		# Slight delay for crossfade effect
		await new_panel.get_tree().create_timer(PAGE_TRANSITION * 0.25).timeout
		var in_tween = new_panel.create_tween()
		in_tween.tween_property(new_panel, "modulate:a", 1.0, PAGE_TRANSITION * 0.5)


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

func _format_number(val: float) -> String:
	"""Format large numbers with K/M suffixes"""
	var abs_val = abs(val)
	var sign_str = "-" if val < 0 else ""
	
	if abs_val >= 1_000_000_000:
		return "%s%.2fB" % [sign_str, abs_val / 1_000_000_000]
	elif abs_val >= 1_000_000:
		return "%s%.1fM" % [sign_str, abs_val / 1_000_000]
	elif abs_val >= 1_000:
		return "%s%.1fK" % [sign_str, abs_val / 1_000]
	else:
		return "%s%.0f" % [sign_str, abs_val]


func _format_money(val: float, use_sign: bool = false) -> String:
	"""Format money with € prefix and optional sign"""
	var prefix = "€"
	if use_sign and val > 0:
		prefix = "+€"
	elif val < 0:
		prefix = "-€"
		val = abs(val)
	
	return prefix + _format_number(abs(val))


func _kill_property_tweens(node: Node, property: String) -> void:
	"""Kill any active tweens on a specific property to prevent conflicts"""
	# Note: Godot 4 doesn't provide direct access to kill specific property tweens
	# This is a best-effort approach - the new tween will override
	pass
