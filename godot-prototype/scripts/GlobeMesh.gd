extends MeshInstance3D
class_name GlobeMesh

## The globe sphere with a day/night shader material.
## Handles updating the sun direction based on simulation time.

const SPHERE_SEGMENTS: int = 128
const SPHERE_RINGS: int = 64

var shader_material: ShaderMaterial
var sun_angle: float = 0.0  # Radians, rotates over 24 game-hours

func _ready() -> void:
	# Create sphere mesh
	var sphere := SphereMesh.new()
	sphere.radius = GlobeUtils.GLOBE_RADIUS
	sphere.height = GlobeUtils.GLOBE_RADIUS * 2.0
	sphere.radial_segments = SPHERE_SEGMENTS
	sphere.rings = SPHERE_RINGS
	mesh = sphere

	# Create shader material
	shader_material = ShaderMaterial.new()
	var shader = load("res://shaders/globe_surface.gdshader")
	if shader:
		shader_material.shader = shader
	else:
		push_warning("GlobeMesh: Could not load globe_surface.gdshader")

	# Load textures (will fall back to placeholder colors if not found)
	_load_textures()

	material_override = shader_material

func _load_textures() -> void:
	"""Load earth textures. Uses placeholder if files don't exist yet."""
	var day_tex = _try_load_texture("res://assets/textures/earth_day.jpg")
	if not day_tex:
		day_tex = _try_load_texture("res://assets/textures/earth_day.png")
	if day_tex:
		shader_material.set_shader_parameter("day_texture", day_tex)
	else:
		# Create a simple procedural placeholder
		_create_placeholder_day_texture()

	var night_tex = _try_load_texture("res://assets/textures/earth_night.jpg")
	if not night_tex:
		night_tex = _try_load_texture("res://assets/textures/earth_night.png")
	if night_tex:
		shader_material.set_shader_parameter("night_texture", night_tex)
	else:
		_create_placeholder_night_texture()

func _try_load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return null

func _create_placeholder_day_texture() -> void:
	"""Create a simple procedural earth-like texture as placeholder."""
	var img := Image.create(512, 256, false, Image.FORMAT_RGB8)
	for y in range(256):
		for x in range(512):
			var u: float = float(x) / 512.0
			var v: float = float(y) / 256.0

			# Simple continent-like noise using sin patterns
			var land: float = sin(u * 12.0 + v * 3.0) * sin(v * 8.0 - u * 5.0)
			land += sin(u * 7.0 - v * 11.0) * 0.5
			land += sin(u * 20.0 + v * 15.0) * 0.2

			if land > 0.3:
				# Land: muted tan/green
				img.set_pixel(x, y, Color(0.35, 0.42, 0.28))
			elif land > 0.1:
				# Coastline: lighter
				img.set_pixel(x, y, Color(0.40, 0.48, 0.35))
			else:
				# Ocean: deep teal
				img.set_pixel(x, y, Color(0.08, 0.18, 0.25))

	var tex := ImageTexture.create_from_image(img)
	shader_material.set_shader_parameter("day_texture", tex)

func _create_placeholder_night_texture() -> void:
	"""Create a simple city-lights placeholder."""
	var img := Image.create(512, 256, false, Image.FORMAT_RGB8)
	img.fill(Color(0.0, 0.0, 0.02))

	# Scatter some "city lights" in typical populated areas
	var rng := RandomNumberGenerator.new()
	rng.seed = 42  # Deterministic
	for _i in range(800):
		var x: int = rng.randi_range(0, 511)
		var y: int = rng.randi_range(40, 200)  # Avoid poles

		# Cluster lights near known regions (rough approximation)
		var brightness: float = rng.randf_range(0.3, 1.0)
		var col := Color(brightness * 1.0, brightness * 0.8, brightness * 0.4)
		img.set_pixel(x, y, col)

		# Small cluster around the point
		for _j in range(rng.randi_range(0, 4)):
			var ox: int = clampi(x + rng.randi_range(-3, 3), 0, 511)
			var oy: int = clampi(y + rng.randi_range(-2, 2), 0, 255)
			var b2: float = brightness * rng.randf_range(0.3, 0.7)
			img.set_pixel(ox, oy, Color(b2 * 1.0, b2 * 0.8, b2 * 0.4))

	var tex := ImageTexture.create_from_image(img)
	shader_material.set_shader_parameter("night_texture", tex)

func update_sun_direction(game_hour: float) -> void:
	"""Update sun direction based on the current hour in the game week.
	game_hour: 0-168 (hours in a week). Sun makes one rotation per 24 hours."""
	var hour_of_day: float = fmod(game_hour, 24.0)
	sun_angle = (hour_of_day / 24.0) * TAU

	var sun_dir := Vector3(
		cos(sun_angle),
		0.25,  # Slight tilt above horizon
		sin(sun_angle)
	).normalized()

	if shader_material:
		shader_material.set_shader_parameter("sun_direction", sun_dir)
