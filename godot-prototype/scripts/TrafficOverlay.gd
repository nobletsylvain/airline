## TrafficOverlay.gd
## Renders directional particle flow on route lines showing passenger movement.
## Uses shader-based chevron animation for performance with 200+ routes.
extends Node2D
class_name TrafficOverlay

## Traffic density thresholds (weekly passengers)
const DENSITY_SPARSE := 500      # < 500: sparse single file
const DENSITY_SINGLE := 2000     # 500-2k: tight single file
const DENSITY_DOUBLE := 5000     # 2k-5k: double stream
# 5k+: triple stream + glow

## Flow colors by route status (art-bible.md compliant)
const COLOR_PLAYER_PROFIT := Color(0.0, 0.78, 0.33, 0.7)    # #00c853 - Green (Alert palette)
const COLOR_PLAYER_LOSS := Color(1.0, 0.09, 0.27, 0.6)      # #ff1744 - Red (Alert palette)
const COLOR_PLAYER_NEUTRAL := Color(0.0, 0.83, 1.0, 0.65)   # #00d4ff - Cyan Primary (Avionics)
const COLOR_COMPETITOR := Color(0.55, 0.56, 0.60, 0.30)     # #8b9098 - Gray (Avionics)

## Alpha ranges for readability
const PLAYER_MIN_ALPHA := 0.5
const COMPETITOR_ALPHA_MIN := 0.25
const COMPETITOR_ALPHA_MAX := 0.35

## Line thickness for traffic overlay (widened for visibility)
const BASE_LINE_WIDTH := 10.0
const MAX_LINE_WIDTH := 28.0

## Zoom fade transition
const ZOOM_FADE_THRESHOLD := 3
const ZOOM_FADE_DURATION := 0.2  # 200ms fade transition

## Reference to parent WorldMap for coordinate conversion
var world_map: Control = null

## Cached shader material
var traffic_shader: Shader = null
var route_overlays: Dictionary = {}  # route.id -> Line2D with shader

## Hub pulse tracking
var hub_pulse_phases: Dictionary = {}  # airport.iata_code -> phase (0-1)

## Performance: only update visible routes
var _update_timer: float = 0.0
var _update_interval: float = 0.1  # Update every 100ms

## Dirty flag to skip redundant overlay rebuilds
var _overlays_dirty: bool = true

## Zoom fade state
var _target_alpha: float = 1.0
var _current_alpha: float = 1.0
var _is_fading: bool = false


func _ready() -> void:
	# Load the traffic flow shader
	traffic_shader = load("res://shaders/traffic_flow.gdshader")
	if not traffic_shader:
		push_warning("TrafficOverlay: Could not load traffic_flow.gdshader")
	
	# Connect to route change signals to mark overlays dirty
	if GameData:
		GameData.route_created.connect(_on_route_changed)
		GameData.route_removed.connect(_on_route_changed)
		GameData.route_network_changed.connect(_on_network_changed)


func _on_route_changed(_route, _airline) -> void:
	"""Mark overlays dirty when a route is added or removed"""
	mark_dirty()


func _on_network_changed(_airline) -> void:
	"""Mark overlays dirty when route network changes (profitability updates)"""
	mark_dirty()


func setup(map: Control) -> void:
	"""Initialize with reference to WorldMap"""
	world_map = map


func _process(delta: float) -> void:
	# Update hub pulse phases
	_update_hub_pulses(delta)
	
	# Update zoom fade transition
	_update_zoom_fade(delta)
	
	# Periodic route overlay update (for performance)
	_update_timer += delta
	if _update_timer >= _update_interval:
		_update_timer = 0.0
		_update_overlays()


func _update_zoom_fade(delta: float) -> void:
	"""Smoothly fade in/out based on zoom level"""
	if not _is_fading and _current_alpha == _target_alpha:
		return
	
	# Calculate fade speed (complete fade in ZOOM_FADE_DURATION seconds)
	var fade_speed = 1.0 / ZOOM_FADE_DURATION
	
	# Lerp towards target
	if _current_alpha < _target_alpha:
		_current_alpha = min(_current_alpha + fade_speed * delta, _target_alpha)
	elif _current_alpha > _target_alpha:
		_current_alpha = max(_current_alpha - fade_speed * delta, _target_alpha)
	
	# Apply alpha to modulate
	modulate.a = _current_alpha
	
	# Check if fade complete
	if abs(_current_alpha - _target_alpha) < 0.01:
		_current_alpha = _target_alpha
		_is_fading = false
		
		# Hide completely when faded out (performance)
		visible = _current_alpha > 0.01


func _update_hub_pulses(delta: float) -> void:
	"""Update hub airport pulse animations (breathing effect)"""
	if not GameData.player_airline:
		return
	
	for hub in GameData.player_airline.hubs:
		var iata = hub.iata_code
		
		# Initialize phase if not exists
		if not hub_pulse_phases.has(iata):
			hub_pulse_phases[iata] = randf()  # Random start phase
		
		# Calculate pulse speed based on daily departures
		var daily_departures = _get_hub_daily_departures(hub)
		var pulse_speed = 0.5 + (daily_departures / 20.0)  # More departures = faster pulse
		pulse_speed = clamp(pulse_speed, 0.5, 3.0)
		
		# Update phase
		hub_pulse_phases[iata] = fmod(hub_pulse_phases[iata] + delta * pulse_speed, 1.0)


func _get_hub_daily_departures(hub: Airport) -> int:
	"""Count daily departures from a hub"""
	if not GameData.player_airline:
		return 0
	
	var departures := 0
	for route in GameData.player_airline.routes:
		if route.from_airport == hub:
			departures += route.frequency  # Weekly frequency / 7 ≈ daily
	
	# Approximate daily from weekly
	return int(ceil(departures / 7.0))


func get_hub_pulse_scale(airport: Airport) -> float:
	"""Get current pulse scale for a hub airport (1.0 to 1.05)"""
	if not airport or not hub_pulse_phases.has(airport.iata_code):
		return 1.0
	
	var phase = hub_pulse_phases[airport.iata_code]
	# Sine wave: 0-1 phase -> 1.0-1.05-1.0 scale (breathing effect)
	return 1.0 + 0.05 * sin(phase * TAU)


func mark_dirty() -> void:
	"""Mark overlays as needing rebuild (call when routes/profitability change)"""
	_overlays_dirty = true


func _update_overlays() -> void:
	"""Update all route overlays based on current game state"""
	if not _overlays_dirty:
		return
	
	if not world_map or not GameData.player_airline:
		return
	
	_overlays_dirty = false
	
	# Track which routes still exist
	var active_routes: Dictionary = {}
	
	# Update player routes
	for route in GameData.player_airline.routes:
		active_routes[route.id] = true
		_update_route_overlay(route, true)
	
	# Optionally show competitor routes (dimmed)
	for airline in GameData.airlines:
		if airline == GameData.player_airline:
			continue
		for route in airline.routes:
			active_routes[route.id] = true
			_update_route_overlay(route, false)
	
	# Remove overlays for deleted routes
	var to_remove: Array[int] = []
	for route_id in route_overlays:
		if not active_routes.has(route_id):
			to_remove.append(route_id)
	
	for route_id in to_remove:
		var overlay = route_overlays[route_id]
		overlay.queue_free()
		route_overlays.erase(route_id)


func _update_route_overlay(route: Route, is_player: bool) -> void:
	"""Create or update overlay for a specific route"""
	if not route.from_airport or not route.to_airport:
		return
	
	# Get or create Line2D overlay
	var overlay: Line2D
	if route_overlays.has(route.id):
		overlay = route_overlays[route.id]
	else:
		overlay = _create_route_overlay(route)
		route_overlays[route.id] = overlay
	
	# Update overlay position and appearance
	_configure_overlay(overlay, route, is_player)


func _create_route_overlay(route: Route) -> Line2D:
	"""Create a new Line2D with traffic shader for a route"""
	var line = Line2D.new()
	line.width = BASE_LINE_WIDTH
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.antialiased = true
	
	# Create shader material
	if traffic_shader:
		var mat = ShaderMaterial.new()
		mat.shader = traffic_shader
		line.material = mat
	
	add_child(line)
	return line


func _configure_overlay(overlay: Line2D, route: Route, is_player: bool) -> void:
	"""Configure overlay appearance based on route traffic"""
	# Get geodesic arc points from WorldMap (uses cached great circle calculation)
	var arc_points: Array[Vector2] = world_map.get_geodesic_screen_points_for_route(route)
	
	# Set points along the geodesic arc
	overlay.clear_points()
	if arc_points.is_empty():
		# Fallback to straight line if geodesic not available
		var from_pos = world_map.world_to_screen(route.from_airport.position_2d)
		var to_pos = world_map.world_to_screen(route.to_airport.position_2d)
		overlay.add_point(from_pos)
		overlay.add_point(to_pos)
	else:
		for point in arc_points:
			overlay.add_point(point)
	
	# Determine traffic density
	var pax = route.passengers_transported if route.passengers_transported > 0 else _estimate_pax(route)
	var density_params = _get_density_params(pax)
	
	# Set width based on traffic
	overlay.width = density_params.width
	
	# Configure shader parameters
	if overlay.material is ShaderMaterial:
		var mat: ShaderMaterial = overlay.material
		
		# LOD optimization: Reduce complexity at far zoom
		var zoom_level: int = world_map.osm_zoom if world_map else 5
		var lod_factor: float = clampf(float(zoom_level - 2) / 4.0, 0.3, 1.0)  # 0.3 at zoom 2, 1.0 at zoom 6+
		
		# Flow speed (higher traffic = faster flow)
		mat.set_shader_parameter("flow_speed", density_params.speed)
		
		# Stream count (reduce at far zoom for performance)
		var effective_streams: int = density_params.streams
		if zoom_level < 4:
			effective_streams = mini(effective_streams, 1)  # Single stream at far zoom
		elif zoom_level < 5:
			effective_streams = mini(effective_streams, 2)  # Max 2 streams at medium zoom
		mat.set_shader_parameter("stream_count", effective_streams)
		
		# Chevron density (reduce at far zoom)
		mat.set_shader_parameter("chevron_density", float(density_params.density) * lod_factor)
		
		# Glow for high traffic (disable at far zoom)
		var effective_glow: float = float(density_params.glow) if zoom_level >= 5 else 0.0
		mat.set_shader_parameter("glow_intensity", effective_glow)
		
		# Color based on route status
		var color = _get_route_color(route, is_player)
		mat.set_shader_parameter("flow_color", color)
		
		# Random time offset to desync animations
		mat.set_shader_parameter("time_offset", route.id * 0.17)


func _get_density_params(pax: int) -> Dictionary:
	"""Get visualization parameters based on passenger volume"""
	if pax < DENSITY_SPARSE:
		# Sparse single file
		return {
			"streams": 1.0,
			"density": 2.0,
			"speed": 0.5,
			"width": BASE_LINE_WIDTH,
			"glow": 0.0
		}
	elif pax < DENSITY_SINGLE:
		# Tight single file
		return {
			"streams": 1.0,
			"density": 4.0,
			"speed": 0.8,
			"width": BASE_LINE_WIDTH * 1.2,
			"glow": 0.0
		}
	elif pax < DENSITY_DOUBLE:
		# Double stream
		return {
			"streams": 2.0,
			"density": 5.0,
			"speed": 1.0,
			"width": BASE_LINE_WIDTH * 1.5,
			"glow": 0.2
		}
	else:
		# Triple stream + glow (5k+)
		return {
			"streams": 3.0,
			"density": 6.0,
			"speed": 1.5,
			"width": min(BASE_LINE_WIDTH * 2.0, MAX_LINE_WIDTH),
			"glow": 0.6
		}


func _estimate_pax(route: Route) -> int:
	"""Estimate passengers for new routes that haven't run yet"""
	if not route.from_airport or not route.to_airport:
		return 0
	
	var distance = MarketAnalysis.calculate_great_circle_distance(route.from_airport, route.to_airport)
	var demand = MarketAnalysis.calculate_potential_demand(route.from_airport, route.to_airport, distance)
	
	# Estimate based on route capacity and frequency
	var capacity = route.get_total_capacity() * route.frequency
	return int(min(demand * 0.7, capacity * 0.8))  # Assume 70-80% fill rate


func _get_route_color(route: Route, is_player: bool) -> Color:
	"""Get flow color based on route profitability with proper alpha"""
	if not is_player:
		# Competitor routes: use gray with specified alpha range
		var color = COLOR_COMPETITOR
		# Vary alpha slightly based on route traffic for depth
		var traffic_factor = clamp(route.passengers_transported / 2000.0, 0.0, 1.0)
		color.a = lerp(COMPETITOR_ALPHA_MIN, COMPETITOR_ALPHA_MAX, traffic_factor)
		return color
	
	# Player routes: ensure minimum alpha for readability
	var color: Color
	if route.weekly_profit > 10000:
		color = COLOR_PLAYER_PROFIT
	elif route.weekly_profit < -10000:
		color = COLOR_PLAYER_LOSS
	else:
		color = COLOR_PLAYER_NEUTRAL
	
	# Ensure minimum alpha
	color.a = max(color.a, PLAYER_MIN_ALPHA)
	return color


func clear_overlays() -> void:
	"""Remove all route overlays"""
	for overlay in route_overlays.values():
		overlay.queue_free()
	route_overlays.clear()


func set_visible_for_zoom(zoom_level: int) -> void:
	"""Adjust visibility based on map zoom level with smooth fade transition"""
	var should_show = zoom_level >= ZOOM_FADE_THRESHOLD
	
	if should_show and _target_alpha < 1.0:
		# Start fade in
		_target_alpha = 1.0
		_is_fading = true
		visible = true  # Make visible immediately to show fade
	elif not should_show and _target_alpha > 0.0:
		# Start fade out
		_target_alpha = 0.0
		_is_fading = true
