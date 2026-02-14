extends Camera3D
class_name GlobeCamera

## Orbit camera with physical inertia and tilt-shift depth of field.
## Orbits around the origin (globe center) at a configurable distance.

const MIN_DISTANCE: float = 6.5    # Just above globe surface
const MAX_DISTANCE: float = 25.0   # Full globe view
const ZOOM_SPEED: float = 1.2
const ROTATE_SPEED: float = 0.3    # Degrees per pixel of mouse movement
const INERTIA_DECAY: float = 0.92  # Per-frame velocity decay (lower = more friction)
const MIN_VELOCITY: float = 0.05   # Stop threshold for inertia
const MIN_PITCH: float = -89.0
const MAX_PITCH: float = 89.0

var orbit_distance: float = 18.0
var target_distance: float = 18.0
var yaw: float = 0.0               # Horizontal rotation (degrees)
var pitch: float = 20.0            # Vertical tilt (degrees)
var angular_velocity: Vector2 = Vector2.ZERO  # For inertia after release

var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var drag_accumulated: Vector2 = Vector2.ZERO  # Track total drag for click vs drag detection

# DOF
var dof_enabled: bool = true
var camera_attributes: CameraAttributesPractical

func _ready() -> void:
	# Setup DOF attributes
	camera_attributes = CameraAttributesPractical.new()
	camera_attributes.dof_blur_far_enabled = true
	camera_attributes.dof_blur_near_enabled = true
	camera_attributes.dof_blur_amount = 0.04
	attributes = camera_attributes

	_update_camera_transform()
	_update_dof()

func handle_input(event: InputEvent) -> bool:
	"""Process input events. Returns true if the event was consumed."""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				last_mouse_pos = event.position
				drag_accumulated = Vector2.ZERO
				angular_velocity = Vector2.ZERO
				return true
			else:
				is_dragging = false
				return drag_accumulated.length() > 5.0  # Consume if it was a drag, not a click

		# Zoom with scroll wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			target_distance = maxf(MIN_DISTANCE, target_distance - ZOOM_SPEED)
			return true
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			target_distance = minf(MAX_DISTANCE, target_distance + ZOOM_SPEED)
			return true

	if event is InputEventMouseMotion and is_dragging:
		var delta: Vector2 = event.position - last_mouse_pos
		last_mouse_pos = event.position
		drag_accumulated += delta.abs()

		# Apply rotation
		yaw -= delta.x * ROTATE_SPEED
		pitch -= delta.y * ROTATE_SPEED
		pitch = clampf(pitch, MIN_PITCH, MAX_PITCH)

		# Store velocity for inertia (averaged over recent movement)
		angular_velocity = Vector2(-delta.x, -delta.y) * ROTATE_SPEED
		return true

	return false

func _process(delta: float) -> void:
	# Apply inertia when not dragging
	if not is_dragging:
		if angular_velocity.length() > MIN_VELOCITY:
			yaw += angular_velocity.x
			pitch += angular_velocity.y
			pitch = clampf(pitch, MIN_PITCH, MAX_PITCH)
			angular_velocity *= INERTIA_DECAY
		else:
			angular_velocity = Vector2.ZERO

	# Smooth zoom
	orbit_distance = lerpf(orbit_distance, target_distance, 8.0 * delta)

	# Update DOF based on zoom
	_update_dof()

	# Update camera transform
	_update_camera_transform()

func _update_camera_transform() -> void:
	"""Position camera on orbit sphere looking at origin."""
	var yaw_rad: float = deg_to_rad(yaw)
	var pitch_rad: float = deg_to_rad(pitch)

	var pos := Vector3(
		orbit_distance * cos(pitch_rad) * sin(yaw_rad),
		orbit_distance * sin(pitch_rad),
		orbit_distance * cos(pitch_rad) * cos(yaw_rad)
	)

	global_position = pos
	look_at(Vector3.ZERO, Vector3.UP)

func _update_dof() -> void:
	"""Adjust DOF based on zoom level — more blur when zoomed in (tilt-shift)."""
	if not dof_enabled or not camera_attributes:
		return

	# Normalize zoom: 0 = closest, 1 = farthest
	var zoom_factor: float = inverse_lerp(MIN_DISTANCE, MAX_DISTANCE, orbit_distance)

	# Tilt-shift effect: stronger DOF when zoomed in
	camera_attributes.dof_blur_amount = lerpf(0.1, 0.015, zoom_factor)

	# Focus on the globe surface (distance from camera to globe surface)
	var focus_distance: float = orbit_distance - GlobeUtils.GLOBE_RADIUS
	camera_attributes.dof_blur_far_distance = focus_distance + lerpf(2.0, 12.0, zoom_factor)
	camera_attributes.dof_blur_far_transition = lerpf(2.0, 8.0, zoom_factor)
	camera_attributes.dof_blur_near_distance = maxf(0.1, focus_distance - lerpf(2.0, 8.0, zoom_factor))
	camera_attributes.dof_blur_near_transition = lerpf(1.5, 5.0, zoom_factor)

func get_zoom_factor() -> float:
	"""Returns 0.0 (zoomed in) to 1.0 (zoomed out)."""
	return inverse_lerp(MIN_DISTANCE, MAX_DISTANCE, orbit_distance)

func was_click(threshold: float = 5.0) -> bool:
	"""Check if the last drag was small enough to count as a click."""
	return drag_accumulated.length() <= threshold
