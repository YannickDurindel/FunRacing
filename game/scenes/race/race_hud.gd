extends Control

# All 10 HUD elements

@onready var lbl_position: Label = $TopLeft/Position
@onready var lbl_gap_ahead: Label = $TopLeft/GapAhead
@onready var lbl_gap_behind: Label = $TopLeft/GapBehind
@onready var lbl_lap_time: Label = $TopCenter/LapTime
@onready var sector_boxes: Array = [$TopCenter/S1, $TopCenter/S2, $TopCenter/S3]
@onready var lbl_lap_counter: Label = $TopRight/LapCounter
@onready var lbl_tire_compound: Label = $BottomLeft/TireCompound
@onready var prog_tire_deg: ProgressBar = $BottomLeft/TireDeg
@onready var lbl_speed: Label = $BottomCenter/Speed
@onready var lbl_gear: Label = $BottomCenter/Gear
@onready var prog_ers: ProgressBar = $BottomRight/ERSBar
@onready var lbl_drs: Label = $BottomRight/DRSIndicator

var _player_car: F1Car = null
var _sector_timer: SectorTimer = null
var _drs_blink_time: float = 0.0
var _drs_blink_state: bool = false

const DRS_BLINK_INTERVAL: float = 0.25


func _ready() -> void:
	# Will be set by race_world after cars are spawned
	set_process(false)


func init(player_car: F1Car, sector_timer: SectorTimer) -> void:
	_player_car = player_car
	_sector_timer = sector_timer
	if _sector_timer != null:
		_sector_timer.sector_completed.connect(_on_sector_completed)
		_sector_timer.lap_completed.connect(_on_lap_completed)
	player_car.speed_updated.connect(_on_speed_updated)
	player_car.tire_degradation_changed.connect(_on_tire_deg_changed)
	set_process(true)


func _process(delta: float) -> void:
	if _player_car == null:
		return

	_update_position_display()
	_update_lap_time()
	_update_ers()
	_update_drs(delta)


func _update_position_display() -> void:
	var data: Dictionary = RaceState.get_car_data(0)
	if data.is_empty():
		return

	var pos: int = data.get("position", 0)
	lbl_position.text = "P%d" % pos

	# Gap ahead
	var sorted: Array = RaceState.sorted_positions
	var my_idx: int = sorted.find(0)
	if my_idx > 0:
		var ahead_id: int = sorted[my_idx - 1]
		var ahead_data: Dictionary = RaceState.get_car_data(ahead_id)
		var gap: float = ahead_data.get("gap_to_leader", 0.0) - data.get("gap_to_leader", 0.0)
		lbl_gap_ahead.text = LapTimer.format_gap(absf(gap))
	else:
		lbl_gap_ahead.text = "LEAD"

	# Gap behind
	if my_idx < sorted.size() - 1:
		var behind_id: int = sorted[my_idx + 1]
		var behind_data: Dictionary = RaceState.get_car_data(behind_id)
		var gap: float = data.get("gap_to_leader", 0.0) - behind_data.get("gap_to_leader", 0.0)
		lbl_gap_behind.text = LapTimer.format_gap(absf(gap))
	else:
		lbl_gap_behind.text = ""

	# Lap counter
	var laps: int = data.get("laps_completed", 0)
	lbl_lap_counter.text = "L%d/%d" % [laps + 1, RaceState.total_laps]


func _update_lap_time() -> void:
	if _sector_timer != null:
		lbl_lap_time.text = LapTimer.format(_sector_timer.get_current_lap_time())


func _on_speed_updated(kmh: float, gear: int, _rpm: float) -> void:
	lbl_speed.text = "%d" % int(kmh)
	lbl_gear.text = "G%d" % gear


func _on_tire_deg_changed(pct: float) -> void:
	prog_tire_deg.value = pct
	# Color: green < 40%, yellow 40-70%, red > 70%
	if pct < 40.0:
		prog_tire_deg.modulate = Color.GREEN
	elif pct < 70.0:
		prog_tire_deg.modulate = Color.YELLOW
	else:
		prog_tire_deg.modulate = Color.RED

	if _player_car != null:
		lbl_tire_compound.text = _player_car.tire_model.get_compound_name()


func _on_sector_completed(sector: int, _time: float, color: SectorTimer.SectorColor) -> void:
	if sector < sector_boxes.size():
		match color:
			SectorTimer.SectorColor.PURPLE: sector_boxes[sector].modulate = Color.MAGENTA
			SectorTimer.SectorColor.GREEN:  sector_boxes[sector].modulate = Color.GREEN
			SectorTimer.SectorColor.YELLOW: sector_boxes[sector].modulate = Color.YELLOW
			_: sector_boxes[sector].modulate = Color.WHITE
		# Reset after 3s
		var box = sector_boxes[sector]
		await get_tree().create_timer(3.0).timeout
		if is_instance_valid(box):
			box.modulate = Color.WHITE


func _on_lap_completed(_time: float, _is_pb: bool) -> void:
	# Reset sector colours
	for box in sector_boxes:
		if is_instance_valid(box):
			box.modulate = Color.WHITE


func _update_ers() -> void:
	if _player_car == null or _player_car.ers_system == null:
		return
	prog_ers.value = _player_car.ers_system.get_charge_percent()


func _update_drs(delta: float) -> void:
	if _player_car == null or _player_car.drs_system == null:
		return
	match _player_car.drs_system.state:
		DRSSystem.DRSState.UNAVAILABLE:
			lbl_drs.text = "DRS"
			lbl_drs.modulate = Color.GRAY
		DRSSystem.DRSState.AVAILABLE:
			lbl_drs.text = "DRS"
			lbl_drs.modulate = Color.GREEN
		DRSSystem.DRSState.ACTIVE:
			_drs_blink_time += delta
			if _drs_blink_time >= DRS_BLINK_INTERVAL:
				_drs_blink_time -= DRS_BLINK_INTERVAL
				_drs_blink_state = not _drs_blink_state
			lbl_drs.text = "DRS"
			lbl_drs.modulate = Color.GREEN if _drs_blink_state else Color(0, 0.5, 0, 1)
