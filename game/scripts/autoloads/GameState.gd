extends Node

const CareerDataScript = preload("res://scripts/career/career_data.gd")

# Active career reference (CareerData Resource)
var career = null
var selected_track_id: String = ""
var selected_weekend_index: int = 0
var session_type: String = ""  # "qualifying", "race", "practice"

# Scene stack for back navigation
var _scene_stack: Array[String] = []

signal scene_changed(scene_path: String)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func go_to(scene_path: String, push_current: bool = true) -> void:
	if push_current and get_tree().current_scene:
		_scene_stack.push_back(get_tree().current_scene.scene_file_path)
	get_tree().change_scene_to_file(scene_path)
	scene_changed.emit(scene_path)


func go_back() -> void:
	if _scene_stack.is_empty():
		go_to("res://scenes/main_menu/main_menu.tscn", false)
		return
	var prev: String = _scene_stack.pop_back()
	get_tree().change_scene_to_file(prev)
	scene_changed.emit(prev)


func start_new_career(player_name: String) -> void:
	career = CareerManager.create_new_career(player_name)
	SaveManager.save_career(career)
	go_to("res://scenes/career/career_hub.tscn", false)


func start_race_weekend(track_id: String, weekend_index: int) -> void:
	selected_track_id = track_id
	selected_weekend_index = weekend_index
	session_type = "qualifying"
	go_to("res://scenes/career/qualifying.tscn")


func start_race(track_id: String) -> void:
	selected_track_id = track_id
	session_type = "race"
	go_to("res://scenes/race/race_world.tscn")


func finish_race(results: Array) -> void:
	CareerManager.record_race_results(selected_track_id, selected_weekend_index, results)
	SaveManager.save_career(career)
	go_to("res://scenes/race/post_race.tscn", false)


func load_career_and_go() -> void:
	career = SaveManager.load_career()
	if career == null:
		go_to("res://scenes/main_menu/main_menu.tscn", false)
	else:
		CareerManager.set_career(career)
		go_to("res://scenes/career/career_hub.tscn", false)
