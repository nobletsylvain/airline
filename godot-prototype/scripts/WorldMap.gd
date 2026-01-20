extends Control

## World map visualization with airports and routes - Enhanced with zoom and better graphics

@export var airport_marker_scene: PackedScene
@export var background_color: Color = Color(0.1, 0.15, 0.2)
@export var ocean_color: Color = Color(0.15, 0.25, 0.35)
@export var land_color: Color = Color(0.25, 0.35, 0.3)

var airport_markers: Dictionary = {}  # iata_code -> AirportMarker node
var route_lines: Array[Line2D] = []
var selected_airport: Airport = null
var hover_airport: Airport = null
var hover_route: Route = null
var selected_route: Route = null
var preview_mouse_pos: Vector2 = Vector2.ZERO  # Track mouse for preview line

# Plane animation system
var plane_sprites: Array[PlaneSprite] = []
var hover_plane: PlaneSprite = null
var last_route_count: int = 0  # Track when routes change to respawn planes

# Route visualization settings
var show_route_labels: bool = true
var show_profitability_colors: bool = true
var show_capacity_thickness: bool = true

# Zoom and pan variables
var zoom_level: float = 1.0
var min_zoom: float = 0.5
var max_zoom: float = 3.0
var zoom_step: float = 0.2
var pan_offset: Vector2 = Vector2.ZERO
var is_panning: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO

signal airport_clicked(airport: Airport)
signal airport_hovered(airport: Airport)
signal route_created(from_airport: Airport, to_airport: Airport)
signal route_clicked(route: Route)
signal route_hovered(route: Route)

func _ready() -> void:
	custom_minimum_size = Vector2(1000, 600)
	mouse_filter = Control.MOUSE_FILTER_PASS
	clip_contents = true  # Clip content outside bounds

	# Wait for GameData to initialize
	if GameData.airports.is_empty():
		await GameData.game_initialized

	# Wait one frame for the control to be properly sized
	await get_tree().process_frame
	setup_airports()

	# Enable processing for plane animations
	set_process(true)

func _gui_input(event: InputEvent) -> void:
	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_at_point(event.position, zoom_step)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_at_point(event.position, -zoom_step)
			accept_event()
		# Handle panning with right mouse button
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_panning = true
				last_mouse_pos = event.position
			else:
				is_panning = false
			accept_event()
		# Handle left click for route selection
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_panning:
			var world_pos: Vector2 = screen_to_world(event.position)
			var clicked_route: Route = find_route_at_position(world_pos)
			if clicked_route:
				selected_route = clicked_route
				route_clicked.emit(clicked_route)
				queue_redraw()
				accept_event()

	# Handle mouse motion for hover and panning
	if event is InputEventMouseMotion:
		# Update preview mouse position
		preview_mouse_pos = screen_to_world(event.position)

		if is_panning:
			# Pan dragging
			var delta: Vector2 = event.position - last_mouse_pos
			pan_offset += delta
			last_mouse_pos = event.position
			update_airport_positions()
			queue_redraw()
			accept_event()
		else:
			# Check for route hover
			var world_pos: Vector2 = screen_to_world(event.position)
			var hovered_route: Route = find_route_at_position(world_pos)
			if hovered_route != hover_route:
				hover_route = hovered_route
				if hover_route:
					route_hovered.emit(hover_route)
				queue_redraw()

			# Redraw if airport is selected (for preview line)
			if selected_airport:
				queue_redraw()

func _process(delta: float) -> void:
	"""Update plane positions each frame"""
	# Check if routes have changed (need to respawn planes)
	var current_route_count: int = get_total_route_count()
	if current_route_count != last_route_count:
		spawn_planes()
		last_route_count = current_route_count

	# Calculate current hour within the week
	var current_week_hour: float = get_current_week_hour()

	# Update all plane positions
	for plane in plane_sprites:
		plane.update_position(current_week_hour)

	# Check for plane hover
	update_plane_hover()

	# Redraw to show updated plane positions
	queue_redraw()

func get_total_route_count() -> int:
	"""Count total routes across all airlines"""
	var count: int = 0
	for airline in GameData.airlines:
		count += airline.routes.size()
	return count

func get_current_week_hour() -> float:
	"""Calculate current hour within the week (0-168)"""
	if not GameData.simulation_engine:
		return 0.0

	var progress_through_week: float = GameData.simulation_engine.time_accumulator / GameData.simulation_engine.week_duration
	return progress_through_week * 168.0  # 168 hours in a week

func spawn_planes() -> void:
	"""Create plane sprites for all active routes"""
	# Clear existing planes
	plane_sprites.clear()

	# Spawn planes for all airlines
	for airline in GameData.airlines:
		for route in airline.routes:
			# Create one plane per flight frequency
			for i in range(route.frequency):
				var plane: PlaneSprite = PlaneSprite.new(route, airline, i)
				plane_sprites.append(plane)

	print("Spawned %d plane sprites" % plane_sprites.size())

func update_plane_hover() -> void:
	"""Check if mouse is hovering over any plane"""
	if is_panning:
		hover_plane = null
		return

	var mouse_pos: Vector2 = get_local_mouse_position()
	var world_pos: Vector2 = screen_to_world(mouse_pos)

	var closest_plane: PlaneSprite = null
	var closest_distance: float = 15.0 / zoom_level  # Hover threshold

	for plane in plane_sprites:
		if not plane.is_active:
			continue

		var plane_pos: Vector2 = plane.get_current_position(size)
		var distance: float = world_pos.distance_to(plane_pos)

		if distance < closest_distance:
			closest_distance = distance
			closest_plane = plane

	hover_plane = closest_plane

func zoom_at_point(point: Vector2, delta: float) -> void:
	"""Zoom in/out at a specific point"""
	var old_zoom: float = zoom_level
	zoom_level = clamp(zoom_level + delta, min_zoom, max_zoom)

	if old_zoom != zoom_level:
		# Adjust pan to zoom toward the mouse position
		var zoom_factor: float = zoom_level / old_zoom
		pan_offset = point + (pan_offset - point) * zoom_factor

		update_airport_positions()
		queue_redraw()

func _draw() -> void:
	# Draw background (ocean)
	draw_rect(Rect2(Vector2.ZERO, size), ocean_color, true)

	# Apply zoom and pan transformation
	draw_set_transform(pan_offset, 0.0, Vector2(zoom_level, zoom_level))

	# Draw continents with better Mercator projection
	draw_world_continents()

	# Draw routes (player and competitors)
	draw_all_routes()

	# Draw route preview if airport is selected
	draw_route_preview()

	# Draw animated planes
	draw_all_planes()

	# Reset transformation for UI elements
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Draw plane tooltip (after reset, so it's not affected by zoom)
	draw_plane_tooltip()

func draw_world_continents() -> void:
	"""Draw continents using Mercator projection with better shapes"""
	var map_size: Vector2 = size

	# North America (approximate outline)
	var na_points: PackedVector2Array = [
		latlon_to_screen(70, -170, map_size),   # Alaska
		latlon_to_screen(75, -100, map_size),   # North Canada
		latlon_to_screen(50, -65, map_size),    # East Canada
		latlon_to_screen(45, -70, map_size),    # Nova Scotia
		latlon_to_screen(25, -80, map_size),    # Florida
		latlon_to_screen(20, -90, map_size),    # Mexico Gulf
		latlon_to_screen(15, -95, map_size),    # Central America
		latlon_to_screen(30, -115, map_size),   # California
		latlon_to_screen(50, -125, map_size),   # Pacific Northwest
		latlon_to_screen(60, -140, map_size),   # Alaska South
	]
	draw_colored_polygon(na_points, land_color)

	# South America
	var sa_points: PackedVector2Array = [
		latlon_to_screen(10, -75, map_size),    # Colombia
		latlon_to_screen(-5, -80, map_size),    # Peru
		latlon_to_screen(-35, -70, map_size),   # Chile
		latlon_to_screen(-55, -70, map_size),   # Cape Horn
		latlon_to_screen(-35, -55, map_size),   # Argentina East
		latlon_to_screen(-5, -35, map_size),    # Brazil East
		latlon_to_screen(5, -50, map_size),     # North Brazil
	]
	draw_colored_polygon(sa_points, land_color)

	# Europe
	var eu_points: PackedVector2Array = [
		latlon_to_screen(70, 25, map_size),     # Northern Norway
		latlon_to_screen(60, 30, map_size),     # Finland
		latlon_to_screen(55, 15, map_size),     # Denmark
		latlon_to_screen(50, 5, map_size),      # UK/France
		latlon_to_screen(45, -10, map_size),    # Spain
		latlon_to_screen(36, -5, map_size),     # Gibraltar
		latlon_to_screen(36, 15, map_size),     # Sicily
		latlon_to_screen(42, 25, map_size),     # Greece
		latlon_to_screen(45, 30, map_size),     # Black Sea
		latlon_to_screen(50, 40, map_size),     # Russia West
		latlon_to_screen(65, 40, map_size),     # Russia North
	]
	draw_colored_polygon(eu_points, land_color)

	# Africa
	var af_points: PackedVector2Array = [
		latlon_to_screen(35, -5, map_size),     # Morocco
		latlon_to_screen(30, 10, map_size),     # Libya
		latlon_to_screen(32, 30, map_size),     # Egypt
		latlon_to_screen(15, 45, map_size),     # Horn of Africa
		latlon_to_screen(-5, 40, map_size),     # Kenya
		latlon_to_screen(-35, 25, map_size),    # South Africa East
		latlon_to_screen(-35, 18, map_size),    # Cape of Good Hope
		latlon_to_screen(-15, 12, map_size),    # Angola
		latlon_to_screen(5, 10, map_size),      # West Africa
		latlon_to_screen(10, -15, map_size),    # Senegal
	]
	draw_colored_polygon(af_points, land_color)

	# Asia (Main landmass)
	var asia_points: PackedVector2Array = [
		latlon_to_screen(70, 60, map_size),     # Russia North
		latlon_to_screen(75, 100, map_size),    # Siberia
		latlon_to_screen(70, 140, map_size),    # East Siberia
		latlon_to_screen(60, 160, map_size),    # Kamchatka
		latlon_to_screen(45, 135, map_size),    # Manchuria
		latlon_to_screen(35, 140, map_size),    # Japan area
		latlon_to_screen(20, 110, map_size),    # South China
		latlon_to_screen(1, 105, map_size),     # Malaysia
		latlon_to_screen(10, 80, map_size),     # India South
		latlon_to_screen(25, 70, map_size),     # India
		latlon_to_screen(30, 50, map_size),     # Iran
		latlon_to_screen(40, 45, map_size),     # Caucasus
	]
	draw_colored_polygon(asia_points, land_color)

	# Australia
	var au_points: PackedVector2Array = [
		latlon_to_screen(-10, 130, map_size),   # North
		latlon_to_screen(-15, 145, map_size),   # Queensland
		latlon_to_screen(-38, 148, map_size),   # Victoria
		latlon_to_screen(-43, 145, map_size),   # Tasmania
		latlon_to_screen(-35, 115, map_size),   # Perth
		latlon_to_screen(-20, 115, map_size),   # West Coast
	]
	draw_colored_polygon(au_points, land_color)

func latlon_to_screen(lat: float, lon: float, map_size: Vector2) -> Vector2:
	"""Helper function to convert lat/lon to screen coordinates"""
	return GameData.lat_lon_to_screen(lat, lon, map_size)

func draw_all_routes() -> void:
	"""Draw routes for player and all AI competitors with different colors"""
	# Draw AI competitor routes first (so player routes are on top)
	for airline in GameData.airlines:
		if airline == GameData.player_airline:
			continue

		# Assign color based on airline
		var route_color: Color = get_airline_color(airline)

		for route in airline.routes:
			draw_single_route(route, route_color)

	# Draw player routes last (on top)
	if GameData.player_airline:
		for route in GameData.player_airline.routes:
			# Color based on profitability
			var route_color: Color = Color.GREEN if route.weekly_profit > 0 else Color.RED
			draw_single_route(route, route_color)

func get_airline_color(airline: Airline) -> Color:
	"""Get a unique color for each AI airline"""
	# Simple hash-based coloring
	var hash: int = airline.name.hash()
	var hue: float = (hash % 360) / 360.0
	return Color.from_hsv(hue, 0.7, 0.8, 0.5)

func draw_single_route(route: Route, base_color: Color) -> void:
	"""Draw a single route line with enhanced visualization"""
	if not route.from_airport or not route.to_airport:
		return

	var from_pos: Vector2 = route.from_airport.position_2d
	var to_pos: Vector2 = route.to_airport.position_2d

	if from_pos == Vector2.ZERO or to_pos == Vector2.ZERO:
		return

	# Determine line color based on profitability
	var line_color: Color = base_color
	if show_profitability_colors and route.airline_id == GameData.player_airline.id:
		# Color code player routes by profitability
		if route.weekly_profit > 100000:  # High profit
			line_color = Color(0.2, 1.0, 0.3, 0.8)  # Bright green
		elif route.weekly_profit > 0:  # Profit
			line_color = Color(0.6, 0.9, 0.4, 0.7)  # Light green
		elif route.weekly_profit > -50000:  # Small loss
			line_color = Color(1.0, 0.8, 0.2, 0.7)  # Yellow
		else:  # Big loss
			line_color = Color(1.0, 0.3, 0.2, 0.8)  # Red
	else:
		line_color.a = 0.5  # AI airline routes more transparent

	# Determine line thickness based on capacity or frequency
	var line_thickness: float = 2.0
	if show_capacity_thickness:
		var total_capacity: int = route.get_total_capacity() * route.frequency
		line_thickness = 1.5 + (total_capacity / 500.0)  # Scale: 1.5-6.0
		line_thickness = clamp(line_thickness, 1.5, 6.0)

	# Apply zoom adjustment
	line_thickness = line_thickness / zoom_level

	# Highlight if hovered or selected
	if route == hover_route or route == selected_route:
		line_thickness *= 1.5
		line_color.a = 1.0
		line_color = line_color.lightened(0.2)

	# Draw line
	draw_line(from_pos, to_pos, line_color, line_thickness)

	# Draw direction arrow
	var direction: Vector2 = (to_pos - from_pos).normalized()
	var mid_point: Vector2 = (from_pos + to_pos) / 2.0
	var arrow_size: float = (8.0 + line_thickness * 2) / zoom_level

	var arrow_left: Vector2 = mid_point - direction * arrow_size + direction.rotated(PI/2) * arrow_size * 0.5
	var arrow_right: Vector2 = mid_point - direction * arrow_size - direction.rotated(PI/2) * arrow_size * 0.5

	var arrow_points: PackedVector2Array = [mid_point, arrow_left, arrow_right]
	draw_colored_polygon(arrow_points, line_color)

	# Draw route labels if enabled and zoomed in enough
	if show_route_labels and zoom_level > 1.0 and route.airline_id == GameData.player_airline.id:
		draw_route_label(route, mid_point, line_color)

func draw_route_label(route: Route, position: Vector2, color: Color) -> void:
	"""Draw informative label on route"""
	if not route:
		return

	# Create label text
	var label_text: String = ""

	# Show passengers transported
	if route.passengers_transported > 0:
		label_text = "%d pax" % route.passengers_transported

	# Show profit if significant
	if abs(route.weekly_profit) > 10000:
		var profit_str: String = "$%.0fK" % (route.weekly_profit / 1000.0)
		if route.weekly_profit > 0:
			profit_str = "+" + profit_str
		if label_text != "":
			label_text += " | " + profit_str
		else:
			label_text = profit_str

	# Show load factor if low or high
	var total_cap: int = route.get_total_capacity() * route.frequency
	if total_cap > 0:
		var load_factor: float = (route.passengers_transported / float(total_cap)) * 100.0
		if load_factor < 60 or load_factor > 95:
			var lf_str: String = "%.0f%%" % load_factor
			if label_text != "":
				label_text += " | " + lf_str
			else:
				label_text = lf_str

	if label_text == "":
		return

	# Draw text background
	var font_size: int = int(12 / zoom_level)
	var text_size: Vector2 = Vector2(label_text.length() * font_size * 0.6, font_size + 4)

	var bg_rect: Rect2 = Rect2(position - text_size / 2, text_size)
	var bg_color: Color = Color(0.0, 0.0, 0.0, 0.7)
	draw_rect(bg_rect, bg_color, true)

	# Draw text
	var text_color: Color = color.lightened(0.3)
	text_color.a = 1.0
	draw_string(ThemeDB.fallback_font, position - Vector2(text_size.x / 2, -text_size.y / 4), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

func draw_all_planes() -> void:
	"""Draw all active plane sprites"""
	for plane in plane_sprites:
		if plane.is_active:
			plane.draw_plane(self, zoom_level)

func draw_plane_tooltip() -> void:
	"""Draw tooltip for hovered plane"""
	if not hover_plane or not hover_plane.is_active:
		return

	# Get screen position of plane (with zoom and pan applied)
	var plane_world_pos: Vector2 = hover_plane.get_current_position(size)
	var plane_screen_pos: Vector2 = world_to_screen(plane_world_pos)

	# Get tooltip text
	var tooltip_text: String = hover_plane.get_tooltip_text()
	if tooltip_text == "":
		return

	# Calculate tooltip size
	var font_size: int = 12
	var lines: PackedStringArray = tooltip_text.split("\n")
	var max_width: float = 0.0
	for line in lines:
		var line_width: float = line.length() * font_size * 0.6
		max_width = max(max_width, line_width)

	var tooltip_size: Vector2 = Vector2(max_width + 16, lines.size() * (font_size + 4) + 12)

	# Position tooltip above and to the right of plane
	var tooltip_pos: Vector2 = plane_screen_pos + Vector2(15, -tooltip_size.y - 10)

	# Keep tooltip on screen
	if tooltip_pos.x + tooltip_size.x > size.x:
		tooltip_pos.x = plane_screen_pos.x - tooltip_size.x - 15
	if tooltip_pos.y < 0:
		tooltip_pos.y = plane_screen_pos.y + 20

	# Draw background
	var bg_rect: Rect2 = Rect2(tooltip_pos, tooltip_size)
	draw_rect(bg_rect, Color(0.0, 0.0, 0.0, 0.85), true)
	draw_rect(bg_rect, Color(1.0, 1.0, 1.0, 0.3), false, 1.0)

	# Draw text lines
	var y_offset: float = 8.0
	for line in lines:
		draw_string(
			ThemeDB.fallback_font,
			tooltip_pos + Vector2(8, y_offset + font_size),
			line,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			Color.WHITE
		)
		y_offset += font_size + 4

func draw_route_preview() -> void:
	"""Draw preview line when creating a route"""
	if not selected_airport:
		return

	# Don't draw preview if hovering over the selected airport itself
	if hover_airport == selected_airport:
		return

	var from_pos: Vector2 = selected_airport.position_2d
	var to_pos: Vector2 = preview_mouse_pos

	# If hovering over another airport, snap to that airport
	if hover_airport:
		to_pos = hover_airport.position_2d

	# Draw dashed preview line
	var line_color: Color = Color(0.4, 0.8, 1.0, 0.6)  # Light blue, semi-transparent
	var line_thickness: float = 2.5 / zoom_level

	# Draw as dashed line by drawing multiple segments
	var direction: Vector2 = to_pos - from_pos
	var distance: float = direction.length()
	var normalized_dir: Vector2 = direction.normalized()

	var dash_length: float = 15.0 / zoom_level
	var gap_length: float = 10.0 / zoom_level
	var current_distance: float = 0.0

	while current_distance < distance:
		var segment_start: Vector2 = from_pos + normalized_dir * current_distance
		var segment_end: Vector2 = from_pos + normalized_dir * min(current_distance + dash_length, distance)

		draw_line(segment_start, segment_end, line_color, line_thickness)

		current_distance += dash_length + gap_length

	# Draw distance label if hovering over another airport
	if hover_airport:
		var route_distance: float = MarketAnalysis.calculate_great_circle_distance(selected_airport, hover_airport)
		var mid_point: Vector2 = (from_pos + to_pos) / 2.0

		var distance_text: String = "%.0f km" % route_distance
		var font_size: int = int(14 / zoom_level)
		var text_size: Vector2 = Vector2(distance_text.length() * font_size * 0.6, font_size + 4)

		# Draw background
		var bg_rect: Rect2 = Rect2(mid_point - text_size / 2, text_size)
		draw_rect(bg_rect, Color(0.0, 0.0, 0.0, 0.7), true)

		# Draw text
		draw_string(ThemeDB.fallback_font, mid_point - Vector2(text_size.x / 2, -text_size.y / 4), distance_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

func setup_airports() -> void:
	"""Create visual markers for all airports"""
	var map_size: Vector2 = size
	print("WorldMap: Setting up airports. Map size: %s" % map_size)
	print("WorldMap: Number of airports: %d" % GameData.airports.size())

	for airport in GameData.airports:
		# Calculate screen position
		airport.position_2d = GameData.lat_lon_to_screen(airport.latitude, airport.longitude, map_size)
		print("  %s: lat/lon (%.2f, %.2f) -> screen pos %s" % [airport.iata_code, airport.latitude, airport.longitude, airport.position_2d])

		# Create marker
		create_airport_marker(airport)

	queue_redraw()

func update_airport_positions() -> void:
	"""Update airport marker positions based on zoom and pan"""
	for airport in GameData.airports:
		if airport.iata_code in airport_markers:
			var marker: Control = airport_markers[airport.iata_code]
			var transformed_pos: Vector2 = airport.position_2d * zoom_level + pan_offset
			marker.position = transformed_pos - Vector2(12, 12)  # Center the marker

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
	marker.queue_redraw()  # Force initial draw

func _draw_airport_marker(marker: Control, airport: Airport) -> void:
	"""Draw an individual airport marker"""
	var center: Vector2 = Vector2(12, 12)
	var radius: float = 6.0

	# Color and size based on hub tier
	var color: Color = Color.YELLOW
	if airport.hub_tier == 1:  # Mega Hub
		color = Color.ORANGE
		radius = 9.0
	elif airport.hub_tier == 2:  # Major Hub
		color = Color.GOLD
		radius = 7.5
	elif airport.hub_tier == 3:  # Regional Hub
		color = Color.YELLOW
		radius = 6.5

	# Check if this is a player hub
	var is_player_hub: bool = false
	if GameData.player_airline:
		is_player_hub = GameData.player_airline.has_hub(airport)

	# Draw player hub indicator (double ring)
	if is_player_hub:
		# Outer ring (airline primary color)
		var hub_ring_outer: float = radius + 4.5
		var hub_ring_inner: float = radius + 2.5
		marker.draw_arc(center, hub_ring_outer, 0, TAU, 32, GameData.player_airline.primary_color, 2.0, true)

		# Inner ring (white)
		marker.draw_arc(center, hub_ring_inner, 0, TAU, 32, Color.WHITE, 1.5, true)

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

func screen_to_world(screen_pos: Vector2) -> Vector2:
	"""Convert screen coordinates to world coordinates (accounting for zoom and pan)"""
	return (screen_pos - pan_offset) / zoom_level

func world_to_screen(world_pos: Vector2) -> Vector2:
	"""Convert world coordinates to screen coordinates"""
	return world_pos * zoom_level + pan_offset

func find_route_at_position(world_pos: Vector2, threshold: float = 10.0) -> Route:
	"""Find route near the given world position"""
	# Adjust threshold for zoom level
	var adjusted_threshold: float = threshold / zoom_level

	var closest_route: Route = null
	var closest_distance: float = adjusted_threshold

	# Check player routes first (priority)
	if GameData.player_airline:
		for route in GameData.player_airline.routes:
			var distance: float = distance_to_route_line(world_pos, route)
			if distance < closest_distance:
				closest_distance = distance
				closest_route = route

	# Check AI routes if no player route found
	if not closest_route:
		for airline in GameData.airlines:
			if airline == GameData.player_airline:
				continue
			for route in airline.routes:
				var distance: float = distance_to_route_line(world_pos, route)
				if distance < closest_distance:
					closest_distance = distance
					closest_route = route

	return closest_route

func distance_to_route_line(point: Vector2, route: Route) -> float:
	"""Calculate perpendicular distance from point to route line"""
	if not route.from_airport or not route.to_airport:
		return INF

	var from_pos: Vector2 = route.from_airport.position_2d
	var to_pos: Vector2 = route.to_airport.position_2d

	if from_pos == Vector2.ZERO or to_pos == Vector2.ZERO:
		return INF

	# Calculate distance from point to line segment
	var line_vec: Vector2 = to_pos - from_pos
	var point_vec: Vector2 = point - from_pos
	var line_len: float = line_vec.length()

	if line_len == 0:
		return point_vec.length()

	# Project point onto line
	var t: float = clamp(point_vec.dot(line_vec) / (line_len * line_len), 0.0, 1.0)
	var projection: Vector2 = from_pos + t * line_vec

	# Return distance to projection
	return point.distance_to(projection)
