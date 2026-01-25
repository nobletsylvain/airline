extends Control
class_name RouteDifficultyPanel

## Panel showing route creation difficulty breakdown
## Embedded in RouteConfigDialog to show difficulty factors

signal negotiation_requested()

# UI Elements
var difficulty_score_label: Label
var difficulty_bar: ProgressBar
var factors_vbox: VBoxContainer
var creation_cost_label: Label
var negotiate_button: Button
var warning_label: Label

# Data
var from_airport: Airport = null
var to_airport: Airport = null
var difficulty_score: float = 0.0
var creation_cost: float = 0.0
var difficulty_factors: Array[Dictionary] = []

func _ready() -> void:
	build_ui()

func build_ui() -> void:
	"""Build the difficulty panel UI"""
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)

	# Title - Enhanced styling
	var title = Label.new()
	title.text = "Route Creation Difficulty"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(title)

	# Difficulty score and bar
	var score_hbox = HBoxContainer.new()
	score_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(score_hbox)

	difficulty_score_label = Label.new()
	difficulty_score_label.text = "Difficulty: 0/100"
	difficulty_score_label.add_theme_font_size_override("font_size", 14)
	difficulty_score_label.custom_minimum_size = Vector2(150, 0)
	score_hbox.add_child(difficulty_score_label)

	difficulty_bar = ProgressBar.new()
	difficulty_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	difficulty_bar.max_value = 100.0
	difficulty_bar.show_percentage = false
	difficulty_bar.custom_minimum_size = Vector2(0, 24)

	# Style the progress bar
	var bg_style = UITheme.create_progress_bar_style(false)
	difficulty_bar.add_theme_stylebox_override("background", bg_style)

	var fill_style = UITheme.create_progress_bar_style(true, Color.ORANGE)
	difficulty_bar.add_theme_stylebox_override("fill", fill_style)

	score_hbox.add_child(difficulty_bar)

	# Difficulty factors
	var factors_label = Label.new()
	factors_label.text = "Difficulty Factors:"
	factors_label.add_theme_font_size_override("font_size", 12)
	factors_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	vbox.add_child(factors_label)

	factors_vbox = VBoxContainer.new()
	factors_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(factors_vbox)

	# Creation cost
	creation_cost_label = Label.new()
	creation_cost_label.add_theme_font_size_override("font_size", 14)
	creation_cost_label.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(creation_cost_label)

	# Warning label
	warning_label = Label.new()
	warning_label.add_theme_font_size_override("font_size", 12)
	warning_label.add_theme_color_override("font_color", UITheme.ERROR_COLOR)
	warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning_label.visible = false
	vbox.add_child(warning_label)

	# Negotiate button - Enhanced secondary button style
	negotiate_button = Button.new()
	negotiate_button.text = "🤝 Use Delegate for Negotiation"
	negotiate_button.custom_minimum_size = Vector2(0, 40)
	negotiate_button.add_theme_font_size_override("font_size", 13)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0, 0, 0, 0)  # Transparent
	btn_style.border_color = UITheme.PRIMARY_BLUE
	btn_style.set_border_width_all(1.5)
	btn_style.set_corner_radius_all(10)
	btn_style.set_content_margin_all(12)
	negotiate_button.add_theme_stylebox_override("normal", btn_style)
	negotiate_button.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.231, 0.510, 0.965, 0.1)  # Light blue background
	btn_hover.border_color = UITheme.PRIMARY_BLUE
	btn_hover.set_border_width_all(1.5)
	btn_hover.set_corner_radius_all(10)
	btn_hover.set_content_margin_all(12)
	negotiate_button.add_theme_stylebox_override("hover", btn_hover)
	negotiate_button.add_theme_color_override("font_hover_color", UITheme.PRIMARY_BLUE_DARK)
	
	negotiate_button.pressed.connect(_on_negotiate_pressed)
	vbox.add_child(negotiate_button)

func update_difficulty(from: Airport, to: Airport) -> void:
	"""Update difficulty display for route"""
	from_airport = from
	to_airport = to

	if not from_airport or not to_airport:
		return

	# Calculate difficulty (placeholder - will be replaced with actual calculation)
	difficulty_score = _calculate_difficulty()
	creation_cost = _calculate_creation_cost()

	# Update UI
	_update_difficulty_display()
	_update_factors()
	_update_warnings()

func _calculate_difficulty() -> float:
	"""Calculate route difficulty score (0-100)"""
	if not GameData.player_airline or not from_airport or not to_airport:
		return 50.0

	var base_difficulty = 50.0

	# Distance factor
	var distance = GameData.calculate_distance(from_airport, to_airport)
	if distance > 10000:
		base_difficulty += 10.0
	elif distance < 2000:
		base_difficulty -= 5.0

	# Airport size factor (using hub_tier instead of size)
	if to_airport.hub_tier <= 1:  # Mega hub
		base_difficulty += 15.0
	elif to_airport.hub_tier >= 4:  # Small airport
		base_difficulty -= 10.0

	# Country relationship factor
	var to_country_code = to_airport.country
	if not to_country_code.is_empty():
		# Normalize country code for lookup
		var normalized_code = _normalize_country_code(to_country_code)
		var relationship = GameData.calculate_country_relationship(GameData.player_airline.id, normalized_code)
		# Relationship affects difficulty: -30 to +30 points
		var relationship_modifier = (relationship / 100.0) * -30.0  # Positive relationship reduces difficulty
		base_difficulty += relationship_modifier

	# Market share factor
	var market_share_bonus = _calculate_market_share_difficulty_reduction(to_airport)
	base_difficulty -= market_share_bonus

	# Delegate negotiation discount
	var negotiation_task = GameData.player_airline.get_delegate_task_for_route(from_airport, to_airport)
	if negotiation_task and negotiation_task.is_completed():
		base_difficulty -= negotiation_task.difficulty_reduction

	return clamp(base_difficulty, 0.0, 100.0)

func _calculate_market_share_difficulty_reduction(airport: Airport) -> float:
	"""Calculate difficulty reduction from market share in destination country"""
	if not GameData.player_airline:
		return 0.0
	
	var country_code = airport.country
	if country_code.is_empty():
		return 0.0
	
	var normalized_code = _normalize_country_code(country_code)
	
	# Count routes to this country
	var routes_to_country = 0
	var total_routes_to_country = 0
	
	for route in GameData.player_airline.routes:
		if route.to_airport:
			var route_country = _normalize_country_code(route.to_airport.country)
			if route_country == normalized_code:
				routes_to_country += 1
	
	for airline in GameData.airlines:
		for route in airline.routes:
			if route.to_airport:
				var route_country = _normalize_country_code(route.to_airport.country)
				if route_country == normalized_code:
					total_routes_to_country += 1
	
	if total_routes_to_country == 0:
		return 0.0
	
	var market_share = float(routes_to_country) / float(total_routes_to_country)
	# Market share reduces difficulty: up to -15 points for 100% market share
	return market_share * 15.0

func _calculate_creation_cost() -> float:
	"""Calculate route creation cost"""
	# TODO: Implement actual cost calculation
	# Base cost + difficulty modifier
	var base_cost = 100000.0
	var difficulty_multiplier = 1.0 + (difficulty_score / 100.0) * 2.0
	return base_cost * difficulty_multiplier

func _update_difficulty_display() -> void:
	"""Update difficulty score display"""
	difficulty_score_label.text = "Difficulty: %.0f/100" % difficulty_score
	difficulty_bar.value = difficulty_score

	# Color code based on difficulty
	var difficulty_color: Color
	if difficulty_score < 30:
		difficulty_color = UITheme.PROFIT_COLOR  # Green - Easy
	elif difficulty_score < 60:
		difficulty_color = UITheme.WARNING_COLOR  # Yellow - Medium
	else:
		difficulty_color = UITheme.ERROR_COLOR  # Red - Hard

	var fill_style = UITheme.create_progress_bar_style(true, difficulty_color)
	difficulty_bar.add_theme_stylebox_override("fill", fill_style)

	# Update creation cost
	creation_cost_label.text = "Creation Cost: %s" % UITheme.format_money(creation_cost)

func _update_factors() -> void:
	"""Update difficulty factors list"""
	# Clear existing factors
	for child in factors_vbox.get_children():
		child.queue_free()

	difficulty_factors.clear()

	# Add factors (placeholder - will be replaced with actual data)
	var distance = GameData.calculate_distance(from_airport, to_airport)
	difficulty_factors.append({
		"name": "Distance",
		"value": "+%.0f" % (distance / 1000.0),
		"color": UITheme.get_text_secondary()
	})

	if to_airport.hub_tier <= 1:  # Mega hub
		difficulty_factors.append({
			"name": "Airport Size",
			"value": "+15",
			"color": UITheme.WARNING_COLOR
		})
	elif to_airport.hub_tier >= 4:  # Small airport
		difficulty_factors.append({
			"name": "Airport Size",
			"value": "-10",
			"color": UITheme.PROFIT_COLOR
		})

	# Country relationship factors
	if GameData.player_airline and to_airport:
		var to_country_code = to_airport.country
		if not to_country_code.is_empty():
			var normalized_code = _normalize_country_code(to_country_code)
			var relationship = GameData.calculate_country_relationship(GameData.player_airline.id, normalized_code)
			var relationship_modifier = (relationship / 100.0) * -30.0
			if relationship_modifier != 0.0:
				var country = GameData.get_country_by_code(normalized_code)
				var country_name = country.name if country else to_country_code
				var value_str = "%.0f" % relationship_modifier
				var color = UITheme.PROFIT_COLOR if relationship_modifier < 0 else UITheme.WARNING_COLOR
				difficulty_factors.append({
					"name": "Relationship (%s)" % country_name,
					"value": value_str,
					"color": color
				})
	
	# Market share factors
	if GameData.player_airline and to_airport:
		var market_share_reduction = _calculate_market_share_difficulty_reduction(to_airport)
		if market_share_reduction > 0.0:
			difficulty_factors.append({
				"name": "Market Share",
				"value": "-%.0f" % market_share_reduction,
				"color": UITheme.PROFIT_COLOR
			})
	
	# Add helper function for country code normalization
func _normalize_country_code(code: String) -> String:
	"""Normalize country code (same as GameData)"""
	var code_map = {
		"USA": "US",
		"United States": "US",
		"UK": "GB",
		"United Kingdom": "GB",
		"UAE": "AE",
		"United Arab Emirates": "AE",
		"South Korea": "KR",
		"Korea": "KR",
	}
	if code_map.has(code):
		return code_map[code]
	if code.length() == 2:
		return code.to_upper()
	return code.substr(0, 2).to_upper()
	
	# Delegate negotiation discounts
	if GameData.player_airline:
		var negotiation_task = GameData.player_airline.get_delegate_task_for_route(from_airport, to_airport)
		if negotiation_task:
			if negotiation_task.is_completed():
				difficulty_factors.append({
					"name": "Delegate Negotiation",
					"value": "-%.0f" % negotiation_task.difficulty_reduction,
					"color": UITheme.PROFIT_COLOR
				})
			else:
				difficulty_factors.append({
					"name": "Negotiation in Progress",
					"value": "%.0f%%" % negotiation_task.get_progress_percent(),
					"color": UITheme.WARNING_COLOR
				})

	# Display factors
	for factor in difficulty_factors:
		var factor_hbox = HBoxContainer.new()
		factor_hbox.add_theme_constant_override("separation", 8)
		factors_vbox.add_child(factor_hbox)

		var name_label = Label.new()
		name_label.text = factor.get("name", "Unknown")
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", UITheme.get_text_secondary())
		name_label.custom_minimum_size = Vector2(120, 0)
		factor_hbox.add_child(name_label)

		var value_label = Label.new()
		value_label.text = factor.get("value", "0")
		value_label.add_theme_font_size_override("font_size", 11)
		value_label.add_theme_color_override("font_color", factor.get("color", UITheme.get_text_primary()))
		factor_hbox.add_child(value_label)

func _update_warnings() -> void:
	"""Update warning messages"""
	warning_label.visible = false
	warning_label.text = ""

	# Check if difficulty too high
	if difficulty_score >= 80:
		warning_label.text = "⚠ Warning: Very high difficulty. Consider using delegate negotiation or improving country relationships first."
		warning_label.visible = true
	elif difficulty_score >= 60:
		warning_label.text = "⚠ High difficulty. Delegate negotiation recommended."
		warning_label.visible = true

	# Check if insufficient funds
	if GameData.player_airline and GameData.player_airline.balance < creation_cost:
		var funds_warning = "\n⚠ Insufficient funds. Need %s more." % UITheme.format_money(creation_cost - GameData.player_airline.balance)
		warning_label.text += funds_warning
		warning_label.visible = true

func _on_negotiate_pressed() -> void:
	"""Handle negotiate button press"""
	negotiation_requested.emit()

func set_negotiation_discount(discount_percent: float) -> void:
	"""Apply negotiation discount"""
	# TODO: Apply discount to difficulty and cost
	# For now, just reduce difficulty
	difficulty_score = max(0.0, difficulty_score - discount_percent)
	creation_cost = creation_cost * (1.0 - discount_percent / 100.0)
	_update_difficulty_display()

func can_create_route() -> bool:
	"""Check if route can be created"""
	if difficulty_score >= 100:
		return false
	if GameData.player_airline and GameData.player_airline.balance < creation_cost:
		return false
	return true
