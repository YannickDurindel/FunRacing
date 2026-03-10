extends Node
class_name RacingLine

const LOOKAHEAD_DISTANCE: float = 20.0   # metres ahead on spline
const LATERAL_OFFSET_MAX: float = 1.5    # metres for overtake

var _curve: Curve3D = null
var _baked_length: float = 0.0
var lateral_offset: float = 0.0  # set by ai_overtake


func setup(curve: Curve3D) -> void:
	_curve = curve
	if _curve != null:
		_baked_length = _curve.get_baked_length()


func get_steering_target(car_world_pos: Vector3, car_forward: Vector3) -> Vector3:
	if _curve == null or _baked_length < 1.0:
		return car_world_pos + car_forward * LOOKAHEAD_DISTANCE

	var offset: float = _curve.get_closest_offset(car_world_pos)
	var lookahead_offset: float = fmod(offset + LOOKAHEAD_DISTANCE, _baked_length)
	var target: Vector3 = _curve.sample_baked(lookahead_offset, true)

	# Apply lateral offset for overtaking (perpendicular to track direction)
	if abs(lateral_offset) > 0.01:
		var tangent: Vector3 = _curve.sample_baked_with_rotation(lookahead_offset, true).basis.z
		var perp: Vector3 = tangent.cross(Vector3.UP).normalized()
		target += perp * lateral_offset

	return target


func get_curvature(car_world_pos: Vector3) -> float:
	# Estimate curvature: angle between current tangent and lookahead tangent
	if _curve == null:
		return 0.0
	var offset: float = _curve.get_closest_offset(car_world_pos)
	var t1: Transform3D = _curve.sample_baked_with_rotation(offset, true)
	var t2_offset: float = fmod(offset + LOOKAHEAD_DISTANCE, _baked_length)
	var t2: Transform3D = _curve.sample_baked_with_rotation(t2_offset, true)
	return t1.basis.z.angle_to(t2.basis.z)


func get_progress_ratio(world_pos: Vector3) -> float:
	if _curve == null:
		return 0.0
	var offset: float = _curve.get_closest_offset(world_pos)
	return offset / _baked_length
