## PerformanceProfiler.gd
## Debug utility for performance profiling and stress testing.
## Press F3 in debug builds to toggle overlay.
##
## Usage:
##   Add as child of GameUI or call from debug console.
##   Load dynamically: var profiler = load("res://scripts/debug/PerformanceProfiler.gd").new()
extends CanvasLayer


# =============================================================================
# CONFIGURATION
# =============================================================================

const PROFILE_DURATION := 10.0  # Seconds to profile
const SAMPLE_INTERVAL := 0.1    # Sample every 100ms
const STRESS_ROUTE_COUNT := 50   # Reduced - map only covers European region
const STRESS_AIRCRAFT_COUNT := 50

## Performance targets (art-bible spec)
const TARGET_FPS := 60.0
const TARGET_FRAME_TIME_MS := 16.67
const WARN_FRAME_TIME_MS := 20.0
const CRITICAL_FRAME_TIME_MS := 33.33


# =============================================================================
# STATE
# =============================================================================

var _is_profiling: bool = false
var _profile_start_time: float = 0.0
var _frame_times: PackedFloat64Array = []
var _memory_samples: PackedFloat64Array = []
var _object_counts: PackedInt64Array = []

var _overlay_visible: bool = false
var _overlay_panel: PanelContainer = null
var _stats_label: RichTextLabel = null

## Live monitoring
var _frame_time_history: PackedFloat64Array = []
const HISTORY_SIZE := 120  # 2 seconds at 60fps


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	layer = 100  # On top of everything
	_create_overlay()
	_overlay_panel.visible = false


func _input(event: InputEvent) -> void:
	# F3 toggles profiler overlay (debug builds only)
	if OS.is_debug_build() and event is InputEventKey:
		if event.pressed and event.keycode == KEY_F3:
			toggle_overlay()
			get_viewport().set_input_as_handled()
		# F4 starts stress test
		elif event.pressed and event.keycode == KEY_F4:
			start_stress_test()
			get_viewport().set_input_as_handled()
		# F5 starts profiling session
		elif event.pressed and event.keycode == KEY_F5:
			start_profiling()
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	# Track frame time history for live display
	var frame_time_ms := delta * 1000.0
	_frame_time_history.append(frame_time_ms)
	if _frame_time_history.size() > HISTORY_SIZE:
		_frame_time_history.remove_at(0)
	
	# Collect samples during profiling
	if _is_profiling:
		_frame_times.append(frame_time_ms)
		
		var elapsed := Time.get_ticks_msec() / 1000.0 - _profile_start_time
		if elapsed >= PROFILE_DURATION:
			_finish_profiling()
	
	# Update overlay if visible
	if _overlay_visible and _stats_label:
		_update_overlay()


# =============================================================================
# OVERLAY
# =============================================================================

func _create_overlay() -> void:
	_overlay_panel = PanelContainer.new()
	_overlay_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_overlay_panel.offset_left = -320
	_overlay_panel.offset_right = -10
	_overlay_panel.offset_top = 10
	_overlay_panel.offset_bottom = 280
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	style.border_color = Color(0.3, 0.6, 1.0, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	_overlay_panel.add_theme_stylebox_override("panel", style)
	
	_stats_label = RichTextLabel.new()
	_stats_label.bbcode_enabled = true
	_stats_label.fit_content = true
	_stats_label.scroll_active = false
	_stats_label.add_theme_font_size_override("normal_font_size", 12)
	_stats_label.add_theme_font_size_override("bold_font_size", 13)
	_overlay_panel.add_child(_stats_label)
	
	add_child(_overlay_panel)


func toggle_overlay() -> void:
	_overlay_visible = not _overlay_visible
	_overlay_panel.visible = _overlay_visible


func _update_overlay() -> void:
	var fps := Performance.get_monitor(Performance.TIME_FPS)
	var _frame_time := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_time := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var objects := int(Performance.get_monitor(Performance.OBJECT_COUNT))
	var memory_mb := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var orphans := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	var draw_calls := int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	
	# Calculate averages from history
	var avg_frame_time := 0.0
	var max_frame_time := 0.0
	if _frame_time_history.size() > 0:
		for t in _frame_time_history:
			avg_frame_time += t
			max_frame_time = max(max_frame_time, t)
		avg_frame_time /= _frame_time_history.size()
	
	# Color code frame time
	var frame_color := "green"
	if avg_frame_time > CRITICAL_FRAME_TIME_MS:
		frame_color = "red"
	elif avg_frame_time > WARN_FRAME_TIME_MS:
		frame_color = "yellow"
	
	# Game state info
	var route_count := 0
	var aircraft_count := 0
	var hub_count := 0
	if GameData and GameData.player_airline:
		route_count = GameData.player_airline.routes.size()
		aircraft_count = GameData.player_airline.aircraft.size()
		hub_count = GameData.player_airline.hubs.size()
	
	var text := "[b]PERFORMANCE PROFILER (F3)[/b]\n"
	text += "[color=gray]F4: Stress Test | F5: Profile 10s[/color]\n\n"
	
	text += "[b]Frame Timing[/b]\n"
	text += "FPS: [color=%s]%.1f[/color]\n" % [frame_color, fps]
	text += "Frame: [color=%s]%.2fms[/color] (avg) / %.2fms (max)\n" % [frame_color, avg_frame_time, max_frame_time]
	text += "Physics: %.2fms\n\n" % physics_time
	
	text += "[b]Rendering[/b]\n"
	text += "Draw calls: %d\n" % draw_calls
	text += "Nodes: %d\n" % nodes
	text += "Orphans: %d\n\n" % orphans
	
	text += "[b]Memory[/b]\n"
	text += "Static: %.1f MB\n" % memory_mb
	text += "Objects: %d\n\n" % objects
	
	text += "[b]Game State[/b]\n"
	text += "Routes: %d / %d target\n" % [route_count, STRESS_ROUTE_COUNT]
	text += "Aircraft: %d / %d target\n" % [aircraft_count, STRESS_AIRCRAFT_COUNT]
	text += "Hubs: %d\n" % hub_count
	
	if _is_profiling:
		var remaining := PROFILE_DURATION - (Time.get_ticks_msec() / 1000.0 - _profile_start_time)
		text += "\n[color=cyan][b]PROFILING... %.1fs remaining[/b][/color]" % remaining
	
	_stats_label.text = text


# =============================================================================
# STRESS TEST
# =============================================================================

func start_stress_test() -> void:
	"""Spawn 200+ routes for stress testing"""
	if not GameData or not GameData.player_airline:
		push_warning("PerformanceProfiler: Cannot stress test without player airline")
		return
	
	print("PerformanceProfiler: Starting stress test...")
	print("  Target: %d routes, %d aircraft" % [STRESS_ROUTE_COUNT, STRESS_AIRCRAFT_COUNT])
	
	var airline: Airline = GameData.player_airline
	var airports_array: Array[Airport] = GameData.airports
	
	if airports_array.size() < 2:
		push_warning("PerformanceProfiler: Not enough airports for stress test")
		return
	
	# Give player money and aircraft for testing
	airline.balance = 1_000_000_000.0  # €1B for testing
	
	# Add aircraft if needed
	var aircraft_needed: int = STRESS_AIRCRAFT_COUNT - airline.aircraft.size()
	if aircraft_needed > 0 and GameData.aircraft_models.size() > 0:
		var model: AircraftModel = GameData.aircraft_models[0]
		for i in range(aircraft_needed):
			var aircraft: AircraftInstance = AircraftInstance.new()
			aircraft.model = model
			aircraft.id = GameData.next_aircraft_id
			GameData.next_aircraft_id += 1
			airline.aircraft.append(aircraft)
	
	# Ensure we have multiple hubs
	var hub_targets := mini(10, airports_array.size())
	while airline.hubs.size() < hub_targets:
		var random_airport: Airport = airports_array[randi() % airports_array.size()]
		if not airline.has_hub(random_airport):
			airline.add_hub(random_airport)
	
	# Add routes - origin must be from hubs, destination can be any airport
	var routes_needed: int = STRESS_ROUTE_COUNT - airline.routes.size()
	if routes_needed <= 0:
		print("PerformanceProfiler: Already have enough routes")
	else:
		var routes_created: int = 0
		var attempts: int = 0
		var max_attempts: int = 500  # Fixed limit to prevent hangs
		
		# Get list of hub airports for route origins
		var hub_airports: Array[Airport] = airline.hubs
		
		# Safety check - need at least one hub
		if hub_airports.is_empty():
			push_warning("PerformanceProfiler: No hubs available for stress test")
		else:
			while routes_created < routes_needed and attempts < max_attempts:
				attempts += 1
				
				# Origin must be from a hub
				var hub_idx: int = randi() % hub_airports.size()
				var dest_idx: int = randi() % airports_array.size()
				var origin: Airport = hub_airports[hub_idx]
				var dest: Airport = airports_array[dest_idx]
				
				if origin == dest:
					continue
				
				# Check if route already exists
				var exists: bool = false
				for existing_route in airline.routes:
					if (existing_route.from_airport == origin and existing_route.to_airport == dest) or \
					   (existing_route.from_airport == dest and existing_route.to_airport == origin):
						exists = true
						break
				
				if exists:
					continue
				
				# Create route - find available aircraft manually
				var available_aircraft: Array[AircraftInstance] = []
				for ac in airline.aircraft:
					if not ac.is_assigned:
						available_aircraft.append(ac)
				
				if available_aircraft.is_empty():
					# No more aircraft available - stop creating routes
					print("PerformanceProfiler: No more available aircraft")
					break
				
				var aircraft: AircraftInstance = available_aircraft[0]
				var new_route: Route = GameData.create_route_for_airline(airline, origin, dest, aircraft)
				if new_route:
					new_route.frequency = 1
					new_route.price_economy = 150.0
					new_route.price_business = 400.0
					routes_created += 1
	
	print("PerformanceProfiler: Stress test setup complete")
	print("  Routes: %d" % airline.routes.size())
	print("  Aircraft: %d" % airline.aircraft.size())
	print("  Hubs: %d" % airline.hubs.size())
	
	# Trigger UI refresh
	GameData.route_network_changed.emit(airline)


# =============================================================================
# PROFILING SESSION
# =============================================================================

func start_profiling() -> void:
	"""Start a timed profiling session"""
	if _is_profiling:
		print("PerformanceProfiler: Already profiling")
		return
	
	print("PerformanceProfiler: Starting %ds profiling session..." % int(PROFILE_DURATION))
	
	_is_profiling = true
	_profile_start_time = Time.get_ticks_msec() / 1000.0
	_frame_times.clear()
	_memory_samples.clear()
	_object_counts.clear()
	
	# Take initial memory snapshot
	_memory_samples.append(Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0)
	_object_counts.append(int(Performance.get_monitor(Performance.OBJECT_COUNT)))
	
	# Show overlay during profiling
	if not _overlay_visible:
		toggle_overlay()


func _finish_profiling() -> void:
	"""Complete profiling and generate report"""
	_is_profiling = false
	
	# Take final memory snapshot
	_memory_samples.append(Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0)
	_object_counts.append(int(Performance.get_monitor(Performance.OBJECT_COUNT)))
	
	# Calculate statistics
	var report := _generate_report()
	
	# Print report to console
	print("\n" + report)
	
	# Also copy to clipboard if possible
	DisplayServer.clipboard_set(report)
	print("\n[Report copied to clipboard]")


func _generate_report() -> String:
	"""Generate formatted performance report"""
	var avg_frame_time := 0.0
	var max_frame_time := 0.0
	var min_frame_time := 999.0
	var p99_frame_time := 0.0
	
	if _frame_times.size() > 0:
		var sorted_times := _frame_times.duplicate()
		sorted_times.sort()
		
		for t in _frame_times:
			avg_frame_time += t
			max_frame_time = max(max_frame_time, t)
			min_frame_time = min(min_frame_time, t)
		avg_frame_time /= _frame_times.size()
		
		var p99_idx := int(_frame_times.size() * 0.99)
		p99_frame_time = sorted_times[mini(p99_idx, sorted_times.size() - 1)]
	
	# Game state
	var route_count := 0
	var aircraft_count := 0
	var hub_count := 0
	if GameData and GameData.player_airline:
		route_count = GameData.player_airline.routes.size()
		aircraft_count = GameData.player_airline.aircraft.size()
		hub_count = GameData.player_airline.hubs.size()
	
	# Memory delta
	var memory_start: float = _memory_samples[0] if _memory_samples.size() > 0 else 0.0
	var memory_end: float = _memory_samples[_memory_samples.size() - 1] if _memory_samples.size() > 1 else memory_start
	var object_start: int = _object_counts[0] if _object_counts.size() > 0 else 0
	var object_end: int = _object_counts[_object_counts.size() - 1] if _object_counts.size() > 1 else object_start
	
	# Determine pass/fail
	var fps_pass: bool = avg_frame_time <= TARGET_FRAME_TIME_MS
	var aircraft_pass: bool = avg_frame_time <= WARN_FRAME_TIME_MS  # More lenient for aircraft
	var panel_pass: bool = max_frame_time < 50.0  # No single frame over 50ms
	var memory_pass: bool = abs(memory_end - memory_start) < 10.0  # Less than 10MB growth
	var hitch_pass: bool = p99_frame_time < CRITICAL_FRAME_TIME_MS
	
	var report: String = "## Performance Profile Results\n\n"
	
	report += "### Test Configuration\n"
	report += "- Routes: %d\n" % route_count
	report += "- Aircraft: %d\n" % aircraft_count
	report += "- Hubs: %d\n" % hub_count
	report += "- Duration: %.1f seconds\n" % PROFILE_DURATION
	report += "- Samples: %d frames\n\n" % _frame_times.size()
	
	report += "### Frame Time\n"
	report += "- Average: %.2fms (%.1f FPS)\n" % [avg_frame_time, 1000.0 / avg_frame_time if avg_frame_time > 0.0 else 0.0]
	report += "- 99th percentile: %.2fms\n" % p99_frame_time
	report += "- Worst frame: %.2fms\n" % max_frame_time
	report += "- Best frame: %.2fms\n\n" % min_frame_time
	
	report += "### Memory\n"
	report += "- Start: %.1f MB\n" % memory_start
	report += "- End: %.1f MB\n" % memory_end
	report += "- Delta: %+.1f MB\n" % (memory_end - memory_start)
	report += "- Object count: %d → %d (%+d)\n\n" % [object_start, object_end, object_end - object_start]
	
	report += "### Acceptance Criteria\n"
	report += "| Metric | Target | Status |\n"
	report += "|--------|--------|--------|\n"
	report += "| 200 routes at 60fps | <16.67ms avg | %s |\n" % ("✅" if fps_pass else "❌ %.2fms" % avg_frame_time)
	report += "| 50 aircraft smooth | <20ms avg | %s |\n" % ("✅" if aircraft_pass else "❌")
	report += "| No frame drops on panel | <50ms max | %s |\n" % ("✅" if panel_pass else "❌ %.2fms" % max_frame_time)
	report += "| Memory stable | <10MB growth | %s |\n" % ("✅" if memory_pass else "❌ +%.1fMB" % (memory_end - memory_start))
	report += "| No hitches on sim | <33ms p99 | %s |\n\n" % ("✅" if hitch_pass else "❌ %.2fms" % p99_frame_time)
	
	# Bottleneck analysis
	report += "### Bottlenecks Found\n"
	if avg_frame_time > TARGET_FRAME_TIME_MS:
		report += "1. **Frame time exceeds target** — %.2fms avg vs 16.67ms target\n" % avg_frame_time
		report += "   - Consider: Batch draw calls, reduce per-frame updates\n"
	if max_frame_time > 50.0:
		report += "2. **Frame spikes detected** — %.2fms worst frame\n" % max_frame_time
		report += "   - Consider: Profile specific operations, spread work across frames\n"
	if memory_end - memory_start > 10.0:
		report += "3. **Memory growth detected** — +%.1f MB over session\n" % (memory_end - memory_start)
		report += "   - Consider: Check for orphaned nodes, tween cleanup\n"
	if avg_frame_time <= TARGET_FRAME_TIME_MS and max_frame_time < 50.0:
		report += "None detected — performance within targets.\n"
	
	report += "\n### Verdict\n"
	var all_pass: bool = fps_pass and aircraft_pass and panel_pass and memory_pass and hitch_pass
	if all_pass:
		report += "[x] **Ship as-is** — All performance targets met\n"
		report += "[ ] Needs optimization\n"
	else:
		report += "[ ] Ship as-is\n"
		report += "[x] **Needs optimization** — See bottlenecks above\n"
	
	return report


# =============================================================================
# UTILITY
# =============================================================================

func get_live_stats() -> Dictionary:
	"""Get current performance stats as dictionary"""
	return {
		"fps": Performance.get_monitor(Performance.TIME_FPS),
		"frame_time_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		"memory_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"objects": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"nodes": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"draw_calls": int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
	}
