extends ConfirmationDialog
class_name AircraftPurchaseDialog

## Dialog for purchasing aircraft

signal aircraft_purchased(aircraft: AircraftInstance)

# UI Elements
var aircraft_list: ItemList
var aircraft_details_label: RichTextLabel
var cost_label: Label
var fleet_count_label: Label

# Data
var available_models: Array[AircraftModel] = []
var selected_model: AircraftModel = null

func _init() -> void:
	title = "Purchase Aircraft"
	size = Vector2i(750, 650)
	ok_button_text = "Purchase Aircraft"
	cancel_button_text = "Cancel"

func _ready() -> void:
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
	scroll.custom_minimum_size = Vector2(730, 550)
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 15)
	scroll.add_child(vbox)

	# === Header Section ===
	var header_label = Label.new()
	header_label.text = "Expand your fleet by purchasing new aircraft"
	header_label.add_theme_font_size_override("font_size", 14)
	header_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(header_label)

	# === Fleet Status Section ===
	var status_panel = create_section_panel("Current Fleet")
	vbox.add_child(status_panel)

	fleet_count_label = Label.new()
	fleet_count_label.add_theme_font_size_override("font_size", 14)
	status_panel.add_child(fleet_count_label)

	# === Available Aircraft Section ===
	var aircraft_panel = create_section_panel("Available Aircraft Models")
	vbox.add_child(aircraft_panel)

	var aircraft_vbox = VBoxContainer.new()
	aircraft_vbox.add_theme_constant_override("separation", 10)
	aircraft_panel.add_child(aircraft_vbox)

	var list_label = Label.new()
	list_label.text = "Select an aircraft model to purchase:"
	list_label.add_theme_font_size_override("font_size", 14)
	aircraft_vbox.add_child(list_label)

	aircraft_list = ItemList.new()
	aircraft_list.custom_minimum_size = Vector2(0, 200)
	aircraft_list.item_selected.connect(_on_aircraft_selected)
	aircraft_vbox.add_child(aircraft_list)

	# === Aircraft Details Section ===
	var details_panel = create_section_panel("Aircraft Specifications")
	vbox.add_child(details_panel)

	aircraft_details_label = RichTextLabel.new()
	aircraft_details_label.bbcode_enabled = true
	aircraft_details_label.fit_content = true
	aircraft_details_label.custom_minimum_size = Vector2(0, 140)
	aircraft_details_label.add_theme_font_size_override("normal_font_size", 14)
	aircraft_details_label.text = "[i]Select an aircraft to view specifications[/i]"
	details_panel.add_child(aircraft_details_label)

	# === Cost Section ===
	var cost_panel = create_section_panel("Purchase Cost")
	vbox.add_child(cost_panel)

	cost_label = Label.new()
	cost_label.add_theme_font_size_override("font_size", 16)
	cost_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
	cost_label.text = "Select an aircraft"
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
	update_fleet_status()
	populate_aircraft_list()
	popup_centered()

func update_fleet_status() -> void:
	"""Update current fleet status display"""
	if not GameData.player_airline:
		return

	var fleet_count = GameData.player_airline.aircraft.size()
	var fleet_summary = ""

	if fleet_count == 0:
		fleet_summary = "No aircraft in fleet"
	else:
		# Count aircraft by model
		var model_counts: Dictionary = {}
		for aircraft in GameData.player_airline.aircraft:
			var model_name = aircraft.model.get_display_name()
			if model_name in model_counts:
				model_counts[model_name] += 1
			else:
				model_counts[model_name] = 1

		var parts: Array[String] = []
		for model_name in model_counts:
			parts.append("%dx %s" % [model_counts[model_name], model_name])
		fleet_summary = ", ".join(parts)

	fleet_count_label.text = "You have %d aircraft: %s" % [fleet_count, fleet_summary]

func populate_aircraft_list() -> void:
	"""Populate the list with available aircraft models"""
	if not aircraft_list:
		return

	aircraft_list.clear()
	available_models.clear()

	if not GameData.player_airline:
		return

	# Get all aircraft models sorted by price
	available_models = GameData.aircraft_models.duplicate()
	available_models.sort_custom(func(a, b): return a.price < b.price)

	# Add to list
	for model in available_models:
		var can_afford = GameData.player_airline.balance >= model.price
		var icon = "+" if can_afford else "-"

		var text = "%s %s | %d seats | %s km range | $%s" % [
			icon,
			model.get_display_name(),
			model.max_total_seats,
			format_number_with_commas(model.range_km),
			format_money(model.price)
		]

		aircraft_list.add_item(text)

		# Gray out if can't afford
		if not can_afford:
			var item_idx = aircraft_list.item_count - 1
			aircraft_list.set_item_custom_fg_color(item_idx, Color(0.5, 0.5, 0.5))

	if available_models.is_empty():
		aircraft_list.add_item("No aircraft models available!")
		get_ok_button().disabled = true

func _on_aircraft_selected(index: int) -> void:
	"""Aircraft selected from list"""
	if index >= 0 and index < available_models.size():
		selected_model = available_models[index]
		update_aircraft_details()
		update_cost_display()

func update_aircraft_details() -> void:
	"""Update aircraft details display"""
	if not aircraft_details_label or not selected_model:
		return

	var text = "[b]%s[/b]\n" % selected_model.get_display_name()
	text += "[i]%s[/i]\n\n" % selected_model.manufacturer

	text += "[u]Performance[/u]\n"
	text += "  Range: [b]%s km[/b]\n" % format_number_with_commas(selected_model.range_km)
	text += "  Cruise Speed: [b]%d km/h[/b]\n" % selected_model.speed_kmh
	text += "  Fuel Burn: [b]%.1f gal/hour[/b]\n\n" % selected_model.fuel_burn

	text += "[u]Capacity[/u]\n"
	text += "  Maximum Seats: [b]%d[/b]\n" % selected_model.max_total_seats
	text += "  Default Config: [b]%dY / %dC / %dF[/b]\n" % [
		selected_model.default_economy,
		selected_model.default_business,
		selected_model.default_first
	]

	# Calculate route suitability
	text += "\n[u]Suitable Routes[/u]\n"
	if selected_model.range_km < 2000:
		text += "  Short-haul domestic routes"
	elif selected_model.range_km < 5000:
		text += "  Medium-haul continental routes"
	elif selected_model.range_km < 10000:
		text += "  Long-haul intercontinental routes"
	else:
		text += "  Ultra long-haul global routes"

	aircraft_details_label.text = text

func update_cost_display() -> void:
	"""Update cost label"""
	if not cost_label or not selected_model:
		return

	var cost = selected_model.price
	var can_afford = GameData.player_airline.balance >= cost

	if can_afford:
		cost_label.text = "Cost: $%s (Balance after: $%s)" % [
			format_money(cost),
			format_money(GameData.player_airline.balance - cost)
		]
		cost_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
	else:
		var shortfall = cost - GameData.player_airline.balance
		cost_label.text = "Cost: $%s (Need $%s more!)" % [
			format_money(cost),
			format_money(shortfall)
		]
		cost_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))

	get_ok_button().disabled = not can_afford

func _on_confirmed() -> void:
	"""Dialog confirmed - purchase aircraft"""
	if not selected_model:
		return

	# Attempt to purchase aircraft
	var aircraft = GameData.purchase_aircraft(GameData.player_airline, selected_model)
	if aircraft:
		aircraft_purchased.emit(aircraft)
		print("Aircraft purchased: %s" % selected_model.get_display_name())

func format_money(amount: float) -> String:
	"""Format money with thousands separators"""
	return format_number_with_commas(int(amount))

func format_number_with_commas(num: int) -> String:
	"""Format number with thousands separators"""
	var s: String = str(num)
	var result: String = ""
	var count: int = 0

	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i > 0:
			result = "," + result

	return result
