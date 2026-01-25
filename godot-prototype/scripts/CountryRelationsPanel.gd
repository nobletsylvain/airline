extends Control
class_name CountryRelationsPanel

## Country Relationships Panel - View and manage diplomatic relationships

signal relationship_details_requested(country_code: String)

# UI Elements
var scroll_container: ScrollContainer
var main_vbox: VBoxContainer
var header_hbox: HBoxContainer
var home_country_label: Label
var countries_list: VBoxContainer
var search_field: LineEdit
var filter_buttons: HBoxContainer

# Data
var countries: Array[Dictionary] = []
var filtered_countries: Array[Dictionary] = []
var home_country_code: String = ""

func _ready() -> void:
	build_ui()
	load_countries()

func build_ui() -> void:
	"""Build the country relations panel UI"""
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var outer_vbox = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 16)
	margin.add_child(outer_vbox)

	# Header
	create_header(outer_vbox)

	# Search and filters
	create_search_and_filters(outer_vbox)

	# Scrollable countries list
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)

	main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 8)
	scroll_container.add_child(main_vbox)

	countries_list = VBoxContainer.new()
	countries_list.add_theme_constant_override("separation", 8)
	main_vbox.add_child(countries_list)

func create_header(parent: VBoxContainer) -> void:
	"""Create header section - Figma-inspired design"""
	header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 16)
	parent.add_child(header_hbox)

	# Title section with subtitle
	var title_vbox = VBoxContainer.new()
	title_vbox.add_theme_constant_override("separation", 4)
	header_hbox.add_child(title_vbox)

	var title = Label.new()
	title.text = "Country Relationships"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	title_vbox.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Manage diplomatic relations and international access"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_secondary())
	title_vbox.add_child(subtitle)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	# Home country display - Enhanced badge style
	var home_panel = PanelContainer.new()
	var home_style = StyleBoxFlat.new()
	home_style.bg_color = UITheme.get_panel_bg()
	home_style.border_color = UITheme.get_panel_border()
	home_style.set_border_width_all(1)
	home_style.set_corner_radius_all(12)
	home_style.set_content_margin_all(16)
	home_style.shadow_color = Color(0, 0, 0, 0.05)
	home_style.shadow_size = 2
	home_panel.add_theme_stylebox_override("panel", home_style)
	header_hbox.add_child(home_panel)

	var home_margin = MarginContainer.new()
	home_margin.add_theme_constant_override("margin_all", 12)
	home_panel.add_child(home_margin)

	var home_vbox = VBoxContainer.new()
	home_vbox.add_theme_constant_override("separation", 4)
	home_margin.add_child(home_vbox)

	var home_title = Label.new()
	home_title.text = "Home Country"
	home_title.add_theme_font_size_override("font_size", 11)
	home_title.add_theme_color_override("font_color", UITheme.get_text_muted())
	home_vbox.add_child(home_title)

	home_country_label = Label.new()
	home_country_label.text = "Not Set"
	home_country_label.add_theme_font_size_override("font_size", 14)
	home_country_label.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	home_vbox.add_child(home_country_label)

func create_search_and_filters(parent: VBoxContainer) -> void:
	"""Create search and filter controls - Figma-inspired design"""
	var search_panel = PanelContainer.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = UITheme.get_panel_bg()
	panel_style.border_color = UITheme.get_panel_border()
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(12)
	panel_style.set_content_margin_all(16)
	panel_style.shadow_color = Color(0, 0, 0, 0.05)
	panel_style.shadow_size = 2
	search_panel.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(search_panel)

	var search_margin = MarginContainer.new()
	search_margin.add_theme_constant_override("margin_all", 12)
	search_panel.add_child(search_margin)

	var search_vbox = VBoxContainer.new()
	search_vbox.add_theme_constant_override("separation", 8)
	search_margin.add_child(search_vbox)

	# Search field - Enhanced with icon placeholder
	search_field = LineEdit.new()
	search_field.placeholder_text = "🔍 Search countries..."
	search_field.custom_minimum_size = Vector2(0, 40)
	
	# Enhanced search field styling (normal state)
	var field_style = StyleBoxFlat.new()
	field_style.bg_color = Color(0.968, 0.976, 0.984)  # slate-50
	field_style.border_color = UITheme.get_panel_border()
	field_style.set_border_width_all(1)
	field_style.set_corner_radius_all(10)
	field_style.set_content_margin_all(12)
	search_field.add_theme_stylebox_override("normal", field_style)
	
	var field_focus_style = StyleBoxFlat.new()
	field_focus_style.bg_color = Color.WHITE
	field_focus_style.border_color = UITheme.PRIMARY_BLUE
	field_focus_style.set_border_width_all(2)
	field_focus_style.set_corner_radius_all(10)
	field_focus_style.set_content_margin_all(12)
	search_field.add_theme_stylebox_override("focus", field_focus_style)
	
	search_field.text_changed.connect(_on_search_changed)
	search_vbox.add_child(search_field)

	# Filter buttons
	filter_buttons = HBoxContainer.new()
	filter_buttons.add_theme_constant_override("separation", 8)
	search_vbox.add_child(filter_buttons)

	var all_btn = create_filter_button("All", "all")
	all_btn.button_pressed = true
	filter_buttons.add_child(all_btn)

	filter_buttons.add_child(create_filter_button("Friendly", "friendly"))
	filter_buttons.add_child(create_filter_button("Neutral", "neutral"))
	filter_buttons.add_child(create_filter_button("Hostile", "hostile"))

func create_filter_button(text: String, filter_type: String) -> Button:
	"""Create a filter button - Figma-inspired toggle style"""
	var btn = Button.new()
	btn.text = text
	btn.toggle_mode = true
	btn.custom_minimum_size = Vector2(100, 36)
	btn.add_theme_font_size_override("font_size", 12)
	btn.set_meta("filter_type", filter_type)
	
	# Normal state
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.968, 0.976, 0.984)  # slate-50
	normal_style.border_color = UITheme.get_panel_border()
	normal_style.set_border_width_all(1)
	normal_style.set_corner_radius_all(10)
	normal_style.set_content_margin_all(10)
	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_color_override("font_color", UITheme.get_text_secondary())
	
	# Pressed/active state
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = UITheme.PRIMARY_BLUE
	pressed_style.set_corner_radius_all(10)
	pressed_style.set_content_margin_all(10)
	pressed_style.shadow_color = Color(0.231, 0.510, 0.965, 0.2)
	pressed_style.shadow_size = 4
	btn.add_theme_stylebox_override("pressed", pressed_style)
	btn.add_theme_color_override("font_pressed_color", UITheme.TEXT_WHITE)
	
	# Hover state
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.get_hover_color()
	hover_style.border_color = UITheme.get_panel_border()
	hover_style.set_border_width_all(1)
	hover_style.set_corner_radius_all(10)
	hover_style.set_content_margin_all(10)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.pressed.connect(_on_filter_changed.bind(filter_type))
	return btn

func load_countries() -> void:
	"""Load countries data"""
	countries.clear()

	if not GameData.player_airline:
		return

	# Load actual countries from GameData
	for country in GameData.countries:
		var relationship = GameData.calculate_country_relationship(GameData.player_airline.id, country.code)
		var country_dict = {
			"code": country.code,
			"name": country.name,
			"relationship": relationship,
			"region": country.region
		}
		countries.append(country_dict)

	# Get home country
	home_country_code = GameData.player_airline.get_meta("home_country", "")
	if home_country_code.is_empty():
		# Try to infer from first hub
		if not GameData.player_airline.hubs.is_empty():
			home_country_code = GameData.player_airline.hubs[0].country
		else:
			home_country_code = "USA"  # Default
	
	# Normalize country code (some airports use "USA", some use "United States")
	# Try to find matching country
	var matched_country_code = home_country_code
	for country in GameData.countries:
		if country.code == home_country_code or country.name == home_country_code:
			matched_country_code = country.code
			break
	home_country_code = matched_country_code

	_update_home_country_display()
	_apply_filters()

func _update_home_country_display() -> void:
	"""Update home country label"""
	if home_country_code.is_empty():
		home_country_label.text = "Not Set"
		return

	# Find home country
	var home_country: Dictionary = {}
	for country in countries:
		if country.get("code") == home_country_code:
			home_country = country
			break
	
	if not home_country.is_empty():
		home_country_label.text = home_country.get("name", home_country_code)
	else:
		home_country_label.text = home_country_code

func _apply_filters() -> void:
	"""Apply search and filter"""
	var search_text = search_field.text.to_lower()
	var active_filter = _get_active_filter()

	# Filter countries
	filtered_countries.clear()
	for country in countries:
		var matches: bool = true
		
		# Search filter
		if not search_text.is_empty():
			var name = country.get("name", "").to_lower()
			if not name.contains(search_text):
				matches = false
		
		# Relationship filter
		if matches and active_filter != "all":
			var relationship = country.get("relationship", 0)
			match active_filter:
				"friendly":
					if relationship < 10:
						matches = false
				"neutral":
					if relationship < -5 or relationship >= 10:
						matches = false
				"hostile":
					if relationship >= -5:
						matches = false
		
		if matches:
			filtered_countries.append(country)

	# Sort by relationship (best first)
	filtered_countries.sort_custom(_sort_countries_by_relationship)

	_refresh_countries_list()

func _sort_countries_by_relationship(a: Dictionary, b: Dictionary) -> bool:
	"""Sort comparison function - returns true if a should come before b"""
	return a.get("relationship", 0) > b.get("relationship", 0)

func _get_active_filter() -> String:
	"""Get currently active filter"""
	for child in filter_buttons.get_children():
		if child is Button and child.button_pressed:
			return child.get_meta("filter_type", "all")
	return "all"

func _refresh_countries_list() -> void:
	"""Refresh the countries list display"""
	# Clear existing cards
	for child in countries_list.get_children():
		child.queue_free()

	# Create country cards
	for country in filtered_countries:
		var card = create_country_card(country)
		countries_list.add_child(card)

func create_country_card(country: Dictionary) -> Control:
	"""Create a card for displaying country relationship - Figma-inspired design"""
	var card = PanelContainer.new()
	
	# Enhanced card style
	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.get_card_bg()
	style.border_color = UITheme.get_panel_border()
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	style.shadow_color = Color(0, 0, 0, 0.05)
	style.shadow_size = 2
	card.add_theme_stylebox_override("panel", style)
	
	# Add hover effect
	card.mouse_entered.connect(_on_country_card_hover.bind(card, true))
	card.mouse_exited.connect(_on_country_card_hover.bind(card, false))

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_all", 12)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	# Country flag/icon (placeholder)
	var icon_label = Label.new()
	icon_label.text = "🌍"
	icon_label.add_theme_font_size_override("font_size", 24)
	icon_label.custom_minimum_size = Vector2(40, 40)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_label)

	# Country info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)

	var country_name = Label.new()
	country_name.text = country.get("name", "Unknown")
	country_name.add_theme_font_size_override("font_size", 14)
	country_name.add_theme_color_override("font_color", UITheme.get_text_primary())
	info_vbox.add_child(country_name)

	# Relationship indicator
	var relationship_indicator = RelationshipIndicator.new()
	var relationship = country.get("relationship", 0)
	if relationship_indicator:
		relationship_indicator.set_relationship(relationship)
		info_vbox.add_child(relationship_indicator)

	# Relationship factors (placeholder)
	var factors_label = Label.new()
	factors_label.text = _get_relationship_factors_text(country)
	factors_label.add_theme_font_size_override("font_size", 11)
	factors_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	info_vbox.add_child(factors_label)

	# View details button
	var details_btn = Button.new()
	details_btn.text = "Details"
	details_btn.custom_minimum_size = Vector2(80, 32)
	details_btn.add_theme_font_size_override("font_size", 12)
	var btn_style = UITheme.create_secondary_button_style()
	details_btn.add_theme_stylebox_override("normal", btn_style)
	details_btn.pressed.connect(_on_view_details.bind(country.get("code", "")))
	hbox.add_child(details_btn)

	return card

func _get_relationship_factors_text(country: Dictionary) -> String:
	"""Get relationship factors text"""
	var factors: Array[String] = []
	var relationship = country.get("relationship", 0)

	# Home country bonus
	if country.get("code") == home_country_code:
		factors.append("Home Country (+15)")
	else:
		# Get actual relationship factors
		var country_code = country.get("code", "")
		if not country_code.is_empty() and GameData.player_airline:
			var base_relationship = GameData.get_country_relationship(GameData.player_airline.id, country_code)
			var calculated_relationship = GameData.calculate_country_relationship(GameData.player_airline.id, country_code)
			
			# Show relationship breakdown
			factors.append("Base: %.0f" % base_relationship)
			
			# Market share bonus
			var market_share_bonus = _calculate_market_share_bonus(country_code)
			if market_share_bonus > 0:
				factors.append("Market Share: +%.0f" % market_share_bonus)
			
			# Delegate bonus
			var delegate_bonus = _calculate_delegate_bonus(country_code)
			if delegate_bonus > 0:
				factors.append("Delegates: +%.0f" % delegate_bonus)

	return " | ".join(factors)

func _on_search_changed(_text: String) -> void:
	"""Handle search text change"""
	_apply_filters()

func _on_filter_changed(filter_type: String) -> void:
	"""Handle filter button press"""
	# Update button states
	for child in filter_buttons.get_children():
		if child is Button:
			child.button_pressed = (child.get_meta("filter_type", "") == filter_type)

	_apply_filters()

func _on_view_details(country_code: String) -> void:
	"""Handle view details button"""
	relationship_details_requested.emit(country_code)

func _on_country_card_hover(card: PanelContainer, is_hover: bool) -> void:
	"""Handle country card hover effect"""
	var style = StyleBoxFlat.new()
	if is_hover:
		style.bg_color = UITheme.get_card_hover()
		style.shadow_color = Color(0, 0, 0, 0.1)
		style.shadow_size = 4
		style.border_color = UITheme.PRIMARY_BLUE.lightened(0.3)
	else:
		style.bg_color = UITheme.get_card_bg()
		style.shadow_color = Color(0, 0, 0, 0.05)
		style.shadow_size = 2
		style.border_color = UITheme.get_panel_border()
	
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	card.add_theme_stylebox_override("panel", style)

func _calculate_market_share_bonus(country_code: String) -> float:
	"""Calculate relationship bonus from market share"""
	if not GameData.player_airline:
		return 0.0
	
	var routes_to_country = 0
	var total_routes_to_country = 0
	
	for route in GameData.player_airline.routes:
		if route.to_airport and route.to_airport.country == country_code:
			routes_to_country += 1
	
	for airline in GameData.airlines:
		for route in airline.routes:
			if route.to_airport and route.to_airport.country == country_code:
				total_routes_to_country += 1
	
	if total_routes_to_country == 0:
		return 0.0
	
	var market_share = float(routes_to_country) / float(total_routes_to_country)
	return market_share * 20.0

func _calculate_delegate_bonus(country_code: String) -> float:
	"""Calculate relationship bonus from active delegates"""
	if not GameData.player_airline:
		return 0.0
	
	var bonus = 0.0
	for task in GameData.player_airline.delegate_tasks:
		if task.task_type == DelegateTask.TaskType.COUNTRY_RELATIONSHIP:
			if task.target_country_code == country_code:
				var delegate = _get_delegate_for_task(task)
				if delegate:
					var effectiveness = delegate.get_effectiveness()
					bonus += task.progress * effectiveness * 5.0
	
	return bonus

func _get_delegate_for_task(task: DelegateTask) -> Delegate:
	"""Get delegate assigned to a task"""
	if not GameData.player_airline:
		return null
	
	for delegate in GameData.player_airline.delegates:
		if delegate.current_task == task:
			return delegate
	return null
