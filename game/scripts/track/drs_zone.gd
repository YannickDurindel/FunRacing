extends Area3D

# DRS activation zone — notifies cars that enter/exit
# Cars layer=2, this Area3D mask=2


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # detect cars
	body_entered.connect(_on_car_entered)
	body_exited.connect(_on_car_exited)


func _on_car_entered(body: Node3D) -> void:
	if body is F1Car:
		body.set_drs_zone(true)


func _on_car_exited(body: Node3D) -> void:
	if body is F1Car:
		body.set_drs_zone(false)
