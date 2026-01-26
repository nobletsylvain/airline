extends ConfirmationDialog
class_name DelegateAssignmentDialog

## Dialog for assigning delegates to tasks
## Supports Country Relationship, Link Negotiation, and Campaign tasks

signal delegate_assigned(task_type: String, target_data: Dictionary)

# UI Elements
var task_type_tabs: TabContainer
var country_panel: Control
var negotiation_panel: Control
var campaign_panel: Control

# Country task UI
var country_selector: OptionButton
var country_relationship_label: Label
var country_benefits_label: RichTextLabel

# Negotiation task UI
var from_airport_selector: OptionButton
var to_airport_selector: OptionButton
var route_difficulty_label: Label
var negotiation_benefits_label: RichTextLabel

# Campaign task UI
var campaign_location_selector: OptionButton
var campaign_cost_label: Label
var campaign_benefits_label: RichTextLabel

# Data
var selected_task_type: String = "country"
var available_countries: Array[Dictionary] = []
var available_airports: Array[Airport] = []
var available_campaigns: Array[Dictionary] = []

func _init() -> void:
	title = "Assign Delegate"
	size = Vector2i(700, 600)  # Larger for better layout
	ok_button_text = "Assign Delegate"

func _ready() -> void:
	get_cancel_button().text = "Cancel"
	build_ui()
	confirmed.connect(_on_confirmed)
	hide()

func build_ui() -> void:
	"""Build the dialog UI - Figma-inspired design"""
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(680, 500)
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 15)
	scroll.add_child(vbox)

	# Task type selector
	create_task_type_selector(vbox)

	# Task-specific panels
	create_task_panels(vbox)

	# Benefits summary
	create_benefits_section(vbox)

func create_task_type_selector(parent: VBoxContainer) -> void:
	"""Create task type tab selector - Figma-inspired"""
	var label = Label.new()
	label.text = "Select Task Type"
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", UITheme.get_text_primary())
	parent.add_child(label)
	
	var subtitle = Label.new()
	subtitle.text = "Choose the type of task for your delegate"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UITheme.get_text_secondary())
	parent.add_child(subtitle)

	task_type_tabs = TabContainer.new()
	task_type_tabs.custom_minimum_size = Vector2(0, 300)
	parent.add_child(task_type_tabs)

	task_type_tabs.tab_selected.connect(_on_task_type_changed)

func create_task_panels(parent: VBoxContainer) -> void:
	"""Create panels for each task type"""
	# Country Relationship Panel
	country_panel = create_country_panel()
	task_type_tabs.add_child(country_panel)
	task_type_tabs.set_tab_title(0, "Country Relationship")

	# Link Negotiation Panel
	negotiation_panel = create_negotiation_panel()
	task_type_tabs.add_child(negotiation_panel)
	task_type_tabs.set_tab_title(1, "Route Negotiation")

	# Campaign Panel
	campaign_panel = create_campaign_panel()
	task_type_tabs.add_child(campaign_panel)
	task_type_tabs.set_tab_title(2, "Campaign")

func create_country_panel() -> Control:
	"""Create country relationship task panel"""
	var panel = VBoxContainer.new()
	panel.add_theme_constant_override("separation", 12)

	var label = Label.new()
	label.text = "Improve diplomatic relationship with a country"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)

	# Country selector
	var selector_label = Label.new()
	selector_label.text = "Select Country:"
	selector_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(selector_label)

	country_selector = OptionButton.new()
	country_selector.custom_minimum_size = Vector2(0, 32)
	country_selector.item_selected.connect(_on_country_selected)
	panel.add_child(country_selector)

	# Relationship info
	country_relationship_label = Label.new()
	country_relationship_label.add_theme_font_size_override("font_size", 12)
	country_relationship_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	country_relationship_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(country_relationship_label)

	# Benefits
	country_benefits_label = RichTextLabel.new()
	country_benefits_label.bbcode_enabled = true
	country_benefits_label.custom_minimum_size = Vector2(0, 80)
	country_benefits_label.fit_content = true
	panel.add_child(country_benefits_label)

	return panel

func create_negotiation_panel() -> Control:
	"""Create route negotiation task panel"""
	var panel = VBoxContainer.new()
	panel.add_theme_constant_override("separation", 12)

	var label = Label.new()
	label.text = "Negotiate route access to reduce creation costs"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)

	# From airport
	var from_label = Label.new()
	from_label.text = "From Airport:"
	from_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(from_label)

	from_airport_selector = OptionButton.new()
	from_airport_selector.custom_minimum_size = Vector2(0, 32)
	from_airport_selector.item_selected.connect(_on_route_selected)
	panel.add_child(from_airport_selector)

	# To airport
	var to_label = Label.new()
	to_label.text = "To Airport:"
	to_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(to_label)

	to_airport_selector = OptionButton.new()
	to_airport_selector.custom_minimum_size = Vector2(0, 32)
	to_airport_selector.item_selected.connect(_on_route_selected)
	panel.add_child(to_airport_selector)

	# Difficulty info
	route_difficulty_label = Label.new()
	route_difficulty_label.add_theme_font_size_override("font_size", 12)
	route_difficulty_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	route_difficulty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(route_difficulty_label)

	# Benefits
	negotiation_benefits_label = RichTextLabel.new()
	negotiation_benefits_label.bbcode_enabled = true
	negotiation_benefits_label.custom_minimum_size = Vector2(0, 60)
	negotiation_benefits_label.fit_content = true
	panel.add_child(negotiation_benefits_label)

	return panel

func create_campaign_panel() -> Control:
	"""Create campaign task panel"""
	var panel = VBoxContainer.new()
	panel.add_theme_constant_override("separation", 12)

	var label = Label.new()
	label.text = "Run marketing campaign to boost awareness"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", UITheme.get_text_secondary())
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)

	# Campaign location
	var location_label = Label.new()
	location_label.text = "Campaign Location:"
	location_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(location_label)

	campaign_location_selector = OptionButton.new()
	campaign_location_selector.custom_minimum_size = Vector2(0, 32)
	campaign_location_selector.item_selected.connect(_on_campaign_selected)
	panel.add_child(campaign_location_selector)

	# Cost
	campaign_cost_label = Label.new()
	campaign_cost_label.add_theme_font_size_override("font_size", 12)
	campaign_cost_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	panel.add_child(campaign_cost_label)

	# Benefits
	campaign_benefits_label = RichTextLabel.new()
	campaign_benefits_label.bbcode_enabled = true
	campaign_benefits_label.custom_minimum_size = Vector2(0, 80)
	campaign_benefits_label.fit_content = true
	panel.add_child(campaign_benefits_label)

	return panel

func create_benefits_section(parent: VBoxContainer) -> void:
	"""Create benefits summary section"""
	var panel = PanelContainer.new()
	var style = UITheme.create_panel_style()
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_all", 12)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "Task Benefits"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)
	vbox.add_child(title)

	var benefits_text = RichTextLabel.new()
	benefits_text.name = "BenefitsText"
	benefits_text.bbcode_enabled = true
	benefits_text.custom_minimum_size = Vector2(0, 60)
	benefits_text.fit_content = true
	vbox.add_child(benefits_text)

func _on_task_type_changed(tab_index: int) -> void:
	"""Handle task type tab change"""
	match tab_index:
		0:
			selected_task_type = "country"
			_load_countries()
		1:
			selected_task_type = "negotiation"
			_load_airports()
		2:
			selected_task_type = "campaign"
			_load_campaigns()

func _on_country_selected(index: int) -> void:
	"""Handle country selection"""
	if index < 0 or index >= available_countries.size():
		return

	var country = available_countries[index]
	_update_country_info(country)

func _on_route_selected(_index: int) -> void:
	"""Handle route selection"""
	var from_idx = from_airport_selector.selected
	var to_idx = to_airport_selector.selected

	if from_idx < 0 or to_idx < 0:
		return

	var from_airport = available_airports[from_idx]
	var to_airport = available_airports[to_idx]
	_update_route_info(from_airport, to_airport)

func _on_campaign_selected(index: int) -> void:
	"""Handle campaign selection"""
	if index < 0 or index >= available_campaigns.size():
		return

	var campaign = available_campaigns[index]
	_update_campaign_info(campaign)

func _load_countries() -> void:
	"""Load available countries"""
	country_selector.clear()
	available_countries.clear()

	# Load actual countries from GameData
	for country in GameData.countries:
		country_selector.add_item(country.name)
		available_countries.append({
			"code": country.code,
			"name": country.name
		})

	if country_selector.get_item_count() > 0:
		country_selector.selected = 0
		_on_country_selected(0)

func _load_airports() -> void:
	"""Load available airports"""
	from_airport_selector.clear()
	to_airport_selector.clear()
	available_airports.clear()

	if GameData.airports:
		for airport in GameData.airports:
			var text = "%s - %s" % [airport.iata_code, airport.city]
			from_airport_selector.add_item(text)
			to_airport_selector.add_item(text)
			available_airports.append(airport)

func _load_campaigns() -> void:
	"""Load available campaigns"""
	campaign_location_selector.clear()
	available_campaigns.clear()

	# TODO: Load actual campaigns from GameData
	# For now, use placeholder
	var campaigns = [
		{"location": "New York", "cost": 50000},
		{"location": "London", "cost": 45000},
		{"location": "Tokyo", "cost": 60000},
	]

	for campaign in campaigns:
		campaign_location_selector.add_item(campaign.location)
		available_campaigns.append(campaign)

	if campaign_location_selector.get_item_count() > 0:
		campaign_location_selector.selected = 0
		_on_campaign_selected(0)

func _update_country_info(country: Dictionary) -> void:
	"""Update country relationship info"""
	if not GameData.player_airline:
		return
	
	var country_code = country.get("code", "")
	var relationship = GameData.calculate_country_relationship(GameData.player_airline.id, country_code)
	var country_obj = GameData.get_country_by_code(country_code)
	var level = country_obj.get_relationship_level(relationship) if country_obj else "Neutral"
	
	country_relationship_label.text = "Current relationship: %s (%.0f)\nImproving relationship will reduce route creation costs to this country." % [level, relationship]

	country_benefits_label.text = "[b]Benefits:[/b]\n• Reduced route creation costs\n• Improved market access\n• Better passenger demand"

func _update_route_info(from_airport: Airport, to_airport: Airport) -> void:
	"""Update route negotiation info"""
	var distance = GameData.calculate_distance(from_airport, to_airport)
	
	# Calculate base difficulty
	var base_difficulty = 50.0
	if distance > 10000:
		base_difficulty += 10.0
	elif distance < 2000:
		base_difficulty -= 5.0
	
	# Estimate negotiation discount (12-20 points based on delegate level)
	var estimated_discount = 15.0  # Average
	
	route_difficulty_label.text = "Route: %s → %s (%.0f km)\nBase Difficulty: %.0f\nNegotiation will reduce difficulty by ~%.0f points" % [
		from_airport.iata_code,
		to_airport.iata_code,
		distance,
		base_difficulty,
		estimated_discount
	]

	negotiation_benefits_label.text = "[b]Benefits:[/b]\n• Reduced route creation cost (20-30%%)\n• Faster route approval\n• Lower ongoing operational costs"

func _update_campaign_info(campaign: Dictionary) -> void:
	"""Update campaign info"""
	campaign_cost_label.text = "Cost: %s" % UITheme.format_money(campaign.get("cost", 0))

	campaign_benefits_label.text = "[b]Benefits:[/b]\n• Increased airline awareness\n• Improved reputation\n• Higher passenger demand"

func _on_confirmed() -> void:
	"""Handle dialog confirmation"""
	var target_data: Dictionary = {}

	match selected_task_type:
		"country":
			var idx = country_selector.selected
			if idx >= 0 and idx < available_countries.size():
				target_data = available_countries[idx]
		"negotiation":
			var from_idx = from_airport_selector.selected
			var to_idx = to_airport_selector.selected
			if from_idx >= 0 and to_idx >= 0:
				target_data = {
					"from_airport": available_airports[from_idx],
					"to_airport": available_airports[to_idx]
				}
		"campaign":
			var idx = campaign_location_selector.selected
			if idx >= 0 and idx < available_campaigns.size():
				target_data = available_campaigns[idx]

	if not target_data.is_empty():
		delegate_assigned.emit(selected_task_type, target_data)

func show_for_task_type(task_type: String = "", target: Dictionary = {}) -> void:
	"""Show dialog for specific task type"""
	if not task_type.is_empty():
		match task_type:
			"country":
				task_type_tabs.current_tab = 0
			"negotiation":
				task_type_tabs.current_tab = 1
			"campaign":
				task_type_tabs.current_tab = 2

	_on_task_type_changed(task_type_tabs.current_tab)
	popup_centered()
