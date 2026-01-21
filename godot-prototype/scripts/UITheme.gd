extends Node
class_name UITheme

## Centralized UI Theme - Colors, Fonts, and Style Constants
## Supports Dark/Light theme toggle
## Based on Figma mockup design - Modern airline tycoon dashboard

# ============================================================================
# THEME MODE
# ============================================================================

enum ThemeMode { LIGHT, DARK }

static var current_theme: ThemeMode = ThemeMode.LIGHT
static var theme_changed_callbacks: Array[Callable] = []

static func set_theme(mode: ThemeMode) -> void:
	"""Set the current theme and notify listeners"""
	if current_theme != mode:
		current_theme = mode
		for callback in theme_changed_callbacks:
			if callback.is_valid():
				callback.call()

static func toggle_theme() -> void:
	"""Toggle between light and dark themes"""
	if current_theme == ThemeMode.LIGHT:
		set_theme(ThemeMode.DARK)
	else:
		set_theme(ThemeMode.LIGHT)

static func is_dark_mode() -> bool:
	"""Check if dark mode is active"""
	return current_theme == ThemeMode.DARK

static func register_theme_callback(callback: Callable) -> void:
	"""Register a callback to be called when theme changes"""
	if callback not in theme_changed_callbacks:
		theme_changed_callbacks.append(callback)

static func unregister_theme_callback(callback: Callable) -> void:
	"""Unregister a theme change callback"""
	theme_changed_callbacks.erase(callback)

# ============================================================================
# COLOR PALETTE - Base Colors (unchanged by theme)
# ============================================================================

# Primary Brand Colors
const PRIMARY_BLUE = Color("#3b82f6")        # Blue-500 - Primary accent
const PRIMARY_BLUE_DARK = Color("#2563eb")   # Blue-600 - Hover states
const PRIMARY_BLUE_LIGHT = Color("#60a5fa")  # Blue-400 - Light accent

# Profit/Loss Colors (Tailwind emerald/red)
const PROFIT_COLOR = Color("#10b981")        # Emerald-500 - Positive values
const PROFIT_COLOR_LIGHT = Color("#34d399")  # Emerald-400 - Light positive
const PROFIT_BG = Color("#ecfdf5")           # Emerald-50 - Background
const LOSS_COLOR = Color("#ef4444")          # Red-500 - Negative values
const LOSS_COLOR_LIGHT = Color("#f87171")    # Red-400 - Light negative
const LOSS_BG = Color("#fef2f2")             # Red-50 - Background
const NEUTRAL_COLOR = Color("#64748b")       # Slate-500 - Neutral/zero

# Status Colors
const INFO_COLOR = Color("#3b82f6")          # Blue-500 - Information
const WARNING_COLOR = Color("#f59e0b")       # Amber-500 - Warnings
const SUCCESS_COLOR = Color("#10b981")       # Emerald-500 - Success
const ERROR_COLOR = Color("#ef4444")         # Red-500 - Errors

# UI Element Colors (unchanged)
const HUB_COLOR = Color("#eab308")           # Yellow-500 - Player hubs
const PLAYER_ROUTE_COLOR = Color("#3b82f6")  # Blue-500 - Player routes
const COMPETITOR_ROUTE_COLOR = Color("#94a3b8") # Slate-400 - Competitor routes
const SELECTED_COLOR = Color("#dbeafe")      # Blue-100 - Selected items

# Grade Badge Colors
const GRADE_S_COLOR = Color("#eab308")       # Yellow-500 - S rank (gold)
const GRADE_A_COLOR = Color("#8b5cf6")       # Violet-500 - A rank
const GRADE_B_COLOR = Color("#3b82f6")       # Blue-500 - B rank
const GRADE_C_COLOR = Color("#10b981")       # Emerald-500 - C rank
const GRADE_NEW_COLOR = Color("#94a3b8")     # Slate-400 - New

# Sidebar Colors (Always dark)
const SIDEBAR_BG = Color("#0f172a")          # Slate-900 - Sidebar background
const SIDEBAR_ACTIVE = Color("#3b82f6")      # Blue-500 - Active nav item
const SIDEBAR_HOVER = Color("#1e293b")       # Slate-800 - Hover state
const SIDEBAR_TEXT = Color("#94a3b8")        # Slate-400 - Inactive text
const SIDEBAR_TEXT_ACTIVE = Color("#ffffff") # White - Active text

# ============================================================================
# THEME-DEPENDENT COLORS - Use these getters for dynamic theming
# ============================================================================

# Light Theme Colors
const LIGHT_BG_MAIN = Color("#f8fafc")       # Slate-50 - Main area background
const LIGHT_PANEL_BG = Color("#ffffff")      # White - Panel background
const LIGHT_PANEL_BORDER = Color("#e2e8f0")  # Slate-200 - Panel border
const LIGHT_CARD_BG = Color("#ffffff")       # White - Card background
const LIGHT_CARD_HOVER = Color("#f8fafc")    # Slate-50 - Card hover
const LIGHT_TEXT_PRIMARY = Color("#1e293b")  # Slate-800 - Primary text
const LIGHT_TEXT_SECONDARY = Color("#64748b") # Slate-500 - Secondary text
const LIGHT_TEXT_MUTED = Color("#94a3b8")    # Slate-400 - Muted text
const LIGHT_HOVER_COLOR = Color("#f8fafc")   # Slate-50 - Hovered items
const LIGHT_BUTTON_BG = Color("#f1f5f9")     # Slate-100 - Button background

# Dark Theme Colors
const DARK_BG_MAIN = Color("#0f172a")        # Slate-900 - Main area background
const DARK_PANEL_BG = Color("#1e293b")       # Slate-800 - Panel background
const DARK_PANEL_BORDER = Color("#334155")   # Slate-700 - Panel border
const DARK_CARD_BG = Color("#1e293b")        # Slate-800 - Card background
const DARK_CARD_HOVER = Color("#334155")     # Slate-700 - Card hover
const DARK_TEXT_PRIMARY = Color("#f1f5f9")   # Slate-100 - Primary text
const DARK_TEXT_SECONDARY = Color("#94a3b8") # Slate-400 - Secondary text
const DARK_TEXT_MUTED = Color("#64748b")     # Slate-500 - Muted text
const DARK_HOVER_COLOR = Color("#334155")    # Slate-700 - Hovered items
const DARK_BUTTON_BG = Color("#334155")      # Slate-700 - Button background

# Static getters for backwards compatibility (use themed versions below)
const TEXT_PRIMARY = Color("#1e293b")
const TEXT_SECONDARY = Color("#64748b")
const TEXT_MUTED = Color("#94a3b8")
const TEXT_ACCENT = Color("#3b82f6")
const TEXT_WHITE = Color("#ffffff")
const TEXT_LIGHT = Color("#f1f5f9")
const BG_MAIN = Color("#f8fafc")
const BG_DARK = Color("#0f172a")
const PANEL_BG_COLOR = Color("#ffffff")
const PANEL_BORDER_COLOR = Color("#e2e8f0")
const CARD_BG_COLOR = Color("#ffffff")
const CARD_HOVER_BG = Color("#f8fafc")
const CARD_SELECTED_BG = Color("#eff6ff")
const CARD_BORDER = Color("#e2e8f0")
const DARK_PANEL_BG_CONST = Color("#0f172a")
const DARK_PANEL_BORDER_CONST = Color("#334155")
const DARK_CARD_BG_CONST = Color("#1e293b")
const HOVER_COLOR = Color("#f8fafc")

# ============================================================================
# DYNAMIC COLOR GETTERS - Use these for theme-aware colors
# ============================================================================

static func get_bg_main() -> Color:
	return DARK_BG_MAIN if is_dark_mode() else LIGHT_BG_MAIN

static func get_panel_bg() -> Color:
	return DARK_PANEL_BG if is_dark_mode() else LIGHT_PANEL_BG

static func get_panel_border() -> Color:
	return DARK_PANEL_BORDER if is_dark_mode() else LIGHT_PANEL_BORDER

static func get_card_bg() -> Color:
	return DARK_CARD_BG if is_dark_mode() else LIGHT_CARD_BG

static func get_card_hover() -> Color:
	return DARK_CARD_HOVER if is_dark_mode() else LIGHT_CARD_HOVER

static func get_text_primary() -> Color:
	return DARK_TEXT_PRIMARY if is_dark_mode() else LIGHT_TEXT_PRIMARY

static func get_text_secondary() -> Color:
	return DARK_TEXT_SECONDARY if is_dark_mode() else LIGHT_TEXT_SECONDARY

static func get_text_muted() -> Color:
	return DARK_TEXT_MUTED if is_dark_mode() else LIGHT_TEXT_MUTED

static func get_hover_color() -> Color:
	return DARK_HOVER_COLOR if is_dark_mode() else LIGHT_HOVER_COLOR

static func get_button_bg() -> Color:
	return DARK_BUTTON_BG if is_dark_mode() else LIGHT_BUTTON_BG

static func get_button_text() -> Color:
	"""Get button text color based on theme"""
	return DARK_TEXT_PRIMARY if is_dark_mode() else LIGHT_TEXT_PRIMARY

# ============================================================================
# SIZING CONSTANTS
# ============================================================================

const CARD_MIN_HEIGHT = 80
const CARD_PADDING = 16
const CARD_MARGIN = 12
const CARD_BORDER_RADIUS = 16

const PANEL_PADDING = 24
const PANEL_MARGIN = 16
const PANEL_BORDER_RADIUS = 16

const BUTTON_HEIGHT = 40
const BUTTON_PADDING_H = 20
const BUTTON_PADDING_V = 10
const BUTTON_BORDER_RADIUS = 8

const FLOATING_PANEL_WIDTH = 320
const FLOATING_PANEL_MAX_HEIGHT = 400

const RIGHT_PANEL_WIDTH = 500
const SIDEBAR_WIDTH = 256

# ============================================================================
# FONT SIZES
# ============================================================================

const FONT_SIZE_TITLE = 24
const FONT_SIZE_HEADER = 18
const FONT_SIZE_BODY = 14
const FONT_SIZE_SMALL = 12
const FONT_SIZE_TINY = 10

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

static func get_profit_color(value: float) -> Color:
	if value > 0:
		return PROFIT_COLOR
	elif value < 0:
		return LOSS_COLOR
	else:
		return NEUTRAL_COLOR

static func get_profit_color_lerped(value: float, max_value: float = 100000.0) -> Color:
	var normalized = clamp(abs(value) / max_value, 0.0, 1.0)
	if value > 0:
		return NEUTRAL_COLOR.lerp(PROFIT_COLOR, normalized)
	elif value < 0:
		return NEUTRAL_COLOR.lerp(LOSS_COLOR, normalized)
	else:
		return NEUTRAL_COLOR

static func get_grade_color(grade: String) -> Color:
	match grade.to_upper():
		"S", "S+": return GRADE_S_COLOR
		"A", "A+": return GRADE_A_COLOR
		"B", "B+": return GRADE_B_COLOR
		"C", "C+": return GRADE_C_COLOR
		_: return GRADE_NEW_COLOR

static func get_load_factor_color(load_factor: float) -> Color:
	if load_factor >= 85:
		return PROFIT_COLOR
	elif load_factor >= 70:
		return Color("#84cc16")
	elif load_factor >= 50:
		return WARNING_COLOR
	else:
		return LOSS_COLOR

static func get_condition_color(condition: float) -> Color:
	if condition >= 80:
		return PROFIT_COLOR
	elif condition >= 50:
		return WARNING_COLOR
	else:
		return LOSS_COLOR

# ============================================================================
# UI COMPONENT FACTORIES - Theme-Aware
# ============================================================================

static func create_panel_style() -> StyleBoxFlat:
	"""Create standard panel style based on current theme"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_panel_bg()
	style.border_color = get_panel_border()
	style.set_border_width_all(1)
	style.set_corner_radius_all(PANEL_BORDER_RADIUS)
	style.set_content_margin_all(PANEL_PADDING)
	style.shadow_color = Color(0, 0, 0, 0.1 if is_dark_mode() else 0.05)
	style.shadow_size = 4
	return style

static func create_card_style(selected: bool = false, profit: float = 0.0) -> StyleBoxFlat:
	"""Create card style with optional selection and profit border"""
	var style = StyleBoxFlat.new()
	if selected:
		style.bg_color = CARD_SELECTED_BG if not is_dark_mode() else Color("#1e3a5f")
	else:
		style.bg_color = get_card_bg()
	style.set_corner_radius_all(CARD_BORDER_RADIUS)
	style.set_content_margin_all(CARD_PADDING)
	style.shadow_color = Color(0, 0, 0, 0.1 if is_dark_mode() else 0.05)
	style.shadow_size = 2

	if profit != 0:
		style.border_color = get_profit_color(profit)
		style.border_width_left = 4
	else:
		style.border_color = get_panel_border()
		style.set_border_width_all(1)

	return style

static func create_kpi_card_style(accent_color: Color = PRIMARY_BLUE) -> StyleBoxFlat:
	"""Create KPI card style"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_card_bg()
	style.border_color = get_panel_border()
	style.set_border_width_all(1)
	style.set_corner_radius_all(CARD_BORDER_RADIUS)
	style.set_content_margin_all(20)
	style.shadow_color = Color(0, 0, 0, 0.1 if is_dark_mode() else 0.05)
	style.shadow_size = 4
	return style

static func create_header_style() -> StyleBoxFlat:
	"""Create header bar style based on current theme"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_panel_bg()
	style.border_color = get_panel_border()
	style.border_width_bottom = 1
	style.shadow_color = Color(0, 0, 0, 0.1 if is_dark_mode() else 0.08)
	style.shadow_size = 4
	return style

static func create_bottom_bar_style() -> StyleBoxFlat:
	"""Create bottom bar style based on current theme"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_panel_bg()
	style.border_color = get_panel_border()
	style.border_width_top = 1
	return style

static func create_content_bg_style() -> StyleBoxFlat:
	"""Create main content background style"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_bg_main()
	return style

# Sidebar styles (always dark regardless of theme)
static func create_sidebar_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = SIDEBAR_BG
	style.border_color = Color("#1e293b")
	style.border_width_right = 1
	return style

static func create_sidebar_button_style(active: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	if active:
		style.bg_color = SIDEBAR_ACTIVE
		style.shadow_color = Color(0.231, 0.510, 0.965, 0.3)
		style.shadow_size = 8
	else:
		style.bg_color = Color(0, 0, 0, 0)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(12)
	return style

static func create_floating_panel_style() -> StyleBoxFlat:
	"""Create floating panel style (always dark for contrast)"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(DARK_BG_MAIN.r, DARK_BG_MAIN.g, DARK_BG_MAIN.b, 0.95)
	style.border_color = DARK_PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(20)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 16
	style.shadow_offset = Vector2(0, 8)
	return style

static func create_menu_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)
	style.border_color = Color(1, 1, 1, 0.1)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(32)
	return style

# ============================================================================
# BUTTON STYLES - Theme-Aware
# ============================================================================

static func create_button_style(accent: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	if accent:
		style.bg_color = PRIMARY_BLUE
	else:
		style.bg_color = get_button_bg()
	style.set_corner_radius_all(BUTTON_BORDER_RADIUS)
	style.set_content_margin_all(10)
	return style

static func create_button_hover_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_hover_color()
	style.set_corner_radius_all(BUTTON_BORDER_RADIUS)
	style.set_content_margin_all(10)
	return style

static func create_primary_button_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = PRIMARY_BLUE
	style.set_corner_radius_all(BUTTON_BORDER_RADIUS)
	style.set_content_margin_all(12)
	style.shadow_color = Color(0.231, 0.510, 0.965, 0.3)
	style.shadow_size = 8
	return style

static func create_secondary_button_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(1, 1, 1, 0.2) if is_dark_mode() else Color(0, 0, 0, 0.1)
	style.set_border_width_all(1)
	style.set_corner_radius_all(BUTTON_BORDER_RADIUS)
	style.set_content_margin_all(12)
	return style

static func create_menu_button_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.05)
	style.border_color = Color(1, 1, 1, 0.1)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	return style

# ============================================================================
# PROGRESS BAR STYLES
# ============================================================================

static func create_progress_bar_style(filled: bool = true, color: Color = PROFIT_COLOR) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	if filled:
		style.bg_color = color
	else:
		style.bg_color = get_panel_border()
	style.set_corner_radius_all(4)
	return style

# ============================================================================
# BADGE/TAG STYLES
# ============================================================================

static func create_badge_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.15)
	style.set_corner_radius_all(9999)
	style.set_content_margin_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	return style

# ============================================================================
# LABEL HELPERS
# ============================================================================

static func style_label(label: Label, size: int = FONT_SIZE_BODY, color: Color = Color.WHITE) -> void:
	label.add_theme_font_size_override("font_size", size)
	# Use themed color if default was passed
	var final_color = color
	if color == Color.WHITE:
		final_color = get_text_primary()
	label.add_theme_color_override("font_color", final_color)

static func create_styled_label(text: String, size: int = FONT_SIZE_BODY, color: Color = Color.WHITE) -> Label:
	var label = Label.new()
	label.text = text
	style_label(label, size, color)
	return label

static func format_money(amount: float, show_sign: bool = false) -> String:
	var sign_str = ""
	if show_sign and amount > 0:
		sign_str = "+"
	elif amount < 0:
		sign_str = "-"
		amount = abs(amount)

	if amount >= 1_000_000_000:
		return "%s$%.1fB" % [sign_str, amount / 1_000_000_000.0]
	elif amount >= 1_000_000:
		return "%s$%.1fM" % [sign_str, amount / 1_000_000.0]
	elif amount >= 1_000:
		return "%s$%.1fK" % [sign_str, amount / 1_000.0]
	else:
		return "%s$%.0f" % [sign_str, amount]

static func format_number(value: int) -> String:
	if value >= 1_000_000:
		return "%.1fM" % (value / 1_000_000.0)
	elif value >= 1_000:
		return "%.1fK" % (value / 1_000.0)
	else:
		return str(value)

# ============================================================================
# ICON HELPERS (Unicode symbols)
# ============================================================================

const ICON_PLANE = "✈"
const ICON_MONEY = "$"
const ICON_UP = "▲"
const ICON_DOWN = "▼"
const ICON_NEUTRAL = "─"
const ICON_CHECK = "✓"
const ICON_CROSS = "✗"
const ICON_STAR = "★"
const ICON_DIAMOND = "◆"
const ICON_CIRCLE = "●"
const ICON_CIRCLE_HALF = "◐"
const ICON_CIRCLE_EMPTY = "○"
const ICON_ARROW_RIGHT = "→"
const ICON_ARROW_UP_RIGHT = "↗"
const ICON_SUN = "☀"
const ICON_MOON = "🌙"
