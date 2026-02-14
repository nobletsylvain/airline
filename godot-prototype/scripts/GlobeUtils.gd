class_name GlobeUtils
extends RefCounted

## Static utility class for converting between geographic coordinates and 3D positions on a sphere.
## Godot uses Y-up coordinate system.

const GLOBE_RADIUS: float = 5.0

static func lat_lon_to_vec3(lat_deg: float, lon_deg: float, radius: float = GLOBE_RADIUS) -> Vector3:
	"""Convert latitude/longitude to a Vector3 position on a sphere surface."""
	var lat_rad: float = deg_to_rad(lat_deg)
	var lon_rad: float = deg_to_rad(-lon_deg)  # Negate for correct east/west orientation

	var x: float = radius * cos(lat_rad) * sin(lon_rad)
	var y: float = radius * sin(lat_rad)
	var z: float = radius * cos(lat_rad) * cos(lon_rad)

	return Vector3(x, y, z)

static func vec3_to_lat_lon(pos: Vector3) -> Vector2:
	"""Convert a Vector3 position to latitude/longitude (returns Vector2(lat, lon) in degrees)."""
	var normalized: Vector3 = pos.normalized()
	var lat_deg: float = rad_to_deg(asin(clampf(normalized.y, -1.0, 1.0)))
	var lon_deg: float = rad_to_deg(-atan2(normalized.x, normalized.z))
	return Vector2(lat_deg, lon_deg)

static func get_arc_point(from_pos: Vector3, to_pos: Vector3, t: float, height_factor: float = 0.15) -> Vector3:
	"""Get a point along a great-circle arc between two positions on the sphere.
	t: 0.0 = from_pos, 1.0 = to_pos
	height_factor: how high the arc rises above the surface (fraction of angular distance * radius)"""
	var from_dir: Vector3 = from_pos.normalized()
	var to_dir: Vector3 = to_pos.normalized()

	# Slerp along the great circle
	var point_on_sphere: Vector3 = from_dir.slerp(to_dir, t)

	# Calculate arc height (parabolic, peaks at midpoint)
	var angle: float = from_dir.angle_to(to_dir)
	var height: float = angle * height_factor * GLOBE_RADIUS * sin(t * PI)

	# Raise above surface
	return point_on_sphere * (GLOBE_RADIUS + height)

static func get_arc_tangent(from_pos: Vector3, to_pos: Vector3, t: float, height_factor: float = 0.15) -> Vector3:
	"""Get the tangent direction along the arc at parameter t (for orienting planes)."""
	var dt: float = 0.01
	var t0: float = clampf(t - dt, 0.0, 1.0)
	var t1: float = clampf(t + dt, 0.0, 1.0)

	var p0: Vector3 = get_arc_point(from_pos, to_pos, t0, height_factor)
	var p1: Vector3 = get_arc_point(from_pos, to_pos, t1, height_factor)

	return (p1 - p0).normalized()

static func get_arc_points(from_pos: Vector3, to_pos: Vector3, segments: int = 48, height_factor: float = 0.15) -> PackedVector3Array:
	"""Generate an array of points along a great-circle arc for mesh building."""
	var points: PackedVector3Array = PackedVector3Array()
	points.resize(segments + 1)

	for i in range(segments + 1):
		var t: float = float(i) / float(segments)
		points[i] = get_arc_point(from_pos, to_pos, t, height_factor)

	return points

static func get_surface_normal(pos: Vector3) -> Vector3:
	"""Get the surface normal at a position (points away from globe center)."""
	return pos.normalized()
