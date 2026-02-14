extends SubViewportContainer
class_name Globe3D

## Top-level controller for the 3D globe visualization.
## Embeds a 3D scene inside a SubViewport within the 2D UI.
## Emits the same signals as WorldMap.gd for compatibility with GameUI.gd.

# Signals matching WorldMap.gd interface
signal airport_clicked(airport: Airport)
signal airport_hovered(airport: Airport)
signal route_created(from_airport: Airport, to_airport: Airport)
signal route_clicked(route: Route)
signal route_hovered(route: Route)

# 3D scene nodes
var globe_viewport: SubViewport
var globe_camera: GlobeCamera
var globe_mesh: GlobeMesh
var globe_pivot: Node3D
var arc_manager: GlobeArcManager
var marker_manager: GlobeMarkerManager
var plane_manager: GlobePlaneManager
var sun_light: DirectionalLight3D
var fill_light: DirectionalLight3D
var world_env: WorldEnvironment

# Interaction state
var selected_airport: Airport = null
var hover_airport: Airport = null
var selected_route: Route = null

# HUD overlay (2D, drawn on top of viewport)
var hud_panel: PanelContainer

func _ready() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_PASS

	_setup_viewport()
	_setup_environment()
	_setup_lighting()
	_setup_globe()
	_setup_managers()
	_setup_hud()

	# Wait for game data
	if GameData.airports.is_empty():
		await GameData.game_initialized

	# Initialize markers and arcs
	marker_manager.rebuild_markers()
	arc_manager.rebuild_all_arcs()

func _setup_viewport() -> void:
	"""Create the SubViewport for 3D rendering."""
	globe_viewport = SubViewport.new()
	globe_viewport.name = "GlobeViewport"
	globe_viewport.own_world_3d = true
	globe_viewport.transparent_bg = false
	globe_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	globe_viewport.msaa_3d = Viewport.MSAA_2X
	add_child(globe_viewport)

func _setup_environment() -> void:
	"""Dark space background with glow."""
	world_env = WorldEnvironment.new()
	var env := Environment.new()

	# Dark space background
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.02, 0.05)

	# Ambient light (subtle, for dark side visibility)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.06, 0.06, 0.12)
	env.ambient_light_energy = 0.4

	# Glow/bloom for the luminous arc and marker effects
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.4
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.glow_hdr_threshold = 0.8

	# Tonemap
	env.tonemap_mode = Environment.TONE_MAP_FILMIC
	env.tonemap_exposure = 1.0

	world_env.environment = env
	globe_viewport.add_child(world_env)

func _setup_lighting() -> void:
	"""Sun and fill lights for day/night cycle."""
	# Main sun
	sun_light = DirectionalLight3D.new()
	sun_light.name = "SunLight"
	sun_light.light_color = Color(1.0, 0.97, 0.9)
	sun_light.light_energy = 1.3
	sun_light.shadow_enabled = false
	globe_viewport.add_child(sun_light)

	# Fill light (opposite side, faint)
	fill_light = DirectionalLight3D.new()
	fill_light.name = "FillLight"
	fill_light.light_color = Color(0.15, 0.2, 0.35)
	fill_light.light_energy = 0.2
	fill_light.rotation_degrees = Vector3(0, 180, 0)
	globe_viewport.add_child(fill_light)

func _setup_globe() -> void:
	"""Create the globe sphere and camera."""
	# Camera
	globe_camera = GlobeCamera.new()
	globe_camera.name = "GlobeCamera"
	globe_viewport.add_child(globe_camera)

	# Globe pivot (rotation target)
	globe_pivot = Node3D.new()
	globe_pivot.name = "GlobePivot"
	globe_viewport.add_child(globe_pivot)

	# Globe mesh
	globe_mesh = GlobeMesh.new()
	globe_mesh.name = "GlobeMesh"
	globe_pivot.add_child(globe_mesh)

func _setup_managers() -> void:
	"""Create the managers for arcs, markers, and planes."""
	arc_manager = GlobeArcManager.new()
	arc_manager.name = "RouteArcs"
	globe_pivot.add_child(arc_manager)

	marker_manager = GlobeMarkerManager.new()
	marker_manager.name = "AirportMarkers"
	globe_pivot.add_child(marker_manager)

	plane_manager = GlobePlaneManager.new()
	plane_manager.name = "PlaneSprites"
	globe_pivot.add_child(plane_manager)

func _setup_hud() -> void:
	"""Create the 2D HUD overlay on top of the 3D viewport."""
	hud_panel = PanelContainer.new()
	hud_panel.name = "HUDPanel"

	# Style
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.15, 0.85)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	hud_panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	hud_panel.add_child(hbox)

	# Pulsing green dot (will animate in _process)
	var dot_label := Label.new()
	dot_label.name = "GreenDot"
	dot_label.text = "●"
	dot_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
	dot_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(dot_label)

	# Info labels
	var info_label := Label.new()
	info_label.name = "InfoLabel"
	info_label.text = "Week: 1 | Planes: 0 | Cash: $100M"
	info_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	info_label.add_theme_font_size_override("font_size", 13)
	hbox.add_child(info_label)

	# Position: bottom-left with margin
	hud_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hud_panel.position = Vector2(16, -16)
	hud_panel.anchor_bottom = 1.0
	hud_panel.anchor_top = 1.0
	hud_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hud_panel.offset_bottom = -16
	hud_panel.offset_top = -56
	hud_panel.offset_left = 16
	hud_panel.offset_right = 320

	add_child(hud_panel)

func _gui_input(event: InputEvent) -> void:
	"""Route input to camera or interaction system."""
	# Let camera handle rotation/zoom first
	var consumed: bool = globe_camera.handle_input(event)

	# Handle clicks for airport/route selection
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if globe_camera.was_click():
			_handle_click(event.position)

	if consumed:
		accept_event()

func _handle_click(screen_pos: Vector2) -> void:
	"""Handle a click on the globe — select airports or routes."""
	var clicked_airport: Airport = _raycast_airport(screen_pos)

	if clicked_airport:
		if selected_airport and selected_airport != clicked_airport:
			# Second airport selected — create route
			route_created.emit(selected_airport, clicked_airport)
			selected_airport = null
		else:
			# First airport selected
			selected_airport = clicked_airport
			airport_clicked.emit(clicked_airport)
	else:
		# Clicked empty space — deselect
		selected_airport = null

func _raycast_airport(screen_pos: Vector2) -> Airport:
	"""Cast a ray from the camera through screen_pos and find the closest airport."""
	if not globe_camera:
		return null

	var ray_origin: Vector3 = globe_camera.project_ray_origin(screen_pos)
	var ray_dir: Vector3 = globe_camera.project_ray_normal(screen_pos)

	var closest_airport: Airport = null
	var closest_dist: float = 0.4  # Click threshold (world units)

	for iata_code in marker_manager.airport_markers:
		var marker: MeshInstance3D = marker_manager.airport_markers[iata_code]
		if not is_instance_valid(marker):
			continue

		var marker_pos: Vector3 = marker.global_position

		# Point-to-ray distance
		var to_marker: Vector3 = marker_pos - ray_origin
		var projection: float = to_marker.dot(ray_dir)
		if projection < 0:
			continue  # Behind camera

		var closest_point: Vector3 = ray_origin + ray_dir * projection
		var distance: float = marker_pos.distance_to(closest_point)

		if distance < closest_dist:
			closest_dist = distance
			closest_airport = marker_manager.airport_data[iata_code]

	return closest_airport

func _process(_delta: float) -> void:
	"""Update all animated elements each frame."""
	# Get simulation time from global state
	var current_week_hour: float = GameData.current_hour

	# Update globe day/night
	globe_mesh.update_sun_direction(current_week_hour)

	# Update sun light rotation to match shader
	if sun_light:
		var hour_of_day: float = fmod(current_week_hour, 24.0)
		var sun_angle: float = (hour_of_day / 24.0) * TAU
		sun_light.rotation = Vector3(
			deg_to_rad(-15),  # Slight downward angle
			sun_angle,
			0
		)

	# Update plane positions
	plane_manager.update_planes(current_week_hour, globe_camera.orbit_distance)

	# Update route arcs if routes changed
	arc_manager.update_arcs()

	# Update HUD
	_update_hud()

	# Animate green dot pulse
	_animate_hud_dot()

func _update_hud() -> void:
	"""Update the HUD overlay text."""
	var info_label: Label = hud_panel.get_node("HBoxContainer/InfoLabel") if hud_panel else null
	if not info_label:
		return

	var week: int = GameData.current_week if "current_week" in GameData else 1
	var planes: int = plane_manager.get_active_plane_count()
	var cash: float = 0.0
	if GameData.player_airline:
		cash = GameData.player_airline.balance

	var cash_text: String
	if cash >= 1_000_000:
		cash_text = "$%.0fM" % (cash / 1_000_000.0)
	elif cash >= 1000:
		cash_text = "$%.0fK" % (cash / 1000.0)
	else:
		cash_text = "$%.0f" % cash

	info_label.text = "Week: %d  |  Planes: %d  |  Cash: %s" % [week, planes, cash_text]

func _animate_hud_dot() -> void:
	"""Pulse the green dot in the HUD."""
	var dot_label: Label = hud_panel.get_node("HBoxContainer/GreenDot") if hud_panel else null
	if not dot_label:
		return

	var alpha: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 500.0)
	dot_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4, alpha))

func refresh_routes() -> void:
	"""Called when routes change — rebuild arcs and update markers."""
	arc_manager.rebuild_all_arcs()
	marker_manager.update_marker_activity()

func get_screen_position_for_airport(airport: Airport) -> Vector2:
	"""Project a 3D airport position to 2D screen coords (for floating panels)."""
	if not globe_camera or not airport:
		return Vector2.ZERO

	var world_pos: Vector3 = GlobeUtils.lat_lon_to_vec3(
		airport.latitude, airport.longitude, GlobeUtils.GLOBE_RADIUS + 0.02)
	return globe_camera.unproject_position(world_pos)
