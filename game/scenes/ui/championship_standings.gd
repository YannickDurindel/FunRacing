extends Control

@onready var standings_container: VBoxContainer = $ScrollContainer/StandingsContainer
@onready var btn_back: Button = $BtnBack


func _ready() -> void:
	btn_back.pressed.connect(func(): GameState.go_back())
	_populate()


func _populate() -> void:
	for child in standings_container.get_children():
		child.queue_free()

	var career = GameState.career
	if career == null:
		return

	for i in range(career.driver_championship.size()):
		var entry: Dictionary = career.driver_championship[i]
		var row: HBoxContainer = HBoxContainer.new()

		var lbl_pos: Label = Label.new()
		lbl_pos.text = "%d." % (i + 1)
		lbl_pos.custom_minimum_size = Vector2(50, 0)

		var lbl_driver: Label = Label.new()
		var driver_name: String = _get_driver_name(entry["driver_id"])
		lbl_driver.text = driver_name
		lbl_driver.custom_minimum_size = Vector2(250, 0)
		if entry["driver_id"] == "player":
			lbl_driver.modulate = Color.CYAN

		var lbl_pts: Label = Label.new()
		lbl_pts.text = "%d pts" % entry.get("points", 0)
		lbl_pts.custom_minimum_size = Vector2(100, 0)
		if i == 0:
			lbl_pts.modulate = Color.GOLD

		row.add_child(lbl_pos)
		row.add_child(lbl_driver)
		row.add_child(lbl_pts)
		standings_container.add_child(row)


func _get_driver_name(driver_id: String) -> String:
	if driver_id == "player":
		var career = GameState.career
		return career.player_name if career else "Player"
	for d in SeasonGenerator.DRIVERS:
		if d["driver_id"] == driver_id:
			return d["name"]
	return driver_id
