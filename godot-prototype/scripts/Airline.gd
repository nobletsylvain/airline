extends Resource
class_name Airline

## Represents an airline in the game

@export var id: int = 0
@export var name: String = ""
@export var airline_code: String = ""
@export var country: String = ""
@export var balance: float = 1000000.0  # Starting with $1M
@export var reputation: float = 0.0
@export var service_quality: float = 50.0  # 0-100
@export var maintenance_quality: float = 50.0  # 0-100

# Collections
var bases: Array[Airport] = []
var routes: Array[Route] = []
var aircraft: Array[AircraftInstance] = []

# Financial tracking
var total_revenue: float = 0.0
var total_expenses: float = 0.0
var weekly_revenue: float = 0.0
var weekly_expenses: float = 0.0

signal balance_changed(new_balance: float)
signal route_added(route: Route)
signal aircraft_purchased(aircraft: AircraftInstance)

func _init(p_name: String = "", p_code: String = "", p_country: String = "") -> void:
	name = p_name
	airline_code = p_code
	country = p_country

func add_balance(amount: float) -> void:
	balance += amount
	balance_changed.emit(balance)

func deduct_balance(amount: float) -> bool:
	if balance >= amount:
		balance -= amount
		balance_changed.emit(balance)
		return true
	return false

func add_route(route: Route) -> void:
	routes.append(route)
	route_added.emit(route)

func calculate_weekly_profit() -> float:
	return weekly_revenue - weekly_expenses

func reset_weekly_stats() -> void:
	weekly_revenue = 0.0
	weekly_expenses = 0.0

func get_grade() -> String:
	"""Determine airline grade based on reputation"""
	if reputation < 10:
		return "New"
	elif reputation < 30:
		return "Emerging"
	elif reputation < 60:
		return "Established"
	elif reputation < 100:
		return "Professional"
	elif reputation < 150:
		return "Elite"
	elif reputation < 200:
		return "Legendary"
	else:
		return "Mythic"
