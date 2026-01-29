## AmbientAudioManager.gd
## Autoload singleton for ambient soundscapes.
## Crossfades between scenes, applies crisis filters per art-bible 4.2/4.3.
##
## Usage:
##   AmbientAudioManager.set_scene(AmbientAudioManager.Scene.MAP)
##   AmbientAudioManager.set_crisis_level(AmbientAudioManager.CrisisLevel.WARNING)
extends Node
class_name AmbientAudioManagerClass


# =============================================================================
# ENUMS
# =============================================================================

enum Scene {
	NONE,
	OFFICE_BOOTSTRAP,  # Fluorescent hum, distant aircraft
	OFFICE_NATIONAL,   # Rain, muffled airport
	OFFICE_EMPIRE,     # Subtle HVAC, distant city
	HANGAR,            # Echo, aircraft systems, distant activity
	MAP                # Subtle data processing hum
}

enum CrisisLevel {
	NORMAL,   # No filter
	WARNING,  # Slight low-pass
	CRISIS    # Aggressive low-pass + heartbeat undertone
}


# =============================================================================
# CONSTANTS
# =============================================================================

const CROSSFADE_DURATION := 1.0  # seconds
const AMBIENT_BUS_NAME := "Ambient"

## Volume levels for each scene (in dB) - raised for audibility
const SCENE_VOLUMES := {
	Scene.NONE: -80.0,
	Scene.OFFICE_BOOTSTRAP: -8.0,   # Raised from -18
	Scene.OFFICE_NATIONAL: -6.0,    # Raised from -16
	Scene.OFFICE_EMPIRE: -10.0,     # Raised from -20
	Scene.HANGAR: -4.0,             # Raised from -14
	Scene.MAP: -12.0,               # Raised from -22
}

## Crisis filter cutoff frequencies (Hz)
const CRISIS_CUTOFFS := {
	CrisisLevel.NORMAL: 20500.0,   # Full range (no filtering)
	CrisisLevel.WARNING: 8000.0,   # Slight muffling
	CrisisLevel.CRISIS: 3000.0,    # Aggressive muffling
}


# =============================================================================
# STATE
# =============================================================================

var _current_scene: Scene = Scene.NONE
var _current_crisis: CrisisLevel = CrisisLevel.NORMAL

## Audio players
var _ambient_player: AudioStreamPlayer = null
var _ambient_player_next: AudioStreamPlayer = null  # For crossfade
var _heartbeat_player: AudioStreamPlayer = null

## Audio bus effects
var _crisis_filter: AudioEffectLowPassFilter = null
var _ambient_bus_idx: int = -1

## Generated ambient streams
var _ambients: Dictionary = {}

## Crossfade state
var _is_crossfading: bool = false

## User settings
var _enabled: bool = false  # Off by default
var _volume: float = 0.7  # 0.0 to 1.0 (default 70%)


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_setup_audio_bus()
	_setup_players()
	_generate_placeholder_ambients()
	
	# Apply initial volume setting
	set_volume(_volume)
	
	# Connect to game state changes
	if GameData:
		GameData.week_simulated.connect(_on_week_simulated)
	
	# Debug output for audio diagnosis
	if OS.is_debug_build():
		print("[AmbientAudioManager] Initialized")
		print("  Ambient bus idx: ", _ambient_bus_idx)
		print("  Generated %d ambient streams" % _ambients.size())


func _process(_delta: float) -> void:
	# Update crisis level based on financial state
	_update_crisis_from_finances()


# =============================================================================
# PUBLIC API
# =============================================================================

func set_scene(scene: Scene) -> void:
	"""Crossfade to a new ambient scene"""
	if scene == _current_scene:
		return
	
	if OS.is_debug_build():
		print("[AmbientAudioManager] Scene change: %s -> %s" % [Scene.keys()[_current_scene], Scene.keys()[scene]])
	
	_current_scene = scene
	
	if not _enabled:
		if OS.is_debug_build():
			print("  (Ambient disabled, skipping crossfade)")
		return
	
	_crossfade_to(scene)


func set_crisis_level(level: CrisisLevel) -> void:
	"""Apply crisis audio filter"""
	if level == _current_crisis:
		return
	
	_apply_crisis_filter(level)
	_current_crisis = level


func get_current_scene() -> Scene:
	return _current_scene


func get_current_crisis() -> CrisisLevel:
	return _current_crisis


func update_office_ambient() -> void:
	"""Update office ambient based on airline stage"""
	if not GameData or not GameData.player_airline:
		return
	
	var stage = _get_airline_stage()
	match stage:
		"bootstrap":
			set_scene(Scene.OFFICE_BOOTSTRAP)
		"national":
			set_scene(Scene.OFFICE_NATIONAL)
		"empire":
			set_scene(Scene.OFFICE_EMPIRE)


func set_enabled(enabled: bool) -> void:
	"""Enable or disable ambient audio"""
	_enabled = enabled
	if _ambient_player:
		if enabled and _current_scene != Scene.NONE:
			_ambient_player.play()
		else:
			_ambient_player.stop()
	if _heartbeat_player and not enabled:
		_heartbeat_player.stop()


func is_enabled() -> bool:
	return _enabled


func set_volume(volume: float) -> void:
	"""Set ambient volume (0.0 to 1.0)"""
	_volume = clampf(volume, 0.0, 1.0)
	if _ambient_bus_idx >= 0:
		AudioServer.set_bus_volume_db(_ambient_bus_idx, linear_to_db(_volume))


func get_volume() -> float:
	return _volume


# =============================================================================
# AUDIO BUS SETUP
# =============================================================================

func _setup_audio_bus() -> void:
	"""Create Ambient audio bus with crisis filter"""
	_ambient_bus_idx = AudioServer.get_bus_index(AMBIENT_BUS_NAME)
	
	if _ambient_bus_idx == -1:
		# Create new bus
		_ambient_bus_idx = AudioServer.bus_count
		AudioServer.add_bus(_ambient_bus_idx)
		AudioServer.set_bus_name(_ambient_bus_idx, AMBIENT_BUS_NAME)
		AudioServer.set_bus_send(_ambient_bus_idx, "Master")
	
	# Add low-pass filter for crisis states
	_crisis_filter = AudioEffectLowPassFilter.new()
	_crisis_filter.cutoff_hz = CRISIS_CUTOFFS[CrisisLevel.NORMAL]
	_crisis_filter.resonance = 0.5
	AudioServer.add_bus_effect(_ambient_bus_idx, _crisis_filter)


func _setup_players() -> void:
	"""Create audio stream players"""
	# Main ambient player
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = AMBIENT_BUS_NAME
	_ambient_player.volume_db = -80.0
	add_child(_ambient_player)
	
	# Secondary player for crossfade
	_ambient_player_next = AudioStreamPlayer.new()
	_ambient_player_next.bus = AMBIENT_BUS_NAME
	_ambient_player_next.volume_db = -80.0
	add_child(_ambient_player_next)
	
	# Heartbeat player for crisis state
	_heartbeat_player = AudioStreamPlayer.new()
	_heartbeat_player.bus = AMBIENT_BUS_NAME
	_heartbeat_player.volume_db = -80.0
	add_child(_heartbeat_player)


# =============================================================================
# CROSSFADE
# =============================================================================

func _crossfade_to(new_scene: Scene) -> void:
	"""Crossfade from current ambient to new scene"""
	if _is_crossfading:
		return
	
	_is_crossfading = true
	
	var target_volume: float = SCENE_VOLUMES.get(new_scene, -10.0)
	
	# Load new audio into secondary player
	_load_scene_audio(_ambient_player_next, new_scene)
	_ambient_player_next.volume_db = -80.0
	_ambient_player_next.play()
	
	if OS.is_debug_build():
		print("  Crossfading to scene, target volume: %.1f dB" % target_volume)
		print("  Stream: ", _ambient_player_next.stream)
		print("  Playing: ", _ambient_player_next.playing)
	
	# Create crossfade tween
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out current
	tween.tween_property(_ambient_player, "volume_db", -80.0, CROSSFADE_DURATION)
	
	# Fade in new
	tween.tween_property(_ambient_player_next, "volume_db", target_volume, CROSSFADE_DURATION)
	
	# Swap players when done
	tween.chain().tween_callback(_swap_players)


func _swap_players() -> void:
	"""Swap primary and secondary players after crossfade"""
	_ambient_player.stop()
	
	# Swap references
	var temp = _ambient_player
	_ambient_player = _ambient_player_next
	_ambient_player_next = temp
	
	_is_crossfading = false


func _load_scene_audio(player: AudioStreamPlayer, scene: Scene) -> void:
	"""Load the appropriate audio stream for a scene"""
	if scene == Scene.NONE:
		player.stream = null
		return
	
	var stream = _ambients.get(scene)
	if stream:
		player.stream = stream


# =============================================================================
# CRISIS FILTER
# =============================================================================

func _apply_crisis_filter(level: CrisisLevel) -> void:
	"""Apply low-pass filter based on crisis level"""
	if not _crisis_filter:
		return
	
	var target_cutoff = CRISIS_CUTOFFS.get(level, 20500.0)
	var duration = 0.3 if level != CrisisLevel.NORMAL else 0.5
	
	var tween = create_tween()
	tween.tween_property(_crisis_filter, "cutoff_hz", target_cutoff, duration)
	
	# Handle heartbeat for crisis state
	if level == CrisisLevel.CRISIS:
		_start_heartbeat()
	else:
		_stop_heartbeat()


func _start_heartbeat() -> void:
	"""Start heartbeat undertone for crisis state"""
	if not _heartbeat_player.playing:
		_heartbeat_player.stream = _generate_heartbeat()
		_heartbeat_player.volume_db = -80.0
		_heartbeat_player.play()
		
		var tween = create_tween()
		tween.tween_property(_heartbeat_player, "volume_db", -12.0, 0.5)


func _stop_heartbeat() -> void:
	"""Fade out heartbeat"""
	if _heartbeat_player.playing:
		var tween = create_tween()
		tween.tween_property(_heartbeat_player, "volume_db", -80.0, 0.5)
		tween.tween_callback(func(): _heartbeat_player.stop())


func _update_crisis_from_finances() -> void:
	"""Update crisis level based on airline financial health"""
	if not GameData or not GameData.player_airline:
		return
	
	var airline = GameData.player_airline
	var balance = airline.balance
	var weekly_profit = airline.calculate_weekly_profit()
	
	# Determine crisis level
	var new_level = CrisisLevel.NORMAL
	
	if balance < 0 or weekly_profit < -100000:
		new_level = CrisisLevel.CRISIS
	elif balance < 1000000 and weekly_profit < 0:
		new_level = CrisisLevel.WARNING
	
	set_crisis_level(new_level)


# =============================================================================
# PLACEHOLDER AUDIO GENERATION
# =============================================================================

func _generate_placeholder_ambients() -> void:
	"""Generate procedural placeholder ambient sounds"""
	_ambients = {
		Scene.OFFICE_BOOTSTRAP: _generate_fluorescent_hum(),
		Scene.OFFICE_NATIONAL: _generate_rain_loop(),
		Scene.OFFICE_EMPIRE: _generate_hvac_hum(),
		Scene.HANGAR: _generate_hangar_echo(),
		Scene.MAP: _generate_data_hum(),
	}


func _generate_fluorescent_hum() -> AudioStream:
	"""60Hz hum with slight flicker modulation (Bootstrap office)"""
	var sample_rate := 44100
	var duration := 4.0  # Loop duration
	var samples := int(sample_rate * duration)
	
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_end = samples
	
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / sample_rate
		
		# 60Hz fundamental + harmonics
		var hum := sin(t * 60.0 * TAU) * 0.4
		hum += sin(t * 120.0 * TAU) * 0.2
		hum += sin(t * 180.0 * TAU) * 0.1
		
		# Subtle flicker modulation (random-ish)
		var flicker := 1.0 + sin(t * 7.3) * 0.05 + sin(t * 11.7) * 0.03
		hum *= flicker
		
		# Very low volume base
		var sample := int(hum * 1500)
		sample = clamp(sample, -32768, 32767)
		
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	
	audio.data = data
	return audio


func _generate_rain_loop() -> AudioStream:
	"""Filtered white noise with rhythmic variation (National office)"""
	var sample_rate := 44100
	var duration := 6.0
	var samples := int(sample_rate * duration)
	
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_end = samples
	
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	# Simple low-pass filter state
	var filter_state := 0.0
	var filter_coeff := 0.1
	
	for i in range(samples):
		var t := float(i) / sample_rate
		
		# White noise
		var noise := randf_range(-1.0, 1.0)
		
		# Simple low-pass filter
		filter_state = filter_state * (1.0 - filter_coeff) + noise * filter_coeff
		
		# Rhythmic intensity variation (rain gusts)
		var intensity := 0.5 + sin(t * 0.3) * 0.2 + sin(t * 0.7) * 0.15
		
		var sample := int(filter_state * intensity * 3000)
		sample = clamp(sample, -32768, 32767)
		
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	
	audio.data = data
	return audio


func _generate_hvac_hum() -> AudioStream:
	"""Subtle HVAC with distant city sounds (Empire office)"""
	var sample_rate := 44100
	var duration := 5.0
	var samples := int(sample_rate * duration)
	
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_end = samples
	
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	var filter_state := 0.0
	
	for i in range(samples):
		var t := float(i) / sample_rate
		
		# Low HVAC rumble
		var hvac := sin(t * 45.0 * TAU) * 0.3
		hvac += sin(t * 90.0 * TAU) * 0.15
		
		# Filtered noise for air flow
		var noise := randf_range(-1.0, 1.0)
		filter_state = filter_state * 0.95 + noise * 0.05
		hvac += filter_state * 0.2
		
		# Very subtle city rumble modulation
		var city := sin(t * 0.5) * 0.1 + sin(t * 1.7) * 0.05
		hvac *= (1.0 + city)
		
		var sample := int(hvac * 1200)
		sample = clamp(sample, -32768, 32767)
		
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	
	audio.data = data
	return audio


func _generate_hangar_echo() -> AudioStream:
	"""Echoey hangar with distant aircraft activity"""
	var sample_rate := 44100
	var duration := 8.0
	var samples := int(sample_rate * duration)
	
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_end = samples
	
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	# Simple delay line for echo
	var delay_samples := int(sample_rate * 0.15)
	var delay_buffer := PackedFloat32Array()
	delay_buffer.resize(delay_samples)
	var delay_idx := 0
	
	var filter_state := 0.0
	
	for i in range(samples):
		var t := float(i) / sample_rate
		
		# Base ambient (filtered noise)
		var noise := randf_range(-1.0, 1.0)
		filter_state = filter_state * 0.92 + noise * 0.08
		
		# Occasional distant clanks (periodic impulses)
		var clank := 0.0
		if fmod(t, 2.7) < 0.01:
			clank = sin(t * 800.0 * TAU) * exp(-fmod(t, 2.7) * 100.0) * 0.3
		
		# Echo
		var delayed := delay_buffer[delay_idx]
		var combined := filter_state * 0.3 + clank + delayed * 0.4
		
		delay_buffer[delay_idx] = combined * 0.5
		delay_idx = (delay_idx + 1) % delay_samples
		
		var sample := int(combined * 2500)
		sample = clamp(sample, -32768, 32767)
		
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	
	audio.data = data
	return audio


func _generate_data_hum() -> AudioStream:
	"""Soft electronic hum with occasional blips (Map view)"""
	var sample_rate := 44100
	var duration := 5.0
	var samples := int(sample_rate * duration)
	
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_end = samples
	
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / sample_rate
		
		# Electronic hum (higher frequency, very subtle)
		var hum := sin(t * 200.0 * TAU) * 0.15
		hum += sin(t * 400.0 * TAU) * 0.05
		
		# Subtle data processing sounds
		var data_blip := 0.0
		if fmod(t, 1.3) < 0.02:
			data_blip = sin(t * 1200.0 * TAU) * exp(-fmod(t, 1.3) * 80.0) * 0.15
		if fmod(t + 0.4, 2.1) < 0.015:
			data_blip += sin(t * 800.0 * TAU) * exp(-fmod(t + 0.4, 2.1) * 100.0) * 0.1
		
		var sample := int((hum + data_blip) * 1500)
		sample = clamp(sample, -32768, 32767)
		
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	
	audio.data = data
	return audio


func _generate_heartbeat() -> AudioStream:
	"""Heartbeat sound for crisis state"""
	var sample_rate := 44100
	var duration := 1.0  # One heartbeat cycle
	var samples := int(sample_rate * duration)
	
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_end = samples
	
	var data := PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t := float(i) / sample_rate
		
		# Double-beat pattern (lub-dub)
		var beat := 0.0
		
		# First beat (lub) at t=0.0
		if t < 0.1:
			beat = sin(t * 40.0 * TAU) * exp(-t * 30.0)
		
		# Second beat (dub) at t=0.15
		var t2 := t - 0.15
		if t2 > 0.0 and t2 < 0.08:
			beat += sin(t2 * 50.0 * TAU) * exp(-t2 * 40.0) * 0.7
		
		var sample := int(beat * 8000)
		sample = clamp(sample, -32768, 32767)
		
		data[i * 2] = sample & 0xFF
		data[i * 2 + 1] = (sample >> 8) & 0xFF
	
	audio.data = data
	return audio


# =============================================================================
# HELPERS
# =============================================================================

func _get_airline_stage() -> String:
	"""Determine airline stage based on metrics"""
	if not GameData or not GameData.player_airline:
		return "bootstrap"
	
	var airline = GameData.player_airline
	var fleet_size = airline.aircraft.size()
	var route_count = airline.routes.size()
	var hub_count = airline.hubs.size()
	
	# Empire: 10+ aircraft, 5+ hubs, 20+ routes
	if fleet_size >= 10 and hub_count >= 5 and route_count >= 20:
		return "empire"
	
	# National: 5+ aircraft, 2+ hubs, 10+ routes
	if fleet_size >= 5 and hub_count >= 2 and route_count >= 10:
		return "national"
	
	return "bootstrap"


func _on_week_simulated(_week: int) -> void:
	"""Update ambient based on airline growth"""
	update_office_ambient()
