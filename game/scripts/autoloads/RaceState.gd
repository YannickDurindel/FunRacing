extends Node

# Live race data — updated each physics tick by position_tracker and race_session

enum SessionPhase {
	WAITING,
	FORMATION_LAP,
	LIGHTS_SEQUENCE,
	RACING,
	SAFETY_CAR,
	CHEQUERED,
	FINISHED
}

var phase: SessionPhase = SessionPhase.WAITING
var total_laps: int = 0
var current_lap_leader: int = 0
var race_elapsed: float = 0.0
var session_started: bool = false

# Overall best sector times (for purple colouring)
var overall_best_sectors: Array[float] = [INF, INF, INF]
var overall_best_lap: float = INF

# Array of 20 dicts matching the car_data structure from the plan
var car_data: Array = []

# Sorted positions [car_id, ...]
var sorted_positions: Array[int] = []

signal phase_changed(new_phase: SessionPhase)
signal position_update(sorted_array: Array)
signal lap_completed(car_id: int, lap_time: float)
signal race_finished()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func reset() -> void:
	phase = SessionPhase.WAITING
	total_laps = 0
	current_lap_leader = 0
	race_elapsed = 0.0
	session_started = false
	overall_best_sectors = [INF, INF, INF]
	overall_best_lap = INF
	car_data.clear()
	sorted_positions.clear()


func register_car(car_id: int, is_player: bool, driver_id: String, team_id: String) -> void:
	var entry: Dictionary = {
		"car_id": car_id,
		"is_player": is_player,
		"driver_id": driver_id,
		"team_id": team_id,
		"position": car_id + 1,
		"laps_completed": 0,
		"progress_ratio": 0.0,
		"gap_to_leader": 0.0,
		"last_lap_time": 0.0,
		"best_lap_time": INF,
		"sector_times": [0.0, 0.0, 0.0],
		"best_sectors": [INF, INF, INF],
		"tire_compound": "medium",
		"tire_laps": 0,
		"tire_deg": 0.0,
		"ers_charge": 4000.0,
		"drs_eligible": false,
		"in_pit": false,
		"retired": false,
		"finish_time": 0.0
	}
	car_data.append(entry)
	sorted_positions.append(car_id)


func get_car_data(car_id: int) -> Dictionary:
	for entry in car_data:
		if entry["car_id"] == car_id:
			return entry
	return {}


func update_car_progress(car_id: int, laps: int, ratio: float) -> void:
	var data: Dictionary = get_car_data(car_id)
	if data.is_empty():
		return
	data["laps_completed"] = laps
	data["progress_ratio"] = ratio


func set_phase(new_phase: SessionPhase) -> void:
	if phase == new_phase:
		return
	phase = new_phase
	phase_changed.emit(new_phase)
	if new_phase == SessionPhase.RACING:
		session_started = true


func update_sector_best(sector_index: int, time: float) -> bool:
	if time < overall_best_sectors[sector_index]:
		overall_best_sectors[sector_index] = time
		return true
	return false


func _process(delta: float) -> void:
	if session_started and phase == SessionPhase.RACING:
		race_elapsed += delta
