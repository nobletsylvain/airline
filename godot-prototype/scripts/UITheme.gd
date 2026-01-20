extends Node
class_name UITheme

## Centralized UI Theme - Colors, Fonts, and Style Constants
## Based on Figma mockup design - Modern airline tycoon dashboard

# ============================================================================
# COLOR PALETTE - Matching Figma mockup (Tailwind-inspired)
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

# UI Element Colors
const HUB_COLOR = Color("#eab308")           # Yellow-500 - Player hubs
const PLAYER_ROUTE_COLOR = Color("#3b82f6")  # Blue-500 - Player routes
const COMPETITOR_ROUTE_COLOR = Color("#94a3b8") # Slate-400 - Competitor routes
const SELECTED_COLOR = Color("#dbeafe")      # Blue-100 - Selected items
const HOVER_COLOR = Color("#f8fafc")         # Slate-50 - Hovered items

# Grade Badge Colors
const GRADE_S_COLOR = Color("#eab308")       # Yellow-500 - S rank (gold)
const GRADE_A_COLOR = Color("#8b5cf6")       # Violet-500 - A rank
const GRADE_B_COLOR = Color("#3b82f6")       # Blue-500 - B rank
const GRADE_C_COLOR = Color("#10b981")       # Emerald-500 - C rank
const GRADE_NEW_COLOR = Color("#94a3b8")     # Slate-400 - New

# Sidebar Colors (Dark theme)
const SIDEBAR_BG = Color("#0f172a")          # Slate-900 - Sidebar background
const SIDEBAR_ACTIVE = Color("#3b82f6")      # Blue-500 - Active nav item
const SIDEBAR_HOVER = Color("#1e293b")       # Slate-800 - Hover state
const SIDEBAR_TEXT = Color("#94a3b8")        # Slate-400 - Inactive text
const SIDEBAR_TEXT_ACTIVE = Color("#ffffff") # White - Active text

# Panel Colors (Light theme - for main content)
const PANEL_BG_COLOR = Color("#ffffff")      # White - Card background
const PANEL_BORDER_COLOR = Color("#e2e8f0")  # Slate-200 - Subtle border
const CARD_BG_COLOR = Color("#ffffff")       # White - Card background
const CARD_HOVER_BG = Color("#f8fafc")       # Slate-50 - Card hover
const CARD_SELECTED_BG = Color("#eff6ff")    # Blue-50 - Card selected
const CARD_BORDER = Color("#e2e8f0")         # Slate-200 - Card border

# Dark Panel Colors (for overlays, floating panels)
const DARK_PANEL_BG = Color("#0f172a")       # Slate-900 - Dark background
const DARK_PANEL_BORDER = Color("#334155")   # Slate-700 - Dark border
const DARK_CARD_BG = Color("#1e293b")        # Slate-800 - Dark card

# Text Colors
const TEXT_PRIMARY = Color("#1e293b")        # Slate-800 - Primary text (dark)
const TEXT_SECONDARY = Color("#64748b")      # Slate-500 - Secondary text
const TEXT_MUTED = Color("#94a3b8")          # Slate-400 - Muted text
const TEXT_ACCENT = Color("#3b82f6")         # Blue-500 - Accent text
const TEXT_WHITE = Color("#ffffff")          # White - Light on dark
const TEXT_LIGHT = Color("#f1f5f9")          # Slate-100 - Light text

# Background Colors
const BG_MAIN = Color("#f8fafc")             # Slate-50 - Main area background
const BG_DARK = Color("#0f172a")             # Slate-900 - Dark background

# ============================================================================
# SIZING CONSTANTS
# ============================================================================

const CARD_MIN_HEIGHT = 80
const CARD_PADDING = 16
const CARD_MARGIN = 12
const CARD_BORDER_RADIUS = 16               # Rounded-2xl equivalent

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
const SIDEBAR_WIDTH = 256                   # w-64 equivalent

# ============================================================================
# FONT SIZES
# ============================================================================

const FONT_SIZE_TITLE = 24                  # text-2xl
const FONT_SIZE_HEADER = 18                 # text-lg
const FONT_SIZE_BODY = 14                   # text-sm
const FONT_SIZE_SMALL = 12                  # text-xs
const FONT_SIZE_TINY = 10

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

static func get_profit_color(value: float) -> Color:
	"""Get color based on profit/loss value"""
	if value > 0:
		return PROFIT_COLOR
	elif value < 0:
		return LOSS_COLOR
	else:
		return NEUTRAL_COLOR

static func get_profit_color_lerped(value: float, max_value: float = 100000.0) -> Color:
	"""Get color interpolated based on profit magnitude"""
	var normalized = clamp(abs(value) / max_value, 0.0, 1.0)
	if value > 0:
		return NEUTRAL_COLOR.lerp(PROFIT_COLOR, normalized)
	elif value < 0:
		return NEUTRAL_COLOR.lerp(LOSS_COLOR, normalized)
	else:
		return NEUTRAL_COLOR

static func get_grade_color(grade: String) -> Color:
	"""Get color for airline grade"""
	match grade.to_upper():
		"S", "S+": return GRADE_S_COLOR
		"A", "A+": return GRADE_A_COLOR
		"B", "B+": return GRADE_B_COLOR
		"C", "C+": return GRADE_C_COLOR
		_: return GRADE_NEW_COLOR

static func get_load_factor_color(load_factor: float) -> Color:
	"""Get color based on load factor percentage (0-100)"""
	if load_factor >= 85:
		return PROFIT_COLOR  # Excellent
	elif load_factor >= 70:
		return Color("#84cc16")  # Lime-500 - Good
	elif load_factor >= 50:
		return WARNING_COLOR  # Moderate
	else:
		return LOSS_COLOR  # Poor

static func get_condition_color(condition: float) -> Color:
	"""Get color based on aircraft condition percentage (0-100)"""
	if condition >= 80:
		return PROFIT_COLOR
	elif condition >= 50:
		return WARNING_COLOR
	else:
		return LOSS_COLOR

# ============================================================================
# UI COMPONENT FACTORIES - Light Theme (Main Content)
# ============================================================================

static func create_panel_style() -> StyleBoxFlat:
	"""Create standard light panel style"""
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL_BG_COLOR
	style.border_color = PANEL_BORDER_COLOR
	style.set_border_width_all(1)
	style.set_corner_radius_all(PANEL_BORDER_RADIUS)
	style.set_content_margin_all(PANEL_PADDING)
	style.shadow_color = Color(0, 0, 0, 0.05)
	style.shadow_size = 4
	return style

static func create_card_style(selected: bool = false, profit: float = 0.0) -> StyleBoxFlat:
	"""Create card style with optional selection and profit border"""
	var style = StyleBoxFlat.new()
	style.bg_color = CARD_SELECTED_BG if selected else CARD_BG_COLOR
	style.set_corner_radius_all(CARD_BORDER_RADIUS)
	style.set_content_margin_all(CARD_PADDING)
	style.shadow_color = Color(0, 0, 0, 0.05)
	style.shadow_size = 2

	# Profit-colored left border
	if profit != 0:
		style.border_color = get_profit_color(profit)
		style.border_width_left = 4
	else:
		style.border_color = CARD_BORDER
		style.set_border_width_all(1)

	return style

static func create_kpi_card_style(accent_color: Color = PRIMARY_BLUE) -> StyleBoxFlat:
	"""Create KPI card style (white card with colored accent)"""
	var style = StyleBoxFlat.new()
	style.bg_color = CARD_BG_COLOR
	style.border_color = CARD_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(CARD_BORDER_RADIUS)
	style.set_content_margin_all(20)
	style.shadow_color = Color(0, 0, 0, 0.05)
	style.shadow_size = 4
	return style

# ============================================================================
# UI COMPONENT FACTORIES - Dark Theme (Sidebar, Overlays)
# ============================================================================

static func create_sidebar_style() -> StyleBoxFlat:
	"""Create dark sidebar style"""
	var style = StyleBoxFlat.new()
	style.bg_color = SIDEBAR_BG
	style.border_color = Color("#1e293b")  # Slate-800
	style.border_width_right = 1
	return style

static func create_sidebar_button_style(active: bool = false) -> StyleBoxFlat:
	"""Create sidebar navigation button style"""
	var style = StyleBoxFlat.new()
	if active:
		style.bg_color = SIDEBAR_ACTIVE
		style.shadow_color = Color(0.231, 0.510, 0.965, 0.3)  # Blue glow
		style.shadow_size = 8
	else:
		style.bg_color = Color(0, 0, 0, 0)  # Transparent
	style.set_corner_radius_all(12)
	style.set_content_margin_all(12)
	return style

static func create_floating_panel_style() -> StyleBoxFlat:
	"""Create floating panel style (dark, semi-transparent)"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(DARK_PANEL_BG.r, DARK_PANEL_BG.g, DARK_PANEL_BG.b, 0.95)
	style.border_color = DARK_PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(20)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 16
	style.shadow_offset = Vector2(0, 8)
	return style

static func create_menu_panel_style() -> StyleBoxFlat:
	"""Create main menu panel style (dark, glass-like)"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)
	style.border_color = Color(1, 1, 1, 0.1)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(32)
	return style

# ============================================================================
# BUTTON STYLES
# ============================================================================

static func create_button_style(accent: bool = false) -> StyleBoxFlat:
	"""Create button style"""
	var style = StyleBoxFlat.new()
	if accent:
		style.bg_color = PRIMARY_BLUE
	else:
		style.bg_color = Color("#f1f5f9")  # Slate-100
	style.set_corner_radius_all(BUTTON_BORDER_RADIUS)
	style.set_content_margin_all(10)
	return style

static func create_primary_button_style() -> StyleBoxFlat:
	"""Create primary action button (blue)"""
	var style = StyleBoxFlat.new()
	style.bg_color = PRIMARY_BLUE
	style.set_corner_radius_all(BUTTON_BORDER_RADIUS)
	style.set_content_margin_all(12)
	style.shadow_color = Color(0.231, 0.510, 0.965, 0.3)
	style.shadow_size = 8
	return style

static func create_secondary_button_style() -> StyleBoxFlat:
	"""Create secondary button (transparent with border)"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(1, 1, 1, 0.2)
	style.set_border_width_all(1)
	style.set_corner_radius_all(BUTTON_BORDER_RADIUS)
	style.set_content_margin_all(12)
	return style

static func create_menu_button_style() -> StyleBoxFlat:
	"""Create main menu button style"""
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
	"""Create progress bar background or fill style"""
	var style = StyleBoxFlat.new()
	if filled:
		style.bg_color = color
	else:
		style.bg_color = Color("#e2e8f0")  # Slate-200
	style.set_corner_radius_all(4)
	return style

# ============================================================================
# BADGE/TAG STYLES
# ============================================================================

static func create_badge_style(color: Color) -> StyleBoxFlat:
	"""Create status badge style"""
	var style = StyleBoxFlat.new()
	# Use lighter version of color for background
	style.bg_color = Color(color.r, color.g, color.b, 0.15)
	style.set_corner_radius_all(9999)  # Fully rounded
	style.set_content_margin_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	return style

# ============================================================================
# LABEL HELPERS
# ============================================================================

static func style_label(label: Label, size: int = FONT_SIZE_BODY, color: Color = TEXT_PRIMARY) -> void:
	"""Apply standard styling to a label"""
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)

static func create_styled_label(text: String, size: int = FONT_SIZE_BODY, color: Color = TEXT_PRIMARY) -> Label:
	"""Create a new styled label"""
	var label = Label.new()
	label.text = text
	style_label(label, size, color)
	return label

static func format_money(amount: float, show_sign: bool = false) -> String:
	"""Format money with appropriate suffix"""
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
	"""Format large numbers with suffix"""
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
