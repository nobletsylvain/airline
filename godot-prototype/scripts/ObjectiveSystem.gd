extends Node
class_name ObjectiveSystem

## Tracks player objectives and missions for progression

signal objective_completed(objective: Objective)
signal objective_progress_updated(objective: Objective, progress: float)
signal all_objectives_completed()

class Objective:
	var id: String
	var title: String
	var description: String
	var target_value: float
	var current_value: float = 0.0
	var is_completed: bool = false
	var reward_money: float = 0.0
	var reward_reputation: float = 0.0

	func _init(p_id: String, p_title: String, p_desc: String, p_target: float, p_reward_money: float = 0.0):
		id = p_id
		title = p_title
		description = p_desc
		target_value = p_target
		reward_money = p_reward_money

	func update_progress(value: float) -> bool:
		"""Update progress and return true if newly completed"""
		if is_completed:
			return false

		current_value = value
		if current_value >= target_value:
			is_completed = true
			return true
		return false

	func get_progress_percent() -> float:
		return (current_value / target_value * 100.0) if target_value > 0 else 0.0

	func get_status_text() -> String:
		if is_completed:
			return "✓ COMPLETED"
		return "%.0f / %.0f (%.0f%%)" % [current_value, target_value, get_progress_percent()]

var active_objectives: Array[Objective] = []

func _ready() -> void:
	create_beginner_objectives()

func create_beginner_objectives() -> void:
	"""Create starting objectives for new players"""
	active_objectives.clear()

	# Objective 1: Purchase first aircraft
	var obj1 = Objective.new(
		"first_aircraft",
		"Fleet Builder",
		"Purchase your first aircraft",
		1.0,
		5000000.0  # $5M reward
	)
	active_objectives.append(obj1)

	# Objective 2: Create first route
	var obj2 = Objective.new(
		"first_route",
		"Route Pioneer",
		"Create your first route",
		1.0,
		5000000.0
	)
	active_objectives.append(obj2)

	# Objective 3: Transport passengers
	var obj3 = Objective.new(
		"transport_1000_pax",
		"People Mover",
		"Transport 1,000 passengers",
		1000.0,
		10000000.0
	)
	active_objectives.append(obj3)

	# Objective 4: Earn profit
	var obj4 = Objective.new(
		"earn_10m_profit",
		"Profitable Operation",
		"Earn $10M in cumulative profit",
		10000000.0,
		20000000.0
	)
	active_objectives.append(obj4)

	# Objective 5: Build fleet
	var obj5 = Objective.new(
		"own_5_aircraft",
		"Fleet Expansion",
		"Own 5 aircraft",
		5.0,
		25000000.0
	)
	active_objectives.append(obj5)

	# Objective 6: Route network
	var obj6 = Objective.new(
		"operate_10_routes",
		"Network Builder",
		"Operate 10 routes",
		10.0,
		30000000.0
	)
	active_objectives.append(obj6)

	# Objective 7: Build reputation
	var obj7 = Objective.new(
		"reach_reputation_100",
		"Respected Carrier",
		"Reach reputation level 100",
		100.0,
		50000000.0
	)
	active_objectives.append(obj7)

	print("Created %d beginner objectives" % active_objectives.size())

func update_objective_progress(objective_id: String, current_value: float) -> void:
	"""Update progress for a specific objective"""
	for obj in active_objectives:
		if obj.id == objective_id:
			var newly_completed: bool = obj.update_progress(current_value)

			objective_progress_updated.emit(obj, obj.get_progress_percent())

			if newly_completed:
				on_objective_completed(obj)

			break

func on_objective_completed(obj: Objective) -> void:
	"""Handle objective completion"""
	print("\n🎯 OBJECTIVE COMPLETED: %s" % obj.title)
	print("   %s" % obj.description)

	# Apply rewards
	if obj.reward_money > 0 and GameData.player_airline:
		GameData.player_airline.add_balance(obj.reward_money)
		print("   💰 Reward: $%.0fM" % (obj.reward_money / 1000000.0))

	if obj.reward_reputation > 0 and GameData.player_airline:
		GameData.player_airline.reputation += obj.reward_reputation
		print("   ⭐ Reputation: +%.0f" % obj.reward_reputation)

	objective_completed.emit(obj)

	# Check if all objectives complete
	var all_complete: bool = true
	for objective in active_objectives:
		if not objective.is_completed:
			all_complete = false
			break

	if all_complete:
		all_objectives_completed.emit()
		print("\n🏆 ALL OBJECTIVES COMPLETED! You're a true airline tycoon!")

func get_active_objectives() -> Array[Objective]:
	"""Get list of incomplete objectives"""
	var active: Array[Objective] = []
	for obj in active_objectives:
		if not obj.is_completed:
			active.append(obj)
	return active

func get_completed_objectives() -> Array[Objective]:
	"""Get list of completed objectives"""
	var completed: Array[Objective] = []
	for obj in active_objectives:
		if obj.is_completed:
			completed.append(obj)
	return completed

func print_objectives_status() -> void:
	"""Print current objective status"""
	print("\n=== OBJECTIVES ===")

	var active = get_active_objectives()
	var completed = get_completed_objectives()

	print("Completed: %d / %d" % [completed.size(), active_objectives.size()])

	if not active.is_empty():
		print("\nActive Objectives:")
		for obj in active:
			print("  [ ] %s: %s - %s" % [obj.title, obj.description, obj.get_status_text()])

	if not completed.is_empty():
		print("\nCompleted:")
		for obj in completed:
			print("  [✓] %s" % obj.title)

func check_objectives_from_game_state() -> void:
	"""Update all objectives based on current game state"""
	if not GameData.player_airline:
		return

	var airline: Airline = GameData.player_airline

	# Update aircraft count
	update_objective_progress("first_aircraft", airline.aircraft.size())
	update_objective_progress("own_5_aircraft", airline.aircraft.size())

	# Update route count
	update_objective_progress("first_route", airline.routes.size())
	update_objective_progress("operate_10_routes", airline.routes.size())

	# Update total passengers
	var total_pax: int = 0
	for route in airline.routes:
		total_pax += route.passengers_transported

	update_objective_progress("transport_1000_pax", total_pax)

	# Update profit
	var total_profit: float = airline.total_revenue - airline.total_expenses
	update_objective_progress("earn_10m_profit", max(0.0, total_profit))

	# Update reputation
	update_objective_progress("reach_reputation_100", airline.reputation)
