extends Node

# Procedural engine audio via AudioStreamGenerator
# Sine wave + harmonics mapped to RPM

const SAMPLE_RATE: float = 44100.0
const BUFFER_SIZE: int = 512

var _player: AudioStreamPlayer = null
var _generator: AudioStreamGenerator = null
var _playback: AudioStreamGeneratorPlayback = null

var current_rpm: float = 800.0   # idle
var target_rpm: float = 800.0
var _phase: float = 0.0

const RPM_IDLE: float = 800.0
const RPM_MAX: float = 18000.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_generator()


func _setup_generator() -> void:
	_generator = AudioStreamGenerator.new()
	_generator.mix_rate = SAMPLE_RATE
	_generator.buffer_length = 0.1  # 100ms

	_player = AudioStreamPlayer.new()
	_player.stream = _generator
	_player.volume_db = -6.0
	_player.bus = "Master"
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback()


func _process(_delta: float) -> void:
	if _playback == null:
		return
	# Smooth RPM towards target
	current_rpm = lerpf(current_rpm, target_rpm, 0.1)
	_fill_buffer()


func _fill_buffer() -> void:
	if _playback == null:
		return
	var available: int = _playback.get_frames_available()
	if available <= 0:
		return

	var base_freq: float = _rpm_to_freq(current_rpm)
	var frames: PackedVector2Array = PackedVector2Array()
	frames.resize(available)

	for i in range(available):
		var t: float = _phase / SAMPLE_RATE
		# Fundamental + 2nd + 4th harmonic (V10 character)
		var sample: float = 0.0
		sample += 0.5 * sin(TAU * base_freq * t)
		sample += 0.25 * sin(TAU * base_freq * 2.0 * t)
		sample += 0.15 * sin(TAU * base_freq * 4.0 * t)
		sample += 0.10 * sin(TAU * base_freq * 6.0 * t)
		# Slight distortion for engine character
		sample = clampf(sample * 1.2, -1.0, 1.0)
		frames[i] = Vector2(sample, sample)
		_phase += 1.0
		if _phase >= SAMPLE_RATE:
			_phase -= SAMPLE_RATE

	_playback.push_buffer(frames)


func set_rpm(rpm: float) -> void:
	target_rpm = clampf(rpm, RPM_IDLE, RPM_MAX)


func set_throttle_and_speed(throttle: float, speed_kmh: float) -> void:
	# Estimate RPM from speed (assuming 7th gear ~310 km/h = 18000 rpm)
	var speed_ratio: float = clampf(speed_kmh / 310.0, 0.0, 1.0)
	var rpm_from_speed: float = lerpf(RPM_IDLE, RPM_MAX * 0.9, speed_ratio)
	# Blend with throttle revving
	var rpm_from_throttle: float = lerpf(RPM_IDLE, RPM_MAX, throttle)
	target_rpm = maxf(rpm_from_speed, rpm_from_throttle * 0.6)


func _rpm_to_freq(rpm: float) -> float:
	# V10: 5 firing events per revolution / 60 seconds = frequency
	return (rpm / 60.0) * 5.0
