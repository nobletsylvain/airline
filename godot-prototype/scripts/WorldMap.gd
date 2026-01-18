extends Control

## World map visualization with airports and routes

@export var airport_marker_scene: PackedScene
@export var background_color: Color = Color(0.1, 0.15, 0.2)
@export var ocean_color: Color = Color(0.15, 0.25, 0.35)
@export var land_color: Color = Color(0.25, 0.35, 0.3)

var airport_markers: Dictionary = {}  # iata_code -> AirportMarker node
var route_lines: Array[Line2D] = []
var selected_airport: Airport = null
var hover_airport: Airport = null

signal airport_clicked(airport: Airport)
signal airport_hovered(airport: Airport)
signal route_created(from_airport: Airport, to_airport: Airport)

func _ready() -> void:
	custom_minimum_size = Vector2(1000, 600)
	mouse_filter = Control.MOUSE_FILTER_PASS

	# Wait for GameData to initialize
	if GameData.airports.is_empty():
		await GameData.game_initialized

	setup_airports()

func _draw() -> void:
	# Draw background
	draw_rect(Rect2(Vector2.ZERO, size), ocean_color, true)

	# Draw simplified continents (very basic)
	draw_simple_continents()

	# Draw routes
	for route in GameData.player_airline.routes if GameData.player_airline else []:
		draw_route(route)

func draw_simple_continents() -> void:
	"""Draw simplified continent shapes"""
	# This is a very simplified representation
	# North America
	var na_points: PackedVector2Array = [
		Vector2(100, 150),
		Vector2(300, 150),
		Vector2(350, 350),
		Vector2(100, 350)
	]
	draw_colored_polygon(na_points, land_color)

	# Europe
	var eu_points: PackedVector2Array = [
		Vector2(450, 100),
		Vector2(580, 100),
		Vector2(580, 250),
		Vector2(450, 250)
	]
	draw_colored_polygon(eu_points, land_color)

	# Asia
	var as_points: PackedVector2Array = [
		Vector2(600, 100),
		Vector2(850, 100),
		Vector2(850, 350),
		Vector2(600, 350)
	]
	draw_colored_polygon(as_points, land_color)

func draw_route(route: Route) -> void:
	"""Draw a route line between two airports"""
	if not route.from_airport or not route.to_airport:
		return

	var from_pos: Vector2 = route.from_airport.position_2d
	var to_pos: Vector2 = route.to_airport.position_2d

	if from_pos == Vector2.ZERO or to_pos == Vector2.ZERO:
		return

	# Draw line with color based on profitability
	var line_color: Color = Color.GREEN if route.weekly_profit > 0 else Color.RED
	line_color.a = 0.6

	draw_line(from_pos, to_pos, line_color, 2.0)

	# Draw direction arrow
	var direction: Vector2 = (to_pos - from_pos).normalized()
	var mid_point: Vector2 = (from_pos + to_pos) / 2.0
	var arrow_size: float = 10.0

	var arrow_left: Vector2 = mid_point - direction * arrow_size + direction.rotated(PI/2) * arrow_size * 0.5
	var arrow_right: Vector2 = mid_point - direction * arrow_size - direction.rotated(PI/2) * arrow_size * 0.5

	var arrow_points: PackedVector2Array = [mid_point, arrow_left, arrow_right]
	draw_colored_polygon(arrow_points, line_color)

func setup_airports() -> void:
	"""Create visual markers for all airports"""
	var map_size: Vector2 = size

	for airport in GameData.airports:
		# Calculate screen position
		airport.position_2d = GameData.lat_lon_to_screen(airport.latitude, airport.longitude, map_size)

		# Create marker
		create_airport_marker(airport)

	queue_redraw()

func create_airport_marker(airport: Airport) -> void:
	"""Create a visual marker for an airport"""
	var marker: Control = Control.new()
	marker.custom_minimum_size = Vector2(24, 24)
	marker.position = airport.position_2d - Vector2(12, 12)
	marker.mouse_filter = Control.MOUSE_FILTER_STOP
	marker.set_meta("airport", airport)

	# Store reference
	airport_markers[airport.iata_code] = marker

	# Connect mouse events
	marker.gui_input.connect(_on_airport_marker_input.bind(airport))
	marker.mouse_entered.connect(_on_airport_marker_mouse_entered.bind(airport))
	marker.mouse_exited.connect(_on_airport_marker_mouse_exited)

	# Custom draw for marker
	marker.draw.connect(_draw_airport_marker.bind(marker, airport))

	add_child(marker)

func _draw_airport_marker(marker: Control, airport: Airport) -> void:
	"""Draw an individual airport marker"""
	var center: Vector2 = Vector2(12, 12)
	var radius: float = 6.0

	# Color based on size
	var color: Color = Color.YELLOW
	if airport.size >= 11:
		color = Color.ORANGE
		radius = 8.0
	elif airport.size >= 8:
		color = Color.GOLD
		radius = 7.0

	# Highlight if selected or hovered
	if airport == selected_airport:
		marker.draw_circle(center, radius + 3, Color.WHITE)
	elif airport == hover_airport:
		marker.draw_circle(center, radius + 2, Color.LIGHT_GRAY)

	# Draw main circle
	marker.draw_circle(center, radius, color)

	# Draw IATA code
	var font_size: int = 10
	marker.draw_string(ThemeDB.fallback_font, Vector2(center.x - 10, center.y - 10), airport.iata_code, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)

func _on_airport_marker_input(event: InputEvent, airport: Airport) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_airport_clicked(airport)

func _on_airport_marker_mouse_entered(airport: Airport) -> void:
	hover_airport = airport
	airport_hovered.emit(airport)
	queue_redraw()

	# Redraw the specific marker
	if airport.iata_code in airport_markers:
		airport_markers[airport.iata_code].queue_redraw()

func _on_airport_marker_mouse_exited() -> void:
	if hover_airport:
		var prev_hover: Airport = hover_airport
		hover_airport = null
		if prev_hover.iata_code in airport_markers:
			airport_markers[prev_hover.iata_code].queue_redraw()

func _on_airport_clicked(airport: Airport) -> void:
	# If we have a selected airport and click another, create route
	if selected_airport != null and selected_airport != airport:
		route_created.emit(selected_airport, airport)
		selected_airport = null
		queue_redraw()
		# Redraw all markers
		for marker in airport_markers.values():
			marker.queue_redraw()
	else:
		# Select this airport
		var prev_selected: Airport = selected_airport
		selected_airport = airport
		airport_clicked.emit(airport)

		# Redraw affected markers
		if prev_selected and prev_selected.iata_code in airport_markers:
			airport_markers[prev_selected.iata_code].queue_redraw()
		if airport.iata_code in airport_markers:
			airport_markers[airport.iata_code].queue_redraw()

func refresh_routes() -> void:
	"""Redraw all routes"""
	queue_redraw()

func clear_selection() -> void:
	"""Clear airport selection"""
	if selected_airport:
		var prev: Airport = selected_airport
		selected_airport = null
		if prev.iata_code in airport_markers:
			airport_markers[prev.iata_code].queue_redraw()
