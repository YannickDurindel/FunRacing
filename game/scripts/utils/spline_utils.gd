extends Node
class_name SplineUtils


static func build_curve_from_points(points: Array) -> Curve3D:
	var curve: Curve3D = Curve3D.new()
	curve.bake_interval = 0.5
	for p in points:
		curve.add_point(p)
	# Close the loop: connect last point back to first
	if points.size() > 1:
		curve.add_point(points[0])
	return curve


static func sample_evenly(curve: Curve3D, count: int) -> Array:
	var result: Array = []
	var length: float = curve.get_baked_length()
	for i in range(count):
		var offset: float = (float(i) / float(count)) * length
		result.append(curve.sample_baked(offset, true))
	return result


static func get_forward_at_offset(curve: Curve3D, offset: float) -> Vector3:
	var t: Transform3D = curve.sample_baked_with_rotation(offset, true)
	return -t.basis.z
