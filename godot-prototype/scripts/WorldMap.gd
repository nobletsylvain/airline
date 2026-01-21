extends Control

## World map visualization with airports and routes - Using OpenStreetMap tiles with bounds

@export var airport_marker_scene: PackedScene
@export var background_color: Color = Color(0.05, 0.1, 0.2)  # Deep ocean blue

var airport_markers: Dictionary = {}  # iata_code -> AirportMarker node
var route_lines: Array[Line2D] = []
var selected_airport: Airport = null
var hover_airport: Airport = null
var hover_route: Route = null
var selected_route: Route = null
var preview_mouse_pos: Vector2 = Vector2.ZERO  # Track mouse for preview line

# Floating info panel
var floating_panel: PanelContainer = null
var floating_panel_position: Vector2 = Vector2.ZERO
var floating_panel_target: Variant = null  # Can be Airport or Route

# OpenStreetMap tile system
var tile_manager: MapTileManager = null
var osm_zoom: int = 2  # OSM zoom level (0-19, 2 = world view)
var min_osm_zoom: int = 1
var max_osm_zoom: int = 6
var zoom_scale: float = 1.0  # Sub-zoom scale (0.7 to 1.4) for smoother zooming
var zoom_sensitivity: float = 0.08  # How much each scroll changes zoom_scale

# Plane animation system
var plane_sprites: Array[PlaneSprite] = []
var hover_plane: PlaneSprite = null
var last_route_count: int = 0  # Track when routes change to respawn planes
var plane_texture: Texture2D = null  # Loaded airplane icon

# Route visualization settings
var show_route_labels: bool = true
var show_profitability_colors: bool = true
var show_capacity_thickness: bool = true

# Zoom and pan variables
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

	# Initialize tile manager
	tile_manager = MapTileManager.new()
	add_child(tile_manager)
	tile_manager.tile_loaded.connect(_on_tile_loaded)

	# Load plane texture
	plane_texture = load("res://assets/icons/airplane.png")

	# Wait for GameData to initialize
	if GameData.airports.is_empty():
		await GameData.game_initialized

	# Wait one frame for the control to be properly sized
	await get_tree().process_frame

	# Center map on the world and ensure it fills the viewport
	_fit_map_to_viewport()
	setup_airports()

	# Enable processing for plane animations
	set_process(true)

	# Create floating info panel
	create_floating_panel()

func _fit_map_to_viewport() -> void:
	"""Fit the map to fill the viewport while maintaining bounds"""
	# Calculate minimum zoom to fill the viewport
	var world_size = get_world_size()

	# Ensure the map fills the entire viewport
	while world_size.x < size.x or world_size.y < size.y:
		if osm_zoom < max_osm_zoom:
			osm_zoom += 1
			world_size = get_world_size()
		else:
			break

	# Center the map
	pan_offset = (size - world_size) / 2.0

	# Constrain pan to bounds
	_constrain_pan()

func get_world_size() -> Vector2:
	"""Get the world size in pixels at current zoom level with sub-zoom scale"""
	var world_pixels = MapTileManager.get_world_size_pixels(osm_zoom) * zoom_scale
	return Vector2(world_pixels, world_pixels)

func _on_tile_loaded(_z: int, _x: int, _y: int, _texture: ImageTexture) -> void:
	"""Redraw when a new tile is loaded"""
	queue_redraw()

func _constrain_pan() -> void:
	"""Constrain pan offset so the map never leaves the viewport"""
	var world_size = get_world_size()

	# If map is smaller than viewport, center it
	if world_size.x <= size.x:
		pan_offset.x = (size.x - world_size.x) / 2.0
	else:
		# Map is larger than viewport - constrain edges
		# Right edge: pan_offset.x + world_size.x >= size.x
		# Left edge: pan_offset.x <= 0
		pan_offset.x = clamp(pan_offset.x, size.x - world_size.x, 0)

	if world_size.y <= size.y:
		pan_offset.y = (size.y - world_size.y) / 2.0
	else:
		# Bottom edge: pan_offset.y + world_size.y >= size.y
		# Top edge: pan_offset.y <= 0
		pan_offset.y = clamp(pan_offset.y, size.y - world_size.y, 0)

func _gui_input(event: InputEvent) -> void:
	# Handle ESC key to dismiss floating panel and clear selection
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if floating_panel and floating_panel.visible:
			hide_floating_panel()
			accept_event()
			return
		elif selected_airport:
			clear_selection()
			queue_redraw()
			accept_event()
			return

	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_at_point(event.position, 1)  # Zoom in
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_at_point(event.position, -1)  # Zoom out
			accept_event()
		# Handle panning with right mouse button
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_panning = true
				last_mouse_pos = event.position
			else:
				is_panning = false
			accept_event()
		# Handle left click for route selection or dismiss floating panel
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_panning:
			var world_pos: Vector2 = screen_to_world(event.position)
			var clicked_route: Route = find_route_at_position(world_pos)
			if clicked_route:
				hide_floating_panel()
				selected_route = clicked_route
				# Show floating panel for route
				show_floating_panel_for_route(clicked_route, event.position)
				route_clicked.emit(clicked_route)
				queue_redraw()
				accept_event()
			elif floating_panel and floating_panel.visible:
				# Click elsewhere dismisses floating panel
				hide_floating_panel()
				queue_redraw()

	# Handle mouse motion for hover and panning
	if event is InputEventMouseMotion:
		# Update preview mouse position
		preview_mouse_pos = screen_to_world(event.position)

		if is_panning:
			# Pan dragging
			var delta: Vector2 = event.position - last_mouse_pos
			pan_offset += delta
			_constrain_pan()  # Keep map in bounds
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

func _process(_delta: float) -> void:
	"""Update plane positions each frame"""
	# Check if routes have changed (need to respawn planes)
	var current_route_count: int = get_total_route_count()
	if current_route_count != last_route_count:
		spawn_planes()
		last_route_count = current_route_count

	# Calculate current hour within the week (synced with simulation)
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
	"""Calculate current hour within the week (0-168) for plane animations"""
	# Sync with simulation time
	if GameData.simulation_engine:
		return GameData.simulation_engine.get_current_week_hour()
	return 0.0

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

	var closest_plane: PlaneSprite = null
	var closest_distance: float = 20.0  # Hover threshold in screen pixels

	for plane in plane_sprites:
		if not plane.is_active:
			continue

		var plane_world_pos: Vector2 = plane.get_current_position(size)
		var plane_screen_pos: Vector2 = world_to_screen(plane_world_pos)
		var distance: float = mouse_pos.distance_to(plane_screen_pos)

		if distance < closest_distance:
			closest_distance = distance
			closest_plane = plane

	hover_plane = closest_plane

func zoom_at_point(point: Vector2, direction: int) -> void:
	"""Zoom in/out at a specific point with smooth sub-zoom scaling"""
	var old_osm_zoom: int = osm_zoom
	var old_zoom_scale: float = zoom_scale

	# Get the world position at the mouse before zoom change
	var mouse_world_before = screen_to_world(point)

	# Apply smooth zoom change
	if direction > 0:
		zoom_scale *= (1.0 + zoom_sensitivity)
	else:
		zoom_scale /= (1.0 + zoom_sensitivity)

	# Check if we need to change OSM zoom level
	if zoom_scale > 1.4 and osm_zoom < max_osm_zoom:
		osm_zoom += 1
		zoom_scale = 0.7  # Reset to lower bound (0.7 * 2 = 1.4)
	elif zoom_scale < 0.7 and osm_zoom > min_osm_zoom:
		osm_zoom -= 1
		zoom_scale = 1.4  # Reset to upper bound

	# Clamp zoom_scale to valid range
	zoom_scale = clamp(zoom_scale, 0.7, 1.4)

	# Check minimum zoom to ensure map fills viewport
	var world_size = get_world_size()
	while (world_size.x < size.x or world_size.y < size.y):
		if zoom_scale < 1.4:
			zoom_scale *= (1.0 + zoom_sensitivity)
			if zoom_scale > 1.4:
				zoom_scale = 0.7
				if osm_zoom < max_osm_zoom:
					osm_zoom += 1
				else:
					zoom_scale = 1.4
					break
		elif osm_zoom < max_osm_zoom:
			osm_zoom += 1
			zoom_scale = 0.7
		else:
			break
		world_size = get_world_size()

	# Calculate the effective zoom change for repositioning
	var old_effective_zoom = old_zoom_scale * pow(2, old_osm_zoom)
	var new_effective_zoom = zoom_scale * pow(2, osm_zoom)

	if old_effective_zoom != new_effective_zoom:
		# Scale the mouse world position by the zoom ratio
		var zoom_ratio = new_effective_zoom / old_effective_zoom
		var mouse_world_after = mouse_world_before * zoom_ratio

		# Adjust pan so the point under mouse stays in place
		pan_offset = point - mouse_world_after

		# Constrain pan to keep map in bounds
		_constrain_pan()

		update_airport_positions()
		queue_redraw()

func _draw() -> void:
	# Draw background (ocean color as fallback)
	draw_rect(Rect2(Vector2.ZERO, size), background_color, true)

	# Draw map tiles
	draw_map_tiles()

	# Draw routes (player and competitors)
	draw_all_routes()

	# Draw route preview if airport is selected
	draw_route_preview()

	# Draw animated planes
	draw_all_planes()

	# Draw plane tooltip
	draw_plane_tooltip()

func draw_map_tiles() -> void:
	"""Draw visible OpenStreetMap tiles with sub-zoom scaling"""
	if not tile_manager:
		return

	var tile_size = MapTileManager.TILE_SIZE
	var scaled_tile_size = tile_size * zoom_scale

	# Calculate visible tile range based on screen bounds (in unscaled tile coordinates)
	var top_left = screen_to_world(Vector2.ZERO) / zoom_scale
	var bottom_right = screen_to_world(size) / zoom_scale

	var start_tile_x = int(floor(top_left.x / tile_size))
	var start_tile_y = int(floor(top_left.y / tile_size))
	var end_tile_x = int(ceil(bottom_right.x / tile_size))
	var end_tile_y = int(ceil(bottom_right.y / tile_size))

	# Clamp to valid tile range
	var max_tile = int(pow(2, osm_zoom)) - 1
	start_tile_x = clampi(start_tile_x, 0, max_tile)
	start_tile_y = clampi(start_tile_y, 0, max_tile)
	end_tile_x = clampi(end_tile_x, 0, max_tile)
	end_tile_y = clampi(end_tile_y, 0, max_tile)

	# Draw tiles with scaling
	for ty in range(start_tile_y, end_tile_y + 1):
		for tx in range(start_tile_x, end_tile_x + 1):
			var texture = tile_manager.get_tile(osm_zoom, tx, ty)
			# Calculate screen position for this tile (accounting for zoom_scale)
			var tile_world_pos = Vector2(tx * tile_size, ty * tile_size) * zoom_scale
			var screen_pos = world_to_screen(tile_world_pos)

			if texture:
				# Draw scaled tile
				var dest_rect = Rect2(screen_pos, Vector2(scaled_tile_size, scaled_tile_size))
				draw_texture_rect(texture, dest_rect, false)

# Coordinate conversion functions for OSM tile system

func lat_lon_to_pixel(lat: float, lon: float) -> Vector2:
	"""Convert lat/lon to world pixel coordinates at current zoom with sub-zoom scale"""
	var base_pixel = MapTileManager.lat_lon_to_pixel(lat, lon, osm_zoom)
	return base_pixel * zoom_scale

func pixel_to_lat_lon(pixel: Vector2) -> Vector2:
	"""Convert world pixel coordinates to lat/lon at current zoom"""
	var base_pixel = pixel / zoom_scale
	return MapTileManager.pixel_to_lat_lon(base_pixel, osm_zoom)

func lat_lon_to_screen_pos(lat: float, lon: float) -> Vector2:
	"""Convert lat/lon to screen position"""
	var pixel = lat_lon_to_pixel(lat, lon)
	return world_to_screen(pixel)

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

	# Convert world positions to screen positions
	var from_pos: Vector2 = world_to_screen(route.from_airport.position_2d)
	var to_pos: Vector2 = world_to_screen(route.to_airport.position_2d)

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

	# Highlight if hovered or selected
	if route == hover_route or route == selected_route:
		line_thickness *= 1.5
		line_color.a = 1.0
		line_color = line_color.lightened(0.2)

	# Draw line
	draw_line(from_pos, to_pos, line_color, line_thickness)

	# Calculate midpoint and direction for labels
	var direction: Vector2 = (to_pos - from_pos).normalized()
	var mid_point: Vector2 = (from_pos + to_pos) / 2.0

	# Draw route labels if enabled and zoomed in enough
	# Offset label perpendicular to route to avoid overlapping with planes
	if show_route_labels and osm_zoom >= 4 and route.airline_id == GameData.player_airline.id:
		var perpendicular: Vector2 = direction.rotated(PI / 2).normalized()
		var label_offset: Vector2 = perpendicular * 25  # Offset 25 pixels perpendicular to route
		draw_route_label(route, mid_point + label_offset, line_color)

func draw_route_label(route: Route, position: Vector2, color: Color) -> void:
	"""Draw informative label on route (offset from route line to avoid planes)"""
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
	var font_size: int = 12
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
			# Get plane position in world coordinates and convert to screen
			var world_pos = plane.get_current_position(size)
			var screen_pos = world_to_screen(world_pos)
			draw_plane_at(plane, screen_pos)

func draw_plane_at(plane: PlaneSprite, screen_pos: Vector2) -> void:
	"""Draw a plane sprite using texture"""
	if not plane_texture:
		return

	var angle: float = plane.get_rotation_angle()
	var pos: Vector2 = screen_pos

	# Scale the texture (original is 16x16, scale up for visibility)
	var icon_size: float = 32.0
	var tex_size: Vector2 = Vector2(icon_size, icon_size)

	# Create transform for rotation around center
	# The texture points up by default, so we need to rotate it to point right (0 angle) first
	# then add the flight angle
	var rotation_offset: float = -PI / 2  # Rotate from "up" to "right" orientation
	var total_rotation: float = angle + rotation_offset

	# Draw with rotation using draw_set_transform
	var center_offset: Vector2 = tex_size / 2
	draw_set_transform(pos, total_rotation, Vector2.ONE)
	draw_texture_rect(plane_texture, Rect2(-center_offset, tex_size), false, plane.plane_color)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)  # Reset transform

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

	var from_pos: Vector2 = world_to_screen(selected_airport.position_2d)
	var to_pos: Vector2 = get_local_mouse_position()

	# If hovering over another airport, snap to that airport
	if hover_airport:
		to_pos = world_to_screen(hover_airport.position_2d)

	# Draw dashed preview line
	var line_color: Color = Color(0.4, 0.8, 1.0, 0.6)  # Light blue, semi-transparent
	var line_thickness: float = 2.5

	# Draw as dashed line by drawing multiple segments
	var direction: Vector2 = to_pos - from_pos
	var total_distance: float = direction.length()
	var normalized_dir: Vector2 = direction.normalized()

	var dash_length: float = 15.0
	var gap_length: float = 10.0
	var current_distance: float = 0.0

	while current_distance < total_distance:
		var segment_start: Vector2 = from_pos + normalized_dir * current_distance
		var segment_end: Vector2 = from_pos + normalized_dir * min(current_distance + dash_length, total_distance)

		draw_line(segment_start, segment_end, line_color, line_thickness)

		current_distance += dash_length + gap_length

	# Draw distance label if hovering over another airport
	if hover_airport:
		var route_distance: float = MarketAnalysis.calculate_great_circle_distance(selected_airport, hover_airport)
		var mid_point: Vector2 = (from_pos + to_pos) / 2.0

		var distance_text: String = "%.0f km" % route_distance
		var font_size: int = 14
		var text_size: Vector2 = Vector2(distance_text.length() * font_size * 0.6, font_size + 4)

		# Draw background
		var bg_rect: Rect2 = Rect2(mid_point - text_size / 2, text_size)
		draw_rect(bg_rect, Color(0.0, 0.0, 0.0, 0.7), true)

		# Draw text
		draw_string(ThemeDB.fallback_font, mid_point - Vector2(text_size.x / 2, -text_size.y / 4), distance_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

func setup_airports() -> void:
	"""Create visual markers for all airports"""
	print("WorldMap: Setting up airports with OSM tiles")
	print("WorldMap: Number of airports: %d" % GameData.airports.size())

	for airport in GameData.airports:
		# Calculate pixel position at current zoom level
		airport.position_2d = lat_lon_to_pixel(airport.latitude, airport.longitude)
		print("  %s: lat/lon (%.2f, %.2f) -> pixel pos %s" % [airport.iata_code, airport.latitude, airport.longitude, airport.position_2d])

		# Create marker
		create_airport_marker(airport)

	queue_redraw()

func update_airport_positions() -> void:
	"""Update airport marker positions based on zoom and pan"""
	for airport in GameData.airports:
		# Recalculate pixel position at current zoom level
		airport.position_2d = lat_lon_to_pixel(airport.latitude, airport.longitude)

		if airport.iata_code in airport_markers:
			var marker: Control = airport_markers[airport.iata_code]
			var screen_pos: Vector2 = world_to_screen(airport.position_2d)
			marker.position = screen_pos - Vector2(12, 12)  # Center the marker

func create_airport_marker(airport: Airport) -> void:
	"""Create a visual marker for an airport"""
	var marker: Control = Control.new()
	marker.custom_minimum_size = Vector2(24, 24)
	var screen_pos = world_to_screen(airport.position_2d)
	marker.position = screen_pos - Vector2(12, 12)
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

	# Draw outline around main circle (dark gray border)
	marker.draw_circle(center, radius + 1.0, Color(0.3, 0.3, 0.3, 0.8))

	# Draw main circle
	marker.draw_circle(center, radius, color)

	# Draw IATA code (black text for visibility)
	var font_size: int = 10
	marker.draw_string(ThemeDB.fallback_font, Vector2(center.x - 10, center.y - 10), airport.iata_code, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.BLACK)

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
	# Hide any existing floating panel first
	hide_floating_panel()

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

		# Show floating panel near the airport
		var screen_pos = world_to_screen(airport.position_2d)
		show_floating_panel_for_airport(airport, screen_pos)

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
	"""Convert screen coordinates to world (pixel) coordinates"""
	return screen_pos - pan_offset

func world_to_screen(world_pos: Vector2) -> Vector2:
	"""Convert world (pixel) coordinates to screen coordinates"""
	return world_pos + pan_offset

func find_route_at_position(world_pos: Vector2, threshold: float = 15.0) -> Route:
	"""Find route near the given world position"""
	var closest_route: Route = null
	var closest_distance: float = threshold

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

# ============================================================================
# FLOATING INFO PANEL SYSTEM
# ============================================================================

func create_floating_panel() -> void:
	"""Create the floating info panel (initially hidden)"""
	floating_panel = PanelContainer.new()
	floating_panel.name = "FloatingInfoPanel"
	floating_panel.visible = false
	floating_panel.custom_minimum_size = Vector2(280, 100)
	floating_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	# Apply themed style
	var style = UITheme.create_floating_panel_style()
	floating_panel.add_theme_stylebox_override("panel", style)

	# Create content container
	var vbox = VBoxContainer.new()
	vbox.name = "Content"
	vbox.add_theme_constant_override("separation", 8)
	floating_panel.add_child(vbox)

	# Title label
	var title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZE_HEADER)
	title_label.add_theme_color_override("font_color", UITheme.TEXT_ACCENT)
	vbox.add_child(title_label)

	# Info label (multi-line) - use light text for dark panel
	var info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZE_BODY)
	info_label.add_theme_color_override("font_color", UITheme.TEXT_LIGHT)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(info_label)

	# Stats label (for colored stats) - use light text for dark panel
	var stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZE_BODY)
	stats_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	vbox.add_child(stats_label)

	# Button container
	var button_box = HBoxContainer.new()
	button_box.name = "ButtonBox"
	button_box.add_theme_constant_override("separation", 8)
	vbox.add_child(button_box)

	# Action button 1 - styled for dark panel
	var action1_btn = Button.new()
	action1_btn.name = "Action1Button"
	action1_btn.custom_minimum_size = Vector2(100, 32)
	action1_btn.add_theme_font_size_override("font_size", UITheme.FONT_SIZE_SMALL)
	action1_btn.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	action1_btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
	var btn1_style = UITheme.create_primary_button_style()
	action1_btn.add_theme_stylebox_override("normal", btn1_style)
	action1_btn.pressed.connect(_on_floating_panel_action1)
	button_box.add_child(action1_btn)

	# Action button 2 - styled for dark panel
	var action2_btn = Button.new()
	action2_btn.name = "Action2Button"
	action2_btn.custom_minimum_size = Vector2(100, 32)
	action2_btn.add_theme_font_size_override("font_size", UITheme.FONT_SIZE_SMALL)
	action2_btn.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	action2_btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
	var btn2_style = UITheme.create_secondary_button_style()
	action2_btn.add_theme_stylebox_override("normal", btn2_style)
	action2_btn.pressed.connect(_on_floating_panel_action2)
	button_box.add_child(action2_btn)

	# Close button (small X) - light color for dark panel
	var close_btn = Button.new()
	close_btn.name = "CloseButton"
	close_btn.text = "✕"
	close_btn.flat = true
	close_btn.custom_minimum_size = Vector2(24, 24)
	close_btn.add_theme_font_size_override("font_size", 14)
	close_btn.add_theme_color_override("font_color", UITheme.TEXT_MUTED)
	close_btn.add_theme_color_override("font_hover_color", UITheme.TEXT_WHITE)
	close_btn.pressed.connect(hide_floating_panel)

	# Position close button at top-right
	close_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_btn.position = Vector2(-28, 4)
	floating_panel.add_child(close_btn)

	add_child(floating_panel)
	print("Floating info panel created")

func show_floating_panel_for_airport(airport: Airport, screen_pos: Vector2) -> void:
	"""Show floating panel with airport info"""
	if not floating_panel or not airport:
		return

	floating_panel_target = airport

	# Get panel content nodes
	var vbox = floating_panel.get_node("Content")
	var title_label: Label = vbox.get_node("TitleLabel")
	var info_label: Label = vbox.get_node("InfoLabel")
	var stats_label: Label = vbox.get_node("StatsLabel")
	var button_box: HBoxContainer = vbox.get_node("ButtonBox")
	var action1_btn: Button = button_box.get_node("Action1Button")
	var action2_btn: Button = button_box.get_node("Action2Button")

	# Check if player hub
	var is_player_hub = GameData.player_airline and GameData.player_airline.has_hub(airport)

	# Set title with hub indicator
	if is_player_hub:
		title_label.text = "★ %s - %s" % [airport.iata_code, airport.name]
		title_label.add_theme_color_override("font_color", UITheme.HUB_COLOR)
	else:
		title_label.text = "%s - %s" % [airport.iata_code, airport.name]
		title_label.add_theme_color_override("font_color", UITheme.TEXT_ACCENT)

	# Set info
	info_label.text = "%s, %s\n%s | %d runways" % [
		airport.city,
		airport.country,
		airport.get_hub_name(),
		airport.runway_count
	]

	# Set stats with formatting - use light text for dark panel
	var pax_millions = airport.annual_passengers
	stats_label.text = "Traffic: %dM pax/year\nGDP: $%s per capita" % [
		pax_millions,
		UITheme.format_number(airport.gdp_per_capita)
	]
	stats_label.add_theme_color_override("font_color", UITheme.TEXT_MUTED)

	# Configure buttons
	if is_player_hub:
		action1_btn.text = "Plan Route"
		action1_btn.visible = true
		action2_btn.text = "View Routes"
		action2_btn.visible = GameData.player_airline.routes.size() > 0
	else:
		action1_btn.text = "Select"
		action1_btn.visible = true
		action2_btn.visible = false

	# Position and show panel
	_position_floating_panel(screen_pos)
	floating_panel.visible = true

func show_floating_panel_for_route(route: Route, screen_pos: Vector2) -> void:
	"""Show floating panel with route info"""
	if not floating_panel or not route:
		return

	floating_panel_target = route

	# Get panel content nodes
	var vbox = floating_panel.get_node("Content")
	var title_label: Label = vbox.get_node("TitleLabel")
	var info_label: Label = vbox.get_node("InfoLabel")
	var stats_label: Label = vbox.get_node("StatsLabel")
	var button_box: HBoxContainer = vbox.get_node("ButtonBox")
	var action1_btn: Button = button_box.get_node("Action1Button")
	var action2_btn: Button = button_box.get_node("Action2Button")

	# Determine if player's route
	var is_player_route = route.airline_id == GameData.player_airline.id

	# Set title
	title_label.text = route.get_display_name()
	if is_player_route:
		title_label.add_theme_color_override("font_color", UITheme.PLAYER_ROUTE_COLOR)
	else:
		title_label.add_theme_color_override("font_color", UITheme.COMPETITOR_ROUTE_COLOR)

	# Set info
	var aircraft_name = "No aircraft"
	if not route.assigned_aircraft.is_empty():
		aircraft_name = route.assigned_aircraft[0].model.get_display_name()

	info_label.text = "✈ %s\n%.0f km | %.1f hrs | %dx/week" % [
		aircraft_name,
		route.distance_km,
		route.flight_duration_hours,
		route.frequency
	]

	# Set stats with profit coloring
	var profit = route.weekly_profit
	var profit_color = UITheme.get_profit_color(profit)
	var profit_sign = "+" if profit >= 0 else ""

	# Calculate load factor
	var load_factor: float = 0.0
	if route.get_total_capacity() > 0 and route.frequency > 0:
		load_factor = (route.passengers_transported / float(route.get_total_capacity() * route.frequency)) * 100

	var load_color = UITheme.get_load_factor_color(load_factor)

	stats_label.text = "Load: %.0f%% | Pax: %d\nProfit: %s$%s/wk" % [
		load_factor,
		route.passengers_transported,
		profit_sign,
		UITheme.format_money(abs(profit))
	]
	stats_label.add_theme_color_override("font_color", profit_color)

	# Configure buttons
	if is_player_route:
		action1_btn.text = "Edit Route"
		action1_btn.visible = true
		action2_btn.text = "Cancel Route"
		action2_btn.visible = true
	else:
		action1_btn.text = "View Details"
		action1_btn.visible = true
		action2_btn.visible = false

	# Position and show panel
	_position_floating_panel(screen_pos)
	floating_panel.visible = true

func _position_floating_panel(near_pos: Vector2) -> void:
	"""Position floating panel near the given screen position, keeping within viewport"""
	if not floating_panel:
		return

	# Get panel size
	var panel_size = floating_panel.get_combined_minimum_size()

	# Default position: to the right and below
	var panel_pos = near_pos + Vector2(20, 10)

	# Keep within viewport bounds
	if panel_pos.x + panel_size.x > size.x - 10:
		panel_pos.x = near_pos.x - panel_size.x - 20

	if panel_pos.y + panel_size.y > size.y - 10:
		panel_pos.y = near_pos.y - panel_size.y - 10

	if panel_pos.x < 10:
		panel_pos.x = 10

	if panel_pos.y < 10:
		panel_pos.y = 10

	floating_panel.position = panel_pos

func hide_floating_panel() -> void:
	"""Hide the floating info panel"""
	if floating_panel:
		floating_panel.visible = false
		floating_panel_target = null

func _on_floating_panel_action1() -> void:
	"""Handle first action button click"""
	if floating_panel_target is Airport:
		var airport: Airport = floating_panel_target
		var is_player_hub = GameData.player_airline and GameData.player_airline.has_hub(airport)
		if is_player_hub:
			# Emit signal to open route planning dialog
			airport_clicked.emit(airport)
		else:
			# Select this airport for route creation
			selected_airport = airport
			queue_redraw()
		hide_floating_panel()
	elif floating_panel_target is Route:
		var route: Route = floating_panel_target
		if route.airline_id == GameData.player_airline.id:
			# Emit signal to open route editor
			route_clicked.emit(route)
		hide_floating_panel()

func _on_floating_panel_action2() -> void:
	"""Handle second action button click"""
	if floating_panel_target is Route:
		var route: Route = floating_panel_target
		if route.airline_id == GameData.player_airline.id:
			# TODO: Cancel/delete route confirmation
			print("Cancel route requested for: %s" % route.get_display_name())
	hide_floating_panel()
