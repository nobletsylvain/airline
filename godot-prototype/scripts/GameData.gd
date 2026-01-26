extends Node

## Global game data singleton

# Game state
var current_week: int = 0
var current_hour: float = 0.0  # Hour within the week (0-167), updated live
var current_cycle: int = 0
var is_simulating: bool = false
var next_aircraft_id: int = 1
var next_loan_id: int = 1
var next_delegate_id: int = 1
var next_delegate_task_id: int = 1

# Collections
var airports: Array[Airport] = []
var airlines: Array[Airline] = []
var aircraft_models: Array[AircraftModel] = []
var player_airline: Airline = null
var ai_controllers: Array[AIController] = []
var countries: Array[Country] = []  # All countries in the game
var country_relationships: Dictionary = {}  # {airline_id: {country_code: relationship_score}}

# Tutorial & Progression
var tutorial_manager: TutorialManager = null
var objective_system: ObjectiveSystem = null
var simulation_engine: Node = null  # Reference to SimulationEngine for plane animations
var is_first_time_player: bool = true

# New game settings (from main menu)
var new_game_settings: Dictionary = {}

# Signals
signal week_simulated(week_number: int)
signal game_initialized()
signal aircraft_purchased(aircraft: AircraftInstance, airline: Airline)
signal loan_created(loan: Loan, airline: Airline)
signal ai_decision_made(airline: Airline, decision_type: String)
signal route_created(route: Route, airline: Airline)
signal first_route_created(route: Route, airline: Airline)  # Special signal for first route
signal route_removed(route: Route, airline: Airline)  # Signal when route is removed
signal route_network_changed(airline: Airline)  # Signal when route network changes (for profitability recalculation)

func _ready() -> void:
	# Create tutorial and objective systems first
	tutorial_manager = TutorialManager.new()
	add_child(tutorial_manager)

	objective_system = ObjectiveSystem.new()
	add_child(objective_system)

	# Connect tutorial signals
	tutorial_manager.tutorial_completed.connect(_on_tutorial_completed)

	# Initialize game data
	initialize_game_data()

func initialize_game_data() -> void:
	"""Initialize game data from JSON files via DataLoader"""
	# Load data from JSON files (prototype-airports.json, prototype-aircraft.json)
	load_airports_from_json()
	load_aircraft_from_json()
	
	create_countries()
	create_player_airline()
	create_ai_airlines()
	
	# Auto-assign initial hub if one was selected in menu
	auto_assign_initial_hub()
	
	# PROTOTYPE SIMPLIFICATION (S.3): Delegates disabled for prototype
	# Uncomment below to re-enable delegate system
	#if player_airline:
	#	player_airline.initialize_delegates(3)  # Start with 3 delegates
	
	game_initialized.emit()

	# PROTOTYPE SIMPLIFICATION (S.5): Tutorial disabled for prototype testing
	# Uncomment below to re-enable tutorial auto-start
	#if is_first_time_player:
	#	print("\nStarting tutorial in 2 seconds...")
	#	await get_tree().create_timer(2.0).timeout
	#	tutorial_manager.start_tutorial()
	print("Tutorial auto-start disabled for prototype (S.5)")


func load_airports_from_json() -> void:
	"""Load airports from JSON via DataLoader autoload singleton"""
	var data_loader = get_node_or_null("/root/DataLoader")
	
	if data_loader:
		airports = data_loader.load_airports()
	else:
		push_warning("DataLoader autoload not available")
		airports = []
	
	if airports.is_empty():
		push_warning("No airports loaded from JSON, falling back to hardcoded data")
		create_sample_airports()  # Fallback to hardcoded data
	else:
		print("GameData: Loaded %d airports from JSON" % airports.size())


func load_aircraft_from_json() -> void:
	"""Load aircraft models from JSON via DataLoader autoload singleton"""
	var data_loader = get_node_or_null("/root/DataLoader")
	
	if data_loader:
		aircraft_models = data_loader.load_aircraft_models()
	else:
		push_warning("DataLoader autoload not available")
		aircraft_models = []
	
	if aircraft_models.is_empty():
		push_warning("No aircraft models loaded from JSON, falling back to hardcoded data")
		create_aircraft_models()  # Fallback to hardcoded data
	else:
		print("GameData: Loaded %d aircraft models from JSON" % aircraft_models.size())

func auto_assign_initial_hub() -> void:
	"""Auto-assign the hub if one was selected in the main menu"""
	if not player_airline:
		return
	
	var hub_code: String = player_airline.get_meta("initial_hub_code", "")
	if hub_code.length() == 0:
		return  # No hub selected
	
	var hub_airport: Airport = get_airport_by_iata(hub_code)
	if hub_airport:
		# First hub is free, so just add it
		player_airline.add_hub(hub_airport)
		print("Auto-assigned initial hub: %s (%s)" % [hub_airport.iata_code, hub_airport.city])
		# Remove the meta since we've used it
		player_airline.remove_meta("initial_hub_code")
	else:
		print("Warning: Could not find airport with code: %s" % hub_code)

func _on_tutorial_completed() -> void:
	"""Called when tutorial is finished"""
	is_first_time_player = false
	print("\nObjectives are now active! Check your progress anytime.")

func create_sample_airports() -> void:
	"""LEGACY FALLBACK: Create airports with hardcoded data.
	This is only called if JSON loading fails. Prefer using prototype-airports.json.
	"""
	push_warning("Using hardcoded airport data (JSON load failed)")
	# Data format: iata, name, city, country, region, lat, lon, elevation, hub_tier, annual_pax(M), runways, max_slots, gdp_per_capita, landing_fee, pax_fee
	var airport_data: Array[Dictionary] = [
		# MEGA HUBS (Tier 1: 100M+ passengers)
		{"iata": "ATL", "name": "Hartsfield-Jackson Atlanta", "city": "Atlanta", "country": "USA", "region": "North America",
		 "lat": 33.6407, "lon": -84.4277, "elev": 313, "tier": 1, "pax": 110, "runways": 5, "slots": 1200, "gdp": 65000, "land_fee": 8000, "pax_fee": 12},
		{"iata": "DXB", "name": "Dubai International", "city": "Dubai", "country": "UAE", "region": "Middle East",
		 "lat": 25.2532, "lon": 55.3657, "elev": 19, "tier": 1, "pax": 86, "runways": 2, "slots": 900, "gdp": 44000, "land_fee": 7000, "pax_fee": 15},

		# MAJOR HUBS (Tier 2: 50-100M passengers)
		{"iata": "LHR", "name": "London Heathrow", "city": "London", "country": "UK", "region": "Europe",
		 "lat": 51.4700, "lon": -0.4543, "elev": 25, "tier": 2, "pax": 79, "runways": 2, "slots": 800, "gdp": 48000, "land_fee": 9000, "pax_fee": 18},
		{"iata": "HND", "name": "Tokyo Haneda", "city": "Tokyo", "country": "Japan", "region": "Asia",
		 "lat": 35.5494, "lon": 139.7798, "elev": 11, "tier": 2, "pax": 78, "runways": 4, "slots": 850, "gdp": 42000, "land_fee": 8500, "pax_fee": 14},
		{"iata": "LAX", "name": "Los Angeles International", "city": "Los Angeles", "country": "USA", "region": "North America",
		 "lat": 33.9416, "lon": -118.4085, "elev": 38, "tier": 2, "pax": 75, "runways": 4, "slots": 900, "gdp": 70000, "land_fee": 7500, "pax_fee": 13},
		{"iata": "ORD", "name": "O'Hare International", "city": "Chicago", "country": "USA", "region": "North America",
		 "lat": 41.9742, "lon": -87.9073, "elev": 205, "tier": 2, "pax": 73, "runways": 8, "slots": 1100, "gdp": 62000, "land_fee": 7000, "pax_fee": 11},
		{"iata": "CDG", "name": "Charles de Gaulle", "city": "Paris", "country": "France", "region": "Europe",
		 "lat": 49.0097, "lon": 2.5479, "elev": 119, "tier": 2, "pax": 67, "runways": 4, "slots": 850, "gdp": 45000, "land_fee": 8500, "pax_fee": 16},
		{"iata": "FRA", "name": "Frankfurt Airport", "city": "Frankfurt", "country": "Germany", "region": "Europe",
		 "lat": 50.0379, "lon": 8.5622, "elev": 111, "tier": 2, "pax": 59, "runways": 4, "slots": 800, "gdp": 53000, "land_fee": 8000, "pax_fee": 15},
		{"iata": "SIN", "name": "Singapore Changi", "city": "Singapore", "country": "Singapore", "region": "Asia",
		 "lat": 1.3644, "lon": 103.9915, "elev": 7, "tier": 2, "pax": 58, "runways": 2, "slots": 750, "gdp": 72000, "land_fee": 7500, "pax_fee": 17},

		# REGIONAL HUBS (Tier 3: 20-50M passengers)
		{"iata": "JFK", "name": "John F. Kennedy International", "city": "New York", "country": "USA", "region": "North America",
		 "lat": 40.6413, "lon": -73.7781, "elev": 4, "tier": 3, "pax": 55, "runways": 4, "slots": 700, "gdp": 75000, "land_fee": 9500, "pax_fee": 15},
		{"iata": "ICN", "name": "Incheon International", "city": "Seoul", "country": "South Korea", "region": "Asia",
		 "lat": 37.4602, "lon": 126.4407, "elev": 2, "tier": 3, "pax": 49, "runways": 3, "slots": 650, "gdp": 35000, "land_fee": 6500, "pax_fee": 12},
		{"iata": "NRT", "name": "Narita International", "city": "Tokyo", "country": "Japan", "region": "Asia",
		 "lat": 35.7720, "lon": 140.3929, "elev": 43, "tier": 3, "pax": 43, "runways": 2, "slots": 550, "gdp": 42000, "land_fee": 7000, "pax_fee": 13},
		{"iata": "SYD", "name": "Sydney Airport", "city": "Sydney", "country": "Australia", "region": "Oceania",
		 "lat": -33.9399, "lon": 151.1753, "elev": 6, "tier": 3, "pax": 37, "runways": 3, "slots": 500, "gdp": 58000, "land_fee": 6000, "pax_fee": 14},
		{"iata": "MIA", "name": "Miami International", "city": "Miami", "country": "USA", "region": "North America",
		 "lat": 25.7959, "lon": -80.2870, "elev": 3, "tier": 3, "pax": 35, "runways": 3, "slots": 550, "gdp": 60000, "land_fee": 6500, "pax_fee": 11},

		# Note: PEK (Beijing) was renamed to PKX (Daxing) in 2019, keeping as PEK for recognition
		{"iata": "PEK", "name": "Beijing Capital", "city": "Beijing", "country": "China", "region": "Asia",
		 "lat": 40.0799, "lon": 116.6031, "elev": 35, "tier": 2, "pax": 65, "runways": 3, "slots": 800, "gdp": 22000, "land_fee": 5500, "pax_fee": 10},
	]

	for data in airport_data:
		var airport: Airport = Airport.new(data.iata, data.name, data.city, data.country)
		airport.region = data.region
		airport.latitude = data.lat
		airport.longitude = data.lon
		airport.elevation = data.elev
		airport.hub_tier = data.tier
		airport.annual_passengers = data.pax
		airport.runway_count = data.runways
		airport.max_slots_per_week = data.slots
		airport.gdp_per_capita = data.gdp
		airport.landing_fee = data.land_fee
		airport.passenger_fee = data.pax_fee
		airports.append(airport)

func create_aircraft_models() -> void:
	"""LEGACY FALLBACK: Create aircraft models with hardcoded data.
	This is only called if JSON loading fails. Prefer using prototype-aircraft.json.
	
	PROTOTYPE SIMPLIFICATION (S.1): Only ATR 72-600 available.
	"""
	push_warning("Using hardcoded aircraft data (JSON load failed)")
	
	# PROTOTYPE: Only ATR 72-600 per prototype-scope.md §8.3
	# Other aircraft commented out for prototype - re-enable later
	var models: Array[Dictionary] = [
		# Regional turboprop - PROTOTYPE ONLY AIRCRAFT
		{
			"name": "ATR 72-600", "mfr": "ATR",
			"max_seats": 72, "range": 1500, "price": 26500000,
			"min_economy": 50, "max_first": 0, "max_business": 0,
			"default": {"eco": 72, "bus": 0, "first": 0}  # Single class
		},
		# NOTE: Additional aircraft disabled for prototype (S.1)
		# Uncomment below to restore full fleet variety
		#{"name": "737-800", "mfr": "Boeing", "max_seats": 189, ...},
		#{"name": "A320", "mfr": "Airbus", "max_seats": 180, ...},
		# ... etc
	]

	for model_data in models:
		var model: AircraftModel = AircraftModel.new(
			model_data.name,
			model_data.mfr,
			model_data.max_seats,
			model_data.range,
			model_data.price,
			model_data.min_economy,
			model_data.max_first,
			model_data.max_business
		)

		# Set default configuration
		model.set_default_configuration(
			model_data.default.eco,
			model_data.default.bus,
			model_data.default.first
		)

		aircraft_models.append(model)

func create_countries() -> void:
	"""Create countries from airport data"""
	countries.clear()
	country_relationships.clear()
	
	# Extract unique countries from airports
	var country_codes: Dictionary = {}  # country_code -> country_data
	
	for airport in airports:
		var country_code = airport.country
		if country_code.is_empty():
			continue
		
		# Normalize country code (use standardized code)
		var normalized_code = _normalize_country_code(country_code)
		
		if not country_codes.has(normalized_code):
			# Get region from first airport of this country
			var country_name = _get_country_name(country_code)
			var country = Country.new(normalized_code, country_name, airport.region)
			
			# Calculate average GDP and total population from airports
			var total_gdp = 0.0
			var total_pop = 0
			var airport_count = 0
			
			for ap in airports:
				var ap_code = _normalize_country_code(ap.country)
				if ap_code == normalized_code:
					total_gdp += ap.gdp_per_capita
					total_pop += ap.annual_passengers * 1000  # Rough estimate
					airport_count += 1
			
			if airport_count > 0:
				country.gdp_per_capita = total_gdp / airport_count
				country.population = total_pop
			
			countries.append(country)
			country_codes[normalized_code] = country
	
	print("Created %d countries" % countries.size())

func _normalize_country_code(code: String) -> String:
	"""Normalize country code to standard format"""
	# Map common variations to standard codes
	var code_map = {
		"USA": "US",
		"United States": "US",
		"UK": "GB",
		"United Kingdom": "GB",
		"UAE": "AE",
		"United Arab Emirates": "AE",
		"South Korea": "KR",
		"Korea": "KR",
		"Japan": "JP",
		"France": "FR",
		"Germany": "DE",
		"Singapore": "SG",
		"Australia": "AU",
		"China": "CN",
	}
	
	if code_map.has(code):
		return code_map[code]
	
	# If already a 2-letter code, return as-is
	if code.length() == 2:
		return code.to_upper()
	
	# Otherwise try to find matching country by name (only if countries already exist)
	if not countries.is_empty():
		for country in countries:
			if country.name == code:
				return country.code
	
	# Return first 2 letters uppercase as fallback
	return code.substr(0, 2).to_upper()

func _get_country_name(code: String) -> String:
	"""Get country name from code"""
	var country_names = {
		"USA": "United States",
		"UK": "United Kingdom",
		"UAE": "United Arab Emirates",
		"Japan": "Japan",
		"France": "France",
		"Germany": "Germany",
		"Singapore": "Singapore",
		"South Korea": "South Korea",
		"Australia": "Australia",
		"China": "China",
	}
	# Check if code is already a name (some airports use full names)
	if country_names.has(code):
		return country_names[code]
	# If not found, return code as-is (might already be a name)
	return code

func get_country_by_code(code: String) -> Country:
	"""Get country by code"""
	for country in countries:
		if country.code == code:
			return country
	return null

func get_country_relationship(airline_id: int, country_code: String) -> float:
	"""Get relationship score between airline and country (-100 to +100)"""
	# Normalize country code
	var normalized_code = _normalize_country_code(country_code)
	
	if not country_relationships.has(airline_id):
		country_relationships[airline_id] = {}
	
	var airline_relationships = country_relationships[airline_id]
	if not airline_relationships.has(normalized_code):
		# Initialize relationship based on home country
		var airline = get_airline_by_id(airline_id)
		if airline:
			var home_country = airline.get_meta("home_country", "")
			var normalized_home = _normalize_country_code(home_country)
			if normalized_home == normalized_code:
				airline_relationships[normalized_code] = 15.0  # Home country bonus
			else:
				airline_relationships[normalized_code] = 0.0  # Neutral
		else:
			airline_relationships[normalized_code] = 0.0
	
	return airline_relationships.get(normalized_code, 0.0)

func improve_country_relationship(airline_id: int, country_code: String, amount: float) -> void:
	"""Improve relationship with a country"""
	var normalized_code = _normalize_country_code(country_code)
	
	if not country_relationships.has(airline_id):
		country_relationships[airline_id] = {}
	
	var current = get_country_relationship(airline_id, normalized_code)
	var new_relationship = clamp(current + amount, -100.0, 100.0)
	country_relationships[airline_id][normalized_code] = new_relationship

func get_airline_by_id(airline_id: int) -> Airline:
	"""Get airline by ID"""
	for airline in airlines:
		if airline.id == airline_id:
			return airline
	return null

func calculate_country_relationship(airline_id: int, country_code: String) -> float:
	"""Calculate relationship score based on various factors"""
	var normalized_code = _normalize_country_code(country_code)
	var base_relationship = get_country_relationship(airline_id, normalized_code)
	var airline = get_airline_by_id(airline_id)
	if not airline:
		return base_relationship
	
	# Home country bonus (already included in base, but check again)
	var home_country = airline.get_meta("home_country", "")
	var normalized_home = _normalize_country_code(home_country)
	if normalized_home == normalized_code and base_relationship < 15.0:
		base_relationship = 15.0  # Ensure home country gets bonus
	
	# Market share bonus (routes to this country)
	var market_share_bonus = _calculate_market_share_bonus(airline, normalized_code)
	base_relationship += market_share_bonus
	
	# Delegate level bonus
	var delegate_bonus = _calculate_delegate_bonus(airline, normalized_code)
	base_relationship += delegate_bonus
	
	return clamp(base_relationship, -100.0, 100.0)

func _calculate_market_share_bonus(airline: Airline, country_code: String) -> float:
	"""Calculate relationship bonus from market share in country"""
	var routes_to_country = 0
	var total_routes_to_country = 0
	
	for route in airline.routes:
		if route.to_airport:
			var route_country = _normalize_country_code(route.to_airport.country)
			if route_country == country_code:
				routes_to_country += 1
	
	# Count total routes to this country from all airlines
	for other_airline in airlines:
		for route in other_airline.routes:
			if route.to_airport:
				var route_country = _normalize_country_code(route.to_airport.country)
				if route_country == country_code:
					total_routes_to_country += 1
	
	if total_routes_to_country == 0:
		return 0.0
	
	var market_share = float(routes_to_country) / float(total_routes_to_country)
	# Market share bonus: up to +20 for 100% market share
	return market_share * 20.0

func _calculate_delegate_bonus(airline: Airline, country_code: String) -> float:
	"""Calculate relationship bonus from active delegate tasks"""
	var bonus = 0.0
	var normalized_code = _normalize_country_code(country_code)
	
	for task in airline.delegate_tasks:
		if task.task_type == DelegateTask.TaskType.COUNTRY_RELATIONSHIP:
			var task_country = _normalize_country_code(task.target_country_code)
			if task_country == normalized_code:
				# Bonus based on task progress and delegate level
				var delegate = _get_delegate_for_task(airline, task)
				if delegate:
					var effectiveness = delegate.get_effectiveness()
					bonus += task.progress * effectiveness * 5.0  # Up to 5 points per delegate
	
	return bonus

func _get_delegate_for_task(airline: Airline, task: DelegateTask) -> Delegate:
	"""Get delegate assigned to a task"""
	for delegate in airline.delegates:
		if delegate.current_task == task:
			return delegate
	return null

func create_player_airline() -> void:
	"""Create the player's airline using settings from main menu"""
	# Get settings from main menu, or use defaults
	var airline_name = new_game_settings.get("airline_name", "SkyLine Airways")
	var starting_budget = new_game_settings.get("starting_budget", 100000000.0)
	var hub_code = new_game_settings.get("hub_code", "")

	# Generate airline code from name (first 3 letters uppercase)
	var code_base = airline_name.replace(" ", "").substr(0, 3).to_upper()
	if code_base.length() < 3:
		code_base = (code_base + "XXX").substr(0, 3)

	player_airline = Airline.new(airline_name, code_base, "International")
	player_airline.id = 1
	player_airline.balance = starting_budget
	airlines.append(player_airline)

	print("Created player airline: %s (%s) with $%s" % [airline_name, code_base, GameData.format_money(starting_budget)])

	# If a hub was selected in the menu, we'll assign it after airports are loaded
	if hub_code.length() > 0:
		# Store for later assignment (airports may not be loaded yet)
		player_airline.set_meta("initial_hub_code", hub_code)

func create_ai_airlines() -> void:
	"""Create AI-controlled competitor airlines
	
	PROTOTYPE SIMPLIFICATION (S.2): Only 1 static competitor per prototype-scope.md §8.3.
	"""
	# PROTOTYPE: Reduced to 1 competitor (Euro Express - balanced European carrier)
	# Other AI airlines disabled for prototype - re-enable later
	var ai_airlines_data: Array[Dictionary] = [
		# Single static competitor for prototype testing
		{"name": "Euro Express", "code": "EEX", "country": "DE", "personality": AIController.AIPersonality.BALANCED},
		# NOTE: Additional AI airlines disabled for prototype (S.2)
		# Uncomment below to restore full AI competition
		#{"name": "Global Wings", "code": "GLW", "country": "UK", "personality": AIController.AIPersonality.AGGRESSIVE},
		#{"name": "Pacific Air", "code": "PAC", "country": "Japan", "personality": AIController.AIPersonality.BALANCED},
		#{"name": "TransContinental", "code": "TCN", "country": "USA", "personality": AIController.AIPersonality.BALANCED},
	]

	var next_id: int = 2  # Player is ID 1

	for data in ai_airlines_data:
		var airline: Airline = Airline.new(data.name, data.code, data.country)
		airline.id = next_id
		airline.balance = 100000000.0  # Same starting capital as player
		airlines.append(airline)

		# Create AI controller for this airline
		var ai: AIController = AIController.new(airline, data.personality)
		ai_controllers.append(ai)

		print("Created AI airline: %s (%s) - %s strategy" % [
			airline.name,
			airline.airline_code,
			ai.get_personality_name()
		])

		next_id += 1

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

func purchase_aircraft(airline: Airline, model: AircraftModel, config: AircraftConfiguration = null) -> AircraftInstance:
	"""Purchase an aircraft for an airline with optional custom configuration"""
	if not airline or not model:
		return null

	# Check if airline has enough balance
	if airline.balance < model.price:
		print("Insufficient funds to purchase %s" % model.get_display_name())
		return null

	# Deduct cost
	airline.deduct_balance(model.price)

	# Use provided configuration or default
	var final_config: AircraftConfiguration = config if config else model.get_default_configuration()

	# Create aircraft instance with configuration
	var aircraft: AircraftInstance = AircraftInstance.new(next_aircraft_id, model, airline.id, final_config)
	next_aircraft_id += 1

	# Add to airline's fleet
	airline.aircraft.append(aircraft)

	# Emit signal
	aircraft_purchased.emit(aircraft, airline)

	# Notify tutorial if this is player's purchase
	if airline == player_airline and tutorial_manager:
		tutorial_manager.on_action_performed("purchase_aircraft")

	# Update objectives
	if airline == player_airline and objective_system:
		objective_system.check_objectives_from_game_state()

	print("Purchased %s [%s] for $%.0f (Balance: $%.0f)" % [
		model.get_display_name(),
		final_config.get_config_summary(),
		model.price,
		airline.balance
	])

	return aircraft

func create_loan(airline: Airline, amount: float, term_weeks: int) -> Loan:
	"""Create a new loan for an airline"""
	if not airline:
		return null

	# Check credit limit
	var credit_limit: float = airline.get_credit_limit()
	if amount > credit_limit:
		print("Loan amount $%.0f exceeds credit limit $%.0f" % [amount, credit_limit])
		return null

	# Check if airline can afford the payment
	var interest_rate: float = airline.get_interest_rate()
	var test_loan: Loan = Loan.new(0, airline.id, amount, interest_rate, term_weeks, current_week)

	if not airline.can_afford_loan_payment(test_loan.weekly_payment):
		print("Cannot afford weekly payment of $%.0f" % test_loan.weekly_payment)
		return null

	# Create the actual loan
	var loan: Loan = Loan.new(next_loan_id, airline.id, amount, interest_rate, term_weeks, current_week)
	next_loan_id += 1

	# Add loan to airline
	airline.add_loan(loan)

	# Add cash to airline balance
	airline.add_balance(amount)

	# Emit signal
	loan_created.emit(loan, airline)

	print("Loan created: $%.0f at %.1f%% for %d weeks (Payment: $%.0f/week)" % [amount, interest_rate * 100, term_weeks, loan.weekly_payment])

	return loan

func find_route_opportunities(from_airport: Airport, top_n: int = 10) -> Array[Dictionary]:
	"""Find best route opportunities from a given airport"""
	return MarketAnalysis.find_best_opportunities(from_airport, airports, airlines, player_airline, top_n)

func analyze_route(from: Airport, to: Airport) -> Dictionary:
	"""Analyze a specific route for demand, supply, and opportunity"""
	return MarketAnalysis.analyze_route_opportunity(from, to, airlines, player_airline)

func get_recommended_pricing_for_route(from: Airport, to: Airport) -> Dictionary:
	"""Get AI-recommended pricing for a route"""
	var analysis: Dictionary = analyze_route(from, to)
	return MarketAnalysis.get_recommended_pricing(
		analysis.demand,
		analysis.supply,
		analysis.distance_km,
		analysis.competition
	)

func create_route_for_airline(airline: Airline, from: Airport, to: Airport, aircraft: AircraftInstance = null) -> Route:
	"""Helper function to create a route with tutorial/objective hooks"""
	if not airline or not from or not to:
		return null

	# Validate hub connectivity (route must originate from a hub)
	if not airline.can_create_route_from(from, to):
		print("Cannot create route: %s is not a hub for %s" % [from.iata_code, airline.name])
		print("Available hubs: %s" % airline.get_hub_names())
		return null

	# Create route
	var route: Route = Route.new(from, to, airline.id)

	# Get recommended pricing
	var pricing: Dictionary = get_recommended_pricing_for_route(from, to)
	route.price_economy = pricing.economy
	route.price_business = pricing.business
	route.price_first = pricing.first

	# Assign aircraft if provided
	if aircraft and not aircraft.is_assigned:
		route.assign_aircraft(aircraft)

	# Add to airline
	airline.add_route(route)

	# Check if this is the player's first route
	var is_first_route: bool = (airline == player_airline and airline.routes.size() == 1)

	# Emit signals
	route_created.emit(route, airline)
	route_network_changed.emit(airline)  # Notify that network changed (for profitability recalculation)
	if is_first_route:
		first_route_created.emit(route, airline)

	# Notify tutorial if player route
	if airline == player_airline and tutorial_manager:
		tutorial_manager.on_action_performed("create_route")

	# Update objectives
	if airline == player_airline and objective_system:
		objective_system.check_objectives_from_game_state()

	print("Created route: %s (Freq: %d, Pricing: Y:$%.0f J:$%.0f F:$%.0f)" % [
		route.get_display_name(),
		route.frequency,
		route.price_economy,
		route.price_business,
		route.price_first
	])

	return route

## Hub Management

func calculate_hub_cost(airport: Airport, airline: Airline) -> float:
	"""Calculate cost to purchase hub access at an airport"""
	# Base cost depends on airport size and demand
	var base_cost: float = 500000.0  # $500K base

	# Scale by hub tier (larger hubs are more expensive)
	match airport.hub_tier:
		1:  # Mega Hub
			base_cost = 5000000.0  # $5M
		2:  # Major Hub
			base_cost = 2000000.0  # $2M
		3:  # Regional Hub
			base_cost = 1000000.0  # $1M
		_:  # Smaller airports
			base_cost = 500000.0   # $500K

	# Scale by annual passengers (demand)
	var demand_multiplier: float = 1.0 + (airport.annual_passengers / 50000000.0)  # +1 per 50M passengers
	demand_multiplier = clamp(demand_multiplier, 1.0, 3.0)

	# Discount for first hub (tutorial)
	if airline.get_hub_count() == 0:
		demand_multiplier *= 0.0  # First hub is free!

	# Discount for additional hubs based on airline reputation
	elif airline.reputation > 100:
		demand_multiplier *= 0.8  # 20% discount for elite airlines

	return base_cost * demand_multiplier

func purchase_hub_for_airline(airline: Airline, airport: Airport) -> bool:
	"""Purchase hub access at an airport for an airline"""
	if airline.has_hub(airport):
		print("Airline %s already has a hub at %s" % [airline.name, airport.iata_code])
		return false

	var cost: float = calculate_hub_cost(airport, airline)

	# First hub is free
	if airline.get_hub_count() == 0:
		airline.add_hub(airport)
		print("Hub established at %s (FREE - first hub!)" % airport.iata_code)
		return true

	# Check if airline can afford it
	if not airline.deduct_balance(cost):
		print("Cannot afford hub at %s (Cost: $%s, Balance: $%s)" % [
			airport.iata_code,
			GameData.format_money(cost),
			GameData.format_money(airline.balance)
		])
		return false

	# Add hub
	airline.add_hub(airport)
	print("Hub purchased at %s for $%s" % [airport.iata_code, GameData.format_money(cost)])

	return true

func get_affordable_hub_airports(airline: Airline) -> Array[Airport]:
	"""Get list of airports where airline can afford to open a hub"""
	var affordable: Array[Airport] = []

	for airport in airports:
		if airline.has_hub(airport):
			continue  # Skip airports that are already hubs

		var cost: float = calculate_hub_cost(airport, airline)
		if airline.balance >= cost:
			affordable.append(airport)

	return affordable

## Utility Functions

static func format_money(amount: float) -> String:
	"""Format money with thousands separators"""
	var s: String = str(int(amount))
	var result: String = ""
	var count: int = 0

	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i > 0:
			result = "," + result

	return result

static func format_number(num: float) -> String:
	"""Format large numbers with K/M suffixes"""
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	else:
		return str(int(num))
