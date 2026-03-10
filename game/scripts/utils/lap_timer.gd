extends Node
class_name LapTimer

var _start: float = 0.0
var _running: bool = false


func start() -> void:
	_start = Time.get_ticks_msec() / 1000.0
	_running = true


func stop() -> float:
	_running = false
	return elapsed()


func elapsed() -> float:
	if not _running:
		return 0.0
	return Time.get_ticks_msec() / 1000.0 - _start


static func format(seconds: float) -> String:
	if seconds <= 0.0 or seconds == INF:
		return "--:--.---"
	var m: int = int(seconds) / 60
	var s: int = int(seconds) % 60
	var ms: int = int(fmod(seconds, 1.0) * 1000)
	return "%d:%02d.%03d" % [m, s, ms]


static func format_gap(seconds: float) -> String:
	if seconds >= 999.0:
		return "LAP"
	if seconds <= 0.0:
		return "+0.000"
	return "+%.3f" % seconds
