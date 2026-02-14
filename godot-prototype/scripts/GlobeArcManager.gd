extends Node3D
class_name GlobeArcManager

## Manages 3D route arc visualization on the globe.
## Each route is rendered as a glowing quad strip following a great-circle path.

const ARC_SEGMENTS: int = 48
const BASE_WIDTH: float = 0.03
const MAX_WIDTH: float = 0.12
const GLOW_PASSES: int = 3  # Number of overlapping passes for glow effect

var arc_shader: Shader
var route_meshes: Dictionary = {}  # Route.id -> Array[MeshInstance3D] (one per glow pass)

func _ready() -> void:
	arc_shader = load("res://shaders/arc_line.gdshader")

func rebuild_all_arcs() -> void:
	"""Rebuild all route arcs from current game data."""
	# Clear existing arcs
	for arc_array in route_meshes.values():
		for mesh_inst in arc_array:
			if is_instance_valid(mesh_inst):
				mesh_inst.queue_free()
	route_meshes.clear()

	# Build arcs for all airlines
	for airline in GameData.airlines:
		for route in airline.routes:
			_create_arc_for_route(route, airline)

func update_arcs() -> void:
	"""Check if routes have changed and rebuild if needed."""
	var current_count: int = 0
	for airline in GameData.airlines:
		current_count += airline.routes.size()

	if current_count != route_meshes.size():
		rebuild_all_arcs()

func _create_arc_for_route(route: Route, airline: Airline) -> void:
	"""Create glowing arc mesh(es) for a single route."""
	if not route.from_airport or not route.to_airport:
		return

	var from_pos: Vector3 = GlobeUtils.lat_lon_to_vec3(
		route.from_airport.latitude, route.from_airport.longitude)
	var to_pos: Vector3 = GlobeUtils.lat_lon_to_vec3(
		route.to_airport.latitude, route.to_airport.longitude)

	# Determine color and width based on airline and profitability
	var is_player: bool = airline == GameData.player_airline
	var base_color: Color
	var width: float

	if is_player:
		base_color = _get_profitability_color(route)
		# Width based on capacity
		var total_capacity: int = route.get_total_capacity() * route.frequency
		width = lerpf(BASE_WIDTH, MAX_WIDTH, clampf(total_capacity / 2000.0, 0.0, 1.0))
	else:
		# AI routes: dimmer, using airline color
		base_color = Color(airline.primary_color, 0.4)
		width = BASE_WIDTH * 0.7

	# Create multiple passes for glow effect
	var meshes: Array[MeshInstance3D] = []
	for pass_idx in range(GLOW_PASSES):
		var glow_mult: float
		var alpha_mult: float
		var width_mult: float

		match pass_idx:
			0:  # Outer glow
				glow_mult = 0.3
				alpha_mult = 0.15
				width_mult = 3.0
			1:  # Mid glow
				glow_mult = 0.7
				alpha_mult = 0.4
				width_mult = 1.8
			2:  # Core
				glow_mult = 1.5
				alpha_mult = 1.0
				width_mult = 1.0

		var pass_width: float = width * width_mult
		var pass_color := Color(base_color.r, base_color.g, base_color.b, base_color.a * alpha_mult)

		var mesh_inst: MeshInstance3D = _build_arc_strip(from_pos, to_pos, pass_width, pass_color, glow_mult)
		meshes.append(mesh_inst)
		add_child(mesh_inst)

	route_meshes[route.id] = meshes

func _build_arc_strip(from_pos: Vector3, to_pos: Vector3, width: float, color: Color, glow_mult: float) -> MeshInstance3D:
	"""Build a quad strip mesh along the great-circle arc."""
	var mesh_inst := MeshInstance3D.new()
	var imm := ImmediateMesh.new()
	mesh_inst.mesh = imm
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Create material
	var mat := ShaderMaterial.new()
	if arc_shader:
		mat.shader = arc_shader
	mat.set_shader_parameter("line_color", color)
	mat.set_shader_parameter("glow_intensity", glow_mult)
	mat.set_shader_parameter("glow_width_multiplier", 1.0)
	mat.render_priority = 1
	mesh_inst.material_override = mat

	# Build quad strip geometry
	var from_dir: Vector3 = from_pos.normalized()
	var to_dir: Vector3 = to_pos.normalized()

	imm.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	for i in range(ARC_SEGMENTS + 1):
		var t: float = float(i) / float(ARC_SEGMENTS)
		var point: Vector3 = GlobeUtils.get_arc_point(from_pos, to_pos, t)
		var tangent: Vector3 = GlobeUtils.get_arc_tangent(from_pos, to_pos, t)
		var surface_normal: Vector3 = point.normalized()

		# Perpendicular to both tangent and surface normal (gives us the strip width direction)
		var right: Vector3 = tangent.cross(surface_normal).normalized()

		# Two vertices across the strip width
		var v1: Vector3 = point + right * width * 0.5
		var v2: Vector3 = point - right * width * 0.5

		# UV: x = along arc (0-1), y = across width (0 or 1)
		imm.surface_set_uv(Vector2(t, 0.0))
		imm.surface_set_color(color)
		imm.surface_add_vertex(v1)

		imm.surface_set_uv(Vector2(t, 1.0))
		imm.surface_set_color(color)
		imm.surface_add_vertex(v2)

	imm.surface_end()

	return mesh_inst

func _get_profitability_color(route: Route) -> Color:
	"""Color based on route profitability — matching the mockup aesthetic."""
	if route.weekly_profit > 100000:
		# Highly profitable: bright luminous blue
		return Color(0.3, 0.75, 1.0, 0.9)
	elif route.weekly_profit > 0:
		# Profitable: standard blue
		return Color(0.25, 0.6, 1.0, 0.8)
	elif route.weekly_profit > -50000:
		# Small loss: amber/orange
		return Color(1.0, 0.65, 0.2, 0.7)
	else:
		# Big loss: dim red-orange
		return Color(0.9, 0.3, 0.15, 0.6)
