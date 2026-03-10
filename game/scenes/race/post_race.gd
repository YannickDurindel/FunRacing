extends Control

@onready var results_container: VBoxContainer = $ScrollContainer/ResultsContainer
@onready var btn_continue: Button = $BtnContinue
@onready var lbl_title: Label = $Title
@onready var lbl_points: Label = $PointsSummary


func _ready() -> void:
	btn_continue.pressed.connect(_on_continue)
	_populate_results()


func _populate_results() -> void:
	# Clear existing
	for child in results_container.get_children():
		child.queue_free()

	# Rebuild from RaceState car_data sorted by finish position
	var results: Array = RaceState.car_data.duplicate()
	results.sort_custom(func(a, b): return a.get("finish_time", 9999) < b.get("finish_time", 9999))

	var player_position: int = 0
	var player_points: int = 0

	for i in range(results.size()):
		var data: Dictionary = results[i]
		var pos: int = i + 1
		if data.get("is_player", false):
			player_position = pos
			player_points = PointsTable.get_points(pos)

		var row: HBoxContainer = HBoxContainer.new()
		var lbl_pos: Label = Label.new()
		lbl_pos.text = "%d." % pos
		lbl_pos.custom_minimum_size = Vector2(40, 0)

		var lbl_driver: Label = Label.new()
		lbl_driver.text = data.get("driver_id", "Unknown")
		lbl_driver.custom_minimum_size = Vector2(200, 0)
		if data.get("is_player", false):
			lbl_driver.modulate = Color.CYAN

		var lbl_pts: Label = Label.new()
		lbl_pts.text = "+%d pts" % PointsTable.get_points(pos)
		lbl_pts.custom_minimum_size = Vector2(80, 0)

		var lbl_time: Label = Label.new()
		lbl_time.text = LapTimer.format(data.get("finish_time", 0.0))

		row.add_child(lbl_pos)
		row.add_child(lbl_driver)
		row.add_child(lbl_pts)
		row.add_child(lbl_time)
		results_container.add_child(row)

	lbl_title.text = "Race Results — P%d" % player_position
	lbl_points.text = "+%d Championship Points" % player_points


func _on_continue() -> void:
	if CareerManager.is_season_complete():
		# Season complete!
		GameState.go_to("res://scenes/career/career_hub.tscn", false)
	else:
		GameState.go_to("res://scenes/career/career_hub.tscn", false)
