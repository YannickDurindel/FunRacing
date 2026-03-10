extends VehicleBody3D
class_name F1Car

# ── Physics Constants ──────────────────────────────────────────────
const MASS_KG: float = 740.0
const ENGINE_FORCE_MAX: float = 27000.0   # Newtons
const BRAKE_FORCE_MAX: float = 40000.0
const STEERING_MAX_RAD: float = 0.2967    # 17 degrees in radians

# ── Sub-systems (set up in _ready) ────────────────────────────────
var physics_system: CarPhysics = null
var tire_model: TireModel = null
var drs_system: DRSSystem = null
var ers_system: ERSSystem = null
var pit_stop_system: PitStop = null

# ── State ─────────────────────────────────────────────────────────
var car_id: int = 0
var is_player: bool = false
var driver_id: String = "player"
var team_id: String = "team_aurora"

var current_speed_mps: float = 0.0
var current_speed_kmh: float = 0.0
var current_gear: int = 1
var current_rpm: float = 800.0
var engine_force_max: float = ENGINE_FORCE_MAX
var brake_force_max: float = BRAKE_FORCE_MAX

# ── Upgrade multipliers ────────────────────────────────────────────
var upgrade_engine_level: int = 0
var upgrade_brakes_level: int = 0

# ── Input (set by f1_car.gd each physics tick) ────────────────────
var input_throttle: float = 0.0
var input_brake: float = 0.0
var input_steering: float = 0.0   # -1..1
var input_drs: bool = false
var input_ers: bool = false

signal speed_updated(kmh: float, gear: int, rpm: float)
signal tire_degradation_changed(pct: float)


func _ready() -> void:
	mass = MASS_KG

	# Create subsystems
	physics_system = CarPhysics.new()
	tire_model = TireModel.new()
	drs_system = DRSSystem.new()
	ers_system = ERSSystem.new()
	pit_stop_system = PitStop.new()

	add_child(physics_system)
	add_child(tire_model)
	add_child(drs_system)
	add_child(ers_system)
	add_child(pit_stop_system)

	# Connect signals
	pit_stop_system.pit_stop_complete.connect(_on_pit_stop_complete)

	# Wheel tuning (wheels must be direct children added in scene)
	_tune_wheels()


func _tune_wheels() -> void:
	for child in get_children():
		if child is VehicleWheel3D:
			child.wheel_friction_slip = 2.8 * tire_model.get_grip_factor()
			child.suspension_stiffness = 80.0
			child.suspension_travel = 0.03
			child.suspension_rest_length = 0.18
			child.damping_compression = 0.4
			child.damping_relaxation = 0.5


func _physics_process(delta: float) -> void:
	current_speed_mps = linear_velocity.length()
	current_speed_kmh = current_speed_mps * 3.6
	_update_gear()
	_update_rpm()

	if pit_stop_system.is_in_pit():
		_handle_pit_mode(delta)
		return

	_apply_steering()
	_apply_drive_forces(delta)
	physics_system.apply_aerodynamics(self, current_speed_mps, drs_system.is_active())
	ers_system.get_boost_force(self)
	_update_tire_friction()
	_broadcast_audio()

	speed_updated.emit(current_speed_kmh, current_gear, current_rpm)


func _apply_steering() -> void:
	var target_steer: float = input_steering * STEERING_MAX_RAD
	# Reduce steering at high speed
	var speed_factor: float = 1.0 - clampf(current_speed_kmh / 400.0, 0.0, 0.6)
	steering = lerpf(steering, target_steer * speed_factor, 0.2)


func _apply_drive_forces(delta: float) -> void:
	var is_braking: bool = input_brake > 0.01

	# ERS regen/boost
	ers_system.update(delta, is_braking, input_ers)
	# DRS
	var gap: float = _get_gap_to_car_ahead()
	drs_system.update(gap, _in_drs_zone(), input_drs, int(RaceState.phase))

	if is_braking:
		engine_force = 0.0
		brake = input_brake * brake_force_max
	else:
		brake = 0.0
		var grip_factor: float = tire_model.get_grip_factor()
		engine_force = input_throttle * engine_force_max * grip_factor


func _handle_pit_mode(delta: float) -> void:
	# Speed limiter in pit lane
	engine_force = 0.0
	brake = 0.0
	steering = 0.0
	if current_speed_mps > PitStop.PIT_SPEED_LIMIT:
		brake = brake_force_max * 0.3
	pit_stop_system.update(delta, current_speed_mps)


func _update_gear() -> void:
	# Simple 7-speed simulation based on speed
	var thresholds: Array = [0, 50, 100, 150, 200, 250, 300]
	current_gear = 1
	for i in range(thresholds.size() - 1):
		if current_speed_kmh > thresholds[i]:
			current_gear = i + 1


func _update_rpm() -> void:
	var gear_ratios: Array = [3.5, 2.5, 1.8, 1.4, 1.1, 0.9, 0.75]
	var ratio: float = gear_ratios[current_gear - 1]
	current_rpm = clampf(current_speed_mps * ratio * 180.0 + 800.0, 800.0, 18000.0)
	if is_player:
		AudioManager.set_rpm(current_rpm)


func _update_tire_friction() -> void:
	var grip: float = tire_model.get_grip_factor()
	for child in get_children():
		if child is VehicleWheel3D:
			child.wheel_friction_slip = 2.8 * grip


func _get_gap_to_car_ahead() -> float:
	if not is_player:
		return 999.0
	# RaceState provides pre-calculated gap
	var data: Dictionary = RaceState.get_car_data(car_id)
	if data.is_empty():
		return 999.0
	return data.get("gap_to_leader", 999.0)


func _in_drs_zone() -> bool:
	# Set externally by drs_zone.gd area triggers
	return false  # Overridden via property


var _in_drs_zone_flag: bool = false


func set_drs_zone(active: bool) -> void:
	_in_drs_zone_flag = active


func _broadcast_audio() -> void:
	if is_player:
		AudioManager.set_throttle_and_speed(input_throttle, current_speed_kmh)


func on_lap_completed() -> void:
	tire_model.on_lap_completed()
	tire_degradation_changed.emit(tire_model.get_deg_percentage())


func _on_pit_stop_complete(compound: TireModel.Compound) -> void:
	tire_model.set_compound(compound)
	pit_stop_system.exit_pit()


func apply_upgrades(career: CareerData) -> void:
	upgrade_engine_level = career.upgrades["engine"]["level"]
	upgrade_brakes_level = career.upgrades["brakes"]["level"]

	engine_force_max = ENGINE_FORCE_MAX
	for i in range(upgrade_engine_level):
		engine_force_max *= 1.03

	brake_force_max = BRAKE_FORCE_MAX
	for i in range(upgrade_brakes_level):
		brake_force_max *= 1.08

	physics_system.apply_upgrade_multipliers(
		career.upgrades["engine"]["level"],
		career.upgrades["aero"]["level"],
		career.upgrades["brakes"]["level"],
		career.upgrades["tires"]["level"],
		career.upgrades["ers"]["level"]
	)
	tire_model.apply_tire_upgrade(career.upgrades["tires"]["level"])
	ers_system.apply_ers_upgrade(career.upgrades["ers"]["level"])
