extends Node

## Global game data singleton

# Game state
var current_week: int = 0
var current_cycle: int = 0
var is_simulating: bool = false

# Collections
var airports: Array[Airport] = []
var airlines: Array[Airline] = []
var aircraft_models: Array[AircraftModel] = []
var player_airline: Airline = null

# Signals
signal week_simulated(week_number: int)
signal game_initialized()

func _ready() -> void:
	initialize_game_data()

func initialize_game_data() -> void:
	"""Initialize sample airports and aircraft models"""
	create_sample_airports()
	create_aircraft_models()
	create_player_airline()
	game_initialized.emit()

func create_sample_airports() -> void:
	"""Create a set of sample airports around the world"""
	var airport_data: Array[Dictionary] = [
		{"iata": "JFK", "name": "John F. Kennedy International", "city": "New York", "country": "USA",
		 "lat": 40.6413, "lon": -73.7781, "size": 12, "pop": 8000000},
		{"iata": "LAX", "name": "Los Angeles International", "city": "Los Angeles", "country": "USA",
		 "lat": 33.9416, "lon": -118.4085, "size": 12, "pop": 4000000},
		{"iata": "LHR", "name": "London Heathrow", "city": "London", "country": "UK",
		 "lat": 51.4700, "lon": -0.4543, "size": 12, "pop": 9000000},
		{"iata": "NRT", "name": "Narita International", "city": "Tokyo", "country": "Japan",
		 "lat": 35.7720, "lon": 140.3929, "size": 11, "pop": 14000000},
		{"iata": "SYD", "name": "Sydney Airport", "city": "Sydney", "country": "Australia",
		 "lat": -33.9399, "lon": 151.1753, "size": 10, "pop": 5000000},
		{"iata": "DXB", "name": "Dubai International", "city": "Dubai", "country": "UAE",
		 "lat": 25.2532, "lon": 55.3657, "size": 11, "pop": 3000000},
		{"iata": "CDG", "name": "Charles de Gaulle", "city": "Paris", "country": "France",
		 "lat": 49.0097, "lon": 2.5479, "size": 12, "pop": 11000000},
		{"iata": "FRA", "name": "Frankfurt Airport", "city": "Frankfurt", "country": "Germany",
		 "lat": 50.0379, "lon": 8.5622, "size": 11, "pop": 750000},
		{"iata": "SIN", "name": "Singapore Changi", "city": "Singapore", "country": "Singapore",
		 "lat": 1.3644, "lon": 103.9915, "size": 11, "pop": 5700000},
		{"iata": "ORD", "name": "O'Hare International", "city": "Chicago", "country": "USA",
		 "lat": 41.9742, "lon": -87.9073, "size": 12, "pop": 2700000},
		{"iata": "ATL", "name": "Hartsfield-Jackson Atlanta", "city": "Atlanta", "country": "USA",
		 "lat": 33.6407, "lon": -84.4277, "size": 12, "pop": 500000},
		{"iata": "HND", "name": "Tokyo Haneda", "city": "Tokyo", "country": "Japan",
		 "lat": 35.5494, "lon": 139.7798, "size": 12, "pop": 14000000},
		{"iata": "PEK", "name": "Beijing Capital", "city": "Beijing", "country": "China",
		 "lat": 40.0799, "lon": 116.6031, "size": 12, "pop": 21000000},
		{"iata": "ICN", "name": "Incheon International", "city": "Seoul", "country": "South Korea",
		 "lat": 37.4602, "lon": 126.4407, "size": 11, "pop": 10000000},
		{"iata": "MIA", "name": "Miami International", "city": "Miami", "country": "USA",
		 "lat": 25.7959, "lon": -80.2870, "size": 10, "pop": 470000},
	]

	for data in airport_data:
		var airport: Airport = Airport.new(data.iata, data.name, data.city, data.country)
		airport.latitude = data.lat
		airport.longitude = data.lon
		airport.size = data.size
		airport.population = data.pop
		airport.income_level = 50 + randi() % 40  # Random income 50-90
		airports.append(airport)

func create_aircraft_models() -> void:
	"""Create sample aircraft models"""
	var models: Array[Dictionary] = [
		{"name": "737-800", "mfr": "Boeing", "eco": 162, "bus": 12, "first": 0, "range": 5665, "price": 89000000},
		{"name": "A320", "mfr": "Airbus", "eco": 150, "bus": 12, "first": 0, "range": 6150, "price": 98000000},
		{"name": "787-9", "mfr": "Boeing", "eco": 242, "bus": 38, "first": 8, "range": 14140, "price": 265000000},
		{"name": "A350-900", "mfr": "Airbus", "eco": 270, "bus": 40, "first": 8, "range": 15000, "price": 317000000},
		{"name": "777-300ER", "mfr": "Boeing", "eco": 310, "bus": 58, "first": 8, "range": 13649, "price": 375000000},
		{"name": "A380", "mfr": "Airbus", "eco": 399, "bus": 80, "first": 14, "range": 15200, "price": 445000000},
		{"name": "737-700", "mfr": "Boeing", "eco": 126, "bus": 8, "first": 0, "range": 6230, "price": 74000000},
		{"name": "A220-300", "mfr": "Airbus", "eco": 135, "bus": 0, "first": 0, "range": 6297, "price": 91000000},
	]

	for model_data in models:
		var model: AircraftModel = AircraftModel.new(
			model_data.name,
			model_data.mfr,
			model_data.eco,
			model_data.bus,
			model_data.first,
			model_data.range,
			model_data.price
		)
		aircraft_models.append(model)

func create_player_airline() -> void:
	"""Create the player's airline"""
	player_airline = Airline.new("SkyLine Airways", "SKY", "USA")
	player_airline.id = 1
	player_airline.balance = 5000000.0  # Start with $5M
	airlines.append(player_airline)

func get_airport_by_iata(iata: String) -> Airport:
	for airport in airports:
		if airport.iata_code == iata:
			return airport
	return null

func get_aircraft_model_by_name(model_name: String) -> AircraftModel:
	for model in aircraft_models:
		if model.model_name == model_name:
			return model
	return null

func lat_lon_to_screen(lat: float, lon: float, map_size: Vector2) -> Vector2:
	"""Convert latitude/longitude to screen coordinates (Mercator projection)"""
	# Normalize longitude (-180 to 180) to (0 to 1)
	var x: float = (lon + 180.0) / 360.0

	# Mercator projection for latitude
	var lat_rad: float = deg_to_rad(lat)
	var merc_y: float = log(tan(PI/4.0 + lat_rad/2.0))
	var y: float = 0.5 - merc_y / (2.0 * PI)

	return Vector2(x * map_size.x, y * map_size.y)
