extends Node

# Manages the start sequence: 5 lights → lights out → GO

const LIGHT_INTERVAL: float = 0.8  # seconds between each light
const LIGHTS_HOLD: float = 0.5     # seconds all 5 lights hold before random extinguish

var _lights_on: int = 0
var _timer: float = 0.0
var _sequence_running: bool = false
var _random_delay: float = 0.0

signal light_added(count: int)      # 1..5
signal lights_out()                  # Race starts!
signal false_start(car_id: int)


func _ready() -> void:
	set_process(false)


func begin_start_sequence() -> void:
	_lights_on = 0
	_timer = 0.0
	_sequence_running = true
	_random_delay = randf_range(0.2, 3.0)
	set_process(true)
	RaceState.set_phase(RaceState.SessionPhase.LIGHTS_SEQUENCE)


func _process(delta: float) -> void:
	if not _sequence_running:
		return
	_timer += delta

	if _lights_on < 5:
		if _timer >= LIGHT_INTERVAL:
			_timer -= LIGHT_INTERVAL
			_lights_on += 1
			light_added.emit(_lights_on)
	else:
		# All 5 lights on — wait random delay then lights out
		if _timer >= LIGHTS_HOLD + _random_delay:
			_sequence_running = false
			set_process(false)
			lights_out.emit()
			RaceState.set_phase(RaceState.SessionPhase.RACING)


func check_false_start(car_id: int, moved: bool) -> void:
	if _lights_on < 5 and moved:
		false_start.emit(car_id)
