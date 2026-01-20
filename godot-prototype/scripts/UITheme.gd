extends Node
class_name UITheme

## Centralized UI Theme - Colors, Fonts, and Style Constants
## Use UITheme.PROFIT_COLOR, UITheme.create_card(), etc.

# ============================================================================
# COLOR PALETTE
# ============================================================================

# Profit/Loss Colors
const PROFIT_COLOR = Color("#4CAF50")       # Green - positive values
const PROFIT_COLOR_LIGHT = Color("#81C784") # Light green - subtle positive
const LOSS_COLOR = Color("#F44336")         # Red - negative values
const LOSS_COLOR_LIGHT = Color("#E57373")   # Light red - subtle negative
const NEUTRAL_COLOR = Color("#9E9E9E")      # Gray - neutral/zero values

# Status Colors
const INFO_COLOR = Color("#2196F3")         # Blue - information
const WARNING_COLOR = Color("#FF9800")      # Orange - warnings
const SUCCESS_COLOR = Color("#4CAF50")      # Green - success (same as profit)
const ERROR_COLOR = Color("#F44336")        # Red - errors (same as loss)

# UI Element Colors
const HUB_COLOR = Color("#FFD700")          # Gold - player hubs
const PLAYER_ROUTE_COLOR = Color("#00BCD4") # Cyan - player routes
const COMPETITOR_ROUTE_COLOR = Color("#78909C") # Blue-gray - competitor routes
const SELECTED_COLOR = Color("#E1F5FE")     # Light blue - selected items
const HOVER_COLOR = Color("#F5F5F5")        # Light gray - hovered items

# Grade Badge Colors
const GRADE_S_COLOR = Color("#FFD700")      # Gold - S rank
const GRADE_A_COLOR = Color("#9C27B0")      # Purple - A rank
const GRADE_B_COLOR = Color("#2196F3")      # Blue - B rank
const GRADE_C_COLOR = Color("#4CAF50")      # Green - C rank
const GRADE_NEW_COLOR = Color("#9E9E9E")    # Gray - New

# Panel Colors
const PANEL_BG_COLOR = Color(0.12, 0.12, 0.14, 0.95)      # Dark background
const PANEL_BORDER_COLOR = Color(0.3, 0.3, 0.35, 1.0)     # Subtle border
const CARD_BG_COLOR = Color(0.15, 0.15, 0.18, 1.0)        # Card background
const CARD_HOVER_BG = Color(0.2, 0.2, 0.24, 1.0)          # Card hover
const CARD_SELECTED_BG = Color(0.2, 0.25, 0.35, 1.0)      # Card selected

# Text Colors
const TEXT_PRIMARY = Color(0.95, 0.95, 0.95)    # White - primary text
const TEXT_SECONDARY = Color(0.7, 0.7, 0.7)     # Gray - secondary text
const TEXT_MUTED = Color(0.5, 0.5, 0.5)         # Dark gray - muted text
const TEXT_ACCENT = Color(0.4, 0.7, 1.0)        # Light blue - accent text

# ============================================================================
# SIZING CONSTANTS
# ============================================================================

const CARD_MIN_HEIGHT = 80
const CARD_PADDING = 12
const CARD_MARGIN = 8
const CARD_BORDER_RADIUS = 8

const PANEL_PADDING = 16
const PANEL_MARGIN = 10

const BUTTON_HEIGHT = 36
const BUTTON_PADDING_H = 16
const BUTTON_PADDING_V = 8

const FLOATING_PANEL_WIDTH = 320
const FLOATING_PANEL_MAX_HEIGHT = 400

const RIGHT_PANEL_WIDTH = 500  # Reduced from 700

# ============================================================================
# FONT SIZES
# ============================================================================

const FONT_SIZE_TITLE = 20
const FONT_SIZE_HEADER = 16
const FONT_SIZE_BODY = 14
const FONT_SIZE_SMALL = 12
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
		return Color("#8BC34A")  # Good - lime green
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
# UI COMPONENT FACTORIES
# ============================================================================

static func create_panel_style() -> StyleBoxFlat:
	"""Create standard panel style"""
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL_BG_COLOR
	style.border_color = PANEL_BORDER_COLOR
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(PANEL_PADDING)
	return style

static func create_card_style(selected: bool = false, profit: float = 0.0) -> StyleBoxFlat:
	"""Create card style with optional selection and profit border"""
	var style = StyleBoxFlat.new()
	style.bg_color = CARD_SELECTED_BG if selected else CARD_BG_COLOR
	style.set_corner_radius_all(CARD_BORDER_RADIUS)
	style.set_content_margin_all(CARD_PADDING)

	# Profit-colored left border
	if profit != 0:
		style.border_color = get_profit_color(profit)
		style.border_width_left = 4
	else:
		style.border_color = PANEL_BORDER_COLOR
		style.set_border_width_all(1)

	return style

static func create_floating_panel_style() -> StyleBoxFlat:
	"""Create floating panel style (semi-transparent)"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
	style.border_color = Color(0.4, 0.4, 0.45, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	return style

static func create_button_style(accent: bool = false) -> StyleBoxFlat:
	"""Create button style"""
	var style = StyleBoxFlat.new()
	if accent:
		style.bg_color = INFO_COLOR
	else:
		style.bg_color = Color(0.25, 0.25, 0.3)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	return style

static func create_progress_bar_style(filled: bool = true) -> StyleBoxFlat:
	"""Create progress bar background or fill style"""
	var style = StyleBoxFlat.new()
	if filled:
		style.bg_color = PROFIT_COLOR
	else:
		style.bg_color = Color(0.2, 0.2, 0.25)
	style.set_corner_radius_all(4)
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
