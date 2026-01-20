extends Node2D
class_name PlaneSprite

## Represents an animated plane flying along a route in real-time

var route: Route
var flight_number: int = 0  # Which flight in the frequency (0-6 for 7x weekly)
var progress: float = 0.0  # 0.0 = departure, 1.0 = arrival
var is_active: bool = true
var airline: Airline

# Visual properties
var plane_color: Color = Color.WHITE
var plane_size: float = 8.0

# Flight timing
var departure_time: float = 0.0  # Hours into the week (0-168)
var arrival_time: float = 0.0
var flight_duration: float = 0.0  # Hours

signal plane_clicked(plane: PlaneSprite)

func _init(p_route: Route, p_airline: Airline, p_flight_number: int) -> void:
	route = p_route
	airline = p_airline
	flight_number = p_flight_number

	if airline:
		plane_color = airline.primary_color

	if route:
		flight_duration = route.flight_duration_hours

		# Calculate departure time based on frequency
		# Spread flights evenly throughout the week (168 hours)
		var hours_between_flights: float = 168.0 / max(route.frequency, 1)
		departure_time = flight_number * hours_between_flights
		arrival_time = departure_time + flight_duration

func update_position(current_week_hour: float) -> void:
	"""Update plane position based on current time in the week"""
	if not route or not route.from_airport or not route.to_airport:
		is_active = false
		return

	# Check if flight is active
	if current_week_hour >= departure_time and current_week_hour <= arrival_time:
		# Flight in progress
		var elapsed: float = current_week_hour - departure_time
		progress = clamp(elapsed / flight_duration, 0.0, 1.0)
		is_active = true
	else:
		# Flight not active at this time
		is_active = false
		progress = 0.0

func get_current_position(map_size: Vector2) -> Vector2:
	"""Calculate current screen position based on progress along great circle"""
	if not route or not route.from_airport or not route.to_airport:
		return Vector2.ZERO

	# Get start and end positions
	var from_pos: Vector2 = route.from_airport.position_2d
	var to_pos: Vector2 = route.to_airport.position_2d

	# Linear interpolation for now (could enhance with great circle interpolation)
	return from_pos.lerp(to_pos, progress)

func get_rotation_angle() -> float:
	"""Calculate rotation angle based on flight direction"""
	if not route or not route.from_airport or not route.to_airport:
		return 0.0

	var from_pos: Vector2 = route.from_airport.position_2d
	var to_pos: Vector2 = route.to_airport.position_2d
	var direction: Vector2 = (to_pos - from_pos).normalized()

	# Return angle in radians (0 = pointing right)
	return direction.angle()

func get_tooltip_text() -> String:
	"""Generate tooltip text for this plane"""
	if not route or not airline:
		return ""

	var from_code: String = route.from_airport.iata_code if route.from_airport else "???"
	var to_code: String = route.to_airport.iata_code if route.to_airport else "???"

	var flight_id: String = "%s%d" % [airline.airline_code, route.id * 10 + flight_number]
	var progress_pct: int = int(progress * 100)

	var remaining_hours: float = flight_duration * (1.0 - progress)
	var eta_text: String = "%.1fh" % remaining_hours

	return "%s: %s → %s\nProgress: %d%%\nETA: %s" % [
		flight_id,
		from_code,
		to_code,
		progress_pct,
		eta_text
	]

func draw_plane(canvas: Control, zoom_level: float) -> void:
	"""Draw the plane sprite on the given canvas"""
	if not is_active:
		return

	var map_size: Vector2 = canvas.size
	var pos: Vector2 = get_current_position(map_size)
	var angle: float = get_rotation_angle()

	# Adjust size for zoom
	var adjusted_size: float = plane_size / zoom_level

	# Draw plane as a triangle pointing in flight direction
	var plane_points: PackedVector2Array = [
		pos + Vector2(adjusted_size * 1.5, 0).rotated(angle),  # Nose
		pos + Vector2(-adjusted_size, adjusted_size * 0.8).rotated(angle),  # Left wing
		pos + Vector2(-adjusted_size, -adjusted_size * 0.8).rotated(angle)  # Right wing
	]

	# Draw plane body
	canvas.draw_colored_polygon(plane_points, plane_color)

	# Draw outline for contrast
	canvas.draw_polyline(plane_points + PackedVector2Array([plane_points[0]]), Color.BLACK, 1.0 / zoom_level, true)
