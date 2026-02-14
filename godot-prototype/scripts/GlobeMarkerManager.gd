extends Node3D
class_name GlobeMarkerManager

## Manages airport markers on the globe as glowing billboard embers.
## Hubs pulse and glow proportionally to their traffic volume.

const BASE_MARKER_SIZE: float = 0.12
const HUB_MARKER_SIZE: float = 0.25
const PLAYER_HUB_SIZE: float = 0.35

var marker_shader: Shader
var airport_markers: Dictionary = {}  # iata_code -> MeshInstance3D
var airport_data: Dictionary = {}     # iata_code -> Airport

func _ready() -> void:
	marker_shader = load("res://shaders/airport_marker.gdshader")

func rebuild_markers() -> void:
	"""Create markers for all airports."""
	# Clear existing
	for marker in airport_markers.values():
		if is_instance_valid(marker):
			marker.queue_free()
	airport_markers.clear()
	airport_data.clear()

	for airport in GameData.airports:
		_create_marker(airport)

func _create_marker(airport: Airport) -> void:
	"""Create a glowing billboard marker for an airport."""
	var pos: Vector3 = GlobeUtils.lat_lon_to_vec3(
		airport.latitude, airport.longitude, GlobeUtils.GLOBE_RADIUS + 0.01)

	var marker := MeshInstance3D.new()
	marker.name = "Marker_" + airport.iata_code

	# Determine size based on hub tier and player ownership
	var is_player_hub: bool = false
	if GameData.player_airline:
		is_player_hub = GameData.player_airline.has_hub(airport)

	var marker_size: float = BASE_MARKER_SIZE
	if is_player_hub:
		marker_size = PLAYER_HUB_SIZE
	elif airport.hub_tier <= 2:
		marker_size = HUB_MARKER_SIZE

	# Billboard quad mesh
	var quad := QuadMesh.new()
	quad.size = Vector2(marker_size, marker_size)
	marker.mesh = quad

	# Material
	var mat := ShaderMaterial.new()
	if marker_shader:
		mat.shader = marker_shader

	var color: Color = _get_marker_color(airport, is_player_hub)
	mat.set_shader_parameter("marker_color", color)
	mat.set_shader_parameter("glow_intensity", _get_glow_intensity(airport, is_player_hub))
	mat.set_shader_parameter("pulse_speed", _get_pulse_speed(airport))
	mat.set_shader_parameter("pulse_amount", 0.25 if is_player_hub else 0.15)
	mat.render_priority = 2
	marker.material_override = mat

	# Billboard behavior is handled by the shader's vertex() function

	# Position on globe surface
	marker.position = pos
	marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Store references
	marker.set_meta("airport", airport)
	marker.set_meta("iata_code", airport.iata_code)
	airport_markers[airport.iata_code] = marker
	airport_data[airport.iata_code] = airport

	add_child(marker)

func _get_marker_color(airport: Airport, is_player_hub: bool) -> Color:
	"""Color coding: golden for player hubs, white/blue for others."""
	if is_player_hub:
		return Color(1.0, 0.75, 0.15, 1.0)  # Golden ember

	match airport.hub_tier:
		1:  # Mega hub
			return Color(1.0, 0.85, 0.4, 0.9)  # Warm gold
		2:  # Major hub
			return Color(0.9, 0.8, 0.5, 0.8)   # Soft gold
		3:  # Regional hub
			return Color(0.7, 0.75, 0.8, 0.7)   # Cool silver
		_:  # Small airport
			return Color(0.5, 0.55, 0.6, 0.5)   # Dim gray

func _get_glow_intensity(airport: Airport, is_player_hub: bool) -> float:
	if is_player_hub:
		return 3.5
	match airport.hub_tier:
		1: return 2.5
		2: return 2.0
		3: return 1.5
		_: return 1.0

func _get_pulse_speed(airport: Airport) -> float:
	"""Busier airports pulse faster."""
	# Count routes connected to this airport
	var route_count: int = 0
	for airline in GameData.airlines:
		for route in airline.routes:
			if route.from_airport == airport or route.to_airport == airport:
				route_count += 1

	# Base pulse speed with activity multiplier
	return clampf(1.0 + route_count * 0.5, 1.0, 6.0)

func update_marker_activity() -> void:
	"""Update marker pulse speeds based on current traffic."""
	for iata_code in airport_markers:
		var marker: MeshInstance3D = airport_markers[iata_code]
		var airport: Airport = airport_data[iata_code]
		if not is_instance_valid(marker):
			continue

		var mat: ShaderMaterial = marker.material_override as ShaderMaterial
		if mat:
			mat.set_shader_parameter("pulse_speed", _get_pulse_speed(airport))

func get_marker_at_position(world_pos: Vector3, threshold: float = 0.3) -> Airport:
	"""Find the closest airport marker to a world position."""
	var closest: Airport = null
	var closest_dist: float = threshold

	for iata_code in airport_markers:
		var marker: MeshInstance3D = airport_markers[iata_code]
		if not is_instance_valid(marker):
			continue

		var dist: float = marker.global_position.distance_to(world_pos)
		if dist < closest_dist:
			closest_dist = dist
			closest = airport_data[iata_code]

	return closest

func highlight_connected_routes(airport: Airport, arc_manager: GlobeArcManager) -> void:
	"""Flare up routes connected to the hovered airport (visual feedback)."""
	# This will be called from the Globe3D interaction system
	pass  # TODO: Implement route flare on hover
