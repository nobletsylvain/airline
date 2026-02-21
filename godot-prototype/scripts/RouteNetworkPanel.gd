extends Control
class_name RouteNetworkPanel

## Route Network Panel - Shows all player routes with KPIs, search, and sorting
## Pattern matches FleetManagementPanel.gd architecture

signal create_route_pressed()
signal route_selected(route: Route)

# UI Elements
var scroll_container: ScrollContainer
var routes_container: VBoxContainer
var search_field: LineEdit
var sort_button: Button
var summary_label: Label

# KPI value labels (updated on refresh)
var kpi_routes_value: Label
var kpi_load_value: Label
var kpi_revenue_value: Label
var kpi_unprofitable_value: Label

# Sort state
enum SortMode { PROFIT, LOAD_FACTOR, DISTANCE, NAME }
var current_sort: SortMode = SortMode.PROFIT
var current_search: String = ""

const SORT_LABELS = {
	SortMode.PROFIT: "Sort: Profit",
	SortMode.LOAD_FACTOR: "Sort: Load",
	SortMode.DISTANCE: "Sort: Distance",
	SortMode.NAME: "Sort: Name"
}

func _ready() -> void:
	build_ui()

func build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Main container with margin
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

	# Header row
	_create_header(outer_vbox)

	# KPI row
	_create_kpi_row(outer_vbox)

	# Search/sort bar
	_create_filter_bar(outer_vbox)

	# Scrollable route cards
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll_container)

	routes_container = VBoxContainer.new()
	routes_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes_container.add_theme_constant_override("separation", 12)
	scroll_container.add_child(routes_container)

	# Summary footer
	_create_summary_footer(outer_vbox)

func _create_header(parent: VBoxContainer) -> void:
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	parent.add_child(header)

	var title = Label.new()
	title.text = "Route Network"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.get_text_primary())
	header.add_child(title)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	# Create Route button
	var create_btn = Button.new()
	create_btn.text = "+ Create Route"
	create_btn.custom_minimum_size = Vector2(180, 40)
	create_btn.add_theme_font_size_override("font_size", 14)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = UITheme.PRIMARY_BLUE
	btn_style.set_corner_radius_all(8)
	btn_style.set_content_margin_all(10)
	create_btn.add_theme_stylebox_override("normal", btn_style)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = UITheme.PRIMARY_BLUE.lightened(0.1)
	btn_hover.set_corner_radius_all(8)
	btn_hover.set_content_margin_all(10)
	create_btn.add_theme_stylebox_override("hover", btn_hover)

	create_btn.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	create_btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
	create_btn.pressed.connect(func(): create_route_pressed.emit())
	header.add_child(create_btn)

func _create_kpi_row(parent: VBoxContainer) -> void:
	var kpi_row = HBoxContainer.new()
	kpi_row.add_theme_constant_override("separation", 12)
	parent.add_child(kpi_row)

	# Active Routes
	var routes_kpi: PanelContainer
	routes_kpi = _create_kpi_card("Active Routes", "0")
	kpi_routes_value = routes_kpi.get_node("VBox/Value")
	kpi_row.add_child(routes_kpi)

	# Avg Load Factor
	var load_kpi: PanelContainer
	load_kpi = _create_kpi_card("Avg Load Factor", "0%")
	kpi_load_value = load_kpi.get_node("VBox/Value")
	kpi_row.add_child(load_kpi)

	# Weekly Revenue
	var revenue_kpi: PanelContainer
	revenue_kpi = _create_kpi_card("Weekly Revenue", "$0")
	kpi_revenue_value = revenue_kpi.get_node("VBox/Value")
	kpi_row.add_child(revenue_kpi)

	# Unprofitable
	var unprofitable_kpi: PanelContainer
	unprofitable_kpi = _create_kpi_card("Unprofitable", "0")
	kpi_unprofitable_value = unprofitable_kpi.get_node("VBox/Value")
	kpi_row.add_child(unprofitable_kpi)

func _create_kpi_card(title_text: String, value_text: String) -> PanelContainer:
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 70)
	card.add_theme_stylebox_override("panel", UITheme.create_kpi_card_style())

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	var title = Label.new()
	title.name = "Title"
	title.text = title_text
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", UITheme.get_text_muted())
	vbox.add_child(title)

	var value = Label.new()
	value.name = "Value"
	value.text = value_text
	value.add_theme_font_size_override("font_size", 18)
	value.add_theme_color_override("font_color", UITheme.get_text_primary())
	vbox.add_child(value)

	return card

func _create_filter_bar(parent: VBoxContainer) -> void:
	var filter_row = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 12)
	parent.add_child(filter_row)

	# Search field
	search_field = LineEdit.new()
	search_field.placeholder_text = "Search routes..."
	search_field.custom_minimum_size = Vector2(250, 36)
	search_field.add_theme_font_size_override("font_size", 13)

	var search_style = StyleBoxFlat.new()
	search_style.bg_color = UITheme.get_panel_bg()
	search_style.set_corner_radius_all(6)
	search_style.set_content_margin_all(8)
	search_style.border_color = UITheme.get_panel_border()
	search_style.set_border_width_all(1)
	search_field.add_theme_stylebox_override("normal", search_style)
	search_field.text_changed.connect(_on_search_changed)
	filter_row.add_child(search_field)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filter_row.add_child(spacer)

	# Sort button
	sort_button = Button.new()
	sort_button.text = SORT_LABELS[current_sort]
	sort_button.custom_minimum_size = Vector2(140, 36)
	sort_button.add_theme_font_size_override("font_size", 13)
	sort_button.add_theme_color_override("font_color", UITheme.get_text_primary())
	sort_button.add_theme_stylebox_override("normal", UITheme.create_button_style())
	sort_button.add_theme_stylebox_override("hover", UITheme.create_button_hover_style())
	sort_button.pressed.connect(_on_sort_pressed)
	filter_row.add_child(sort_button)

func _create_summary_footer(parent: VBoxContainer) -> void:
	var footer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	parent.add_child(footer)

	var sep = HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.3)
	parent.add_child(sep)
	# Move separator before footer
	parent.move_child(sep, sep.get_index() - 1)

	summary_label = Label.new()
	summary_label.text = "No routes"
	summary_label.add_theme_font_size_override("font_size", 13)
	summary_label.add_theme_color_override("font_color", UITheme.get_text_muted())
	footer.add_child(summary_label)

# ============================================================================
# DATA & REFRESH
# ============================================================================

func refresh() -> void:
	if not GameData.player_airline:
		return

	var routes = GameData.player_airline.routes.duplicate()

	# Filter by search
	if current_search != "":
		var filtered: Array[Route] = []
		for route in routes:
			var name_str = route.get_display_name().to_lower()
			if current_search.to_lower() in name_str:
				filtered.append(route)
		routes = filtered

	# Sort
	match current_sort:
		SortMode.PROFIT:
			routes.sort_custom(func(a, b): return a.weekly_profit > b.weekly_profit)
		SortMode.LOAD_FACTOR:
			routes.sort_custom(func(a, b): return _get_load_factor(a) > _get_load_factor(b))
		SortMode.DISTANCE:
			routes.sort_custom(func(a, b): return a.distance_km > b.distance_km)
		SortMode.NAME:
			routes.sort_custom(func(a, b): return a.get_display_name() < b.get_display_name())

	# Clear existing cards
	for child in routes_container.get_children():
		child.queue_free()

	# Add route cards
	if routes.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No routes yet. Create your first route from a hub airport!"
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", UITheme.get_text_muted())
		routes_container.add_child(empty_label)
	else:
		for route in routes:
			var card = RouteCard.new()
			routes_container.add_child(card)
			card.set_route(route)
			card.route_selected.connect(_on_route_card_selected)
			card.route_edit_requested.connect(_on_route_card_edit)

	# Update KPIs
	_update_kpis()

	# Update summary
	_update_summary()

func _update_kpis() -> void:
	if not GameData.player_airline:
		return

	var all_routes = GameData.player_airline.routes
	var route_count = all_routes.size()
	var total_revenue: float = 0.0
	var total_load: float = 0.0
	var unprofitable: int = 0

	for route in all_routes:
		total_revenue += route.weekly_profit
		total_load += _get_load_factor(route)
		if route.weekly_profit < 0:
			unprofitable += 1

	var avg_load: float = total_load / route_count if route_count > 0 else 0.0

	# Update labels
	if kpi_routes_value:
		kpi_routes_value.text = str(route_count)
		kpi_routes_value.add_theme_color_override("font_color", UITheme.PRIMARY_BLUE)

	if kpi_load_value:
		kpi_load_value.text = "%.0f%%" % avg_load
		kpi_load_value.add_theme_color_override("font_color", UITheme.get_load_factor_color(avg_load))

	if kpi_revenue_value:
		kpi_revenue_value.text = UITheme.format_money(total_revenue, true)
		kpi_revenue_value.add_theme_color_override("font_color", UITheme.get_profit_color(total_revenue))

	if kpi_unprofitable_value:
		kpi_unprofitable_value.text = str(unprofitable)
		var color = UITheme.LOSS_COLOR if unprofitable > 0 else UITheme.PROFIT_COLOR
		kpi_unprofitable_value.add_theme_color_override("font_color", color)

func _update_summary() -> void:
	if not summary_label or not GameData.player_airline:
		return

	var all_routes = GameData.player_airline.routes
	if all_routes.is_empty():
		summary_label.text = "No routes"
		return

	var total_profit: float = 0.0
	var total_pax: int = 0
	for route in all_routes:
		total_profit += route.weekly_profit
		total_pax += route.passengers_transported

	summary_label.text = "%d routes | %s weekly profit | %s passengers" % [
		all_routes.size(),
		UITheme.format_money(total_profit, true),
		UITheme.format_number(total_pax)
	]

func _get_load_factor(route: Route) -> float:
	var capacity = route.get_total_capacity() * route.frequency
	if capacity <= 0:
		return 0.0
	return clamp((route.passengers_transported / float(capacity)) * 100.0, 0.0, 100.0)

# ============================================================================
# EVENT HANDLERS
# ============================================================================

func _on_search_changed(new_text: String) -> void:
	current_search = new_text
	refresh()

func _on_sort_pressed() -> void:
	# Cycle through sort modes
	current_sort = (current_sort + 1) % SortMode.size() as SortMode
	sort_button.text = SORT_LABELS[current_sort]
	refresh()

func _on_route_card_selected(route: Route) -> void:
	route_selected.emit(route)

func _on_route_card_edit(route: Route) -> void:
	route_selected.emit(route)
