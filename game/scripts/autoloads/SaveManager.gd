extends Node

const CareerDataScript = preload("res://scripts/career/career_data.gd")
const SAVE_PATH: String = "user://saves/career.json"
const SCHEMA_VERSION: int = 1


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("user://saves")


func save_career(career) -> bool:
	if career == null:
		push_error("SaveManager: career is null, nothing to save.")
		return false
	var data: Dictionary = career.to_dict()
	var json_text: String = JSON.stringify(data, "\t")
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open save file for writing: " + SAVE_PATH)
		return false
	file.store_string(json_text)
	file.close()
	return true


func load_career():
	if not FileAccess.file_exists(SAVE_PATH):
		return null
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: cannot open save file for reading.")
		return null
	var text: String = file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if data == null or not data is Dictionary:
		push_error("SaveManager: failed to parse save file JSON.")
		return null
	data = _migrate(data)
	return CareerDataScript.from_dict(data)


func career_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_career() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func _migrate(data: Dictionary) -> Dictionary:
	var version: int = data.get("schema_version", 0)
	# Future migrations go here as schema_version increments
	if version < SCHEMA_VERSION:
		data["schema_version"] = SCHEMA_VERSION
	return data
