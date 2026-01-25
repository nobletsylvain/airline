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

# Branding
@export var primary_color: Color = Color(0.2, 0.4, 0.8)  # Default blue
@export var secondary_color: Color = Color(0.9, 0.9, 0.9)  # Default white/gray
@export var accent_color: Color = Color(1.0, 0.6, 0.0)  # Default orange

# Collections
var hubs: Array[Airport] = []  # Airports where airline has hub access (can originate routes)
var routes: Array[Route] = []
var aircraft: Array[AircraftInstance] = []
var loans: Array[Loan] = []
var delegates: Array[Delegate] = []  # Available delegates
var delegate_tasks: Array[DelegateTask] = []  # Active delegate tasks

# Financial tracking
var total_revenue: float = 0.0
var total_expenses: float = 0.0
var weekly_revenue: float = 0.0
var weekly_expenses: float = 0.0
var total_debt: float = 0.0  # Total remaining loan balances
var weekly_loan_payment: float = 0.0

signal balance_changed(new_balance: float)
signal route_added(route: Route)
signal route_removed(route: Route)
signal aircraft_purchased(aircraft: AircraftInstance)
signal loan_taken(loan: Loan)
signal loan_paid_off(loan: Loan)
signal hub_added(airport: Airport)

func _init(p_name: String = "", p_code: String = "", p_country: String = "") -> void:
	name = p_name
	airline_code = p_code
	country = p_country

	# Assign random branding colors if not set
	if p_name != "":
		randomize_branding()

func set_branding(p_primary: Color, p_secondary: Color, p_accent: Color) -> void:
	"""Set custom airline branding colors"""
	primary_color = p_primary
	secondary_color = p_secondary
	accent_color = p_accent

func randomize_branding() -> void:
	"""Generate random but aesthetically pleasing branding colors"""
	# Generate a random hue for primary color
	var hue: float = randf()
	primary_color = Color.from_hsv(hue, 0.7, 0.8)

	# Secondary is usually white/gray
	secondary_color = Color(0.9 + randf() * 0.1, 0.9 + randf() * 0.1, 0.9 + randf() * 0.1)

	# Accent is complementary or triadic to primary
	var accent_hue: float = fmod(hue + 0.5 + randf() * 0.2 - 0.1, 1.0)
	accent_color = Color.from_hsv(accent_hue, 0.8, 0.9)

func get_brand_colors_hex() -> Dictionary:
	"""Get brand colors as hex strings for UI display"""
	return {
		"primary": primary_color.to_html(),
		"secondary": secondary_color.to_html(),
		"accent": accent_color.to_html()
	}

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

func remove_route(route: Route) -> void:
	"""Remove a route from the airline"""
	if route in routes:
		# Unassign aircraft from this route
		for aircraft in route.assigned_aircraft:
			aircraft.is_assigned = false
			aircraft.assigned_route_id = 0
		
		routes.erase(route)
		route_removed.emit(route)

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

func add_loan(loan: Loan) -> void:
	"""Add a loan to the airline"""
	loans.append(loan)
	update_debt_totals()
	loan_taken.emit(loan)

func update_debt_totals() -> void:
	"""Recalculate total debt and weekly payments"""
	total_debt = 0.0
	weekly_loan_payment = 0.0

	for loan in loans:
		if not loan.is_paid_off():
			total_debt += loan.remaining_balance
			weekly_loan_payment += loan.weekly_payment

func process_loan_payments() -> float:
	"""Process all loan payments for the week, returns total paid"""
	var total_paid: float = 0.0

	for loan in loans:
		if not loan.is_paid_off():
			var payment: float = loan.make_payment()
			total_paid += payment

	# Remove paid-off loans
	var paid_off_loans: Array[Loan] = []
	for loan in loans:
		if loan.is_paid_off():
			paid_off_loans.append(loan)

	for loan in paid_off_loans:
		loans.erase(loan)
		loan_paid_off.emit(loan)

	update_debt_totals()
	return total_paid

func get_credit_limit() -> float:
	"""Calculate maximum loan amount based on airline performance"""
	# Base credit on weekly revenue and reputation
	var base_credit: float = weekly_revenue * 10.0  # 10 weeks of revenue
	var reputation_multiplier: float = 1.0 + (reputation / 100.0)
	return base_credit * reputation_multiplier

func get_interest_rate() -> float:
	"""Get interest rate based on airline grade"""
	var grade: String = get_grade()

	match grade:
		"New":
			return 0.08  # 8% for new airlines
		"Emerging":
			return 0.07
		"Established":
			return 0.06
		"Professional":
			return 0.05
		"Elite":
			return 0.04
		"Legendary":
			return 0.03
		"Mythic":
			return 0.02
		_:
			return 0.08

func can_afford_loan_payment(additional_payment: float) -> bool:
	"""Check if airline can afford an additional loan payment"""
	var projected_payment: float = weekly_loan_payment + additional_payment
	var safety_margin: float = balance * 0.1  # Keep 10% cash reserve
	return (balance - safety_margin) >= projected_payment

## Hub Management

func add_hub(airport: Airport) -> void:
	"""Add a hub airport to the airline"""
	if not has_hub(airport):
		hubs.append(airport)
		hub_added.emit(airport)

func has_hub(airport: Airport) -> bool:
	"""Check if airline has a hub at given airport"""
	return airport in hubs

func get_hub_count() -> int:
	"""Get total number of hubs"""
	return hubs.size()

func can_create_route_from(from_airport: Airport, to_airport: Airport) -> bool:
	"""Check if a route can be created based on hub connectivity rules"""
	# Route must originate from a hub
	if not has_hub(from_airport):
		return false
	return true

func get_hub_names() -> String:
	"""Get comma-separated list of hub names"""
	if hubs.is_empty():
		return "None"

	var names: Array[String] = []
	for hub in hubs:
		names.append(hub.iata_code)
	return ", ".join(names)

## Delegate Management

func get_available_delegates() -> Array[Delegate]:
	"""Get list of available (unassigned) delegates"""
	var available: Array[Delegate] = []
	for delegate in delegates:
		if delegate.is_available:
			available.append(delegate)
	return available

func get_busy_delegates() -> Array[Delegate]:
	"""Get list of busy (assigned) delegates"""
	var busy: Array[Delegate] = []
	for delegate in delegates:
		if not delegate.is_available:
			busy.append(delegate)
	return busy

func get_total_delegates() -> int:
	"""Get total number of delegates"""
	return delegates.size()

func get_available_delegate_count() -> int:
	"""Get count of available delegates"""
	return get_available_delegates().size()

func add_delegate(delegate: Delegate) -> void:
	"""Add a delegate to the airline"""
	if delegate not in delegates:
		delegates.append(delegate)

func assign_delegate_to_task(delegate: Delegate, task: DelegateTask) -> bool:
	"""Assign a delegate to a task"""
	if delegate.airline_id != id:
		return false
	
	if not delegate.assign_task(task):
		return false
	
	if task not in delegate_tasks:
		delegate_tasks.append(task)
	
	return true

func cancel_delegate_task(task: DelegateTask) -> bool:
	"""Cancel a delegate task"""
	if task not in delegate_tasks:
		return false
	
	# Find delegate assigned to this task
	for delegate in delegates:
		if delegate.current_task == task:
			delegate.cancel_task()
			break
	
	delegate_tasks.erase(task)
	return true

func process_delegate_tasks() -> void:
	"""Process all delegate tasks for the week"""
	for task in delegate_tasks:
		if task.is_completed():
			# Complete the task
			_complete_delegate_task(task)
		else:
			# Advance progress
			task.advance_week()

func _complete_delegate_task(task: DelegateTask) -> void:
	"""Complete a delegate task and apply effects"""
	# Find delegate
	for delegate in delegates:
		if delegate.current_task == task:
			delegate.complete_task()
			break
	
	# Apply task effects
	match task.task_type:
		DelegateTask.TaskType.COUNTRY_RELATIONSHIP:
			# Improve country relationship
			GameData.improve_country_relationship(id, task.target_country_code, task.relationship_bonus)
		DelegateTask.TaskType.ROUTE_NEGOTIATION:
			# Route negotiation discount is applied when creating route
			pass
		DelegateTask.TaskType.CAMPAIGN:
			# Boost reputation
			reputation += task.reputation_bonus
	
	# Remove completed task
	delegate_tasks.erase(task)

func get_delegate_task_for_route(from_airport: Airport, to_airport: Airport) -> DelegateTask:
	"""Get active negotiation task for a route, if any"""
	for task in delegate_tasks:
		if task.task_type == DelegateTask.TaskType.ROUTE_NEGOTIATION:
			if task.target_route_from == from_airport.iata_code and task.target_route_to == to_airport.iata_code:
				return task
	return null

func initialize_delegates(count: int = 3) -> void:
	"""Initialize starting delegates for new airline"""
	delegates.clear()
	for i in range(count):
		var delegate = Delegate.new(
			GameData.next_delegate_id + i,
			id,
			"Delegate %d" % (i + 1),
			1  # Starting level
		)
		delegates.append(delegate)
	GameData.next_delegate_id += count
