extends Node
class_name DRSSystem

enum DRSState { UNAVAILABLE, AVAILABLE, ACTIVE }

var state: DRSState = DRSState.UNAVAILABLE
var in_drs_zone: bool = false
var gap_to_car_ahead: float = 999.0  # seconds
const DRS_GAP_THRESHOLD: float = 1.0  # must be within 1.0s

signal state_changed(new_state: DRSState)


func update(gap: float, zone_active: bool, player_wants_drs: bool, race_phase: int) -> void:
	# DRS only available during racing phase (not lap 1)
	if race_phase < 2:  # RaceState.SessionPhase.RACING == 3, but avoid circular
		_set_state(DRSState.UNAVAILABLE)
		return

	gap_to_car_ahead = gap
	in_drs_zone = zone_active

	if not zone_active:
		_set_state(DRSState.UNAVAILABLE)
		return

	if gap <= DRS_GAP_THRESHOLD:
		if player_wants_drs and state != DRSState.ACTIVE:
			_set_state(DRSState.ACTIVE)
		elif not player_wants_drs and state == DRSState.ACTIVE:
			_set_state(DRSState.AVAILABLE)
		elif state == DRSState.UNAVAILABLE:
			_set_state(DRSState.AVAILABLE)
	else:
		if state == DRSState.ACTIVE:
			_set_state(DRSState.UNAVAILABLE)
		else:
			_set_state(DRSState.UNAVAILABLE)


func is_active() -> bool:
	return state == DRSState.ACTIVE


func _set_state(new_state: DRSState) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(new_state)
