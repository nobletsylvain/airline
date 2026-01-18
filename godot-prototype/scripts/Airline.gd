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
var loans: Array[Loan] = []

# Financial tracking
var total_revenue: float = 0.0
var total_expenses: float = 0.0
var weekly_revenue: float = 0.0
var weekly_expenses: float = 0.0
var total_debt: float = 0.0  # Total remaining loan balances
var weekly_loan_payment: float = 0.0

signal balance_changed(new_balance: float)
signal route_added(route: Route)
signal aircraft_purchased(aircraft: AircraftInstance)
signal loan_taken(loan: Loan)
signal loan_paid_off(loan: Loan)

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
