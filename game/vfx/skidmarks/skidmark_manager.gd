extends Node3D

# Pool of 20 Decal nodes — oldest recycled when pool is full
const POOL_SIZE: int = 20
const SKID_THRESHOLD: float = 0.4  # get_skidinfo() < 0.4 means skidding

var _decals: Array[Decal] = []
var _decal_index: int = 0


func _ready() -> void:
	_build_pool()


func _build_pool() -> void:
	for i in range(POOL_SIZE):
		var decal: Decal = Decal.new()
		decal.size = Vector3(0.3, 1.0, 0.8)
		decal.cull_mask = 1
		decal.visible = false
		# Decal material: dark tyre mark
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.05, 0.05, 0.05, 0.7)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		decal.albedo_mix = 0.8
		add_child(decal)
		_decals.append(decal)


func place_skidmark(world_pos: Vector3, orientation: Basis) -> void:
	var decal: Decal = _decals[_decal_index]
	decal.global_position = world_pos
	decal.global_transform.basis = orientation
	decal.visible = true
	_decal_index = (_decal_index + 1) % POOL_SIZE


func update_car_skids(car: VehicleBody3D) -> void:
	for child in car.get_children():
		if not child is VehicleWheel3D:
			continue
		# get_skidinfo() INVERTED: 0=skidding, 1=no skid
		if child.get_skidinfo() < SKID_THRESHOLD:
			var wheel_pos: Vector3 = child.global_position
			wheel_pos.y = 0.01  # just above ground
			place_skidmark(wheel_pos, car.global_transform.basis)
