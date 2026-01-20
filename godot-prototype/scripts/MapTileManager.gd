extends Node
class_name MapTileManager

## Manages OpenStreetMap tile fetching and caching

# OSM tile URL pattern
const TILE_URL_PATTERN = "https://tile.openstreetmap.org/%d/%d/%d.png"
const TILE_SIZE = 256  # Standard OSM tile size in pixels

# Cache for loaded tiles: key = "z_x_y", value = ImageTexture
var tile_cache: Dictionary = {}
var pending_requests: Dictionary = {}  # Track in-flight requests
var http_requests: Array[HTTPRequest] = []
var max_concurrent_requests: int = 8

# Tile request queue
var request_queue: Array[Dictionary] = []

signal tile_loaded(z: int, x: int, y: int, texture: ImageTexture)
signal tile_failed(z: int, x: int, y: int)

func _ready() -> void:
	# Create HTTP request pool
	for i in range(max_concurrent_requests):
		var http = HTTPRequest.new()
		http.use_threads = true
		http.timeout = 10.0
		add_child(http)
		http_requests.append(http)
		http.request_completed.connect(_on_request_completed.bind(http))

func _process(_delta: float) -> void:
	# Process queued requests
	_process_queue()

func _process_queue() -> void:
	"""Process pending tile requests"""
	if request_queue.is_empty():
		return

	# Find an available HTTP request
	for http in http_requests:
		if http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			if request_queue.is_empty():
				break

			var request = request_queue.pop_front()
			_fetch_tile(request.z, request.x, request.y, http)

func get_tile(z: int, x: int, y: int) -> ImageTexture:
	"""Get a tile from cache or queue download"""
	var key = _tile_key(z, x, y)

	# Return cached tile if available
	if key in tile_cache:
		return tile_cache[key]

	# Queue download if not already pending
	if key not in pending_requests:
		request_queue.append({"z": z, "x": x, "y": y})
		pending_requests[key] = true

	return null

func _fetch_tile(z: int, x: int, y: int, http: HTTPRequest) -> void:
	"""Fetch a tile from OpenStreetMap"""
	var url = TILE_URL_PATTERN % [z, x, y]
	var key = _tile_key(z, x, y)

	# Set user agent (required by OSM policy)
	var headers = ["User-Agent: GodotAirlineGame/1.0"]

	http.set_meta("tile_key", key)
	http.set_meta("tile_z", z)
	http.set_meta("tile_x", x)
	http.set_meta("tile_y", y)

	var error = http.request(url, headers)
	if error != OK:
		pending_requests.erase(key)
		tile_failed.emit(z, x, y)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	"""Handle completed tile request"""
	var key = http.get_meta("tile_key")
	var z = http.get_meta("tile_z")
	var x = http.get_meta("tile_x")
	var y = http.get_meta("tile_y")

	pending_requests.erase(key)

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		tile_failed.emit(z, x, y)
		return

	# Load image from PNG data
	var image = Image.new()
	var error = image.load_png_from_buffer(body)

	if error != OK:
		tile_failed.emit(z, x, y)
		return

	# Create texture
	var texture = ImageTexture.create_from_image(image)
	tile_cache[key] = texture

	tile_loaded.emit(z, x, y, texture)

func _tile_key(z: int, x: int, y: int) -> String:
	return "%d_%d_%d" % [z, x, y]

# Coordinate conversion functions

static func lon_to_tile_x(lon: float, zoom: int) -> int:
	"""Convert longitude to tile X coordinate"""
	return int(floor((lon + 180.0) / 360.0 * pow(2, zoom)))

static func lat_to_tile_y(lat: float, zoom: int) -> int:
	"""Convert latitude to tile Y coordinate"""
	var lat_rad = deg_to_rad(lat)
	return int(floor((1.0 - log(tan(lat_rad) + 1.0 / cos(lat_rad)) / PI) / 2.0 * pow(2, zoom)))

static func tile_x_to_lon(x: int, zoom: int) -> float:
	"""Convert tile X coordinate to longitude"""
	return x / pow(2, zoom) * 360.0 - 180.0

static func tile_y_to_lat(y: int, zoom: int) -> float:
	"""Convert tile Y coordinate to latitude"""
	var n = PI - 2.0 * PI * y / pow(2, zoom)
	return rad_to_deg(atan(sinh(n)))

static func lat_lon_to_pixel(lat: float, lon: float, zoom: int) -> Vector2:
	"""Convert lat/lon to pixel coordinates at given zoom level"""
	var x = (lon + 180.0) / 360.0 * pow(2, zoom) * TILE_SIZE
	var lat_rad = deg_to_rad(lat)
	var y = (1.0 - log(tan(lat_rad) + 1.0 / cos(lat_rad)) / PI) / 2.0 * pow(2, zoom) * TILE_SIZE
	return Vector2(x, y)

static func pixel_to_lat_lon(pixel: Vector2, zoom: int) -> Vector2:
	"""Convert pixel coordinates to lat/lon at given zoom level"""
	var lon = pixel.x / (pow(2, zoom) * TILE_SIZE) * 360.0 - 180.0
	var n = PI - 2.0 * PI * pixel.y / (pow(2, zoom) * TILE_SIZE)
	var lat = rad_to_deg(atan(sinh(n)))
	return Vector2(lat, lon)

func clear_cache() -> void:
	"""Clear the tile cache"""
	tile_cache.clear()

func get_cache_size() -> int:
	"""Get number of cached tiles"""
	return tile_cache.size()
