## GeodesicUtils.gd
## Utility functions for geodesic (great circle) calculations.
## Used for rendering realistic curved route arcs on the world map.
class_name GeodesicUtils
extends RefCounted

## Earth radius in kilometers (mean radius)
const EARTH_RADIUS_KM := 6371.0

## Point count scaling thresholds
const SHORT_ROUTE_KM := 1000.0
const MEDIUM_ROUTE_KM := 5000.0

## Point counts for different route lengths
const SHORT_ROUTE_POINTS := 8
const MEDIUM_ROUTE_POINTS := 12
const LONG_ROUTE_POINTS := 20


static func calculate_geodesic_points(
	lat1_deg: float, lon1_deg: float,
	lat2_deg: float, lon2_deg: float,
	num_points: int = -1
) -> Array[Vector2]:
	"""Calculate intermediate points along a great circle arc.
	
	Args:
		lat1_deg, lon1_deg: Origin coordinates in degrees
		lat2_deg, lon2_deg: Destination coordinates in degrees
		num_points: Number of points to generate (-1 for auto based on distance)
	
	Returns:
		Array of Vector2(longitude, latitude) in degrees
	"""
	# Convert to radians
	var lat1 = deg_to_rad(lat1_deg)
	var lon1 = deg_to_rad(lon1_deg)
	var lat2 = deg_to_rad(lat2_deg)
	var lon2 = deg_to_rad(lon2_deg)
	
	# Calculate angular distance (central angle)
	var delta = _angular_distance(lat1, lon1, lat2, lon2)
	
	# Auto-determine point count based on distance if not specified
	if num_points < 0:
		var distance_km = delta * EARTH_RADIUS_KM
		num_points = _get_point_count_for_distance(distance_km)
	
	var points: Array[Vector2] = []
	
	# Handle edge case: points are the same or very close
	if delta < 0.0001:
		points.append(Vector2(lon1_deg, lat1_deg))
		points.append(Vector2(lon2_deg, lat2_deg))
		return points
	
	# Generate points along the great circle using spherical interpolation
	for i in range(num_points + 1):
		var t = float(i) / float(num_points)
		var point = _interpolate_great_circle(lat1, lon1, lat2, lon2, delta, t)
		points.append(point)
	
	return points


static func _angular_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
	"""Calculate angular distance (central angle) between two points in radians.
	Uses the haversine formula for numerical stability."""
	var dlat = lat2 - lat1
	var dlon = lon2 - lon1
	
	var a = sin(dlat / 2.0) * sin(dlat / 2.0) + \
			cos(lat1) * cos(lat2) * sin(dlon / 2.0) * sin(dlon / 2.0)
	
	# Clamp to avoid numerical issues with asin
	a = clamp(a, 0.0, 1.0)
	
	return 2.0 * asin(sqrt(a))


static func _interpolate_great_circle(
	lat1: float, lon1: float,
	lat2: float, lon2: float,
	delta: float, t: float
) -> Vector2:
	"""Interpolate a point along the great circle arc.
	
	Uses spherical linear interpolation (slerp) formula:
	For fraction t in [0, 1]:
		a = sin((1-t)*δ) / sin(δ)
		b = sin(t*δ) / sin(δ)
	"""
	# Handle edge cases
	if t <= 0.0:
		return Vector2(rad_to_deg(lon1), rad_to_deg(lat1))
	if t >= 1.0:
		return Vector2(rad_to_deg(lon2), rad_to_deg(lat2))
	
	# Handle antipodal edge case (sin(delta) near zero when points ~180° apart)
	# This prevents division by zero and NaN positions
	if abs(sin(delta)) < 0.0001:
		# Fallback to linear interpolation for near-antipodal points
		var lat = lat1 * (1.0 - t) + lat2 * t
		var lon = lon1 * (1.0 - t) + lon2 * t
		return Vector2(rad_to_deg(lon), rad_to_deg(lat))
	
	# Spherical interpolation coefficients
	var a = sin((1.0 - t) * delta) / sin(delta)
	var b = sin(t * delta) / sin(delta)
	
	# Convert to Cartesian coordinates, interpolate, convert back
	var x = a * cos(lat1) * cos(lon1) + b * cos(lat2) * cos(lon2)
	var y = a * cos(lat1) * sin(lon1) + b * cos(lat2) * sin(lon2)
	var z = a * sin(lat1) + b * sin(lat2)
	
	# Convert back to lat/lon
	var lat = atan2(z, sqrt(x * x + y * y))
	var lon = atan2(y, x)
	
	# Return as Vector2(longitude, latitude) in degrees
	return Vector2(rad_to_deg(lon), rad_to_deg(lat))


static func _get_point_count_for_distance(distance_km: float) -> int:
	"""Determine number of interpolation points based on route distance."""
	if distance_km < SHORT_ROUTE_KM:
		return SHORT_ROUTE_POINTS
	elif distance_km < MEDIUM_ROUTE_KM:
		return MEDIUM_ROUTE_POINTS
	else:
		return LONG_ROUTE_POINTS


static func calculate_distance_km(
	lat1_deg: float, lon1_deg: float,
	lat2_deg: float, lon2_deg: float
) -> float:
	"""Calculate great circle distance between two points in kilometers."""
	var lat1 = deg_to_rad(lat1_deg)
	var lon1 = deg_to_rad(lon1_deg)
	var lat2 = deg_to_rad(lat2_deg)
	var lon2 = deg_to_rad(lon2_deg)
	
	var delta = _angular_distance(lat1, lon1, lat2, lon2)
	return delta * EARTH_RADIUS_KM


static func get_arc_midpoint(
	lat1_deg: float, lon1_deg: float,
	lat2_deg: float, lon2_deg: float
) -> Vector2:
	"""Get the midpoint of a great circle arc (useful for route labels)."""
	var lat1 = deg_to_rad(lat1_deg)
	var lon1 = deg_to_rad(lon1_deg)
	var lat2 = deg_to_rad(lat2_deg)
	var lon2 = deg_to_rad(lon2_deg)
	
	var delta = _angular_distance(lat1, lon1, lat2, lon2)
	
	if delta < 0.0001:
		return Vector2(lon1_deg, lat1_deg)
	
	return _interpolate_great_circle(lat1, lon1, lat2, lon2, delta, 0.5)
