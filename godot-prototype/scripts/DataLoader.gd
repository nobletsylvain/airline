extends Node
## NOTE: Do not use class_name here - conflicts with autoload singleton name "DataLoader"

## JSON Data Loader Utility
## Loads game data from JSON files in res://data/
## Used by GameData to initialize airports, aircraft, etc.

const DEFAULT_DATA_PATH = "res://data/"

signal data_loaded(data_type: String, count: int)
signal data_load_error(data_type: String, error: String)

## ============================================================================
## GENERIC JSON LOADING
## ============================================================================

func load_json_file(path: String) -> Variant:
	"""
	Load and parse a JSON file from the given path.
	Returns the parsed data or null if loading fails.
	Emits data_load_error signal on failure.
	"""
	if not FileAccess.file_exists(path):
		var error_msg = "File not found: %s" % path
		push_error(error_msg)
		data_load_error.emit("json", error_msg)
		return null
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		var error_msg = "Failed to open file: %s (error: %s)" % [path, FileAccess.get_open_error()]
		push_error(error_msg)
		data_load_error.emit("json", error_msg)
		return null
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		var error_msg = "JSON parse error in %s at line %d: %s" % [path, json.get_error_line(), json.get_error_message()]
		push_error(error_msg)
		data_load_error.emit("json", error_msg)
		return null
	
	return json.data


## ============================================================================
## AIRPORT DATA LOADING
## ============================================================================

func load_airports(path: String = "") -> Array[Airport]:
	"""
	Load airports from JSON file.
	
	Expected JSON format:
	{
		"airports": [
			{
				"iata": "AMS",
				"name": "Amsterdam Schiphol",
				"city": "Amsterdam",
				"country": "NL",
				"region": "Europe",
				"lat": 52.3086,
				"lon": 4.7639,
				"elevation": 3,
				"hub_tier": 2,
				"annual_passengers": 71,
				"runways": 6,
				"gdp_per_capita": 57000,
				"landing_fee": 8000,
				"passenger_fee": 15
			},
			...
		]
	}
	
	Returns array of Airport resources.
	"""
	if path.is_empty():
		path = DEFAULT_DATA_PATH + "prototype-airports.json"
	
	var data = load_json_file(path)
	if data == null:
		return []
	
	var airports: Array[Airport] = []
	
	# Handle both formats: {"airports": [...]} or just [...]
	var airport_array: Array
	if data is Dictionary and data.has("airports"):
		airport_array = data["airports"]
	elif data is Array:
		airport_array = data
	else:
		var error_msg = "Invalid airport data format in %s - expected 'airports' array" % path
		push_error(error_msg)
		data_load_error.emit("airports", error_msg)
		return []
	
	for airport_data in airport_array:
		var airport = _parse_airport(airport_data)
		if airport:
			airports.append(airport)
	
	print("DataLoader: Loaded %d airports from %s" % [airports.size(), path])
	data_loaded.emit("airports", airports.size())
	
	return airports


func _parse_airport(data: Dictionary) -> Airport:
	"""Parse a single airport dictionary into an Airport resource."""
	# Validate required fields
	var required_fields = ["iata", "name", "lat", "lon"]
	for field in required_fields:
		if not data.has(field):
			push_warning("Airport missing required field '%s': %s" % [field, data])
			return null
	
	var airport = Airport.new(
		data.get("iata", ""),
		data.get("name", ""),
		data.get("city", data.get("name", "")),  # Default city to name if not provided
		data.get("country", "")
	)
	
	# Geographic data
	airport.latitude = float(data.get("lat", 0.0))
	airport.longitude = float(data.get("lon", 0.0))
	airport.elevation = int(data.get("elevation", 0))
	airport.region = data.get("region", "")
	
	# Airport characteristics
	airport.hub_tier = int(data.get("hub_tier", 4))
	airport.annual_passengers = int(data.get("annual_passengers", 0))
	airport.runway_count = int(data.get("runways", 1))
	airport.max_slots_per_week = int(data.get("max_slots", 168))
	
	# Economic data
	airport.gdp_per_capita = int(data.get("gdp_per_capita", 50000))
	airport.landing_fee = float(data.get("landing_fee", 5000.0))
	airport.passenger_fee = float(data.get("passenger_fee", 10.0))
	
	# Population (for demand calculation) - use annual passengers as proxy if not provided
	if data.has("population"):
		# Store in metadata for demand calculations
		airport.set_meta("population", int(data.get("population", 0)))
	
	return airport


## ============================================================================
## AIRCRAFT DATA LOADING
## ============================================================================

func load_aircraft_models(path: String = "") -> Array[AircraftModel]:
	"""
	Load aircraft models from JSON file.
	
	Expected JSON format:
	{
		"aircraft": [
			{
				"name": "ATR 72-600",
				"manufacturer": "ATR",
				"max_seats": 78,
				"range_km": 1528,
				"speed_kmh": 556,
				"price": 26000000,
				"fuel_burn_per_hour": 350,
				"daily_cost": 8000,
				"turnaround_minutes": 45,
				"min_economy": 50,
				"max_business": 0,
				"max_first": 0,
				"default_config": {
					"economy": 78,
					"business": 0,
					"first": 0
				}
			},
			...
		]
	}
	
	Returns array of AircraftModel resources.
	"""
	if path.is_empty():
		path = DEFAULT_DATA_PATH + "prototype-aircraft.json"
	
	var data = load_json_file(path)
	if data == null:
		return []
	
	var models: Array[AircraftModel] = []
	
	# Handle both formats: {"aircraft": [...]} or just [...]
	var aircraft_array: Array
	if data is Dictionary and data.has("aircraft"):
		aircraft_array = data["aircraft"]
	elif data is Array:
		aircraft_array = data
	else:
		var error_msg = "Invalid aircraft data format in %s - expected 'aircraft' array" % path
		push_error(error_msg)
		data_load_error.emit("aircraft", error_msg)
		return []
	
	for aircraft_data in aircraft_array:
		var model = _parse_aircraft_model(aircraft_data)
		if model:
			models.append(model)
	
	print("DataLoader: Loaded %d aircraft models from %s" % [models.size(), path])
	data_loaded.emit("aircraft", models.size())
	
	return models


func _parse_aircraft_model(data: Dictionary) -> AircraftModel:
	"""Parse a single aircraft dictionary into an AircraftModel resource."""
	# Validate required fields
	var required_fields = ["name", "max_seats", "range_km", "price"]
	for field in required_fields:
		if not data.has(field):
			push_warning("Aircraft missing required field '%s': %s" % [field, data])
			return null
	
	var model = AircraftModel.new(
		data.get("name", ""),
		data.get("manufacturer", ""),
		int(data.get("max_seats", 0)),
		int(data.get("range_km", 0)),
		float(data.get("price", 0.0)),
		int(data.get("min_economy", 0)),
		int(data.get("max_first", 0)),
		int(data.get("max_business", 0))
	)
	
	# Additional specifications
	model.speed_kmh = int(data.get("speed_kmh", 800))
	model.fuel_burn = float(data.get("fuel_burn_per_hour", 0.0))
	model.runway_requirement = int(data.get("runway_requirement", 0))
	
	# Store additional data in metadata for easy access
	if data.has("daily_cost"):
		model.set_meta("daily_cost", float(data.get("daily_cost", 0.0)))
	if data.has("turnaround_minutes"):
		model.set_meta("turnaround_minutes", int(data.get("turnaround_minutes", 30)))
	if data.has("lease_rate_monthly"):
		model.set_meta("lease_rate_monthly", float(data.get("lease_rate_monthly", 0.0)))
	if data.has("maintenance_cost_per_hour"):
		model.set_meta("maintenance_cost_per_hour", float(data.get("maintenance_cost_per_hour", 0.0)))
	if data.has("category"):
		model.set_meta("category", data.get("category", ""))
	
	# Set default configuration if provided
	if data.has("default_config"):
		var config = data["default_config"]
		model.set_default_configuration(
			int(config.get("economy", model.max_total_seats)),
			int(config.get("business", 0)),
			int(config.get("first", 0))
		)
	else:
		# Default to all economy
		model.set_default_configuration(model.max_total_seats, 0, 0)
	
	return model


## ============================================================================
## UTILITY FUNCTIONS
## ============================================================================

func file_exists(path: String) -> bool:
	"""Check if a data file exists."""
	return FileAccess.file_exists(path)


func get_data_path(filename: String) -> String:
	"""Get full path for a data file."""
	return DEFAULT_DATA_PATH + filename


func save_json_file(path: String, data: Variant) -> bool:
	"""
	Save data to a JSON file.
	Useful for creating initial data files or saving game state.
	"""
	var json_string = JSON.stringify(data, "\t")  # Pretty print with tabs
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var error_msg = "Failed to open file for writing: %s (error: %s)" % [path, FileAccess.get_open_error()]
		push_error(error_msg)
		return false
	
	file.store_string(json_string)
	file.close()
	
	print("DataLoader: Saved data to %s" % path)
	return true
