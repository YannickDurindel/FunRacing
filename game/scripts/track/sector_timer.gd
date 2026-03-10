extends Node

enum SectorColor { WHITE, GREEN, PURPLE, YELLOW }

var _sector_start_time: float = 0.0
var _current_sector: int = 0
var _lap_start_time: float = 0.0
var _personal_best_sectors: Array[float] = [INF, INF, INF]
var _personal_best_lap: float = INF
var _sector_times: Array[float] = [0.0, 0.0, 0.0]

signal sector_completed(sector: int, time: float, color: SectorColor)
signal lap_completed(total_time: float, is_personal_best: bool)


func start_lap() -> void:
	_lap_start_time = Time.get_ticks_msec() / 1000.0
	_sector_start_time = _lap_start_time
	_current_sector = 0


func on_sector_crossed(sector_index: int) -> void:
	if sector_index != _current_sector:
		return
	var now: float = Time.get_ticks_msec() / 1000.0
	var sector_time: float = now - _sector_start_time
	_sector_times[_current_sector] = sector_time

	var color: SectorColor = _classify_sector(sector_index, sector_time)
	if sector_time < _personal_best_sectors[_current_sector]:
		_personal_best_sectors[_current_sector] = sector_time

	sector_completed.emit(_current_sector, sector_time, color)
	_sector_start_time = now
	_current_sector = (_current_sector + 1) % 3

	if _current_sector == 0:
		_finish_lap(now)


func _finish_lap(now: float) -> void:
	var lap_time: float = now - _lap_start_time
	var is_pb: bool = lap_time < _personal_best_lap
	if is_pb:
		_personal_best_lap = lap_time
		RaceState.overall_best_lap = minf(RaceState.overall_best_lap, lap_time)
	lap_completed.emit(lap_time, is_pb)
	_lap_start_time = now


func _classify_sector(sector: int, time: float) -> SectorColor:
	if time < RaceState.overall_best_sectors[sector]:
		RaceState.update_sector_best(sector, time)
		return SectorColor.PURPLE
	elif time < _personal_best_sectors[sector]:
		return SectorColor.GREEN
	else:
		return SectorColor.YELLOW


func get_current_lap_time() -> float:
	return Time.get_ticks_msec() / 1000.0 - _lap_start_time


func get_personal_best() -> float:
	return _personal_best_lap
