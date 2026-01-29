## UISoundManager.gd
## Autoload singleton for UI sound effects.
## Provides responsive audio feedback for all interactions per art-bible section 4.1.
extends Node
class_name UISoundManagerClass

## Sound types matching art-bible UI sound specifications
enum Sound {
	CLICK,      # Soft mechanical click (50ms) - Any button press
	PURCHASE,   # Heavy "thunk" / stamp (200ms) - Aircraft buy, route confirm
	NAVIGATE,   # Subtle whoosh (100ms) - Panel/tab switch
	ERROR,      # Low buzz / rejection tone (150ms) - Invalid action, insufficient funds
	SUCCESS,    # Bright chime, ascending (200ms) - Route profitable, milestone
	MONEY_TICK, # Soft ticking, satisfying (variable) - Revenue counter
	ALERT       # Attention tone, not harsh (300ms) - Notifications, warnings
}

## Audio players pool for each sound type
var _audio_players: Dictionary = {}  # Sound -> AudioStreamPlayer

## Debounce tracking to prevent rapid overlapping
var _last_play_time: Dictionary = {}  # Sound -> float (timestamp)
const DEBOUNCE_MS := 50.0  # Minimum ms between same sound plays (raised from 30)

## Volume settings (0.0 to 1.0)
var master_volume: float = 1.0
var _volume: float = 0.5  # Default 50%
var _enabled: bool = false  # Off by default

## Money tally state
var _money_tally_timer: Timer = null
var _money_tally_remaining: int = 0
var _money_tally_rate: float = 0.05  # Seconds between ticks

## Audio bus for UI sounds
const UI_BUS_NAME := "UI"
var _ui_bus_idx: int = -1


func _ready() -> void:
	# Ensure UI audio bus exists (or use Master)
	_setup_audio_bus()
	
	# Create audio players for each sound type
	for sound_type in Sound.values():
		var player = AudioStreamPlayer.new()
		player.bus = UI_BUS_NAME if AudioServer.get_bus_index(UI_BUS_NAME) >= 0 else "Master"
		add_child(player)
		_audio_players[sound_type] = player
		_last_play_time[sound_type] = 0.0
	
	# Setup money tally timer
	_money_tally_timer = Timer.new()
	_money_tally_timer.one_shot = false
	_money_tally_timer.timeout.connect(_on_money_tick)
	add_child(_money_tally_timer)
	
	# Generate placeholder sounds
	_generate_placeholder_sounds()


func _setup_audio_bus() -> void:
	"""Ensure UI audio bus exists"""
	_ui_bus_idx = AudioServer.get_bus_index(UI_BUS_NAME)
	if _ui_bus_idx < 0:
		# Create UI bus as child of Master
		_ui_bus_idx = AudioServer.bus_count
		AudioServer.add_bus(_ui_bus_idx)
		AudioServer.set_bus_name(_ui_bus_idx, UI_BUS_NAME)
		AudioServer.set_bus_send(_ui_bus_idx, "Master")
	
	# Apply initial volume
	AudioServer.set_bus_volume_db(_ui_bus_idx, linear_to_db(_volume))


func set_enabled(enabled: bool) -> void:
	"""Enable or disable UI sounds"""
	_enabled = enabled


func is_enabled() -> bool:
	return _enabled


func set_volume(volume: float) -> void:
	"""Set UI sound volume (0.0 to 1.0)"""
	_volume = clampf(volume, 0.0, 1.0)
	if _ui_bus_idx >= 0:
		AudioServer.set_bus_volume_db(_ui_bus_idx, linear_to_db(_volume))


func get_volume() -> float:
	return _volume


func play(sound: Sound) -> void:
	"""Play a UI sound effect with debounce protection"""
	if not _enabled:
		return
	
	var current_time = Time.get_ticks_msec()
	
	# Check debounce
	if current_time - _last_play_time[sound] < DEBOUNCE_MS:
		return
	
	_last_play_time[sound] = current_time
	
	# Get player and play
	var player: AudioStreamPlayer = _audio_players[sound]
	if player and player.stream:
		player.volume_db = linear_to_db(master_volume * _get_sound_volume(sound))
		player.play()


func play_click() -> void:
	"""Convenience method for button clicks"""
	play(Sound.CLICK)


func play_purchase() -> void:
	"""Convenience method for major purchases"""
	play(Sound.PURCHASE)


func play_navigate() -> void:
	"""Convenience method for panel/tab transitions"""
	play(Sound.NAVIGATE)


func play_error() -> void:
	"""Convenience method for error feedback"""
	play(Sound.ERROR)


func play_success() -> void:
	"""Convenience method for success feedback"""
	play(Sound.SUCCESS)


func play_alert() -> void:
	"""Convenience method for notifications/warnings"""
	play(Sound.ALERT)


func play_money_tally(amount: int) -> void:
	"""Play money tally effect with tick rate based on amount.
	More money = faster ticks for satisfying feedback."""
	if amount <= 0:
		return
	
	# Calculate tick count and rate based on amount
	# Small amounts: few slow ticks
	# Large amounts: many fast ticks (capped for sanity)
	var tick_count: int
	var tick_rate: float
	
	if amount < 10000:
		tick_count = min(5, amount / 2000 + 1)
		tick_rate = 0.12
	elif amount < 100000:
		tick_count = min(10, amount / 10000 + 3)
		tick_rate = 0.08
	elif amount < 1000000:
		tick_count = min(15, amount / 50000 + 5)
		tick_rate = 0.05
	else:
		tick_count = 20
		tick_rate = 0.03
	
	_money_tally_remaining = tick_count
	_money_tally_rate = tick_rate
	_money_tally_timer.wait_time = tick_rate
	_money_tally_timer.start()
	
	# Play first tick immediately
	_on_money_tick()


func stop_money_tally() -> void:
	"""Stop any ongoing money tally sound"""
	_money_tally_timer.stop()
	_money_tally_remaining = 0


func set_master_volume(volume: float) -> void:
	"""Set master volume (0.0 to 1.0) - legacy, use set_volume() instead"""
	master_volume = clampf(volume, 0.0, 1.0)


func _on_money_tick() -> void:
	"""Handle money tally tick"""
	if _money_tally_remaining <= 0:
		_money_tally_timer.stop()
		return
	
	play(Sound.MONEY_TICK)
	_money_tally_remaining -= 1
	
	if _money_tally_remaining <= 0:
		_money_tally_timer.stop()


func _get_sound_volume(sound: Sound) -> float:
	"""Get relative volume for each sound type"""
	match sound:
		Sound.CLICK:
			return 0.6
		Sound.PURCHASE:
			return 0.9
		Sound.NAVIGATE:
			return 0.4
		Sound.ERROR:
			return 0.8
		Sound.SUCCESS:
			return 0.7
		Sound.MONEY_TICK:
			return 0.5
		Sound.ALERT:
			return 0.85
		_:
			return 0.7


func _generate_placeholder_sounds() -> void:
	"""Generate procedural placeholder sounds using AudioStreamGenerator.
	These are simple synthesized sounds that match the art-bible character descriptions.
	Replace with professional audio assets in final polish phase."""
	
	# For each sound type, create a simple generated waveform
	_audio_players[Sound.CLICK].stream = _create_click_sound()
	_audio_players[Sound.PURCHASE].stream = _create_purchase_sound()
	_audio_players[Sound.NAVIGATE].stream = _create_navigate_sound()
	_audio_players[Sound.ERROR].stream = _create_error_sound()
	_audio_players[Sound.SUCCESS].stream = _create_success_sound()
	_audio_players[Sound.MONEY_TICK].stream = _create_money_tick_sound()
	_audio_players[Sound.ALERT].stream = _create_alert_sound()


func _create_click_sound() -> AudioStreamWAV:
	"""Soft mechanical click - 50ms"""
	return _generate_tone(800.0, 0.05, 0.8, "click")


func _create_purchase_sound() -> AudioStreamWAV:
	"""Heavy thunk/stamp - 200ms"""
	return _generate_tone(150.0, 0.2, 1.0, "thunk")


func _create_navigate_sound() -> AudioStreamWAV:
	"""Subtle whoosh - 100ms"""
	return _generate_noise(0.1, 0.4, "whoosh")


func _create_error_sound() -> AudioStreamWAV:
	"""Low buzz/rejection - 150ms"""
	return _generate_tone(180.0, 0.15, 0.9, "buzz")


func _create_success_sound() -> AudioStreamWAV:
	"""Bright chime ascending - 200ms"""
	return _generate_chime([523.25, 659.25, 783.99], 0.2)  # C5, E5, G5


func _create_money_tick_sound() -> AudioStreamWAV:
	"""Soft tick - very short"""
	return _generate_tone(1200.0, 0.02, 0.5, "click")


func _create_alert_sound() -> AudioStreamWAV:
	"""Attention tone - 300ms"""
	return _generate_tone(440.0, 0.3, 0.7, "sine")


func _generate_tone(frequency: float, duration: float, amplitude: float, shape: String = "sine") -> AudioStreamWAV:
	"""Generate a simple tone waveform"""
	var sample_rate: int = 44100
	var sample_count: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)  # 16-bit samples
	
	for i in range(sample_count):
		var t: float = float(i) / sample_rate
		var envelope: float = _envelope(t, duration)
		var sample: float = 0.0
		
		match shape:
			"sine":
				sample = sin(TAU * frequency * t)
			"click":
				# Sharp attack, quick decay
				sample = sin(TAU * frequency * t) * exp(-t * 50)
			"thunk":
				# Low frequency with noise burst
				sample = sin(TAU * frequency * t) * exp(-t * 10)
				sample += randf_range(-0.3, 0.3) * exp(-t * 30)
			"buzz":
				# Square-ish wave for buzz
				sample = sign(sin(TAU * frequency * t)) * 0.7
				sample += sin(TAU * frequency * 1.5 * t) * 0.3
			_:
				sample = sin(TAU * frequency * t)
		
		sample *= amplitude * envelope
		sample = clamp(sample, -1.0, 1.0)
		
		# Convert to 16-bit signed integer
		var int_sample: int = int(sample * 32767)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _generate_noise(duration: float, amplitude: float, shape: String = "white") -> AudioStreamWAV:
	"""Generate noise-based sound (for whoosh, etc.)"""
	var sample_rate: int = 44100
	var sample_count: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	
	var prev_sample: float = 0.0
	
	for i in range(sample_count):
		var t: float = float(i) / sample_rate
		var envelope: float = _envelope(t, duration, 0.3, 0.5)  # Quick fade in/out
		var sample: float = 0.0
		
		match shape:
			"white":
				sample = randf_range(-1.0, 1.0)
			"whoosh":
				# Filtered noise with pitch sweep
				var noise = randf_range(-1.0, 1.0)
				# Simple low-pass filter
				sample = prev_sample * 0.7 + noise * 0.3
				prev_sample = sample
				# Add subtle pitch sweep
				sample *= sin(PI * t / duration)
			_:
				sample = randf_range(-1.0, 1.0)
		
		sample *= amplitude * envelope
		sample = clamp(sample, -1.0, 1.0)
		
		var int_sample: int = int(sample * 32767)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _generate_chime(frequencies: Array, duration: float) -> AudioStreamWAV:
	"""Generate ascending chime with multiple frequencies"""
	var sample_rate: int = 44100
	var sample_count: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	
	var note_duration: float = duration / frequencies.size()
	
	for i in range(sample_count):
		var t: float = float(i) / sample_rate
		var sample: float = 0.0
		
		# Determine which note(s) are playing
		for j in range(frequencies.size()):
			var note_start: float = j * note_duration * 0.7  # Overlapping notes
			var note_t: float = t - note_start
			
			if note_t >= 0 and note_t < note_duration:
				var freq: float = frequencies[j]
				var note_env: float = exp(-note_t * 8) * (1.0 - exp(-note_t * 100))
				sample += sin(TAU * freq * note_t) * note_env * 0.5
		
		var envelope: float = _envelope(t, duration, 0.01, 0.3)
		sample *= envelope
		sample = clamp(sample, -1.0, 1.0)
		
		var int_sample: int = int(sample * 32767)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream


func _envelope(t: float, duration: float, attack: float = 0.01, release: float = 0.2) -> float:
	"""Generate ADSR-like envelope"""
	var attack_time: float = duration * attack
	var release_time: float = duration * release
	var sustain_end: float = duration - release_time
	
	if t < attack_time:
		return t / attack_time
	elif t < sustain_end:
		return 1.0
	else:
		return 1.0 - (t - sustain_end) / release_time
