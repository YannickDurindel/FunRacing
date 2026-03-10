extends Resource
class_name TrackData

@export var track_id: String = ""
@export var track_name: String = ""
@export var track_length_m: float = 3000.0
@export var lap_record: float = 0.0

# Racing line spline (Curve3D baked into points)
@export var racing_line: Curve3D = null

# Sector boundary Transform3D (3 checkpoints)
@export var sector_transforms: Array[Transform3D] = []

# DRS zones as AABB (activation area)
@export var drs_zone_aabbs: Array[AABB] = []

# Pit lane entry/exit points
@export var pit_entry: Vector3 = Vector3.ZERO
@export var pit_exit: Vector3 = Vector3.ZERO

# 20 grid positions (Transform3D: position + facing direction)
@export var grid_positions: Array[Transform3D] = []

# Per-track recommended tire strategy (index in Compound enum)
@export var recommended_compound: int = 1  # MEDIUM


func get_baked_length() -> float:
	if racing_line == null:
		return track_length_m
	return racing_line.get_baked_length()


func get_progress_ratio(world_pos: Vector3) -> float:
	if racing_line == null:
		return 0.0
	var closest: Vector3 = racing_line.get_closest_point(world_pos)
	var offset: float = racing_line.get_closest_offset(world_pos)
	return offset / racing_line.get_baked_length()
