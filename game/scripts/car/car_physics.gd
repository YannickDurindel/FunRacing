extends Node
class_name CarPhysics

# Aerodynamic constants
const DOWNFORCE_COEFFICIENT: float = 3.0    # N per (m/s)²
const DRAG_COEFFICIENT_BASE: float = 0.45   # drag coefficient

# DRS removes ~15% drag
const DRS_DRAG_REDUCTION: float = 0.15

var drag_coefficient: float = DRAG_COEFFICIENT_BASE
var downforce_coefficient: float = DOWNFORCE_COEFFICIENT


func apply_aerodynamics(body: VehicleBody3D, speed_mps: float, drs_active: bool) -> void:
	var drag_coeff: float = drag_coefficient
	if drs_active:
		drag_coeff *= (1.0 - DRS_DRAG_REDUCTION)

	var downforce: float = speed_mps * speed_mps * downforce_coefficient
	var drag: float = speed_mps * speed_mps * drag_coeff

	# Downforce pushes car into ground (negative Y)
	body.apply_central_force(Vector3(0.0, -downforce, 0.0))

	# Drag opposes velocity
	var vel: Vector3 = body.linear_velocity
	if vel.length() > 0.1:
		body.apply_central_force(-vel.normalized() * drag)


func apply_upgrade_multipliers(engine_lvl: int, aero_lvl: int, brakes_lvl: int,
								tires_lvl: int, ers_lvl: int) -> void:
	# Aero upgrade affects coefficients
	var aero_mult: float = 1.0 + aero_lvl * 0.05
	downforce_coefficient = DOWNFORCE_COEFFICIENT * aero_mult
	drag_coefficient = DRAG_COEFFICIENT_BASE * (1.0 + aero_lvl * 0.02)
