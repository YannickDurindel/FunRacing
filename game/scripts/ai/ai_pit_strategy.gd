extends Node

# Predetermined pit window for each AI car

var _car: VehicleBody3D = null
var pit_lap: int = 0          # lap on which to pit
var pit_compound: TireModel.Compound = TireModel.Compound.MEDIUM
var has_pitted: bool = false


func setup(car: VehicleBody3D, total_laps: int, compound: TireModel.Compound) -> void:
	_car = car
	pit_compound = compound
	# Pit between lap 40%–65% of race, with slight random variation
	var mid: float = total_laps * 0.525
	pit_lap = int(mid + randf_range(-2.0, 3.0))
	pit_lap = clampi(pit_lap, 3, total_laps - 2)


func check_pit(current_lap: int) -> void:
	if has_pitted:
		return
	if current_lap >= pit_lap:
		has_pitted = true
		var data: Dictionary = RaceState.get_car_data(_car.car_id)
		if not data.is_empty():
			data["in_pit"] = true
			data["tire_compound"] = _compound_name(pit_compound)
			data["tire_laps"] = 0
			data["tire_deg"] = 0.0
		# Simulate pit stop: after 2.5s car rejoins
		if _car.has_method("pit_stop_system"):
			_car.pit_stop_system.new_compound = pit_compound
			_car.pit_stop_system.enter_pit_lane()
		# For pure AI sim: just apply new compound directly after delay
		_apply_pit_async()


func _apply_pit_async() -> void:
	await get_tree().create_timer(2.5).timeout
	if _car == null or not is_instance_valid(_car):
		return
	var data: Dictionary = RaceState.get_car_data(_car.car_id)
	if not data.is_empty():
		data["in_pit"] = false
	if _car.has_node("TireModel"):
		var tm: TireModel = _car.get_node("TireModel")
		tm.set_compound(pit_compound)


func _compound_name(c: TireModel.Compound) -> String:
	match c:
		TireModel.Compound.SOFT:   return "soft"
		TireModel.Compound.MEDIUM: return "medium"
		TireModel.Compound.HARD:   return "hard"
	return "medium"
