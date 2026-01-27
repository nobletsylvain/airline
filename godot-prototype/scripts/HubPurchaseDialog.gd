extends ConfirmationDialog
class_name HubPurchaseDialog

## Dialog for purchasing hub access at airports

signal hub_purchased(airport: Airport)

# UI Elements
var airport_list: ItemList
var airport_details_label: RichTextLabel
var cost_label: Label
var hub_count_label: Label

# Data
var available_airports: Array[Airport] = []
var selected_airport: Airport = null

func _init() -> void:
	title = "Purchase Hub Access"
	size = Vector2i(700, 600)
	ok_button_text = "Purchase Hub"

func _ready() -> void:
	get_cancel_button().text = "Cancel"
	build_ui()
	confirmed.connect(_on_confirmed)
	hide()  # Start hidden, only show when explicitly opened

	# Allow ESC key and close button to close dialog
	close_requested.connect(hide)

func _input(event: InputEvent) -> void:
	"""Handle ESC key to close dialog"""
	if not visible:
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide()
		get_viewport().set_input_as_handled()

func build_ui() -> void:
	"""Build the dialog UI programmatically"""
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(680, 500)
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 15)
	scroll.add_child(vbox)

	# === Header Section ===
	var header_label = Label.new()
	header_label.text = "Expand your network by opening hubs at new airports"
	header_label.add_theme_font_size_override("font_size", 14)
	header_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(header_label)

	# === Hub Status Section ===
	var status_panel = create_section_panel("Current Hubs")
	vbox.add_child(status_panel)

	hub_count_label = Label.new()
	hub_count_label.add_theme_font_size_override("font_size", 14)
	status_panel.add_child(hub_count_label)

	# === Available Airports Section ===
	var airports_panel = create_section_panel("Available Airports")
	vbox.add_child(airports_panel)

	var airports_vbox = VBoxContainer.new()
	airports_vbox.add_theme_constant_override("separation", 10)
	airports_panel.add_child(airports_vbox)

	var list_label = Label.new()
	list_label.text = "Select an airport to establish a hub:"
	list_label.add_theme_font_size_override("font_size", 14)
	airports_vbox.add_child(list_label)

	airport_list = ItemList.new()
	airport_list.custom_minimum_size = Vector2(0, 200)
	airport_list.item_selected.connect(_on_airport_selected)
	airports_vbox.add_child(airport_list)

	# === Airport Details Section ===
	var details_panel = create_section_panel("Airport Details")
	vbox.add_child(details_panel)

	airport_details_label = RichTextLabel.new()
	airport_details_label.bbcode_enabled = true
	airport_details_label.fit_content = true
	airport_details_label.custom_minimum_size = Vector2(0, 120)
	airport_details_label.add_theme_font_size_override("normal_font_size", 14)
	airport_details_label.text = "[i]Select an airport to view details[/i]"
	details_panel.add_child(airport_details_label)

	# === Cost Section ===
	var cost_panel = create_section_panel("Purchase Cost")
	vbox.add_child(cost_panel)

	cost_label = Label.new()
	cost_label.add_theme_font_size_override("font_size", 16)
	cost_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
	cost_label.text = "Select an airport"
	cost_panel.add_child(cost_label)

func create_section_panel(title: String) -> VBoxContainer:
	"""Create a styled section with title"""
	var section_vbox = VBoxContainer.new()
	section_vbox.add_theme_constant_override("separation", 8)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	section_vbox.add_child(title_label)

	var separator = HSeparator.new()
	section_vbox.add_child(separator)

	return section_vbox

func show_dialog() -> void:
	"""Show the dialog and populate with current data"""
	update_hub_status()
	populate_airport_list()
	popup_centered()

func update_hub_status() -> void:
	"""Update current hub status display"""
	if not GameData.player_airline:
		return

	var hub_count = GameData.player_airline.get_hub_count()
	var hub_names = GameData.player_airline.get_hub_names()

	hub_count_label.text = "You have %d hub(s): %s" % [hub_count, hub_names]

func populate_airport_list() -> void:
	"""Populate the list with airports where hubs can be purchased"""
	if not airport_list:
		return

	airport_list.clear()
	available_airports.clear()

	if not GameData.player_airline:
		return

	# Get all airports and sort by cost
	for airport in GameData.airports:
		if GameData.player_airline.has_hub(airport):
			continue  # Skip airports that are already hubs

		available_airports.append(airport)

	# Sort by hub tier (major hubs first) then by cost
	available_airports.sort_custom(func(a, b):
		if a.hub_tier != b.hub_tier:
			return a.hub_tier < b.hub_tier
		return GameData.calculate_hub_cost(a, GameData.player_airline) < GameData.calculate_hub_cost(b, GameData.player_airline)
	)

	# Add to list
	for airport in available_airports:
		var cost = GameData.calculate_hub_cost(airport, GameData.player_airline)
		var can_afford = GameData.player_airline.balance >= cost
		var icon = "✓" if can_afford else "✗"

		var text = "%s %s (%s) - %s | $%s" % [
			icon,
			airport.iata_code,
			airport.city,
			airport.get_hub_name(),
			format_money(cost)
		]

		airport_list.add_item(text)

	if available_airports.is_empty():
		airport_list.add_item("All airports already have hubs!")
		get_ok_button().disabled = true

func _on_airport_selected(index: int) -> void:
	"""Airport selected from list"""
	if index >= 0 and index < available_airports.size():
		selected_airport = available_airports[index]
		update_airport_details()
		update_cost_display()
		get_ok_button().disabled = false

func update_airport_details() -> void:
	"""Update airport details display"""
	if not airport_details_label or not selected_airport:
		return

	var text = "[b]%s (%s)[/b]\n" % [selected_airport.name, selected_airport.iata_code]
	text += "[i]%s, %s[/i]\n\n" % [selected_airport.city, selected_airport.country]
	text += "• Hub Tier: [b]%s[/b]\n" % selected_airport.get_hub_name()
	text += "• Annual Passengers: [b]%dM[/b]\n" % selected_airport.annual_passengers
	text += "• Runways: [b]%d[/b]\n" % selected_airport.runway_count
	text += "• Max Slots/Week: [b]%d[/b]\n" % selected_airport.max_slots_per_week
	text += "• GDP per capita: [b]$%s[/b]" % format_number(selected_airport.gdp_per_capita)

	airport_details_label.text = text

func update_cost_display() -> void:
	"""Update cost label"""
	if not cost_label or not selected_airport:
		return

	var cost = GameData.calculate_hub_cost(selected_airport, GameData.player_airline)
	var can_afford = GameData.player_airline.balance >= cost

	if can_afford:
		cost_label.text = "Cost: €%s" % format_money(cost)
		cost_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
	else:
		cost_label.text = "Cost: €%s (Cannot afford!)" % format_money(cost)
		cost_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))

	get_ok_button().disabled = not can_afford

func _on_confirmed() -> void:
	"""Dialog confirmed - purchase hub"""
	if not selected_airport:
		return

	# Attempt to purchase hub
	if GameData.purchase_hub_for_airline(GameData.player_airline, selected_airport):
		hub_purchased.emit(selected_airport)
		print("Hub purchased at %s" % selected_airport.iata_code)

func format_money(amount: float) -> String:
	"""Format money with thousands separators"""
	var s: String = str(int(amount))
	var result: String = ""
	var count: int = 0

	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i > 0:
			result = "," + result

	return result

func format_number(num: float) -> String:
	"""Format large numbers with K/M suffixes"""
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	else:
		return str(int(num))
