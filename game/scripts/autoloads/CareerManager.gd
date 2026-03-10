extends Node

const CareerDataScript = preload("res://scripts/career/career_data.gd")
const SeasonGeneratorScript = preload("res://scripts/career/season_generator.gd")

const POINTS_TABLE: Dictionary = {1:25, 2:18, 3:15, 4:12, 5:10, 6:8, 7:6, 8:4, 9:2, 10:1}

var _career = null  # CareerData


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func set_career(career) -> void:
	_career = career


func get_career():
	return _career


func create_new_career(player_name: String):
	var cd = CareerDataScript.new()
	cd.player_name = player_name
	cd.player_team_id = "team_aurora"
	cd.car_number = 44
	cd.season_number = 1
	cd.calendar = SeasonGeneratorScript.generate_calendar()
	cd.driver_championship = SeasonGeneratorScript.generate_championship_standings("player")
	cd.constructor_championship = SeasonGeneratorScript.generate_constructor_standings()
	_career = cd
	GameState.career = cd
	return cd


func record_race_results(track_id: String, weekend_index: int, results: Array) -> void:
	if _career == null:
		return
	# results: [{driver_id, position}, ...]
	for entry in results:
		var points: int = POINTS_TABLE.get(entry["position"], 0)
		# Update driver championship
		for ds in _career.driver_championship:
			if ds["driver_id"] == entry["driver_id"]:
				ds["points"] += points
				if entry["position"] == 1:
					ds["wins"] = ds.get("wins", 0) + 1
				break
		# Update constructor championship
		var team_id = _get_team_for_driver(entry["driver_id"])
		if team_id != "":
			for cs in _career.constructor_championship:
				if cs["team_id"] == team_id:
					cs["points"] += points
					break
	# Update calendar entry
	for event in _career.calendar:
		if event["track_id"] == track_id and event["weekend_index"] == weekend_index:
			event["state"] = "completed"
			# Find player result
			for entry in results:
				if entry["driver_id"] == "player":
					event["race_position"] = entry["position"]
					event["points_scored"] = POINTS_TABLE.get(entry["position"], 0)
					_career.prize_money += _prize_for_position(entry["position"])
			break
	_sort_standings()
	SaveManager.save_career(_career)


func record_qualifying(track_id: String, weekend_index: int, position: int) -> void:
	if _career == null:
		return
	for event in _career.calendar:
		if event["track_id"] == track_id and event["weekend_index"] == weekend_index:
			event["qualifying_position"] = position
			event["state"] = "qualifying_done"
			break


func advance_season() -> void:
	if _career == null:
		return
	_career.season_number += 1
	_career.calendar = SeasonGeneratorScript.generate_calendar()
	# Preserve championship points — do NOT reset
	SaveManager.save_career(_career)


func get_next_event() -> Dictionary:
	if _career == null:
		return {}
	for event in _career.calendar:
		if event["state"] == "upcoming" or event["state"] == "qualifying_done":
			return event
	return {}


func is_season_complete() -> bool:
	if _career == null:
		return false
	for event in _career.calendar:
		if event["state"] != "completed":
			return false
	return true


func get_player_championship_position() -> int:
	if _career == null:
		return 0
	for i in range(_career.driver_championship.size()):
		if _career.driver_championship[i]["driver_id"] == "player":
			return i + 1
	return 0


func get_player_points() -> int:
	if _career == null:
		return 0
	for ds in _career.driver_championship:
		if ds["driver_id"] == "player":
			return ds["points"]
	return 0


func _get_team_for_driver(driver_id: String) -> String:
	if driver_id == "player":
		return _career.player_team_id if _career else ""
	for d in SeasonGeneratorScript.DRIVERS:
		if d["driver_id"] == driver_id:
			return d["team_id"]
	return ""


func _sort_standings() -> void:
	_career.driver_championship.sort_custom(func(a, b): return a["points"] > b["points"])
	_career.constructor_championship.sort_custom(func(a, b): return a["points"] > b["points"])


func _prize_for_position(pos: int) -> int:
	# Prize money in thousands
	var prizes: Array = [500, 350, 250, 200, 150, 120, 100, 80, 60, 50]
	if pos >= 1 and pos <= prizes.size():
		return prizes[pos - 1] * 1000
	return 10000
