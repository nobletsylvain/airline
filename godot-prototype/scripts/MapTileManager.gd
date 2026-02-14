extends Node
class_name MapTileManager

## Manages map tile fetching and caching with multiple provider support

# Available tile providers
enum TileProvider {
	OSM,                 # Standard OpenStreetMap
	CARTO_VOYAGER,       # Carto Voyager - clean with English labels
	CARTO_LIGHT_NOLABELS,# Carto Light - no labels, clean borders
	CARTO_DARK,          # Carto Dark Matter - dark theme
	ESRI_NATGEO,         # ESRI NatGeo World Map - Natural Earth style
	STAMEN_TERRAIN       # Stamen Terrain - topographic
}

# Tile URL patterns for each provider
# Note: %d order is [z, x, y] for most, [z, y, x] for ESRI
const PROVIDER_URLS = {
	TileProvider.OSM: [
		"https://tile.openstreetmap.org/%d/%d/%d.png",
		"https://a.tile.openstreetmap.org/%d/%d/%d.png",
		"https://b.tile.openstreetmap.org/%d/%d/%d.png",
	],
	TileProvider.CARTO_VOYAGER: [
		"https://basemaps.cartocdn.com/rastertiles/voyager/%d/%d/%d.png",
		"https://a.basemaps.cartocdn.com/rastertiles/voyager/%d/%d/%d.png",
		"https://b.basemaps.cartocdn.com/rastertiles/voyager/%d/%d/%d.png",
	],
	TileProvider.CARTO_LIGHT_NOLABELS: [
		"https://basemaps.cartocdn.com/light_nolabels/%d/%d/%d.png",
		"https://a.basemaps.cartocdn.com/light_nolabels/%d/%d/%d.png",
		"https://b.basemaps.cartocdn.com/light_nolabels/%d/%d/%d.png",
	],
	TileProvider.CARTO_DARK: [
		"https://basemaps.cartocdn.com/rastertiles/dark_all/%d/%d/%d.png",
		"https://a.basemaps.cartocdn.com/rastertiles/dark_all/%d/%d/%d.png",
		"https://b.basemaps.cartocdn.com/rastertiles/dark_all/%d/%d/%d.png",
	],
	TileProvider.ESRI_NATGEO: [
		# ESRI uses z/y/x order (y before x)
		"https://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer/tile/%d/%d/%d",
	],
	TileProvider.STAMEN_TERRAIN: [
		"https://tiles.stadiamaps.com/tiles/stamen_terrain/%d/%d/%d.png",
	],
}

# Providers that use z/y/x order instead of z/x/y
const YX_ORDER_PROVIDERS = [TileProvider.ESRI_NATGEO]

const TILE_SIZE = 256  # Standard tile size in pixels

# Current provider
var current_provider: TileProvider = TileProvider.CARTO_LIGHT_NOLABELS

# Cache for loaded tiles: key = "provider_z_x_y", value = ImageTexture
var tile_cache: Dictionary = {}
var pending_requests: Dictionary = {}  # Track in-flight requests
var failed_tiles: Dictionary = {}  # Track failed tiles to avoid retrying
var http_requests: Array[HTTPRequest] = []
var max_concurrent_requests: int = 8

# Tile request queue
var request_queue: Array[Dictionary] = []

# Fallback tile texture (generated procedurally if tiles fail)
var fallback_texture: ImageTexture = null

signal tile_loaded(z: int, x: int, y: int, texture: ImageTexture)
signal tile_failed(z: int, x: int, y: int)
signal provider_changed(provider: TileProvider)

func _ready() -> void:
	# Create fallback texture
	_create_fallback_texture()

	# Create HTTP request pool
	for i in range(max_concurrent_requests):
		var http = HTTPRequest.new()
		http.use_threads = true
		http.timeout = 15.0
		add_child(http)
		http_requests.append(http)
		http.request_completed.connect(_on_request_completed.bind(http))

func _create_fallback_texture() -> void:
	"""Create a simple fallback texture for when tiles fail to load"""
	var img = Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.75, 0.85, 0.92, 1.0))  # Light blue-gray (ocean)

	# Draw a subtle grid pattern
	for i in range(0, TILE_SIZE, 64):
		for j in range(TILE_SIZE):
			img.set_pixel(i, j, Color(0.7, 0.8, 0.88, 1.0))
			img.set_pixel(j, i, Color(0.7, 0.8, 0.88, 1.0))

	fallback_texture = ImageTexture.create_from_image(img)

func set_provider(provider: TileProvider) -> void:
	"""Change the tile provider and clear cache"""
	if provider != current_provider:
		current_provider = provider
		clear_cache()
		provider_changed.emit(provider)
		print("Map provider changed to: %s" % get_provider_name(provider))

func get_provider_name(provider: TileProvider) -> String:
	"""Get human-readable name for provider"""
	match provider:
		TileProvider.OSM: return "OpenStreetMap"
		TileProvider.CARTO_VOYAGER: return "Carto Voyager"
		TileProvider.CARTO_LIGHT_NOLABELS: return "Carto Light (No Labels)"
		TileProvider.CARTO_DARK: return "Carto Dark"
		TileProvider.ESRI_NATGEO: return "Natural Earth (ESRI)"
		TileProvider.STAMEN_TERRAIN: return "Stamen Terrain"
	return "Unknown"

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

	# Return fallback for failed tiles
	if key in failed_tiles:
		return fallback_texture

	# Queue download if not already pending
	if key not in pending_requests:
		request_queue.append({"z": z, "x": x, "y": y})
		pending_requests[key] = true

	# Return fallback while loading
	return fallback_texture

func _fetch_tile(z: int, x: int, y: int, http: HTTPRequest) -> void:
	"""Fetch a tile from the current provider"""
	var urls = PROVIDER_URLS[current_provider]
	var url_index = (z + x + y) % urls.size()
	var url_pattern = urls[url_index]
	var key = _tile_key(z, x, y)

	# Build URL with correct coordinate order
	var url: String
	if current_provider in YX_ORDER_PROVIDERS:
		url = url_pattern % [z, y, x]  # z/y/x order
	else:
		url = url_pattern % [z, x, y]  # z/x/y order

	# Set headers
	var headers = [
		"User-Agent: GodotAirlineGame/1.0 (Educational Project)",
		"Accept: image/png,image/jpeg,image/*",
	]

	http.set_meta("tile_key", key)
	http.set_meta("tile_z", z)
	http.set_meta("tile_x", x)
	http.set_meta("tile_y", y)

	var error = http.request(url, headers)
	if error != OK:
		print("Failed to request tile %s: error %d" % [key, error])
		pending_requests.erase(key)
		failed_tiles[key] = true
		tile_failed.emit(z, x, y)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	"""Handle completed tile request"""
	var key = http.get_meta("tile_key")
	var z = http.get_meta("tile_z")
	var x = http.get_meta("tile_x")
	var y = http.get_meta("tile_y")

	pending_requests.erase(key)

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		if response_code != 0:  # Don't spam for network errors
			print("Tile %s failed: result=%d, code=%d" % [key, result, response_code])
		failed_tiles[key] = true
		tile_failed.emit(z, x, y)
		return

	# Load image from buffer (try PNG first, then JPEG)
	var image = Image.new()
	var error = image.load_png_from_buffer(body)

	if error != OK:
		# Try JPEG (ESRI tiles are often JPEG)
		error = image.load_jpg_from_buffer(body)

	if error != OK:
		print("Failed to load tile image %s: error %d" % [key, error])
		failed_tiles[key] = true
		tile_failed.emit(z, x, y)
		return

	# Create texture
	var texture = ImageTexture.create_from_image(image)
	tile_cache[key] = texture

	tile_loaded.emit(z, x, y, texture)

func _tile_key(z: int, x: int, y: int) -> String:
	return "%d_%d_%d_%d" % [current_provider, z, x, y]

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

static func get_world_size_pixels(zoom: int) -> float:
	"""Get total world size in pixels at given zoom level"""
	return pow(2, zoom) * TILE_SIZE

func clear_cache() -> void:
	"""Clear the tile cache"""
	tile_cache.clear()
	failed_tiles.clear()
	pending_requests.clear()
	request_queue.clear()

func get_cache_size() -> int:
	"""Get number of cached tiles"""
	return tile_cache.size()
