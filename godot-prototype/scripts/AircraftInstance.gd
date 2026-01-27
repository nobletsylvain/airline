extends Resource
class_name AircraftInstance

## Instance of an aircraft owned by an airline

enum Status {
	IDLE,           # Available, not assigned to any route
	IN_FLIGHT,      # Currently flying a route
	BOARDING,       # At gate, passengers boarding
	MAINTENANCE,    # Undergoing maintenance
	DELIVERY        # Ordered, awaiting delivery
}

# Status colors for UI
const STATUS_COLORS: Dictionary = {
	Status.IDLE: Color(0.5, 0.5, 0.5),        # Gray
	Status.IN_FLIGHT: Color(0.2, 0.8, 0.3),   # Green
	Status.BOARDING: Color(0.3, 0.6, 0.9),    # Blue
	Status.MAINTENANCE: Color(0.9, 0.4, 0.2), # Orange/Red
	Status.DELIVERY: Color(0.6, 0.4, 0.8)     # Purple
}

const STATUS_NAMES: Dictionary = {
	Status.IDLE: "Idle",
	Status.IN_FLIGHT: "In Flight",
	Status.BOARDING: "Boarding",
	Status.MAINTENANCE: "Maintenance",
	Status.DELIVERY: "Delivery"
}

@export var id: int = 0
@export var model: AircraftModel
@export var configuration: AircraftConfiguration  # Customizable seat layout
@export var airline_id: int = 0
@export var condition: float = 100.0  # 0-100, affects quality
@export var is_assigned: bool = false
@export var assigned_route_id: int = -1
@export var current_status: Status = Status.IDLE
@export var maintenance_due_hours: float = 500.0  # Hours until maintenance needed
@export var delivery_hours_remaining: float = 0.0  # Hours until delivery (if on order)

## Performance history tracking (N.2)
const MAX_HISTORY_WEEKS: int = 8
var revenue_history: Array[float] = []          # Weekly revenue for last 8 weeks
var maintenance_history: Array[float] = []       # Weekly maintenance costs for last 8 weeks
var passengers_history: Array[int] = []          # Weekly passengers carried for last 8 weeks
var total_passengers_carried: int = 0            # Lifetime total passengers
var total_revenue_earned: float = 0.0            # Lifetime total revenue
var total_maintenance_spent: float = 0.0         # Lifetime maintenance costs
var routes_flown: Array[int] = []                # Route IDs this aircraft has flown on

func _init(p_id: int = 0, p_model: AircraftModel = null, p_airline_id: int = 0, p_config: AircraftConfiguration = null) -> void:
	id = p_id
	model = p_model
	airline_id = p_airline_id
	condition = 100.0

	# Use provided configuration or create default
	if p_config:
		configuration = p_config
	elif p_model:
		configuration = p_model.get_default_configuration()
	else:
		configuration = AircraftConfiguration.new()

func degrade_condition(amount: float) -> void:
	condition = max(0.0, condition - amount)

func repair(amount: float) -> void:
	condition = min(100.0, condition + amount)

func get_display_name() -> String:
	if model:
		return "%s %s (ID: %d)" % [model.manufacturer, model.model_name, id]
	return "Unknown Aircraft"

func get_full_display_name() -> String:
	"""Get display name with configuration info"""
	if model and configuration:
		return "%s %s [%s] (ID: %d)" % [
			model.manufacturer,
			model.model_name,
			configuration.get_config_summary(),
			id
		]
	return get_display_name()

func get_status() -> Status:
	"""Get current aircraft status"""
	return current_status

func get_status_name() -> String:
	"""Get human-readable status name"""
	return STATUS_NAMES.get(current_status, "Unknown")

func get_status_color() -> Color:
	"""Get status color for UI"""
	return STATUS_COLORS.get(current_status, Color.WHITE)

func set_status(new_status: Status) -> void:
	"""Set aircraft status"""
	current_status = new_status

func needs_maintenance() -> bool:
	"""Check if aircraft needs maintenance soon"""
	return condition < 70.0 or maintenance_due_hours <= 0

func get_condition_color() -> Color:
	"""Get color based on condition percentage"""
	if condition >= 80:
		return Color(0.2, 0.8, 0.3)  # Green
	elif condition >= 50:
		return Color(0.9, 0.7, 0.2)  # Yellow/Orange
	else:
		return Color(0.9, 0.3, 0.2)  # Red

# Capacity accessors that use the configuration
func get_economy_capacity() -> int:
	return configuration.economy_seats if configuration else 0

func get_business_capacity() -> int:
	return configuration.business_seats if configuration else 0

func get_first_capacity() -> int:
	return configuration.first_seats if configuration else 0

func get_total_capacity() -> int:
	return configuration.get_total_seats() if configuration else 0


## Performance History Methods (N.2)

func record_weekly_performance(revenue: float, maintenance: float, passengers: int, route_id: int) -> void:
	"""Record this week's performance for this aircraft"""
	# Add to history arrays (keep last MAX_HISTORY_WEEKS)
	revenue_history.append(revenue)
	if revenue_history.size() > MAX_HISTORY_WEEKS:
		revenue_history.pop_front()
	
	maintenance_history.append(maintenance)
	if maintenance_history.size() > MAX_HISTORY_WEEKS:
		maintenance_history.pop_front()
	
	passengers_history.append(passengers)
	if passengers_history.size() > MAX_HISTORY_WEEKS:
		passengers_history.pop_front()
	
	# Update lifetime totals
	total_passengers_carried += passengers
	total_revenue_earned += revenue
	total_maintenance_spent += maintenance
	
	# Track routes flown
	if route_id >= 0 and route_id not in routes_flown:
		routes_flown.append(route_id)


func get_average_weekly_revenue() -> float:
	"""Get average weekly revenue over tracked history"""
	if revenue_history.is_empty():
		return 0.0
	var total: float = 0.0
	for rev in revenue_history:
		total += rev
	return total / revenue_history.size()


func get_average_weekly_profit() -> float:
	"""Get average weekly profit (revenue - maintenance) over tracked history"""
	if revenue_history.is_empty() or maintenance_history.is_empty():
		return 0.0
	var total_rev: float = 0.0
	var total_maint: float = 0.0
	for i in range(min(revenue_history.size(), maintenance_history.size())):
		total_rev += revenue_history[i]
		total_maint += maintenance_history[i]
	return (total_rev - total_maint) / min(revenue_history.size(), maintenance_history.size())


func get_profit_margin() -> float:
	"""Get profit margin percentage based on history"""
	var avg_revenue = get_average_weekly_revenue()
	if avg_revenue <= 0:
		return 0.0
	var avg_profit = get_average_weekly_profit()
	return (avg_profit / avg_revenue) * 100.0


func get_revenue_trend() -> float:
	"""Get revenue trend: positive = improving, negative = declining"""
	if revenue_history.size() < 2:
		return 0.0
	var recent_avg: float = 0.0
	var older_avg: float = 0.0
	var half = revenue_history.size() / 2
	
	for i in range(half):
		older_avg += revenue_history[i]
	for i in range(half, revenue_history.size()):
		recent_avg += revenue_history[i]
	
	older_avg /= half if half > 0 else 1
	recent_avg /= (revenue_history.size() - half) if (revenue_history.size() - half) > 0 else 1
	
	if older_avg == 0:
		return 0.0
	return ((recent_avg - older_avg) / older_avg) * 100.0


func get_performance_badge() -> String:
	"""Get performance badge based on profit margin (absolute thresholds).
	For comparative badges, use get_comparative_badge() with fleet context."""
	var margin = get_profit_margin()
	if margin < 0:
		return "Loss Maker"
	elif margin < 10:
		return "Marginal"
	elif margin >= 10:
		return "Good"
	else:
		return "Unknown"


func get_comparative_badge(all_aircraft: Array) -> String:
	"""Get performance badge comparing this aircraft against the fleet.
	
	- 'Best Performer': Top 1 by profit margin (only if profitable)
	- 'Good': Above average profit margin
	- 'Marginal': Near breakeven (0-10% margin)
	- 'Underperformer': Below average but not negative
	- 'Loss Maker': Negative profit margin
	"""
	var my_margin = get_profit_margin()
	
	# First check absolute thresholds for loss/marginal
	if my_margin < 0:
		return "Loss Maker"
	
	# Get margins of all aircraft with history
	var margins: Array[float] = []
	for ac in all_aircraft:
		if ac is AircraftInstance and not ac.revenue_history.is_empty():
			margins.append(ac.get_profit_margin())
	
	if margins.is_empty():
		if my_margin < 10:
			return "Marginal"
		return "Good"
	
	# Find best performer (highest margin, must be profitable)
	var best_margin: float = margins[0]
	for m in margins:
		best_margin = max(best_margin, m)
	
	# Calculate average (excluding negative)
	var positive_margins: Array[float] = []
	for m in margins:
		if m >= 0:
			positive_margins.append(m)
	
	var avg_margin: float = 0.0
	if not positive_margins.is_empty():
		for m in positive_margins:
			avg_margin += m
		avg_margin /= positive_margins.size()
	
	# Determine badge
	if my_margin >= best_margin and my_margin > 0 and best_margin > 10:
		return "Best Performer"
	elif my_margin >= avg_margin and my_margin >= 10:
		return "Good"
	elif my_margin >= 0 and my_margin < 10:
		return "Marginal"
	elif my_margin < avg_margin and my_margin >= 0:
		return "Underperformer"
	else:
		return "Loss Maker"


func get_performance_badge_color() -> Color:
	"""Get color for performance badge based on profit margin"""
	var margin = get_profit_margin()
	if margin < 0:
		return Color(0.9, 0.2, 0.2)  # Red - Loss Maker
	elif margin < 10:
		return Color(0.9, 0.7, 0.2)  # Yellow - Marginal
	else:
		return Color(0.5, 0.8, 0.3)  # Green - Good
	

func get_comparative_badge_color(badge: String) -> Color:
	"""Get color for a comparative performance badge"""
	match badge:
		"Best Performer":
			return Color(0.2, 0.9, 0.3)  # Bright green
		"Good":
			return Color(0.5, 0.8, 0.3)  # Green
		"Marginal":
			return Color(0.9, 0.7, 0.2)  # Yellow
		"Underperformer":
			return Color(0.9, 0.5, 0.2)  # Orange
		"Loss Maker":
			return Color(0.9, 0.2, 0.2)  # Red
		_:
			return Color(0.5, 0.5, 0.5)  # Gray
