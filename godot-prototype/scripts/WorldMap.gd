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

# Traffic overlay system
var traffic_overlay: TrafficOverlay = null

# Geodesic arc cache: route.id -> Array[Vector2] (lat/lon points)
var _geodesic_cache: Dictionary = {}
var _geodesic_cache_version: int = 0  # Incremented when routes change to invalidate cache

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
	
	# Initialize traffic overlay system
	_setup_traffic_overlay()

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
	
	# Redraw hub markers for pulse animation (every frame for smooth animation)
	_update_hub_marker_pulse()

	# Redraw to show updated plane positions
	queue_redraw()


func _update_hub_marker_pulse() -> void:
	"""Redraw player hub markers to show pulse animation"""
	if not GameData.player_airline or not traffic_overlay:
		return
	
	for hub in GameData.player_airline.hubs:
		if hub.iata_code in airport_markers:
			var marker: Control = airport_markers[hub.iata_code]
			marker.queue_redraw()

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

		# Use geodesic position for hover detection
		var plane_screen_pos: Vector2 = _get_plane_geodesic_position(plane)
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
		
		# Update traffic overlay visibility based on zoom
		if traffic_overlay:
			traffic_overlay.set_visible_for_zoom(osm_zoom)

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
	
	# Draw airport tooltip (J.2: demand preview on hover)
	draw_airport_tooltip()

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
	"""Draw a single route line with geodesic arc (great circle path)"""
	if not route.from_airport or not route.to_airport:
		return

	# Get geodesic arc points (cached for performance)
	var arc_points: Array[Vector2] = _get_geodesic_screen_points(route)
	
	if arc_points.is_empty():
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

	# Highlight if hovered or selected
	if route == hover_route or route == selected_route:
		line_thickness *= 1.5
		line_color.a = 1.0
		line_color = line_color.lightened(0.2)
	
	# M.2: Hub network highlighting - dim routes not connected to hovered hub
	if hover_airport and _is_hub_airport(hover_airport):
		var is_connected_to_hub: bool = (route.from_airport == hover_airport or route.to_airport == hover_airport)
		if is_connected_to_hub:
			# Highlight routes connected to this hub
			line_color = line_color.lightened(0.15)
			line_thickness *= 1.3
			line_color.a = min(1.0, line_color.a + 0.2)
		else:
			# Dim routes not connected to this hub
			line_color.a *= 0.25

	# Draw geodesic arc as connected line segments
	_draw_polyline(arc_points, line_color, line_thickness)

	# Calculate midpoint for labels (use actual geodesic midpoint)
	var mid_idx: int = arc_points.size() / 2
	var mid_point: Vector2 = arc_points[mid_idx] if mid_idx < arc_points.size() else arc_points[0]
	
	# Calculate direction at midpoint for label offset
	var direction: Vector2 = Vector2.RIGHT
	if mid_idx > 0 and mid_idx < arc_points.size() - 1:
		direction = (arc_points[mid_idx + 1] - arc_points[mid_idx - 1]).normalized()

	# Draw route labels if enabled and zoomed in enough
	# Offset label perpendicular to route to avoid overlapping with planes
	if show_route_labels and osm_zoom >= 4 and route.airline_id == GameData.player_airline.id:
		var perpendicular: Vector2 = direction.rotated(PI / 2).normalized()
		var label_offset: Vector2 = perpendicular * 25  # Offset 25 pixels perpendicular to route
		draw_route_label(route, mid_point + label_offset, line_color)


func _draw_polyline(points: Array[Vector2], color: Color, width: float) -> void:
	"""Draw a polyline from an array of points"""
	if points.size() < 2:
		return
	
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, width, true)


func _get_geodesic_screen_points(route: Route) -> Array[Vector2]:
	"""Get screen-space points for a geodesic arc (cached)"""
	if not route.from_airport or not route.to_airport:
		return []
	
	# Get or compute geodesic lat/lon points
	var latlon_points: Array[Vector2]
	if _geodesic_cache.has(route.id):
		latlon_points = _geodesic_cache[route.id]
	else:
		# Compute geodesic points using GeodesicUtils
		latlon_points = GeodesicUtils.calculate_geodesic_points(
			route.from_airport.latitude, route.from_airport.longitude,
			route.to_airport.latitude, route.to_airport.longitude
		)
		_geodesic_cache[route.id] = latlon_points
	
	# Convert lat/lon points to screen coordinates
	var screen_points: Array[Vector2] = []
	for point in latlon_points:
		# point is Vector2(longitude, latitude)
		var pixel_pos = lat_lon_to_pixel(point.y, point.x)
		var screen_pos = world_to_screen(pixel_pos)
		screen_points.append(screen_pos)
	
	return screen_points


func get_geodesic_screen_points_for_route(route: Route) -> Array[Vector2]:
	"""Public accessor for TrafficOverlay to get geodesic points"""
	return _get_geodesic_screen_points(route)


func invalidate_geodesic_cache(route_id: int = -1) -> void:
	"""Invalidate geodesic cache. Call when routes change."""
	if route_id < 0:
		_geodesic_cache.clear()
	else:
		_geodesic_cache.erase(route_id)

func draw_route_label(route: Route, position: Vector2, color: Color) -> void:
	"""Draw informative label on route (offset from route line to avoid planes)"""
	if not route:
		return

	# Create label text
	var label_text: String = ""

	# Show passengers transported (with connecting breakdown if significant)
	if route.passengers_transported > 0:
		if route.connecting_passengers > 10:  # Only show breakdown if meaningful
			label_text = "%d pax (%d+%d)" % [
				route.passengers_transported, route.local_passengers, route.connecting_passengers
			]
		else:
			label_text = "%d pax" % route.passengers_transported

	# Show profit if significant
	if abs(route.weekly_profit) > 10000:
		var profit_str: String = "€%.0fK" % (route.weekly_profit / 1000.0)
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
	"""Draw all active plane sprites following geodesic arcs"""
	for plane in plane_sprites:
		if plane.is_active:
			# Get plane position along geodesic arc
			var screen_pos = _get_plane_geodesic_position(plane)
			var rotation = _get_plane_geodesic_rotation(plane)
			draw_plane_at(plane, screen_pos, rotation)


func _get_plane_geodesic_position(plane: PlaneSprite) -> Vector2:
	"""Calculate plane position along geodesic arc based on flight progress"""
	if not plane.route:
		return Vector2.ZERO
	
	# Get geodesic screen points for the route
	var points: Array[Vector2] = _get_geodesic_screen_points(plane.route)
	
	if points.is_empty():
		# Fallback to linear interpolation
		var world_pos = plane.get_current_position(size)
		return world_to_screen(world_pos)
	
	# If return leg, reverse the points array
	var arc_points: Array[Vector2] = points.duplicate()
	if plane.is_return_leg:
		arc_points.reverse()
	
	# Interpolate position along the arc
	return _interpolate_along_arc(arc_points, plane.progress)


func _get_plane_geodesic_rotation(plane: PlaneSprite) -> float:
	"""Calculate plane rotation (tangent) along geodesic arc"""
	if not plane.route:
		return 0.0
	
	# Get geodesic screen points for the route
	var points: Array[Vector2] = _get_geodesic_screen_points(plane.route)
	
	if points.size() < 2:
		# Fallback to simple direction
		return plane.get_rotation_angle()
	
	# If return leg, reverse the points array
	var arc_points: Array[Vector2] = points.duplicate()
	if plane.is_return_leg:
		arc_points.reverse()
	
	# Get tangent direction at current position along arc
	return _get_tangent_at_progress(arc_points, plane.progress)


func _interpolate_along_arc(points: Array[Vector2], progress: float) -> Vector2:
	"""Interpolate a position along an array of arc points based on progress (0-1)"""
	if points.is_empty():
		return Vector2.ZERO
	if points.size() == 1:
		return points[0]
	
	progress = clamp(progress, 0.0, 1.0)
	
	var total_segments: int = points.size() - 1
	var segment_progress: float = progress * total_segments
	var segment_index: int = int(segment_progress)
	
	# Handle edge case at progress = 1.0
	if segment_index >= total_segments:
		return points[total_segments]
	
	var segment_t: float = segment_progress - segment_index
	return points[segment_index].lerp(points[segment_index + 1], segment_t)


func _get_tangent_at_progress(points: Array[Vector2], progress: float) -> float:
	"""Get the direction angle (tangent) at a given progress along the arc"""
	if points.size() < 2:
		return 0.0
	
	progress = clamp(progress, 0.0, 1.0)
	
	var total_segments: int = points.size() - 1
	var segment_progress: float = progress * total_segments
	var segment_index: int = int(segment_progress)
	
	# Clamp to valid range
	if segment_index >= total_segments:
		segment_index = total_segments - 1
	
	# Direction to next point = curve tangent
	var direction: Vector2 = points[segment_index + 1] - points[segment_index]
	return direction.angle()

func draw_plane_at(plane: PlaneSprite, screen_pos: Vector2, rotation: float = 0.0) -> void:
	"""Draw a plane sprite as a directional arrow/chevron following the route curve"""
	var pos: Vector2 = screen_pos
	var radius: float = 6.0  # Base size
	
	# Draw directional plane icon (chevron pointing in flight direction)
	var chevron_length: float = radius * 2.0
	var chevron_width: float = radius * 1.2
	
	# Calculate chevron points based on rotation (nose points in direction of travel)
	var nose: Vector2 = pos + Vector2(chevron_length, 0).rotated(rotation)
	var left_wing: Vector2 = pos + Vector2(-chevron_length * 0.5, -chevron_width).rotated(rotation)
	var right_wing: Vector2 = pos + Vector2(-chevron_length * 0.5, chevron_width).rotated(rotation)
	var tail: Vector2 = pos + Vector2(-chevron_length * 0.3, 0).rotated(rotation)
	
	# Draw filled plane shape
	var plane_points: PackedVector2Array = PackedVector2Array([nose, left_wing, tail, right_wing])
	var plane_colors: PackedColorArray = PackedColorArray([
		plane.plane_color, plane.plane_color, plane.plane_color, plane.plane_color
	])
	
	# Draw shadow/outline
	var shadow_offset := Vector2(1, 1)
	var shadow_points: PackedVector2Array = PackedVector2Array([
		nose + shadow_offset, left_wing + shadow_offset, 
		tail + shadow_offset, right_wing + shadow_offset
	])
	draw_polygon(shadow_points, PackedColorArray([Color(0, 0, 0, 0.4), Color(0, 0, 0, 0.4), Color(0, 0, 0, 0.4), Color(0, 0, 0, 0.4)]))
	
	# Draw main plane body
	draw_polygon(plane_points, plane_colors)
	
	# Draw outline for visibility
	draw_polyline(plane_points + PackedVector2Array([nose]), plane.plane_color.darkened(0.3), 1.5, true)

func draw_plane_tooltip() -> void:
	"""Draw tooltip for hovered plane"""
	if not hover_plane or not hover_plane.is_active:
		return

	# Get screen position of plane along geodesic arc
	var plane_screen_pos: Vector2 = _get_plane_geodesic_position(hover_plane)

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


func draw_airport_tooltip() -> void:
	"""J.2: Draw tooltip with demand preview when hovering over an airport"""
	if not hover_airport:
		return
	
	# Don't show tooltip if we're clicking/selecting (floating panel will show instead)
	if floating_panel and floating_panel.visible:
		return
	
	# Only show demand info if player has at least one hub
	if not GameData.player_airline or GameData.player_airline.hubs.is_empty():
		return
	
	# Get the player's primary hub (first hub)
	var player_hub: Airport = GameData.player_airline.hubs[0]
	
	# Don't show tooltip for the hub itself
	if hover_airport == player_hub:
		return
	
	# Calculate distance and demand
	var distance: float = MarketAnalysis.calculate_great_circle_distance(player_hub, hover_airport)
	var demand: float = MarketAnalysis.calculate_potential_demand(player_hub, hover_airport, distance)
	
	# Get recommended aircraft based on distance
	var recommended_aircraft: String
	if distance <= 1500:
		recommended_aircraft = "ATR 72-600"
	elif distance <= 4000:
		recommended_aircraft = "737-800 / A320neo"
	else:
		recommended_aircraft = "A320neo"
	
	# Check for existing player route
	var has_player_route: bool = false
	for route in GameData.player_airline.routes:
		if (route.from_airport == player_hub and route.to_airport == hover_airport) or \
		   (route.from_airport == hover_airport and route.to_airport == player_hub):
			has_player_route = true
			break
	
	# Check for AI competition
	var competition_count: int = 0
	for airline in GameData.airlines:
		if airline == GameData.player_airline:
			continue
		for route in airline.routes:
			if (route.from_airport == player_hub and route.to_airport == hover_airport) or \
			   (route.from_airport == hover_airport and route.to_airport == player_hub) or \
			   (route.from_airport.iata_code == player_hub.iata_code and route.to_airport.iata_code == hover_airport.iata_code) or \
			   (route.from_airport.iata_code == hover_airport.iata_code and route.to_airport.iata_code == player_hub.iata_code):
				competition_count += 1
	
	# Build tooltip text
	var lines: Array[String] = []
	lines.append("%s (%s)" % [hover_airport.name, hover_airport.iata_code])
	lines.append("From %s: %.0f km" % [player_hub.iata_code, distance])
	lines.append("Est. demand: ~%.0f pax/week" % demand)
	lines.append("Recommended: %s" % recommended_aircraft)
	
	if has_player_route:
		lines.append("✓ You operate this route")
	elif competition_count > 0:
		lines.append("⚠ %d competitor(s)" % competition_count)
	else:
		lines.append("★ No competition!")
	
	# Get screen position of airport
	var airport_screen_pos: Vector2 = world_to_screen(hover_airport.position_2d)
	
	# Calculate tooltip size
	var font_size: int = 12
	var max_width: float = 0.0
	for line in lines:
		var line_width: float = line.length() * font_size * 0.55
		max_width = max(max_width, line_width)
	
	var tooltip_size: Vector2 = Vector2(max_width + 20, lines.size() * (font_size + 4) + 16)
	
	# Position tooltip above and to the right of airport
	var tooltip_pos: Vector2 = airport_screen_pos + Vector2(20, -tooltip_size.y - 10)
	
	# Keep tooltip on screen
	if tooltip_pos.x + tooltip_size.x > size.x:
		tooltip_pos.x = airport_screen_pos.x - tooltip_size.x - 20
	if tooltip_pos.y < 0:
		tooltip_pos.y = airport_screen_pos.y + 30
	if tooltip_pos.x < 10:
		tooltip_pos.x = 10
	
	# Draw background
	var bg_rect: Rect2 = Rect2(tooltip_pos, tooltip_size)
	draw_rect(bg_rect, Color(0.05, 0.08, 0.12, 0.95), true)
	draw_rect(bg_rect, Color(0.3, 0.6, 1.0, 0.6), false, 1.5)
	
	# Draw text lines
	var y_offset: float = 10.0
	for i in range(lines.size()):
		var line: String = lines[i]
		var line_color: Color = Color.WHITE
		
		# Color code certain lines
		if i == 0:
			line_color = Color(0.4, 0.8, 1.0)  # Airport name in blue
		elif "No competition" in line:
			line_color = Color(0.4, 1.0, 0.4)  # Green for no competition
		elif "competitor" in line:
			line_color = Color(1.0, 0.8, 0.3)  # Yellow for competition
		elif "You operate" in line:
			line_color = Color(0.6, 0.8, 1.0)  # Light blue for existing route
		
		draw_string(
			ThemeDB.fallback_font,
			tooltip_pos + Vector2(10, y_offset + font_size),
			line,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			line_color
		)
		y_offset += font_size + 4


func draw_route_preview() -> void:
	"""Draw preview line when creating a route (geodesic arc when hovering over airport)"""
	if not selected_airport:
		return

	# Don't draw preview if hovering over the selected airport itself
	if hover_airport == selected_airport:
		return

	var line_color: Color = Color(0.4, 0.8, 1.0, 0.6)  # Light blue, semi-transparent
	var line_thickness: float = 2.5

	# If hovering over another airport, draw geodesic preview arc
	if hover_airport:
		# Calculate geodesic arc preview
		var arc_points = GeodesicUtils.calculate_geodesic_points(
			selected_airport.latitude, selected_airport.longitude,
			hover_airport.latitude, hover_airport.longitude
		)
		
		# Convert to screen coordinates
		var screen_points: Array[Vector2] = []
		for point in arc_points:
			var pixel_pos = lat_lon_to_pixel(point.y, point.x)
			var screen_pos = world_to_screen(pixel_pos)
			screen_points.append(screen_pos)
		
		# Draw dashed geodesic arc
		_draw_dashed_polyline(screen_points, line_color, line_thickness)
		
		# Draw distance label at geodesic midpoint
		var route_distance: float = MarketAnalysis.calculate_great_circle_distance(selected_airport, hover_airport)
		var mid_idx: int = screen_points.size() / 2
		var mid_point: Vector2 = screen_points[mid_idx] if mid_idx < screen_points.size() else screen_points[0]

		var distance_text: String = "%.0f km" % route_distance
		var font_size: int = 14
		var text_size: Vector2 = Vector2(distance_text.length() * font_size * 0.6, font_size + 4)
		
		# Draw background for distance label
		var bg_rect: Rect2 = Rect2(mid_point - text_size / 2.0, text_size)
		draw_rect(bg_rect, Color(0.1, 0.15, 0.2, 0.9), true, -1)
		draw_string(ThemeDB.fallback_font, mid_point - Vector2(text_size.x / 2.0 - 4, -4), distance_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	else:
		# No airport hover - draw straight dashed line to mouse
		var from_pos: Vector2 = world_to_screen(selected_airport.position_2d)
		var to_pos: Vector2 = get_local_mouse_position()
		
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


func _draw_dashed_polyline(points: Array[Vector2], color: Color, width: float, dash_length: float = 12.0, gap_length: float = 8.0) -> void:
	"""Draw a dashed polyline along an array of points"""
	if points.size() < 2:
		return
	
	var accumulated_distance: float = 0.0
	var in_dash: bool = true
	var dash_remaining: float = dash_length
	
	for i in range(points.size() - 1):
		var segment_start: Vector2 = points[i]
		var segment_end: Vector2 = points[i + 1]
		var segment_dir: Vector2 = (segment_end - segment_start).normalized()
		var segment_length: float = segment_start.distance_to(segment_end)
		var segment_drawn: float = 0.0
		
		while segment_drawn < segment_length:
			var draw_length: float = min(dash_remaining, segment_length - segment_drawn)
			var draw_start: Vector2 = segment_start + segment_dir * segment_drawn
			var draw_end: Vector2 = segment_start + segment_dir * (segment_drawn + draw_length)
			
			if in_dash:
				draw_line(draw_start, draw_end, color, width, true)
			
			segment_drawn += draw_length
			dash_remaining -= draw_length
			
			if dash_remaining <= 0:
				in_dash = not in_dash
				dash_remaining = gap_length if not in_dash else dash_length


func setup_airports() -> void:
	"""Create visual markers for all airports"""
	for airport in GameData.airports:
		# Calculate pixel position at current zoom level
		airport.position_2d = lat_lon_to_pixel(airport.latitude, airport.longitude)

		# Create marker
		create_airport_marker(airport)

	queue_redraw()


func _setup_traffic_overlay() -> void:
	"""Initialize the traffic overlay system for animated route flow"""
	traffic_overlay = TrafficOverlay.new()
	traffic_overlay.setup(self)
	add_child(traffic_overlay)
	
	# Position the overlay behind airport markers but above map tiles
	move_child(traffic_overlay, 1)

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
	"""Draw an individual airport marker with hub pulse effect"""
	var center: Vector2 = Vector2(12, 12)
	var base_radius: float = 6.0

	# Color and size based on hub tier
	var color: Color = Color.YELLOW
	if airport.hub_tier == 1:  # Mega Hub
		color = Color.ORANGE
		base_radius = 9.0
	elif airport.hub_tier == 2:  # Major Hub
		color = Color.GOLD
		base_radius = 7.5
	elif airport.hub_tier == 3:  # Regional Hub
		color = Color.YELLOW
		base_radius = 6.5

	# Check if this is a player hub
	var is_player_hub: bool = false
	if GameData.player_airline:
		is_player_hub = GameData.player_airline.has_hub(airport)

	# Hub pulse effect: Apply breathing scale to player hubs
	var pulse_scale: float = 1.0
	if is_player_hub and traffic_overlay:
		pulse_scale = traffic_overlay.get_hub_pulse_scale(airport)
	
	var radius: float = base_radius * pulse_scale

	# Draw player hub indicator (double ring) with pulse
	if is_player_hub:
		# Outer ring (airline primary color) - pulses with hub
		var hub_ring_outer: float = (base_radius + 4.5) * pulse_scale
		var hub_ring_inner: float = (base_radius + 2.5) * pulse_scale
		
		# Glow effect for pulsing hub
		var glow_alpha: float = 0.3 + 0.2 * (pulse_scale - 1.0) * 20.0  # More glow at peak
		var glow_color: Color = GameData.player_airline.primary_color
		glow_color.a = glow_alpha
		marker.draw_circle(center, hub_ring_outer + 3.0, glow_color)
		
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
	"""Redraw all routes and refresh any visible route info panel"""
	queue_redraw()
	
	# Refresh floating panel if it's showing a route
	if floating_panel and floating_panel.visible and floating_panel_target is Route:
		var route: Route = floating_panel_target as Route
		# Get the current panel position to maintain it
		var current_pos: Vector2 = floating_panel.position + floating_panel.size / 2
		show_floating_panel_for_route(route, current_pos)

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
	var stats_text: String = "Traffic: %dM pax/year\nGDP: $%s per capita" % [
		pax_millions,
		UITheme.format_number(airport.gdp_per_capita)
	]
	
	# M.1: Show hub network stats for player hubs
	if is_player_hub:
		var hub_stats: Dictionary = calculate_hub_stats(airport)
		stats_text += "\n─── Hub Stats ───"
		stats_text += "\nRoutes: %d" % hub_stats.route_count
		stats_text += "\nWeekly Pax: %d" % hub_stats.total_passengers
		if hub_stats.connecting_passengers > 0:
			stats_text += "\nConnecting: ~%d" % hub_stats.connecting_passengers
	
	stats_label.text = stats_text
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

	# Calculate load factor
	var load_factor: float = 0.0
	if route.get_total_capacity() > 0 and route.frequency > 0:
		load_factor = (route.passengers_transported / float(route.get_total_capacity() * route.frequency)) * 100

	var load_color = UITheme.get_load_factor_color(load_factor)

	# Build stats with cost breakdown (K.1) and profit trends (K.2)
	var pax_text: String
	if route.connecting_passengers > 0:
		pax_text = "%d (%d local + %d connecting)" % [
			route.passengers_transported, route.local_passengers, route.connecting_passengers
		]
	else:
		pax_text = "%d" % route.passengers_transported
	
	var stats_text: String = "Load: %.0f%% | Pax: %s\n" % [load_factor, pax_text]
	stats_text += "Revenue: %s/wk\n" % UITheme.format_money(route.revenue_generated)
	
	# Cost breakdown
	if route.total_costs > 0:
		stats_text += "─── Costs ───\n"
		stats_text += "  Fuel: %s\n" % UITheme.format_money(route.fuel_cost)
		stats_text += "  Crew: %s\n" % UITheme.format_money(route.crew_cost)
		stats_text += "  Maint: %s\n" % UITheme.format_money(route.maintenance_cost)
		stats_text += "  Airport: %s\n" % UITheme.format_money(route.airport_fees)
		stats_text += "  Total: %s\n" % UITheme.format_money(route.total_costs)
		stats_text += "─────────────\n"
	
	# K.2: Profit with margin and trend
	var profit_margin: float = route.get_profit_margin()
	var trend: String = route.get_profit_trend()
	stats_text += "Profit: %s/wk %s\n" % [UITheme.format_money(profit, true), trend]
	stats_text += "Margin: %.0f%%" % profit_margin
	
	# P.2: Competitor pricing intelligence (for player routes)
	if is_player_route and GameData.player_airline:
		var intel: Dictionary = MarketAnalysis.get_competitor_pricing_intelligence(route, GameData.player_airline)
		if intel.has_competitors:
			stats_text += "\n─── Pricing ───\n"
			stats_text += _format_competitor_intel_for_popup(intel)
	
	stats_label.text = stats_text
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


func _is_hub_airport(airport: Airport) -> bool:
	"""M.2: Check if an airport is a player hub"""
	if not airport or not GameData.player_airline:
		return false
	return GameData.player_airline.has_hub(airport)


func calculate_hub_stats(hub_airport: Airport) -> Dictionary:
	"""M.1: Calculate hub statistics including connecting passengers"""
	var stats: Dictionary = {
		"route_count": 0,
		"total_passengers": 0,
		"connecting_passengers": 0
	}
	
	if not GameData.player_airline:
		return stats
	
	var hub_routes: Array[Route] = []
	
	# Find all routes from/to this hub
	for route in GameData.player_airline.routes:
		if route.from_airport == hub_airport or route.to_airport == hub_airport:
			hub_routes.append(route)
			stats.route_count += 1
			stats.total_passengers += route.passengers_transported
	
	# Estimate connecting passengers (passengers who could connect between routes)
	# This is a simplified estimate: for each pair of routes, some % of passengers connect
	if hub_routes.size() >= 2:
		var connection_factor: float = 0.15  # Assume 15% of passengers connect
		var total_connection_opportunities: int = 0
		
		for i in range(hub_routes.size()):
			for j in range(i + 1, hub_routes.size()):
				var route1: Route = hub_routes[i]
				var route2: Route = hub_routes[j]
				# Connecting passengers = smaller of the two route passenger counts * connection factor
				var potential_connectors: int = int(min(route1.passengers_transported, route2.passengers_transported) * connection_factor)
				total_connection_opportunities += potential_connectors
		
		stats.connecting_passengers = total_connection_opportunities
	
	return stats


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
			# Show confirmation dialog for route deletion
			show_route_deletion_confirmation(route)
	hide_floating_panel()

func show_route_deletion_confirmation(route: Route) -> void:
	"""Show confirmation dialog before deleting a route"""
	var dialog = ConfirmationDialog.new()
	dialog.title = "Cancel Route"
	dialog.dialog_text = "Are you sure you want to cancel the route %s?\n\nThis will free up the assigned aircraft, but you will lose this route's revenue." % route.get_display_name()
	dialog.ok_button_text = "Cancel Route"
	dialog.get_cancel_button().text = "Keep Route"
	
	# Add to scene tree (add to root or find GameUI)
	var root = get_tree().root
	if root:
		root.add_child(dialog)
	
	# Connect signals
	dialog.confirmed.connect(func():
		delete_route(route)
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	# Show dialog
	dialog.popup_centered()

func delete_route(route: Route) -> void:
	"""Delete a route from the player's airline"""
	if not route or not GameData.player_airline:
		return
	
	if route not in GameData.player_airline.routes:
		push_warning("WorldMap: Route not found in airline routes")
		return
	
	# Remove route from airline
	GameData.player_airline.remove_route(route)
	
	# Emit network change signal for profitability recalculation
	GameData.route_removed.emit(route, GameData.player_airline)
	GameData.route_network_changed.emit(GameData.player_airline)
	
	# Refresh map display
	refresh_routes()


func _format_competitor_intel_for_popup(intel: Dictionary) -> String:
	"""P.2: Format competitor pricing intelligence for the route popup (plain text)."""
	var text: String = ""
	
	# Price comparison
	text += "You: €%.0f | Comp: €%.0f\n" % [intel.player_price, intel.avg_competitor_price]
	
	# Market positioning
	var pos_text: String
	match intel.positioning:
		"premium":
			pos_text = "▲ Premium"
		"discount":
			pos_text = "▼ Discount"
		_:
			pos_text = "● Matched"
	
	if intel.price_difference_pct > 0:
		text += "%s (+%.0f%%)\n" % [pos_text, intel.price_difference_pct]
	elif intel.price_difference_pct < 0:
		text += "%s (%.0f%%)\n" % [pos_text, intel.price_difference_pct]
	else:
		text += "%s\n" % pos_text
	
	# Short recommendation
	match intel.recommendation_type:
		"undercut":
			text += "💡 Consider lowering price"
		"differentiate":
			text += "💡 Differentiate on service"
		_:
			text += "✓ Pricing sustainable"
	
	return text
