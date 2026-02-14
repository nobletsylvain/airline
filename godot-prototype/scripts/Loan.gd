extends Resource
class_name Loan

## Represents a loan/debt for an airline

@export var id: int = 0
@export var airline_id: int = 0
@export var principal: float = 0.0  # Original loan amount
@export var remaining_balance: float = 0.0  # Amount still owed
@export var interest_rate: float = 0.05  # Annual interest rate (5% default)
@export var term_weeks: int = 52  # Loan term in weeks (52 = 1 year)
@export var weeks_remaining: int = 52
@export var weekly_payment: float = 0.0
@export var creation_week: int = 0

func _init(
	p_id: int = 0,
	p_airline_id: int = 0,
	p_principal: float = 0.0,
	p_interest_rate: float = 0.05,
	p_term_weeks: int = 52,
	p_creation_week: int = 0
) -> void:
	id = p_id
	airline_id = p_airline_id
	principal = p_principal
	remaining_balance = p_principal
	interest_rate = p_interest_rate
	term_weeks = p_term_weeks
	weeks_remaining = p_term_weeks
	creation_week = p_creation_week

	# Calculate weekly payment (simplified amortization)
	# Payment = Principal * (r(1+r)^n) / ((1+r)^n - 1)
	var weekly_interest_rate: float = interest_rate / 52.0
	if weekly_interest_rate > 0:
		var factor: float = pow(1 + weekly_interest_rate, term_weeks)
		weekly_payment = principal * (weekly_interest_rate * factor) / (factor - 1)
	else:
		weekly_payment = principal / term_weeks

func make_payment() -> float:
	"""Make a weekly payment, returns amount paid"""
	if weeks_remaining <= 0 or remaining_balance <= 0:
		return 0.0

	var payment: float = min(weekly_payment, remaining_balance)
	remaining_balance -= payment
	weeks_remaining -= 1

	return payment

func pay_off_early() -> float:
	"""Pay off the loan completely, returns amount needed"""
	var payoff_amount: float = remaining_balance
	remaining_balance = 0.0
	weeks_remaining = 0
	return payoff_amount

func is_paid_off() -> bool:
	return remaining_balance <= 0.01 or weeks_remaining <= 0

func get_total_paid() -> float:
	"""Calculate total amount that will be paid over life of loan"""
	return weekly_payment * term_weeks

func get_total_interest() -> float:
	"""Calculate total interest paid over life of loan"""
	return get_total_paid() - principal

func get_progress_percent() -> float:
	"""Get loan repayment progress as percentage"""
	if term_weeks <= 0:
		return 100.0
	return ((term_weeks - weeks_remaining) / float(term_weeks)) * 100.0
