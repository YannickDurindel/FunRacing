extends Node

const GAP_TRIGGER: float = 2.0   # metres to trigger overtake attempt
const OFFSET_AMOUNT: float = 1.5  # metres lateral

var _car: VehicleBody3D = null
var _racing_line: RacingLine = null
var _aggression: float = 0.6

var _overtake_active: bool = false
var _overtake_direction: float = 0.0
var _overtake_timer: float = 0.0
const OVERTAKE_DURATION: float = 3.0


func setup(car: VehicleBody3D, line: RacingLine, aggression: float) -> void:
	_car = car
	_racing_line = line
	_aggression = aggression


func _physics_process(delta: float) -> void:
	if _car == null or _racing_line == null:
		return

	_overtake_timer = maxf(_overtake_timer - delta, 0.0)

	# Find nearest car ahead within gap threshold
	var gap_ahead: float = _get_gap_to_car_ahead()

	if gap_ahead < GAP_TRIGGER and _overtake_timer <= 0.0 and randf() < _aggression * 0.02:
		# Trigger overtake: pick side based on track curvature
		var curvature: float = _racing_line.get_curvature(_car.global_position)
		_overtake_direction = 1.0 if curvature >= 0 else -1.0
		_racing_line.lateral_offset = _overtake_direction * OFFSET_AMOUNT
		_overtake_active = true
		_overtake_timer = OVERTAKE_DURATION
	elif _overtake_timer <= 0.0 and _overtake_active:
		_racing_line.lateral_offset = 0.0
		_overtake_active = false


func _get_gap_to_car_ahead() -> float:
	var my_data: Dictionary = RaceState.get_car_data(_car.car_id)
	if my_data.is_empty():
		return 999.0
	var my_pos: int = my_data.get("position", 20)
	var my_progress: float = float(my_data.get("laps_completed", 0)) + my_data.get("progress_ratio", 0.0)

	for data in RaceState.car_data:
		if data["position"] == my_pos - 1:
			var their_progress: float = float(data.get("laps_completed", 0)) + data.get("progress_ratio", 0.0)
			var dist: float = (their_progress - my_progress) * RaceState.car_data.size()  # rough
			return absf(dist)
	return 999.0
