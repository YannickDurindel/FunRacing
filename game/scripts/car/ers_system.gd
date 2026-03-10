extends Node
class_name ERSSystem

const MAX_CHARGE: float = 4000.0       # kJ
const REGEN_RATE: float = 150.0        # kJ per second under braking
const BOOST_FORCE: float = 15000.0     # Newtons (applied as central force)
const BOOST_DRAIN_RATE: float = 300.0  # kJ per second when boosting
const BOOST_MIN_CHARGE: float = 200.0  # Minimum charge to activate

var charge: float = MAX_CHARGE
var is_boosting: bool = false
var max_charge: float = MAX_CHARGE  # modified by upgrades


func _ready() -> void:
	charge = max_charge


func update(delta: float, is_braking: bool, boost_requested: bool) -> void:
	if is_braking:
		charge = minf(charge + REGEN_RATE * delta, max_charge)
		is_boosting = false
	elif boost_requested and charge >= BOOST_MIN_CHARGE:
		charge = maxf(charge - BOOST_DRAIN_RATE * delta, 0.0)
		is_boosting = true
	else:
		is_boosting = false


func get_boost_force(body: VehicleBody3D) -> void:
	if not is_boosting:
		return
	# Apply forward boost force in car's local forward direction
	var forward: Vector3 = -body.global_transform.basis.z
	body.apply_central_force(forward * BOOST_FORCE)


func get_charge_percent() -> float:
	return (charge / max_charge) * 100.0


func apply_ers_upgrade(level: int) -> void:
	max_charge = MAX_CHARGE + level * 400.0  # +400 kJ per level
	charge = minf(charge, max_charge)
