extends Control

# Single hot lap qualifying session

@onready var lbl_time: Label = $CenterPanel/LapTime
@onready var lbl_best: Label = $CenterPanel/BestTime
@onready var lbl_position: Label = $CenterPanel/QualPosition
@onready var btn_restart: Button = $CenterPanel/BtnRestart
@onready var btn_start_race: Button = $CenterPanel/BtnStartRace
@onready var lbl_countdown: Label = $CenterPanel/Countdown

var _lap_timer: LapTimer = LapTimer.new()
var _best_time: float = INF
var _lap_running: bool = false
var _ai_times: Array = []
var _countdown: float = 5.0
var _counting_down: bool = true


func _ready() -> void:
	add_child(_lap_timer)
	btn_restart.pressed.connect(_restart_lap)
	btn_start_race.pressed.connect(_go_to_race)
	btn_start_race.disabled = true

	# Generate AI qualifying times
	_generate_ai_times()
	_start_countdown()


func _generate_ai_times() -> void:
	# Base Q time for each track
	var base_time: float = 85.0  # ~1:25 for medium circuit
	_ai_times.clear()
	for driver in SeasonGenerator.DRIVERS:
		var skill: float = driver["skill"]
		# Better skill = faster lap, with some randomness
		var time: float = base_time / skill + randf_range(-1.5, 2.0)
		_ai_times.append({"driver_id": driver["driver_id"], "time": time})
	_ai_times.sort_custom(func(a, b): return a["time"] < b["time"])


func _start_countdown() -> void:
	_counting_down = true
	_countdown = 5.0
	lbl_countdown.visible = true
	btn_restart.disabled = true


func _process(delta: float) -> void:
	if _counting_down:
		_countdown -= delta
		lbl_countdown.text = "Qualifying starts in: %d" % ceili(_countdown)
		if _countdown <= 0.0:
			_counting_down = false
			lbl_countdown.visible = false
			btn_restart.disabled = false
			_restart_lap()
		return

	if _lap_running:
		lbl_time.text = LapTimer.format(_lap_timer.elapsed())


func _restart_lap() -> void:
	_lap_running = true
	_lap_timer.start()
	lbl_time.text = "0:00.000"


func on_lap_completed() -> void:
	# Call this from a finish line Area3D trigger in the qualifying scene
	if not _lap_running:
		return
	var lap: float = _lap_timer.stop()
	_lap_running = false

	if lap < _best_time:
		_best_time = lap
		lbl_best.text = "Best: " + LapTimer.format(_best_time)
		_update_position()
		btn_start_race.disabled = false


func _update_position() -> void:
	var position: int = 1
	for ai in _ai_times:
		if ai["time"] < _best_time:
			position += 1
	lbl_position.text = "P%d / 20" % position

	# Save qualifying result
	var event_index: int = GameState.selected_weekend_index
	CareerManager.record_qualifying(GameState.selected_track_id, event_index, position)


func _go_to_race() -> void:
	GameState.start_race(GameState.selected_track_id)
