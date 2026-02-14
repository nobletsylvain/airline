extends Node
class_name TutorialManager

## Manages the first-time user experience (FTUE) tutorial

signal tutorial_step_started(step: TutorialStep)
signal tutorial_step_completed(step: TutorialStep)
signal tutorial_completed()
signal highlight_ui_element(node_path: String, message: String)
signal clear_ui_highlights()

var current_step_index: int = 0
var tutorial_steps: Array[TutorialStep] = []
var is_tutorial_active: bool = false
var tutorial_completed_flag: bool = false

func _ready() -> void:
	create_tutorial_sequence()

func create_tutorial_sequence() -> void:
	"""Create the complete tutorial flow"""
	tutorial_steps.clear()

	# Step 1: Welcome
	var step1 = TutorialStep.new(
		"welcome",
		"Welcome to Airline Tycoon!",
		"Build your airline empire by analyzing markets, purchasing aircraft, and creating profitable routes. Let's get started!",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step1)

	# Step 2: Explain airline customization
	var step2 = TutorialStep.new(
		"airline_intro",
		"Your Airline",
		"You're the CEO of SkyLine Airways. Every airline has a unique brand identity with custom colors. Let's customize your airline!",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step2)

	# Step 3: Highlight top panel
	var step3 = TutorialStep.new(
		"ui_overview",
		"Game Interface",
		"The top panel shows your airline info, current week, and balance. You start with $100M to build your empire.",
		TutorialStep.StepType.HIGHLIGHT_UI
	)
	step3.ui_element_path = "MarginContainer/VBoxContainer/TopPanel"
	step3.highlight_message = "This is your main dashboard"
	tutorial_steps.append(step3)

	# Step 4: Explain the map
	var step4 = TutorialStep.new(
		"map_intro",
		"World Map",
		"This map shows all available airports. The larger the circle, the bigger the airport. Click and drag to pan, use mouse wheel to zoom.",
		TutorialStep.StepType.HIGHLIGHT_UI
	)
	step4.ui_element_path = "MarginContainer/VBoxContainer/MainArea/WorldMap"
	step4.highlight_message = "Your route network will appear here"
	tutorial_steps.append(step4)

	# Step 5: Hub concept introduction
	var step5 = TutorialStep.new(
		"hub_intro",
		"Choose Your Starting Hub",
		"Airlines operate from HUBs - airports where you have operational rights. All routes must originate from one of your hubs. Your first hub is FREE! Choose wisely - major airports like LAX, LHR, or JFK offer more connections.",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step5)

	# Step 6: Wait for hub selection
	var step6 = TutorialStep.new(
		"select_hub",
		"Select Your Hub",
		"Click on any airport on the map to establish your first hub. Larger airports (bigger circles) are major hubs with more passenger demand. You can purchase additional hubs later for a fee.",
		TutorialStep.StepType.WAIT_FOR_ACTION
	)
	step6.required_action = "select_hub"
	tutorial_steps.append(step6)

	# Step 7: Introduce management tabs
	var step7 = TutorialStep.new(
		"tabs_intro",
		"Management Tabs",
		"Use these tabs to manage Routes, Fleet, Finances, and view Market competition. Let's explore the Fleet tab.",
		TutorialStep.StepType.HIGHLIGHT_UI
	)
	step7.ui_element_path = "MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs"
	step7.highlight_message = "All airline management happens here"
	tutorial_steps.append(step7)

	# Step 8: Market analysis introduction
	var step8 = TutorialStep.new(
		"market_analysis_intro",
		"Finding Profitable Routes",
		"The key to success is finding routes with high demand and low competition. The game analyzes every route and shows you opportunities.",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step8)

	# Step 9: Explain demand factors
	var step9 = TutorialStep.new(
		"demand_factors",
		"What Creates Demand?",
		"Passenger demand depends on:\n• City populations (bigger = more travelers)\n• Income levels (wealthier = more flights)\n• Distance (medium routes 500-1500km are best)\n• Competition (fewer airlines = more opportunity)",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step9)

	# Step 10: Aircraft purchase intro
	var step10 = TutorialStep.new(
		"aircraft_intro",
		"Building Your Fleet",
		"You need aircraft to operate routes. Each aircraft model has different capacity, range, and operating costs. Let's buy your first plane!",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step10)

	# Step 11: Highlight Fleet tab
	var step11 = TutorialStep.new(
		"fleet_tab_highlight",
		"Fleet Management",
		"Open the Fleet tab to see available aircraft models. Choose wisely based on your route strategy!",
		TutorialStep.StepType.HIGHLIGHT_UI
	)
	step11.ui_element_path = "MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Fleet"
	step11.highlight_message = "Browse and purchase aircraft here"
	tutorial_steps.append(step11)

	# Step 12: Explain aircraft configuration
	var step12 = TutorialStep.new(
		"aircraft_config_intro",
		"Aircraft Configuration",
		"Unlike real life, you can customize seat layouts!\n• All Economy = Maximum capacity, lower revenue/seat\n• Mixed Config = Balance of economy & business\n• Premium Config = Fewer seats, higher revenue/seat\n\nLong-haul routes benefit from more business/first class seats.",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step12)

	# Step 13: Wait for aircraft purchase
	var step13 = TutorialStep.new(
		"wait_aircraft_purchase",
		"Purchase Your First Aircraft",
		"Select an aircraft model and click Purchase. For your first route, we recommend a Boeing 737-800 or Airbus A320 (good range and capacity).",
		TutorialStep.StepType.WAIT_FOR_ACTION
	)
	step13.required_action = "purchase_aircraft"
	step13.action_hint = "Click an aircraft in the list, then click Purchase"
	tutorial_steps.append(step13)

	# Step 14: Congratulate on purchase
	var step14 = TutorialStep.new(
		"aircraft_purchased",
		"Aircraft Acquired!",
		"Great! Your aircraft is now in your fleet. Next, let's create a profitable route to put it to work.",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step14)

	# Step 15: Route creation intro
	var step15 = TutorialStep.new(
		"route_intro",
		"Creating Routes",
		"Routes connect two airports with scheduled flights. To succeed, you need:\n• Sufficient demand (passengers wanting to fly)\n• Low competition (few other airlines)\n• Proper pricing (not too high, not too low)\n• Aircraft with enough range",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step15)

	# Step 16: Explain route opportunities
	var step16 = TutorialStep.new(
		"route_opportunities",
		"Finding Opportunities",
		"The console can show you the best routes! Type:\nshow_route_opportunities(airport)\n\nThis analyzes all routes from an airport and scores them 0-100 based on profitability. Look for scores above 70!",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step16)

	# Step 17: Wait for route creation
	var step17 = TutorialStep.new(
		"wait_route_creation",
		"Create Your First Route",
		"Click two airports on the map to create a route. The game will calculate distance and suggest pricing. Assign your aircraft to the route!",
		TutorialStep.StepType.WAIT_FOR_ACTION
	)
	step17.required_action = "create_route"
	step17.action_hint = "Click source airport, then destination airport"
	tutorial_steps.append(step17)

	# Step 18: Route created!
	var step18 = TutorialStep.new(
		"route_created",
		"Route Established!",
		"Excellent! Your first route is active. Now let's see how it performs by running the simulation.",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step18)

	# Step 19: Simulation intro
	var step19 = TutorialStep.new(
		"simulation_intro",
		"Weekly Simulation",
		"The game simulates one week at a time. During simulation:\n• Passengers choose airlines based on price, quality, reputation\n• You earn revenue from ticket sales\n• You pay for fuel, crew, maintenance, airport fees\n• Aircraft condition degrades slightly\n• Loans are paid automatically",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step19)

	# Step 20: Highlight play button
	var step20 = TutorialStep.new(
		"play_button_highlight",
		"Run Simulation",
		"Click the Play button to start continuous simulation, or Step to advance one week at a time. Try Step first to see detailed results!",
		TutorialStep.StepType.HIGHLIGHT_UI
	)
	step20.ui_element_path = "MarginContainer/VBoxContainer/TopPanel/HBoxContainer/StepButton"
	step20.highlight_message = "Click to simulate one week"
	tutorial_steps.append(step20)

	# Step 21: Wait for simulation
	var step21 = TutorialStep.new(
		"wait_simulation",
		"Run Your First Week",
		"Click the Step button to simulate one week and see your results!",
		TutorialStep.StepType.WAIT_FOR_ACTION
	)
	step21.required_action = "run_simulation"
	step21.action_hint = "Click the Step button at the top"
	tutorial_steps.append(step21)

	# Step 22: Analyze results
	var step22 = TutorialStep.new(
		"results_analysis",
		"Understanding Results",
		"Check the console for detailed results:\n• Passengers transported\n• Revenue earned\n• Costs incurred\n• Weekly profit\n\nLook at your route in the Routes tab to see performance metrics!",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step22)

	# Step 23: Optimization intro
	var step23 = TutorialStep.new(
		"optimization_intro",
		"Optimizing Performance",
		"Now you can improve profitability:\n• Adjust pricing if load factor is too low/high\n• Increase frequency if route is consistently full\n• Add more aircraft to expand capacity\n• Monitor competition and react to market changes",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step23)

	# Step 24: Competition intro
	var step24 = TutorialStep.new(
		"competition_intro",
		"AI Competition",
		"You're not alone! 4 AI airlines compete with you:\n• Global Wings (Aggressive - expands fast)\n• Pacific Air (Balanced)\n• Euro Express (Conservative - builds slowly)\n• TransContinental (Balanced)\n\nThey'll create routes, buy aircraft, and compete for passengers!",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step24)

	# Step 25: Check Market tab
	var step25 = TutorialStep.new(
		"market_tab_intro",
		"Market Intelligence",
		"Use the Market tab to spy on competitors:\n• See their fleet sizes\n• Check their routes\n• Compare your performance\n• Find underserved markets",
		TutorialStep.StepType.HIGHLIGHT_UI
	)
	step25.ui_element_path = "MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Market"
	step25.highlight_message = "Monitor your competition here"
	tutorial_steps.append(step25)

	# Step 26: Finances tab
	var step26 = TutorialStep.new(
		"finances_intro",
		"Managing Finances",
		"The Finances tab shows:\n• Weekly revenue and expenses\n• Active loans and payments\n• Credit limit based on your performance\n\nYou can take loans to expand faster, but be careful - interest adds up!",
		TutorialStep.StepType.HIGHLIGHT_UI
	)
	step26.ui_element_path = "MarginContainer/VBoxContainer/MainArea/RightPanels/ManagementTabs/Finances"
	step26.highlight_message = "Track money and take loans here"
	tutorial_steps.append(step26)

	# Step 27: Growth strategies
	var step27 = TutorialStep.new(
		"growth_strategies",
		"Strategies for Success",
		"Budget Airline: All-economy configs, low prices, high frequency\nPremium Carrier: Business-heavy configs, long-haul, high prices\nMarket Gap: Find routes with high opportunity scores (70+)\nCompetitive: Undercut rival pricing to steal market share\n\nChoose your strategy and build your empire!",
		TutorialStep.StepType.MESSAGE
	)
	tutorial_steps.append(step27)

	# Step 28: Tutorial complete + reward!
	var step28 = TutorialStep.new(
		"tutorial_complete",
		"Tutorial Complete!",
		"Congratulations! You've learned the essentials of airline management. Here's a bonus to help you grow: +$50M!",
		TutorialStep.StepType.REWARD
	)
	step28.reward_money = 50000000.0
	step28.reward_message = "Bonus: $50M added to your balance!"
	tutorial_steps.append(step28)

	print("Tutorial created: %d steps" % tutorial_steps.size())

func start_tutorial() -> void:
	"""Begin the tutorial sequence"""
	if tutorial_completed_flag:
		print("Tutorial already completed")
		return

	is_tutorial_active = true
	current_step_index = 0
	print("\n=== TUTORIAL STARTED ===")
	advance_to_next_step()

func advance_to_next_step() -> void:
	"""Move to the next tutorial step"""
	if current_step_index >= tutorial_steps.size():
		complete_tutorial()
		return

	var step: TutorialStep = tutorial_steps[current_step_index]
	print("\n--- Tutorial Step %d/%d: %s ---" % [current_step_index + 1, tutorial_steps.size(), step.title])
	print(step.message)

	tutorial_step_started.emit(step)

	# Handle different step types
	match step.step_type:
		TutorialStep.StepType.MESSAGE:
			# Auto-advance after message
			print("(Press Enter or click Continue to proceed)")
			# In real implementation, would wait for user input

		TutorialStep.StepType.HIGHLIGHT_UI:
			if step.ui_element_path != "":
				highlight_ui_element.emit(step.ui_element_path, step.highlight_message)
			print("(Click to continue)")

		TutorialStep.StepType.WAIT_FOR_ACTION:
			print("ACTION REQUIRED: %s" % step.action_hint)
			# Wait for action signal

		TutorialStep.StepType.REWARD:
			apply_reward(step)
			# Auto-advance after reward

func complete_current_step() -> void:
	"""Mark current step as complete and advance"""
	if current_step_index < tutorial_steps.size():
		var step: TutorialStep = tutorial_steps[current_step_index]
		step.mark_completed()
		tutorial_step_completed.emit(step)

		clear_ui_highlights.emit()

		current_step_index += 1
		advance_to_next_step()

func on_action_performed(action: String) -> void:
	"""Called when player performs an action"""
	if not is_tutorial_active:
		return

	if current_step_index >= tutorial_steps.size():
		return

	var step: TutorialStep = tutorial_steps[current_step_index]

	if step.step_type == TutorialStep.StepType.WAIT_FOR_ACTION:
		if step.required_action == action:
			print("✓ Action completed: %s" % action)
			complete_current_step()

func apply_reward(step: TutorialStep) -> void:
	"""Apply tutorial rewards"""
	if step.reward_money > 0 and GameData.player_airline:
		GameData.player_airline.add_balance(step.reward_money)
		print("💰 REWARD: $%.0f added to your balance!" % step.reward_money)

	if step.reward_message != "":
		print("🎁 %s" % step.reward_message)

	# Auto-advance after showing reward
	complete_current_step()

func complete_tutorial() -> void:
	"""Tutorial finished"""
	is_tutorial_active = false
	tutorial_completed_flag = true

	print("\n" + "=".repeat(50))
	print("🎓 TUTORIAL COMPLETE!")
	print("=".repeat(50))
	print("\nYou're now ready to build your airline empire!")
	print("Good luck, CEO!\n")

	tutorial_completed.emit()

func skip_tutorial() -> void:
	"""Allow player to skip tutorial - grants same rewards as completing it"""
	is_tutorial_active = false
	tutorial_completed_flag = true

	# Grant tutorial completion reward (same as completing it)
	if GameData.player_airline:
		GameData.player_airline.add_balance(50000000.0)  # $50M tutorial bonus
		print("Tutorial skipped - $50M bonus granted")

	clear_ui_highlights.emit()
	tutorial_completed.emit()

func is_active() -> bool:
	return is_tutorial_active

func get_current_step() -> TutorialStep:
	if current_step_index < tutorial_steps.size():
		return tutorial_steps[current_step_index]
	return null
