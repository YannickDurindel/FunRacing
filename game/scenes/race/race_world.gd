extends Node3D

const SeasonGeneratorScript = preload("res://scripts/career/season_generator.gd")

# Root scene for any race — spawns track, cars, systems

@onready var race_hud: Control = $RaceHUD
@onready var race_director_node: Node = $RaceDirector
@onready var race_session_node: Node = $RaceSession
@onready var position_tracker_node: Node = $PositionTracker
@onready var debug_overlay: CanvasLayer = $DebugOverlay

var _track_data = null
var _player_car = null
var _ai_cars: Array = []
var _all_cars: Array = []
var _ai_drivers: Array = []
var _ai_pits: Array = []

const TOTAL_LAPS: int = 10
const TRACK_SCENES: Dictionary = {
	"track_01_street":    "res://tracks/track_01_street/track_azur.tscn",
	"track_02_mixed":     "res://tracks/track_02_mixed/track_harrowstone.tscn",
	"track_03_highspeed": "res://tracks/track_03_highspeed/track_veloce.tscn",
}


func _ready() -> void:
	RaceState.reset()

	var track_id: String = GameState.selected_track_id
	if track_id.is_empty():
		track_id = "track_02_mixed"

	_load_track(track_id)
	_spawn_cars()
	_setup_systems()
	_begin_race()


func _load_track(track_id: String) -> void:
	var scene_path: String = TRACK_SCENES.get(track_id, TRACK_SCENES["track_02_mixed"])
	if ResourceLoader.exists(scene_path):
		var track_scene: PackedScene = load(scene_path)
		var track_node: Node3D = track_scene.instantiate()
		add_child(track_node)
		# Track scene should have a child with a TrackData resource export
		if track_node.has_node("TrackDataNode"):
			_track_data = track_node.get_node("TrackDataNode").track_data
	else:
		# Fallback: create a flat test track
		_track_data = _create_test_track_data()
		_create_flat_test_environment()


func _create_test_track_data() -> TrackData:
	var td: TrackData = TrackData.new()
	td.track_id = "test"
	td.track_name = "Test Oval"
	td.track_length_m = 800.0
	# Simple oval racing line
	td.racing_line = Curve3D.new()
	var oval_points: Array = [
		Vector3(0, 0.1, 0),
		Vector3(100, 0.1, -50),
		Vector3(200, 0.1, 0),
		Vector3(200, 0.1, 100),
		Vector3(100, 0.1, 150),
		Vector3(0, 0.1, 100),
	]
	for p in oval_points:
		td.racing_line.add_point(p)
	td.racing_line.add_point(oval_points[0])  # close loop
	# Grid positions along start line
	for i in range(20):
		var row: int = i / 2
		var side: float = -1.0 if i % 2 == 0 else 1.0
		var pos: Vector3 = Vector3(side * 3.5, 0.5, -row * 8.0)
		td.grid_positions.append(Transform3D(Basis.IDENTITY, pos))
	return td


func _create_flat_test_environment() -> void:
	var ground: StaticBody3D = StaticBody3D.new()
	var mesh_inst: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(1000, 1000)
	mesh_inst.mesh = plane
	var col: CollisionShape3D = CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	(col.shape as BoxShape3D).size = Vector3(1000, 0.1, 1000)
	col.position = Vector3(0, -0.05, 0)
	ground.add_child(mesh_inst)
	ground.add_child(col)
	ground.collision_layer = 1
	add_child(ground)

	# Ambient light
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_energy = 1.5
	add_child(sun)

	var env_node: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky: Sky = Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env_node.environment = env
	add_child(env_node)


func _spawn_cars() -> void:
	var career = GameState.career
	var grid: Array[Transform3D] = _track_data.grid_positions if _track_data else []

	# Get player qualifying position (1 if not set)
	var player_grid_pos: int = 0
	if career != null:
		var event: Dictionary = CareerManager.get_next_event()
		var qpos = event.get("qualifying_position", null)
		if qpos != null:
			player_grid_pos = int(qpos) - 1

	# Spawn player car
	_player_car = _create_box_car(0, true, "player", "team_aurora", Color(0.1, 0.4, 0.9))
	if grid.size() > player_grid_pos:
		_player_car.global_transform = grid[player_grid_pos]
	else:
		_player_car.global_position = Vector3(0, 0.5, 0)
	add_child(_player_car)
	_all_cars.append(_player_car)
	RaceState.register_car(0, true, "player", "team_aurora")

	# Apply upgrades
	if career != null:
		_player_car.apply_upgrades(career)

	# Spawn AI cars
	var ai_grid_index: int = 0
	for i in range(SeasonGeneratorScript.DRIVERS.size()):
		var driver: Dictionary = SeasonGeneratorScript.DRIVERS[i]
		var car_id: int = i + 1

		# Skip player grid slot
		while ai_grid_index == player_grid_pos:
			ai_grid_index += 1

		var team_color: Color = _team_color(driver["team_id"])
		var ai_car: F1Car = _create_box_car(car_id, false, driver["driver_id"], driver["team_id"], team_color)

		if grid.size() > ai_grid_index:
			ai_car.global_transform = grid[ai_grid_index]
		else:
			ai_car.global_position = Vector3(float(ai_grid_index) * 3.0 - 30.0, 0.5, -float(ai_grid_index / 2) * 8.0)

		add_child(ai_car)
		_ai_cars.append(ai_car)
		_all_cars.append(ai_car)
		RaceState.register_car(car_id, false, driver["driver_id"], driver["team_id"])
		ai_grid_index += 1

	# Spawn AI drivers & pit strategy
	for i in range(_ai_cars.size()):
		var driver: Dictionary = SeasonGeneratorScript.DRIVERS[i]
		var ai_drv: AIDriver = AIDriver.new()
		var racing_line_node: RacingLine = RacingLine.new()
		if _track_data != null and _track_data.racing_line != null:
			racing_line_node.setup(_track_data.racing_line)
		ai_drv.setup(_ai_cars[i], racing_line_node, driver["skill"], driver["aggression"])
		add_child(racing_line_node)
		add_child(ai_drv)
		_ai_drivers.append(ai_drv)

		var pit: AIPitStrategy = AIPitStrategy.new()
		pit.setup(_ai_cars[i], TOTAL_LAPS, TireModel.Compound.MEDIUM)
		add_child(pit)
		_ai_pits.append(pit)

	# Camera follow player
	var cam: Camera3D = Camera3D.new()
	cam.position = Vector3(0, 2.5, 6.0)
	cam.rotation_degrees.x = -15.0
	_player_car.add_child(cam)
	cam.make_current()


func _create_box_car(car_id: int, is_player_car: bool, driver_id: String, team_id: String, color: Color) -> F1Car:
	var car: F1Car = F1Car.new()
	car.car_id = car_id
	car.is_player = is_player_car
	car.driver_id = driver_id
	car.team_id = team_id
	car.collision_layer = 2
	car.collision_mask = 1  # collide with world

	# Body mesh
	var body_mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(1.8, 0.6, 4.2)
	body_mesh.mesh = box
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.9
	mat.roughness = 0.15
	body_mesh.set_surface_override_material(0, mat)
	body_mesh.position.y = 0.3
	car.add_child(body_mesh)

	# Collision shape
	var col: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(1.8, 0.7, 4.2)
	col.shape = col_box
	col.position.y = 0.35
	car.add_child(col)

	# Wheels (must be direct children of VehicleBody3D)
	var wheel_positions: Array = [
		{"pos": Vector3(-0.85, 0, -1.4), "drive": true,  "steer": true},
		{"pos": Vector3( 0.85, 0, -1.4), "drive": true,  "steer": true},
		{"pos": Vector3(-0.85, 0,  1.4), "drive": true,  "steer": false},
		{"pos": Vector3( 0.85, 0,  1.4), "drive": true,  "steer": false},
	]
	for wp in wheel_positions:
		var wheel: VehicleWheel3D = VehicleWheel3D.new()
		wheel.position = wp["pos"]
		wheel.use_as_traction = wp["drive"]
		wheel.use_as_steering = wp["steer"]
		wheel.wheel_radius = 0.33
		wheel.wheel_friction_slip = 2.8
		wheel.suspension_stiffness = 80.0
		wheel.suspension_travel = 0.03
		wheel.suspension_rest_length = 0.18
		wheel.damping_compression = 0.4
		wheel.damping_relaxation = 0.5
		# Wheel visual mesh
		var wmesh: MeshInstance3D = MeshInstance3D.new()
		var cyl: CylinderMesh = CylinderMesh.new()
		cyl.top_radius = 0.33
		cyl.bottom_radius = 0.33
		cyl.height = 0.28
		wmesh.mesh = cyl
		wmesh.rotation_degrees.z = 90.0
		var wmat: StandardMaterial3D = StandardMaterial3D.new()
		wmat.albedo_color = Color(0.1, 0.1, 0.1)
		wmesh.set_surface_override_material(0, wmat)
		wheel.add_child(wmesh)
		car.add_child(wheel)

	return car


func _setup_systems() -> void:
	race_session_node.setup(TOTAL_LAPS)
	race_session_node.race_complete.connect(_on_race_complete)

	if _track_data != null:
		position_tracker_node.setup(_track_data, _all_cars)

	# Connect player input
	if _player_car != null:
		set_physics_process(true)


func _begin_race() -> void:
	await get_tree().create_timer(1.0).timeout
	race_director_node.begin_start_sequence()
	race_director_node.lights_out.connect(_on_lights_out)


func _on_lights_out() -> void:
	# Enable player input
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	if _player_car == null:
		return
	if RaceState.phase != RaceState.SessionPhase.RACING:
		_player_car.input_throttle = 0.0
		_player_car.input_brake = 1.0
		return

	# Keyboard fallback
	var kbd_steer: float = 0.0
	if Input.is_action_pressed("steer_left"):
		kbd_steer = -1.0
	elif Input.is_action_pressed("steer_right"):
		kbd_steer = 1.0

	var kbd_throttle: float = 1.0 if Input.is_action_pressed("accelerate") else 0.0
	var kbd_brake: float = 1.0 if Input.is_action_pressed("brake") else 0.0

	# Phone input overrides keyboard if connected
	if ControllerServer.is_phone_connected():
		_player_car.input_steering = ControllerServer.steering
		_player_car.input_throttle = ControllerServer.throttle
		_player_car.input_brake = ControllerServer.brake
		_player_car.input_drs = ControllerServer.drs_pressed
		_player_car.input_ers = ControllerServer.ers_pressed
	else:
		_player_car.input_steering = kbd_steer
		_player_car.input_throttle = kbd_throttle
		_player_car.input_brake = kbd_brake
		_player_car.input_drs = Input.is_action_pressed("drs_toggle")
		_player_car.input_ers = Input.is_action_pressed("ers_boost")

	# Check lap completion for pit strategy
	var player_data: Dictionary = RaceState.get_car_data(0)
	var current_lap: int = player_data.get("laps_completed", 0)
	for pit in _ai_pits:
		pit.check_pit(current_lap)

	# Rubber-banding: scale AI target speed
	var player_pos: int = player_data.get("position", 10)
	var rb_scale: float = 1.0 + (float(player_pos - 1) * 0.005)
	for ai_drv in _ai_drivers:
		ai_drv.target_speed_scale = rb_scale


func _on_race_complete(results: Array) -> void:
	# Convert to driver_id indexed results
	var driver_results: Array = []
	for r in results:
		driver_results.append({
			"driver_id": r["driver_id"],
			"position": r["position"]
		})
	GameState.finish_race(driver_results)
