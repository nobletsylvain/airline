extends Node3D
class_name GlobePlaneManager

## Manages animated plane sprites flying along 3D arcs on the globe.
## Reuses PlaneSprite.gd timing logic — only the 3D positioning is new.

const PLANE_QUAD_SIZE: float = 0.15
const MIN_PLANE_SIZE: float = 0.06
const MAX_PLANE_SIZE: float = 0.25
const TRAIL_LENGTH: int = 12  # Number of trail points per plane

var plane_texture: Texture2D
var plane_sprites: Array[PlaneSprite] = []
var plane_nodes: Array[MeshInstance3D] = []
var plane_trails: Array[PackedVector3Array] = []  # Trail position buffers
var trail_mesh: ImmediateMesh  # Single mesh for all trails
var trail_mesh_instance: MeshInstance3D
var last_route_count: int = 0

func _ready() -> void:
	plane_texture = load("res://assets/icons/airplane.png")

	# Create trail mesh instance (single mesh for all trails, rebuilt each frame)
	trail_mesh_instance = MeshInstance3D.new()
	trail_mesh = ImmediateMesh.new()
	trail_mesh_instance.mesh = trail_mesh
	trail_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Trail material: simple additive glow
	var trail_mat := StandardMaterial3D.new()
	trail_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail_mat.albedo_color = Color(0.4, 0.7, 1.0, 0.3)
	trail_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trail_mat.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	trail_mat.no_depth_test = false
	trail_mesh_instance.material_override = trail_mat

	add_child(trail_mesh_instance)

func update_planes(current_week_hour: float, camera_distance: float) -> void:
	"""Update all plane positions and trails."""
	# Check if routes changed
	var current_count: int = _get_total_route_count()
	if current_count != last_route_count:
		_spawn_planes()
		last_route_count = current_count

	# Adapt plane size based on camera zoom
	var size_factor: float = inverse_lerp(6.5, 25.0, camera_distance)
	var plane_size: float = lerpf(MAX_PLANE_SIZE, MIN_PLANE_SIZE, size_factor)

	# Update each plane
	for i in range(plane_sprites.size()):
		var sprite: PlaneSprite = plane_sprites[i]
		sprite.update_position(current_week_hour)

		if i >= plane_nodes.size():
			continue

		var node: MeshInstance3D = plane_nodes[i]

		if not sprite.is_active:
			node.visible = false
			continue

		node.visible = true

		# Get from/to airports based on flight direction
		var from_airport: Airport
		var to_airport: Airport
		if sprite.is_return_leg:
			from_airport = sprite.route.to_airport
			to_airport = sprite.route.from_airport
		else:
			from_airport = sprite.route.from_airport
			to_airport = sprite.route.to_airport

		var from_pos: Vector3 = GlobeUtils.lat_lon_to_vec3(
			from_airport.latitude, from_airport.longitude)
		var to_pos: Vector3 = GlobeUtils.lat_lon_to_vec3(
			to_airport.latitude, to_airport.longitude)

		# Position along the arc
		var world_pos: Vector3 = GlobeUtils.get_arc_point(from_pos, to_pos, sprite.progress)
		node.global_position = world_pos

		# Scale based on zoom
		var quad: QuadMesh = node.mesh as QuadMesh
		if quad:
			quad.size = Vector2(plane_size, plane_size)

		# Update trail
		if i < plane_trails.size():
			var trail: PackedVector3Array = plane_trails[i]
			# Shift buffer and add new position
			if trail.size() >= TRAIL_LENGTH:
				# Remove oldest point
				var new_trail := PackedVector3Array()
				for j in range(1, trail.size()):
					new_trail.append(trail[j])
				new_trail.append(world_pos)
				plane_trails[i] = new_trail
			else:
				trail.append(world_pos)
				plane_trails[i] = trail

	# Rebuild trail geometry
	_draw_trails()

func _spawn_planes() -> void:
	"""Create plane nodes for all active routes."""
	# Clear existing visual nodes
	for node in plane_nodes:
		if is_instance_valid(node):
			node.queue_free()
	# Free PlaneSprite Node2D instances (not in tree, must free manually)
	for sprite in plane_sprites:
		if is_instance_valid(sprite):
			sprite.free()
	plane_nodes.clear()
	plane_sprites.clear()
	plane_trails.clear()

	# Create plane sprites and nodes for all airlines
	for airline in GameData.airlines:
		for route in airline.routes:
			for freq_idx in range(route.frequency):
				var sprite := PlaneSprite.new(route, airline, freq_idx)
				plane_sprites.append(sprite)

				# Create visual node
				var node := _create_plane_node(airline)
				plane_nodes.append(node)
				add_child(node)

				# Initialize trail buffer
				plane_trails.append(PackedVector3Array())

func _create_plane_node(airline: Airline) -> MeshInstance3D:
	"""Create a billboard plane mesh."""
	var node := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(PLANE_QUAD_SIZE, PLANE_QUAD_SIZE)
	node.mesh = quad
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Material: billboard with airplane texture
	var mat := StandardMaterial3D.new()
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	if plane_texture:
		mat.albedo_texture = plane_texture

	# Tint: white for player, airline color for AI
	var is_player: bool = airline == GameData.player_airline
	if is_player:
		mat.albedo_color = Color(1.0, 1.0, 1.0, 0.95)
	else:
		mat.albedo_color = Color(airline.primary_color, 0.7)

	# Emission for glow
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	mat.emission_energy_multiplier = 0.5

	node.material_override = mat
	return node

func _draw_trails() -> void:
	"""Rebuild the trail mesh with fading lines behind each active plane."""
	trail_mesh.clear_surfaces()

	var has_any_trail: bool = false
	for i in range(plane_sprites.size()):
		if not plane_sprites[i].is_active:
			continue
		if i >= plane_trails.size():
			continue
		var trail: PackedVector3Array = plane_trails[i]
		if trail.size() < 2:
			continue

		if not has_any_trail:
			trail_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
			has_any_trail = true

		# Draw trail as line segments with fading alpha
		var airline: Airline = plane_sprites[i].airline
		var is_player: bool = airline == GameData.player_airline
		var trail_color: Color = Color(0.4, 0.7, 1.0) if is_player else Color(airline.primary_color)

		for j in range(trail.size() - 1):
			var alpha: float = float(j) / float(trail.size() - 1) * 0.4
			var col := Color(trail_color.r, trail_color.g, trail_color.b, alpha)

			trail_mesh.surface_set_color(col)
			trail_mesh.surface_add_vertex(trail[j])
			trail_mesh.surface_set_color(col)
			trail_mesh.surface_add_vertex(trail[j + 1])

	if has_any_trail:
		trail_mesh.surface_end()

func _get_total_route_count() -> int:
	var count: int = 0
	for airline in GameData.airlines:
		count += airline.routes.size()
	return count

func get_active_plane_count() -> int:
	"""Count currently active (in-flight) planes."""
	var count: int = 0
	for sprite in plane_sprites:
		if sprite.is_active:
			count += 1
	return count
