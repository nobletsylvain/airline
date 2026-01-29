extends CanvasLayer
class_name FeedbackManager

## Feedback Manager (H.3-H.5)
## Handles daily notifications, weekly summaries, and price change alerts
## Provides clear cause-effect feedback to the player

# Toast notification settings
const TOAST_DURATION: float = 4.0
const TOAST_FADE_TIME: float = 0.5

# UI References
var toast_container: VBoxContainer
var weekly_popup: Panel
var active_toasts: Array[Control] = []

# Track daily stats for summary
var daily_revenue: float = 0.0
var daily_expenses: float = 0.0
var routes_simulated_today: int = 0

var simulation_engine: Node = null

func _ready() -> void:
	# Set layer to be on top
	layer = 100
	
	# Create UI containers
	_create_toast_container()
	_create_weekly_popup()
	
	# Connect to simulation signals (deferred to allow set_simulation_engine to be called)
	call_deferred("_connect_signals")


func set_simulation_engine(engine: Node) -> void:
	"""Set the simulation engine reference"""
	simulation_engine = engine
	_connect_signals()


func _connect_signals() -> void:
	"""Connect to SimulationEngine signals"""
	# Try to find if not set
	if not simulation_engine:
		simulation_engine = _find_simulation_engine()
	
	if simulation_engine:
		# Avoid duplicate connections
		if not simulation_engine.day_completed.is_connected(_on_day_completed):
			simulation_engine.day_completed.connect(_on_day_completed)
			simulation_engine.week_completed.connect(_on_week_completed)
			simulation_engine.pending_prices_applied.connect(_on_pending_prices_applied)
			simulation_engine.route_simulated.connect(_on_route_simulated)
			print("FeedbackManager: Connected to SimulationEngine signals")
	else:
		push_warning("FeedbackManager: Could not find SimulationEngine")
	
	# Connect to GameData signals for competitor events
	if not GameData.competitor_entered_market.is_connected(_on_competitor_entered_market):
		GameData.competitor_entered_market.connect(_on_competitor_entered_market)


func _find_simulation_engine() -> Node:
	"""Find the SimulationEngine node in the scene tree"""
	# Try common locations
	var paths = [
		"/root/Main/SimulationEngine",
		"/root/GameScene/SimulationEngine",
		"/root/SimulationEngine"
	]
	
	for path in paths:
		var node = get_node_or_null(path)
		if node:
			return node
	
	# Search recursively from root
	return _find_node_by_class(get_tree().root, "SimulationEngine")


func _find_node_by_class(node: Node, class_name_to_find: String) -> Node:
	"""Recursively find a node by its script class name"""
	if node.get_script() and node.get_script().get_global_name() == class_name_to_find:
		return node
	
	for child in node.get_children():
		var result = _find_node_by_class(child, class_name_to_find)
		if result:
			return result
	
	return null


# =============================================================================
# TOAST CONTAINER (H.3)
# =============================================================================

func _create_toast_container() -> void:
	"""Create container for toast notifications (top-right corner)"""
	toast_container = VBoxContainer.new()
	toast_container.name = "ToastContainer"
	toast_container.add_theme_constant_override("separation", 8)
	
	# Position at top-right
	toast_container.anchor_left = 1.0
	toast_container.anchor_right = 1.0
	toast_container.anchor_top = 0.0
	toast_container.anchor_bottom = 0.0
	toast_container.offset_left = -320
	toast_container.offset_right = -20
	toast_container.offset_top = 80
	toast_container.offset_bottom = 400
	
	toast_container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	toast_container.grow_vertical = Control.GROW_DIRECTION_END
	
	add_child(toast_container)


func show_toast(title: String, message: String, color: Color = Color.WHITE, duration: float = TOAST_DURATION, play_sound: bool = true) -> void:
	"""Show a non-blocking toast notification"""
	var toast = _create_toast(title, message, color)
	toast_container.add_child(toast)
	active_toasts.append(toast)
	
	# Play alert sound for notifications
	if play_sound and UISoundManager:
		UISoundManager.play_alert()
	
	# Animate in
	toast.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(toast, "modulate:a", 1.0, 0.2)
	
	# Auto-dismiss after duration
	await get_tree().create_timer(duration).timeout
	
	if is_instance_valid(toast):
		var fade_tween = create_tween()
		fade_tween.tween_property(toast, "modulate:a", 0.0, TOAST_FADE_TIME)
		await fade_tween.finished
		
		if is_instance_valid(toast):
			active_toasts.erase(toast)
			toast.queue_free()


func _create_toast(title: String, message: String, accent_color: Color) -> PanelContainer:
	"""Create a toast notification panel"""
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 0)
	
	# Style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.15, 0.95)
	style.border_color = accent_color
	style.set_border_width_all(2)
	style.border_width_left = 4
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)
	
	# Title
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", accent_color)
	vbox.add_child(title_label)
	
	# Message
	var msg_label = Label.new()
	msg_label.text = message
	msg_label.add_theme_font_size_override("font_size", 12)
	msg_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(msg_label)
	
	return panel


# =============================================================================
# WEEKLY POPUP (H.4)
# =============================================================================

func _create_weekly_popup() -> void:
	"""Create the weekly summary popup (modal)"""
	weekly_popup = Panel.new()
	weekly_popup.name = "WeeklySummaryPopup"
	weekly_popup.visible = false
	
	# Center on screen
	weekly_popup.anchor_left = 0.5
	weekly_popup.anchor_right = 0.5
	weekly_popup.anchor_top = 0.5
	weekly_popup.anchor_bottom = 0.5
	weekly_popup.offset_left = -250
	weekly_popup.offset_right = 250
	weekly_popup.offset_top = -200
	weekly_popup.offset_bottom = 200
	
	# Style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.12, 0.98)
	style.border_color = Color(0.3, 0.6, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(20)
	weekly_popup.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.name = "Content"
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.add_theme_constant_override("separation", 12)
	weekly_popup.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	vbox.add_child(title)
	
	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Stats content
	var stats = RichTextLabel.new()
	stats.name = "Stats"
	stats.bbcode_enabled = true
	stats.fit_content = true
	stats.custom_minimum_size = Vector2(0, 200)
	stats.add_theme_font_size_override("normal_font_size", 14)
	vbox.add_child(stats)
	
	# Dismiss button
	var button = Button.new()
	button.name = "DismissButton"
	button.text = "Continue"
	button.custom_minimum_size = Vector2(120, 40)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_on_weekly_popup_dismissed)
	vbox.add_child(button)
	
	add_child(weekly_popup)


func show_weekly_summary(week_number: int) -> void:
	"""Show the weekly summary popup (H.4)"""
	if not GameData.player_airline:
		return
	
	var airline = GameData.player_airline
	
	# Calculate stats
	var total_revenue: float = airline.weekly_revenue
	var total_expenses: float = airline.weekly_expenses
	var profit: float = total_revenue - total_expenses
	var profit_color: String = "#66FF66" if profit >= 0 else "#FF6666"
	var profit_sign: String = "+" if profit >= 0 else ""
	
	# Find best/worst routes
	var best_route: Route = null
	var worst_route: Route = null
	var total_load_factor: float = 0.0
	var route_count: int = 0
	
	for route in airline.routes:
		var capacity: int = route.get_total_capacity() * route.frequency
		if capacity > 0:
			var lf: float = float(route.passengers_transported) / float(capacity) * 100.0
			total_load_factor += lf
			route_count += 1
			
			if best_route == null or route.weekly_profit > best_route.weekly_profit:
				best_route = route
			if worst_route == null or route.weekly_profit < worst_route.weekly_profit:
				worst_route = route
	
	var avg_load_factor: float = total_load_factor / route_count if route_count > 0 else 0.0
	
	# Build summary text
	var stats_text: String = "[b]Financial Summary[/b]\n\n"
	stats_text += "Revenue: [b]€%s[/b]\n" % _format_money(total_revenue)
	stats_text += "Expenses: [b]€%s[/b]\n" % _format_money(total_expenses)
	stats_text += "Profit: [color=%s][b]%s€%s[/b][/color]\n\n" % [profit_color, profit_sign, _format_money(abs(profit))]
	
	stats_text += "[b]Route Performance[/b]\n\n"
	stats_text += "Active Routes: [b]%d[/b]\n" % route_count
	stats_text += "Avg Load Factor: [b]%.0f%%[/b]\n" % avg_load_factor
	
	if best_route:
		var best_profit_color: String = "#66FF66" if best_route.weekly_profit >= 0 else "#FF6666"
		stats_text += "\nBest: [b]%s[/b] [color=%s](€%s)[/color]\n" % [
			best_route.get_display_name(),
			best_profit_color,
			_format_money(best_route.weekly_profit)
		]
	
	if worst_route and worst_route != best_route:
		var worst_profit_color: String = "#66FF66" if worst_route.weekly_profit >= 0 else "#FF6666"
		stats_text += "Worst: [b]%s[/b] [color=%s](€%s)[/color]" % [
			worst_route.get_display_name(),
			worst_profit_color,
			_format_money(worst_route.weekly_profit)
		]
	
	# Update popup
	var title: Label = weekly_popup.get_node("Content/Title")
	var stats: RichTextLabel = weekly_popup.get_node("Content/Stats")
	
	title.text = "📊 Week %d Summary" % week_number
	stats.text = stats_text
	
	weekly_popup.visible = true
	
	# Play money tally sound based on revenue
	if UISoundManager and total_revenue > 0:
		UISoundManager.play_money_tally(int(total_revenue))
	
	# Play success sound if profitable week
	if profit > 0 and UISoundManager:
		# Delay success sound to play after money tally
		await get_tree().create_timer(0.5).timeout
		UISoundManager.play_success()


func _on_weekly_popup_dismissed() -> void:
	"""Handle weekly popup dismiss"""
	if UISoundManager:
		UISoundManager.play_click()
	weekly_popup.visible = false


# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_route_simulated(route: Route, passengers: int, revenue: float) -> void:
	"""Track route simulation for daily summary"""
	daily_revenue += revenue
	routes_simulated_today += 1


func _on_day_completed(day: int) -> void:
	"""Show daily summary notification (H.3)"""
	var day_names: Array[String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	var day_name: String = day_names[day] if day < day_names.size() else "Day %d" % day
	
	# Only show if there's activity
	if routes_simulated_today == 0 and daily_revenue == 0:
		return
	
	var message: String = ""
	if daily_revenue > 0:
		message = "Revenue: €%s" % _format_money(daily_revenue)
	
	# Show toast
	show_toast(
		"📅 %s" % day_name,
		message if message != "" else "Simulation running...",
		Color(0.4, 0.7, 1.0),
		3.0
	)
	
	# Reset daily tracking
	daily_revenue = 0.0
	daily_expenses = 0.0
	routes_simulated_today = 0


func _on_week_completed(week: int) -> void:
	"""Show weekly summary (H.4)"""
	# Small delay to ensure all routes are simulated
	await get_tree().create_timer(0.1).timeout
	show_weekly_summary(week)


func _on_pending_prices_applied(routes_changed: int) -> void:
	"""Show price change notification (H.5)"""
	if routes_changed == 0:
		return
	
	# Get details about which routes changed
	var changes: Array[String] = []
	
	if GameData.player_airline:
		for route in GameData.player_airline.routes:
			# Check if this route had a recent price change
			var elasticity: float = route.get_meta("elasticity_multiplier", 1.0)
			var deviation: float = route.get_meta("price_deviation_pct", 0.0)
			
			if abs(deviation) > 5:
				var effect: String = ""
				if deviation > 0:
					effect = "↓ demand (%.0f%% less)" % ((1.0 - elasticity) * 100)
				else:
					effect = "↑ demand (%.0f%% more)" % ((elasticity - 1.0) * 100)
				
				changes.append("%s: €%.0f → %s" % [
					route.get_display_name(),
					route.price_economy,
					effect
				])
	
	# Build notification message
	var message: String
	if changes.size() > 0:
		message = changes[0]
		if changes.size() > 1:
			message += "\n+%d more route(s)" % (changes.size() - 1)
	else:
		message = "%d route(s) updated" % routes_changed
	
	# Show toast with distinctive color
	show_toast(
		"💰 Price Changes Applied",
		message,
		Color(1.0, 0.8, 0.2),  # Yellow/gold
		5.0  # Longer duration for price changes
	)


func _on_competitor_entered_market(airline: Airline) -> void:
	"""Show notification when AI competitor becomes active after grace period"""
	if not airline:
		return
	
	var message: String = "%s has entered the market!\nExpect competition on your routes." % airline.name
	
	# Show prominent toast with warning color
	show_toast(
		"⚠️ New Competitor",
		message,
		Color(1.0, 0.5, 0.2),  # Orange warning color
		8.0  # Longer duration for important event
	)


# =============================================================================
# UTILITY
# =============================================================================

func _format_money(amount: float) -> String:
	"""Format money with thousands separators"""
	var s: String = str(int(abs(amount)))
	var result: String = ""
	var count: int = 0
	
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i > 0:
			result = "," + result
	
	return result
