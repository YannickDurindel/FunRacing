extends Node
class_name AIDriver

# Controls a VehicleBody3D using the racing line spline

const STEERING_MAX_RAD: float = 0.2967
const THROTTLE_CORNER_THRESHOLD: float = 0.15  # rad curvature to lift throttle
const BRAKE_ZONE_DISTANCE: float = 80.0         # metres before tight corner

var _car: VehicleBody3D = null
var _racing_line: RacingLine = null
var _tire_model: TireModel = null

var skill: float = 0.80        # 0..1, affects precision
var aggression: float = 0.60   # 0..1, affects braking point
var target_speed_scale: float = 1.0  # rubber-banding factor

var _current_throttle: float = 0.0
var _current_brake: float = 0.0
var _current_steer: float = 0.0


func setup(car: VehicleBody3D, line: RacingLine, skill_val: float, aggression_val: float) -> void:
	_car = car
	_racing_line = line
	_tire_model = car.tire_model if car.has_method("_tune_wheels") else null
	skill = skill_val
	aggression = aggression_val


func _physics_process(_delta: float) -> void:
	if _car == null or _racing_line == null:
		return
	if not is_instance_valid(_car):
		return

	var data: Dictionary = RaceState.get_car_data(_car.car_id)
	if data.get("in_pit", false) or data.get("retired", false):
		_car.engine_force = 0.0
		_car.brake = 5000.0
		return

	_compute_inputs()
	_apply_inputs()


func _compute_inputs() -> void:
	var car_pos: Vector3 = _car.global_position
	var car_forward: Vector3 = -_car.global_transform.basis.z
	var speed_kmh: float = _car.linear_velocity.length() * 3.6

	# ── Steering ──────────────────────────────────────────────────
	var target: Vector3 = _racing_line.get_steering_target(car_pos, car_forward)
	var to_target: Vector3 = (target - car_pos).normalized()
	var cross: float = car_forward.cross(to_target).y
	_current_steer = clampf(cross * (2.0 + skill), -1.0, 1.0)

	# ── Curvature for throttle/brake ─────────────────────────────
	var curvature: float = _racing_line.get_curvature(car_pos)

	if curvature > THROTTLE_CORNER_THRESHOLD:
		# Lift throttle in corners, degree based on skill
		var corner_lift: float = remap(curvature, THROTTLE_CORNER_THRESHOLD, 0.8, 0.0, 1.0 - skill * 0.5)
		_current_throttle = clampf(1.0 - corner_lift, 0.3, 1.0)
		_current_brake = 0.0

		# Hard braking for very tight corners
		if curvature > 0.4 and speed_kmh > 100.0:
			_current_throttle = 0.0
			_current_brake = clampf(curvature * aggression, 0.3, 1.0)
	else:
		_current_throttle = target_speed_scale
		_current_brake = 0.0

	# ── Tire grip modification ────────────────────────────────────
	if _tire_model != null:
		_current_throttle *= _tire_model.get_grip_factor()


func _apply_inputs() -> void:
	var speed_factor: float = 1.0 - clampf(_car.linear_velocity.length() * 3.6 / 400.0, 0.0, 0.6)
	_car.steering = lerpf(_car.steering, _current_steer * STEERING_MAX_RAD * speed_factor, 0.15)

	if _current_brake > 0.01:
		_car.engine_force = 0.0
		_car.brake = _current_brake * 40000.0
	else:
		_car.brake = 0.0
		_car.engine_force = _current_throttle * _car.engine_force_max
