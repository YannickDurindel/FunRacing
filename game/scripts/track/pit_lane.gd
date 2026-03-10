extends Area3D

# Pit lane trigger area


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_car_entered)
	body_exited.connect(_on_car_exited)


func _on_car_entered(body: Node3D) -> void:
	if body is F1Car:
		body.pit_stop_system.enter_pit_lane()


func _on_car_exited(body: Node3D) -> void:
	if body is F1Car:
		if body.pit_stop_system.state == PitStop.State.COMPLETE:
			body.pit_stop_system.exit_pit()
