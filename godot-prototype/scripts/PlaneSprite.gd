extends Node2D
class_name PlaneSprite

## Represents an animated plane flying along a route in real-time
## Supports bidirectional flight (outbound and return)

var route: Route
var flight_number: int = 0  # Which flight in the frequency (0-6 for 7x weekly)
var progress: float = 0.0  # 0.0 = departure, 1.0 = arrival
var is_active: bool = true
var is_return_leg: bool = false  # True when flying back (to -> from)
var airline: Airline

# Visual properties
var plane_color: Color = Color.WHITE
var plane_size: float = 8.0

# Flight timing
var outbound_departure: float = 0.0  # Hours into the week (0-168)
var outbound_arrival: float = 0.0
var return_departure: float = 0.0  # Return leg departs after turnaround
var return_arrival: float = 0.0
var flight_duration: float = 0.0  # Hours (one way)
var turnaround_time: float = 1.0  # Hours on ground before return flight

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
		outbound_departure = flight_number * hours_between_flights
		outbound_arrival = outbound_departure + flight_duration

		# Return flight timing (after turnaround)
		return_departure = outbound_arrival + turnaround_time
		return_arrival = return_departure + flight_duration

func update_position(current_week_hour: float) -> void:
	"""Update plane position based on current time in the week"""
	if not route or not route.from_airport or not route.to_airport:
		is_active = false
		return

	# Handle week wraparound for flights that span week boundaries
	var check_hour = current_week_hour

	# Check if outbound flight is active
	if check_hour >= outbound_departure and check_hour <= outbound_arrival:
		var elapsed: float = check_hour - outbound_departure
		progress = clamp(elapsed / flight_duration, 0.0, 1.0)
		is_return_leg = false
		is_active = true
	# Check if return flight is active
	elif check_hour >= return_departure and check_hour <= return_arrival:
		var elapsed: float = check_hour - return_departure
		progress = clamp(elapsed / flight_duration, 0.0, 1.0)
		is_return_leg = true
		is_active = true
	# Handle wraparound: return flight might extend into next week
	elif return_arrival > 168.0 and check_hour <= (return_arrival - 168.0):
		var elapsed: float = check_hour + 168.0 - return_departure
		progress = clamp(elapsed / flight_duration, 0.0, 1.0)
		is_return_leg = true
		is_active = true
	else:
		is_active = false
		progress = 0.0

func get_current_position(map_size: Vector2) -> Vector2:
	"""Calculate current screen position based on progress along route"""
	if not route or not route.from_airport or not route.to_airport:
		return Vector2.ZERO

	# Get start and end positions based on direction
	var start_pos: Vector2
	var end_pos: Vector2

	if is_return_leg:
		# Return flight: to -> from
		start_pos = route.to_airport.position_2d
		end_pos = route.from_airport.position_2d
	else:
		# Outbound flight: from -> to
		start_pos = route.from_airport.position_2d
		end_pos = route.to_airport.position_2d

	# Linear interpolation
	return start_pos.lerp(end_pos, progress)

func get_rotation_angle() -> float:
	"""Calculate rotation angle based on flight direction"""
	if not route or not route.from_airport or not route.to_airport:
		return 0.0

	var start_pos: Vector2
	var end_pos: Vector2

	if is_return_leg:
		# Return flight: to -> from
		start_pos = route.to_airport.position_2d
		end_pos = route.from_airport.position_2d
	else:
		# Outbound flight: from -> to
		start_pos = route.from_airport.position_2d
		end_pos = route.to_airport.position_2d

	var direction: Vector2 = (end_pos - start_pos).normalized()

	# Return angle in radians (0 = pointing right)
	return direction.angle()

func get_tooltip_text() -> String:
	"""Generate tooltip text for this plane"""
	if not route or not airline:
		return ""

	var from_code: String = route.from_airport.iata_code if route.from_airport else "???"
	var to_code: String = route.to_airport.iata_code if route.to_airport else "???"

	# Swap codes if return leg
	var origin: String = from_code if not is_return_leg else to_code
	var dest: String = to_code if not is_return_leg else from_code

	var flight_id: String = "%s%d" % [airline.airline_code, route.id * 10 + flight_number]
	if is_return_leg:
		flight_id += "R"  # Mark return flights

	var progress_pct: int = int(progress * 100)

	var remaining_hours: float = flight_duration * (1.0 - progress)
	var eta_text: String = "%.1fh" % remaining_hours

	return "%s: %s → %s\nProgress: %d%%\nETA: %s" % [
		flight_id,
		origin,
		dest,
		progress_pct,
		eta_text
	]

func draw_plane(canvas: Control, zoom_level: float) -> void:
	"""Draw the plane sprite as outline-only icon style"""
	if not is_active:
		return

	var map_size: Vector2 = canvas.size
	var pos: Vector2 = get_current_position(map_size)
	var angle: float = get_rotation_angle()

	# Adjust size for zoom
	var s: float = (plane_size * 1.5) / zoom_level
	var line_color: Color = plane_color
	var line_width: float = 3.0 / zoom_level

	# Draw outline-only plane icon matching reference
	# Fuselage - vertical body (drawn as thick line)
	var nose_top = pos + Vector2(s * 1.5, 0).rotated(angle)
	var body_bottom = pos + Vector2(-s * 1.2, 0).rotated(angle)

	# Draw fuselage as thick line
	canvas.draw_line(nose_top, body_bottom, line_color, line_width)

	# Left wing - swept back
	var wing_root_l = pos + Vector2(s * 0.0, s * 0.0).rotated(angle)
	var wing_tip_l = pos + Vector2(-s * 0.5, s * 1.4).rotated(angle)
	var wing_back_l = pos + Vector2(-s * 1.0, s * 1.4).rotated(angle)

	# Draw left wing as connected lines
	canvas.draw_line(wing_root_l, wing_tip_l, line_color, line_width)
	canvas.draw_line(wing_tip_l, wing_back_l, line_color, line_width)

	# Right wing - swept back (mirror)
	var wing_tip_r = pos + Vector2(-s * 0.5, -s * 1.4).rotated(angle)
	var wing_back_r = pos + Vector2(-s * 1.0, -s * 1.4).rotated(angle)

	# Draw right wing
	canvas.draw_line(wing_root_l, wing_tip_r, line_color, line_width)
	canvas.draw_line(wing_tip_r, wing_back_r, line_color, line_width)

	# Left tail stabilizer
	var tail_root_l = pos + Vector2(-s * 1.0, 0).rotated(angle)
	var tail_tip_l = pos + Vector2(-s * 1.2, s * 0.7).rotated(angle)
	var tail_back_l = pos + Vector2(-s * 1.5, s * 0.7).rotated(angle)

	canvas.draw_line(tail_root_l, tail_tip_l, line_color, line_width)
	canvas.draw_line(tail_tip_l, tail_back_l, line_color, line_width)

	# Right tail stabilizer (mirror)
	var tail_tip_r = pos + Vector2(-s * 1.2, -s * 0.7).rotated(angle)
	var tail_back_r = pos + Vector2(-s * 1.5, -s * 0.7).rotated(angle)

	canvas.draw_line(tail_root_l, tail_tip_r, line_color, line_width)
	canvas.draw_line(tail_tip_r, tail_back_r, line_color, line_width)
