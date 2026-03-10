extends CanvasLayer

var _label: RichTextLabel = null
var _enabled: bool = false


func _ready() -> void:
	layer = 100
	_label = RichTextLabel.new()
	_label.anchors_preset = Control.PRESET_TOP_LEFT
	_label.position = Vector2(10, 10)
	_label.size = Vector2(400, 300)
	_label.bbcode_enabled = true
	_label.modulate = Color(1, 1, 1, 0.8)
	add_child(_label)
	visible = false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		_enabled = not _enabled
		visible = _enabled


func _process(_delta: float) -> void:
	if not _enabled:
		return
	var lines: Array = []
	lines.append("[color=yellow]FunRacing Debug[/color]")
	lines.append("FPS: %d" % int(Engine.get_frames_per_second()))
	lines.append("Phase: %s" % RaceState.SessionPhase.keys()[RaceState.phase])
	lines.append("Elapsed: %.1fs" % RaceState.race_elapsed)
	lines.append("Cars: %d" % RaceState.car_data.size())
	if not RaceState.sorted_positions.is_empty():
		var leader_id: int = RaceState.sorted_positions[0]
		var ld: Dictionary = RaceState.get_car_data(leader_id)
		if not ld.is_empty():
			lines.append("Leader: %s L%d" % [ld.get("driver_id","?"), ld.get("laps_completed",0)])
	_label.text = "\n".join(lines)
