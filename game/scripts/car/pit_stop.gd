extends Node
class_name PitStop

enum State { IDLE, APPROACHING, STOPPED, COMPLETE }

const PIT_STOP_DURATION: float = 2.5  # seconds
const PIT_SPEED_LIMIT: float = 15.0   # m/s (~54 km/h)

var state: State = State.IDLE
var _timer: float = 0.0
var new_compound: TireModel.Compound = TireModel.Compound.MEDIUM

signal pit_stop_started()
signal pit_stop_complete(compound: TireModel.Compound)


func enter_pit_lane() -> void:
	if state == State.IDLE:
		state = State.APPROACHING
		pit_stop_started.emit()


func update(delta: float, car_speed: float) -> void:
	match state:
		State.APPROACHING:
			if car_speed < 0.5:
				state = State.STOPPED
				_timer = 0.0
		State.STOPPED:
			_timer += delta
			if _timer >= PIT_STOP_DURATION:
				state = State.COMPLETE
				pit_stop_complete.emit(new_compound)
		State.COMPLETE:
			# Will be reset by car on exit
			pass


func exit_pit() -> void:
	state = State.IDLE
	_timer = 0.0


func is_in_pit() -> bool:
	return state != State.IDLE


func get_progress() -> float:
	if state != State.STOPPED:
		return 0.0
	return _timer / PIT_STOP_DURATION
