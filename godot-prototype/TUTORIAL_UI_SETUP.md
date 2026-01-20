# Tutorial UI Setup Guide

## Overview

This guide shows how to add the visual tutorial overlay with skip button to the game.

---

## Option 1: Programmatic Setup (Quick)

Add this to **GameUI.gd** `_ready()` function:

```gdscript
func _ready() -> void:
	# ... existing code ...

	# Create tutorial overlay programmatically
	create_tutorial_overlay()

func create_tutorial_overlay() -> void:
	"""Create tutorial UI overlay programmatically"""
	# Create overlay layer
	var overlay = CanvasLayer.new()
	overlay.name = "TutorialOverlay"
	overlay.layer = 100  # Above everything
	add_child(overlay)

	# Create tutorial panel
	var panel = Panel.new()
	panel.name = "TutorialPanel"
	panel.custom_minimum_size = Vector2(600, 300)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.1
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.1
	panel.offset_left = -300  # Half of width
	panel.offset_top = 0
	panel.offset_right = 300
	panel.offset_bottom = 300
	overlay.add_child(panel)

	# VBox container
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	panel.add_child(vbox)

	# Step number label
	var progress = Label.new()
	progress.name = "ProgressLabel"
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress.add_theme_font_size_override("font_size", 14)
	vbox.add_child(progress)

	# Title label
	var title = Label.new()
	title.name = "TitleLabel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.2, 0.6, 1.0))
	vbox.add_child(title)

	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer1)

	# Message label (RichTextLabel for formatting)
	var message = RichTextLabel.new()
	message.name = "MessageLabel"
	message.bbcode_enabled = true
	message.fit_content = true
	message.custom_minimum_size = Vector2(0, 100)
	message.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(message)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer2)

	# Button container
	var button_box = HBoxContainer.new()
	button_box.name = "ButtonContainer"
	button_box.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(button_box)

	# Skip button (red)
	var skip_btn = Button.new()
	skip_btn.name = "SkipButton"
	skip_btn.text = "Skip Tutorial"
	skip_btn.custom_minimum_size = Vector2(150, 40)
	skip_btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	button_box.add_child(skip_btn)

	# Spacer between buttons
	var button_spacer = Control.new()
	button_spacer.custom_minimum_size = Vector2(20, 0)
	button_box.add_child(button_spacer)

	# Continue button (green)
	var continue_btn = Button.new()
	continue_btn.name = "ContinueButton"
	continue_btn.text = "Continue (Enter)"
	continue_btn.custom_minimum_size = Vector2(150, 40)
	continue_btn.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
	button_box.add_child(continue_btn)

	# Create confirmation dialog
	var dialog = ConfirmationDialog.new()
	dialog.name = "ConfirmationDialog"
	dialog.title = "Skip Tutorial?"
	dialog.dialog_text = "Are you sure you want to skip the tutorial?\n\nYou will miss the $50M completion bonus!"
	dialog.ok_button_text = "Skip Tutorial"
	dialog.cancel_button_text = "Continue Tutorial"
	overlay.add_child(dialog)

	# Initially hide panel
	panel.visible = false

	# Connect to tutorial manager
	setup_tutorial_connections(overlay, panel, title, message, progress, continue_btn, skip_btn, dialog)

func setup_tutorial_connections(overlay: CanvasLayer, panel: Panel, title: Label, message: RichTextLabel, progress: Label, continue_btn: Button, skip_btn: Button, dialog: ConfirmationDialog) -> void:
	"""Connect tutorial UI to tutorial manager"""
	if not GameData.tutorial_manager:
		print("Warning: Tutorial manager not found")
		return

	var tutorial_mgr = GameData.tutorial_manager

	# Connect tutorial events
	tutorial_mgr.tutorial_step_started.connect(func(step: TutorialStep):
		panel.visible = true
		title.text = step.title
		message.text = step.message

		var current_index = tutorial_mgr.current_step_index + 1
		var total = tutorial_mgr.tutorial_steps.size()
		progress.text = "Step %d / %d" % [current_index, total]

		# Show/hide continue based on step type
		match step.step_type:
			TutorialStep.StepType.WAIT_FOR_ACTION:
				continue_btn.visible = false
			_:
				continue_btn.visible = true

		# Hide skip on last step
		skip_btn.visible = current_index < total
	)

	tutorial_mgr.tutorial_completed.connect(func():
		panel.visible = false
	)

	# Connect buttons
	continue_btn.pressed.connect(func():
		tutorial_mgr.complete_current_step()
	)

	skip_btn.pressed.connect(func():
		dialog.popup_centered()
	)

	dialog.confirmed.connect(func():
		tutorial_mgr.skip_tutorial()
		panel.visible = false
	)

	print("Tutorial UI connected!")
```

---

## Option 2: Scene-Based Setup (Recommended)

### Step 1: Create TutorialOverlay Scene

1. In Godot editor, create new scene: **Scene → New Scene**
2. Select **CanvasLayer** as root node
3. Name it `TutorialOverlay`
4. Attach script: `res://scripts/TutorialOverlay.gd`

### Step 2: Build UI Hierarchy

```
TutorialOverlay (CanvasLayer) [layer = 100]
├── TutorialPanel (Panel)
│   └── VBoxContainer [margins: 20px all sides]
│       ├── ProgressLabel (Label) [align: center, size: 14]
│       ├── TitleLabel (Label) [align: center, size: 24, color: #3399FF]
│       ├── Control (spacer, min_size: 0x10)
│       ├── MessageLabel (RichTextLabel) [bbcode: true, fit_content: true]
│       ├── Control (spacer, min_size: 0x10)
│       └── ButtonContainer (HBoxContainer) [alignment: center]
│           ├── SkipButton (Button) [text: "Skip Tutorial", size: 150x40, color: #FF4444]
│           ├── Control (spacer, min_size: 20x0)
│           └── ContinueButton (Button) [text: "Continue (Enter)", size: 150x40, color: #44FF44]
├── ConfirmationDialog
│   ├── title: "Skip Tutorial?"
│   ├── dialog_text: "Are you sure...?"
│   └── ok_button_text: "Skip Tutorial"
└── HighlightOverlay (Control) [mouse_filter: IGNORE]
```

### Step 3: Configure TutorialPanel

**Panel Properties:**
- **Size**: 600x300 (custom_minimum_size)
- **Position**: Anchored to top-center
  - anchor_left: 0.5
  - anchor_right: 0.5
  - anchor_top: 0.1
  - offset_left: -300
  - offset_right: 300
  - offset_bottom: 300
- **Theme**: Create custom theme with:
  - Panel background: semi-transparent dark (#000000AA)
  - Border: 2px solid (#3399FF)
  - Corner radius: 10px

### Step 4: Add to Main Scene

1. Open `Main.tscn`
2. Add TutorialOverlay as child:
   - Right-click root node → **Add Child Node**
   - Select **Instantiate Child Scene**
   - Choose `TutorialOverlay.tscn`
3. Ensure it's **last child** (renders on top)

### Step 5: Test

Run game and verify:
- ✅ Tutorial panel appears after 2 seconds
- ✅ Skip button shows confirmation dialog
- ✅ Continue button advances steps
- ✅ Panel hides on completion
- ✅ Keyboard shortcuts work (Enter, ESC)

---

## Styling Guide

### Color Scheme

```gdscript
# Tutorial Colors
TITLE_COLOR = Color(0.2, 0.6, 1.0)       # #3399FF - Blue
CONTINUE_COLOR = Color(0.3, 1.0, 0.3)    # #44FF44 - Green
SKIP_COLOR = Color(1.0, 0.3, 0.3)        # #FF4444 - Red
PANEL_BG = Color(0, 0, 0, 0.85)          # #000000DD - Dark semi-transparent
BORDER_COLOR = Color(0.2, 0.6, 1.0)      # #3399FF - Blue
```

### Font Sizes

- **Title**: 24px (bold)
- **Message**: 16px (regular)
- **Progress**: 14px (italic)
- **Buttons**: 14px (bold)

### Animations (Optional)

Add fade-in/fade-out transitions:

```gdscript
func show_tutorial_panel() -> void:
	if tutorial_panel:
		tutorial_panel.modulate = Color(1, 1, 1, 0)  # Start transparent
		tutorial_panel.visible = true

		# Fade in over 0.3 seconds
		var tween = create_tween()
		tween.tween_property(tutorial_panel, "modulate", Color(1, 1, 1, 1), 0.3)

func hide_tutorial_panel() -> void:
	if tutorial_panel:
		# Fade out over 0.2 seconds
		var tween = create_tween()
		tween.tween_property(tutorial_panel, "modulate", Color(1, 1, 1, 0), 0.2)
		tween.tween_callback(func(): tutorial_panel.visible = false)
```

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Enter** | Continue to next step |
| **Space** | Continue to next step |
| **ESC** | Open skip confirmation |

Implemented in `TutorialOverlay._input()`.

---

## Customization Options

### Position Variants

**Top Center** (default):
```gdscript
panel.anchor_top = 0.1
panel.anchor_bottom = 0.1
```

**Bottom Center**:
```gdscript
panel.anchor_top = 0.9
panel.anchor_bottom = 0.9
panel.offset_top = -300
panel.offset_bottom = 0
```

**Center Screen**:
```gdscript
panel.anchor_left = 0.5
panel.anchor_right = 0.5
panel.anchor_top = 0.5
panel.anchor_bottom = 0.5
panel.offset_left = -300
panel.offset_right = 300
panel.offset_top = -150
panel.offset_bottom = 150
```

### Size Variants

**Compact** (400x200):
```gdscript
panel.custom_minimum_size = Vector2(400, 200)
panel.offset_left = -200
panel.offset_right = 200
```

**Large** (800x400):
```gdscript
panel.custom_minimum_size = Vector2(800, 400)
panel.offset_left = -400
panel.offset_right = 400
```

---

## Testing Checklist

- [ ] Tutorial panel appears 2s after game start
- [ ] Title and message display correctly
- [ ] Step counter shows "Step X / 26"
- [ ] Continue button advances tutorial
- [ ] Continue button hidden during action steps
- [ ] Skip button shows confirmation dialog
- [ ] Dialog "Skip Tutorial" button works
- [ ] Dialog "Continue Tutorial" button cancels skip
- [ ] Panel hides when tutorial completes
- [ ] Panel hides when tutorial skipped
- [ ] Enter key advances steps
- [ ] ESC key opens skip dialog
- [ ] No $50M reward when tutorial skipped
- [ ] $50M reward given when tutorial completed

---

## Troubleshooting

### Panel Not Showing

**Check:**
1. TutorialOverlay is in scene tree
2. CanvasLayer.layer = 100 (above game UI)
3. Tutorial manager initialized (`GameData.tutorial_manager`)
4. Tutorial auto-starts (`GameData.is_first_time_player = true`)

**Debug:**
```gdscript
print("Tutorial manager: ", GameData.tutorial_manager)
print("Tutorial active: ", GameData.tutorial_manager.is_active())
print("Current step: ", GameData.tutorial_manager.get_current_step())
```

### Buttons Not Working

**Check:**
1. Button signals connected in `_ready()`
2. Buttons have `custom_minimum_size` set
3. Buttons not disabled

**Debug:**
```gdscript
print("Continue button: ", continue_button)
print("Skip button: ", skip_button)
```

### Skip Confirmation Not Showing

**Check:**
1. ConfirmationDialog in scene tree
2. Dialog is child of overlay (not panel)
3. Dialog.confirmed signal connected

---

## Future Enhancements

### Step Indicators

Add dots showing progress:
```
● ● ● ○ ○ ○ ○ ○  (Step 3/8)
```

### Action Hints

Show visual hints during action steps:
```
→ Click the Fleet tab
→ Select an aircraft
→ Press Purchase button
```

### Highlight System

Implement visual highlights for UI elements:
- Pulsing border around target element
- Arrow pointing to element
- Dim background except highlighted area

### Animated Mascot

Add animated character guide:
- Plane icon that "speaks" tutorial messages
- Different expressions for tips/warnings
- Celebration animation on completion

---

## Summary

The skip tutorial button provides:
- ✅ **Easy opt-out** for experienced players
- ✅ **Safety confirmation** to prevent accidental skips
- ✅ **Clear warning** about missing $50M reward
- ✅ **Keyboard shortcuts** (ESC to skip)
- ✅ **Clean integration** with existing tutorial system

Use **Option 1** for quick setup via code, or **Option 2** for full scene-based UI customization!
