extends Node

var total_laps: int = 10
var _cars_finished: Array = []  # [{car_id, finish_order, finish_time}]
var _race_started: bool = false
var _finish_triggered: bool = false

signal car_finished(car_id: int, position: int)
signal race_complete(results: Array)


func _ready() -> void:
	RaceState.lap_completed.connect(_on_lap_completed)
	RaceState.phase_changed.connect(_on_phase_changed)


func setup(laps: int) -> void:
	total_laps = laps
	RaceState.total_laps = laps
	_cars_finished.clear()
	_finish_triggered = false


func _on_phase_changed(phase: RaceState.SessionPhase) -> void:
	if phase == RaceState.SessionPhase.RACING:
		_race_started = true


func _on_lap_completed(car_id: int, _lap_time: float) -> void:
	if not _race_started:
		return
	var data: Dictionary = RaceState.get_car_data(car_id)
	if data.is_empty():
		return
	var laps: int = data.get("laps_completed", 0)

	if laps >= total_laps and not _is_finished(car_id):
		var finish_pos: int = _cars_finished.size() + 1
		_cars_finished.append({
			"car_id": car_id,
			"position": finish_pos,
			"finish_time": RaceState.race_elapsed
		})
		data["finish_time"] = RaceState.race_elapsed
		data["retired"] = false
		car_finished.emit(car_id, finish_pos)

		if finish_pos == 1 and not _finish_triggered:
			_finish_triggered = true
			# Give others 2 laps to finish
			RaceState.set_phase(RaceState.SessionPhase.CHEQUERED)
			_complete_remaining_async()


func _is_finished(car_id: int) -> bool:
	for entry in _cars_finished:
		if entry["car_id"] == car_id:
			return true
	return false


func _complete_remaining_async() -> void:
	await get_tree().create_timer(5.0).timeout
	# Force-finish any remaining cars based on their progress
	var unfinished: Array = []
	for data in RaceState.car_data:
		if not _is_finished(data["car_id"]) and not data.get("retired", false):
			unfinished.append(data)
	unfinished.sort_custom(func(a, b):
		return (float(a["laps_completed"]) + a["progress_ratio"]) > (float(b["laps_completed"]) + b["progress_ratio"])
	)
	for data in unfinished:
		var pos: int = _cars_finished.size() + 1
		_cars_finished.append({"car_id": data["car_id"], "position": pos, "finish_time": RaceState.race_elapsed})
		data["finish_time"] = RaceState.race_elapsed

	_build_and_emit_results()


func _build_and_emit_results() -> void:
	var results: Array = []
	for entry in _cars_finished:
		var data: Dictionary = RaceState.get_car_data(entry["car_id"])
		results.append({
			"car_id": entry["car_id"],
			"driver_id": data.get("driver_id", ""),
			"team_id": data.get("team_id", ""),
			"position": entry["position"],
			"finish_time": entry["finish_time"],
			"best_lap": data.get("best_lap_time", 0.0),
			"tire_compound": data.get("tire_compound", "medium")
		})
	RaceState.set_phase(RaceState.SessionPhase.FINISHED)
	race_complete.emit(results)


func get_laps_remaining_for_car(car_id: int) -> int:
	var data: Dictionary = RaceState.get_car_data(car_id)
	if data.is_empty():
		return 0
	return total_laps - data.get("laps_completed", 0)
