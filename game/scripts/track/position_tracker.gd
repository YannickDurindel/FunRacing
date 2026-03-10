extends Node

# Updates RaceState car positions each physics tick
# Uses progress_ratio + laps_completed for sorting

var _track_data: TrackData = null
var _cars: Array = []   # [{car_id, body: VehicleBody3D, laps, last_ratio}]

const LAP_WRAP_THRESHOLD: float = 0.15  # ratio must cross from >0.85 to <0.15

signal positions_updated(sorted_ids: Array)


func setup(track: TrackData, car_bodies: Array) -> void:
	_track_data = track
	_cars.clear()
	for body in car_bodies:
		if body is VehicleBody3D:
			_cars.append({
				"car_id": body.car_id,
				"body": body,
				"laps": 0,
				"last_ratio": 0.0,
				"progress": 0.0
			})


func _physics_process(_delta: float) -> void:
	if _track_data == null or _cars.is_empty():
		return
	_update_all_positions()
	_sort_and_publish()


func _update_all_positions() -> void:
	for entry in _cars:
		var body: VehicleBody3D = entry["body"]
		if not is_instance_valid(body):
			continue
		var ratio: float = _track_data.get_progress_ratio(body.global_position)
		var last: float = entry["last_ratio"]

		# Lap completion detection: ratio wraps from high to low
		if last > 0.85 and ratio < LAP_WRAP_THRESHOLD:
			entry["laps"] += 1
			RaceState.lap_completed.emit(entry["car_id"], 0.0)  # timer fills real time

		entry["last_ratio"] = ratio
		entry["progress"] = float(entry["laps"]) + ratio
		RaceState.update_car_progress(entry["car_id"], entry["laps"], ratio)


func _sort_and_publish() -> void:
	var sorted_cars: Array = _cars.duplicate()
	sorted_cars.sort_custom(func(a, b): return a["progress"] > b["progress"])

	var sorted_ids: Array[int] = []
	for i in range(sorted_cars.size()):
		var entry = sorted_cars[i]
		sorted_ids.append(entry["car_id"])
		var data: Dictionary = RaceState.get_car_data(entry["car_id"])
		if not data.is_empty():
			data["position"] = i + 1

	RaceState.sorted_positions = sorted_ids

	# Calculate gaps
	if sorted_cars.size() > 0:
		var leader_progress: float = sorted_cars[0]["progress"]
		var track_len: float = _track_data.get_baked_length()
		for i in range(sorted_cars.size()):
			var gap_dist: float = (leader_progress - sorted_cars[i]["progress"]) * track_len
			var data: Dictionary = RaceState.get_car_data(sorted_cars[i]["car_id"])
			if not data.is_empty():
				# Convert distance gap to time gap (rough: ~60m/s average)
				data["gap_to_leader"] = gap_dist / 60.0

	positions_updated.emit(sorted_ids)
