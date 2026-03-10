extends Control

const PROFILE_PATH: String = "user://profile.json"

# ── 2025/2026 F1 Driver Grid ──────────────────────────────────────────────────
# {name, short, number, team, team_color (hex), flag}
const DRIVERS: Array = [
	# Red Bull
	{"name":"Max Verstappen",       "short":"VER","number":1,  "team":"Red Bull Racing",  "color":"1E3B6B","flag":"🇳🇱"},
	{"name":"Liam Lawson",          "short":"LAW","number":30, "team":"Red Bull Racing",  "color":"1E3B6B","flag":"🇳🇿"},
	# Ferrari
	{"name":"Charles Leclerc",      "short":"LEC","number":16, "team":"Ferrari",          "color":"DC0000","flag":"🇲🇨"},
	{"name":"Lewis Hamilton",       "short":"HAM","number":44, "team":"Ferrari",          "color":"DC0000","flag":"🇬🇧"},
	# Mercedes
	{"name":"George Russell",       "short":"RUS","number":63, "team":"Mercedes",         "color":"00A19C","flag":"🇬🇧"},
	{"name":"Andrea Kimi Antonelli","short":"ANT","number":12, "team":"Mercedes",         "color":"00A19C","flag":"🇮🇹"},
	# McLaren
	{"name":"Lando Norris",         "short":"NOR","number":4,  "team":"McLaren",          "color":"FF8000","flag":"🇬🇧"},
	{"name":"Oscar Piastri",        "short":"PIA","number":81, "team":"McLaren",          "color":"FF8000","flag":"🇦🇺"},
	# Aston Martin
	{"name":"Fernando Alonso",      "short":"ALO","number":14, "team":"Aston Martin",     "color":"006F62","flag":"🇪🇸"},
	{"name":"Lance Stroll",         "short":"STR","number":18, "team":"Aston Martin",     "color":"006F62","flag":"🇨🇦"},
	# Williams
	{"name":"Carlos Sainz",         "short":"SAI","number":55, "team":"Williams",         "color":"005AFF","flag":"🇪🇸"},
	{"name":"Alexander Albon",      "short":"ALB","number":23, "team":"Williams",         "color":"005AFF","flag":"🇹🇭"},
	# Alpine
	{"name":"Pierre Gasly",         "short":"GAS","number":10, "team":"Alpine",           "color":"0090FF","flag":"🇫🇷"},
	{"name":"Jack Doohan",          "short":"DOO","number":7,  "team":"Alpine",           "color":"0090FF","flag":"🇦🇺"},
	# Racing Bulls
	{"name":"Yuki Tsunoda",         "short":"TSU","number":22, "team":"Racing Bulls",     "color":"1B3FA6","flag":"🇯🇵"},
	{"name":"Isack Hadjar",         "short":"HAD","number":6,  "team":"Racing Bulls",     "color":"1B3FA6","flag":"🇫🇷"},
	# Audi (née Sauber)
	{"name":"Nico Hulkenberg",      "short":"HUL","number":27, "team":"Audi F1",          "color":"B0BF1A","flag":"🇩🇪"},
	{"name":"Gabriel Bortoleto",    "short":"BOR","number":5,  "team":"Audi F1",          "color":"B0BF1A","flag":"🇧🇷"},
	# Haas
	{"name":"Esteban Ocon",         "short":"OCO","number":31, "team":"Haas",             "color":"B6BABD","flag":"🇫🇷"},
	{"name":"Oliver Bearman",       "short":"BEA","number":87, "team":"Haas",             "color":"B6BABD","flag":"🇬🇧"},
]

var _profile: Dictionary = {}
var _selected_driver: Dictionary = {}


func _ready() -> void:
	_load_profile()
	_build_ui()


func _load_profile() -> void:
	if FileAccess.file_exists(PROFILE_PATH):
		var f: FileAccess = FileAccess.open(PROFILE_PATH, FileAccess.READ)
		if f:
			var data = JSON.parse_string(f.get_as_text())
			f.close()
			if data is Dictionary:
				_profile = data


func _save_profile() -> void:
	var f: FileAccess = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_profile))
		f.close()


func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	if _profile.is_empty():
		_build_driver_select()
	else:
		_build_home_screen()


func _build_home_screen() -> void:
	var center: VBoxContainer = VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.custom_minimum_size = Vector2(420, 440)
	center.offset_left = -210
	center.offset_top = -220
	center.offset_right = 210
	center.offset_bottom = 220
	center.add_theme_constant_override("separation", 20)
	add_child(center)

	var title: Label = Label.new()
	title.text = "FunRacing"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	center.add_child(title)

	var sub: Label = Label.new()
	sub.text = "F1 Career Mode"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.modulate = Color(0.65, 0.65, 0.65)
	sub.add_theme_font_size_override("font_size", 18)
	center.add_child(sub)

	center.add_child(_spacer(10))

	# Driver badge
	var driver: Dictionary = _profile.get("driver", {})
	if not driver.is_empty():
		var badge: PanelContainer = PanelContainer.new()
		var badge_m: MarginContainer = MarginContainer.new()
		badge_m.add_theme_constant_override("margin_left", 20)
		badge_m.add_theme_constant_override("margin_right", 20)
		badge_m.add_theme_constant_override("margin_top", 12)
		badge_m.add_theme_constant_override("margin_bottom", 12)
		badge.add_child(badge_m)

		var bhbox: HBoxContainer = HBoxContainer.new()
		bhbox.add_theme_constant_override("separation", 16)
		badge_m.add_child(bhbox)

		var num_lbl: Label = Label.new()
		num_lbl.text = "#%d" % driver.get("number", 0)
		num_lbl.add_theme_font_size_override("font_size", 32)
		var team_color: Color = Color.html("#" + driver.get("color", "ffffff"))
		num_lbl.modulate = team_color
		bhbox.add_child(num_lbl)

		var dvbox: VBoxContainer = VBoxContainer.new()
		dvbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bhbox.add_child(dvbox)

		var flag_name: Label = Label.new()
		flag_name.text = "%s  %s" % [driver.get("flag",""), driver.get("name","")]
		flag_name.add_theme_font_size_override("font_size", 18)
		dvbox.add_child(flag_name)

		var team_lbl: Label = Label.new()
		team_lbl.text = driver.get("team", "")
		team_lbl.modulate = Color(0.65, 0.65, 0.65)
		team_lbl.add_theme_font_size_override("font_size", 13)
		dvbox.add_child(team_lbl)

		center.add_child(badge)

	center.add_child(_spacer(6))

	var play_btn: Button = Button.new()
	play_btn.text = "Play"
	play_btn.custom_minimum_size = Vector2(300, 58)
	play_btn.add_theme_font_size_override("font_size", 26)
	play_btn.pressed.connect(_go_to_hub)
	center.add_child(play_btn)

	var quit_btn: Button = Button.new()
	quit_btn.text = "Quit"
	quit_btn.custom_minimum_size = Vector2(300, 46)
	quit_btn.add_theme_font_size_override("font_size", 18)
	quit_btn.pressed.connect(get_tree().quit)
	center.add_child(quit_btn)

	center.add_child(_spacer(12))

	var change_btn: Button = Button.new()
	change_btn.text = "Change Driver"
	change_btn.custom_minimum_size = Vector2(200, 34)
	change_btn.modulate = Color(0.5, 0.5, 0.5)
	change_btn.pressed.connect(func():
		if FileAccess.file_exists(PROFILE_PATH):
			DirAccess.remove_absolute(PROFILE_PATH)
		get_tree().reload_current_scene()
	)
	center.add_child(change_btn)

	# Bottom info
	var status: Label = Label.new()
	status.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	status.offset_left = 20
	status.offset_top = -36
	status.offset_right = 800
	status.offset_bottom = -8
	status.text = "Controller: ws://%s:8080   ·   Phone UI: cd web_controller && python3 serve.py" % ControllerServer.get_local_ip()
	status.modulate = Color(0.38, 0.38, 0.38)
	status.add_theme_font_size_override("font_size", 12)
	add_child(status)


func _build_driver_select() -> void:
	# Full-screen layout: title + scrollable driver grid
	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	# Header
	var header: MarginContainer = MarginContainer.new()
	header.custom_minimum_size = Vector2(0, 80)
	header.add_theme_constant_override("margin_left", 40)
	header.add_theme_constant_override("margin_right", 40)
	header.add_theme_constant_override("margin_top", 16)
	header.add_theme_constant_override("margin_bottom", 16)
	root.add_child(header)

	header.queue_free()

	var header2: MarginContainer = MarginContainer.new()
	header2.custom_minimum_size = Vector2(0, 88)
	header2.add_theme_constant_override("margin_left", 40)
	header2.add_theme_constant_override("margin_right", 40)
	header2.add_theme_constant_override("margin_top", 16)
	header2.add_theme_constant_override("margin_bottom", 8)
	root.add_child(header2)

	var hvbox: VBoxContainer = VBoxContainer.new()
	hvbox.add_theme_constant_override("separation", 4)
	header2.add_child(hvbox)

	var htitle: Label = Label.new()
	htitle.text = "FunRacing — Choose Your Driver"
	htitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	htitle.add_theme_font_size_override("font_size", 30)
	hvbox.add_child(htitle)

	var hsub: Label = Label.new()
	hsub.text = "Select the driver you will race as. Your choice determines car number and team."
	hsub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hsub.modulate = Color(0.6, 0.6, 0.6)
	hsub.add_theme_font_size_override("font_size", 14)
	hvbox.add_child(hsub)

	# Scroll area
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var pad: MarginContainer = MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_left", 32)
	pad.add_theme_constant_override("margin_right", 32)
	pad.add_theme_constant_override("margin_top", 16)
	pad.add_theme_constant_override("margin_bottom", 16)
	scroll.add_child(pad)

	var grid: GridContainer = GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	pad.add_child(grid)

	# Group drivers by team for nicer presentation
	var teams_seen: Array = []
	for driver in DRIVERS:
		var team: String = driver["team"]
		if team not in teams_seen:
			teams_seen.append(team)

	for driver in DRIVERS:
		grid.add_child(_make_driver_card(driver))

	# Confirm button (bottom bar)
	var bottom_bar: PanelContainer = PanelContainer.new()
	bottom_bar.custom_minimum_size = Vector2(0, 64)
	root.add_child(bottom_bar)

	var bar_m: MarginContainer = MarginContainer.new()
	bar_m.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar_m.add_theme_constant_override("margin_left", 32)
	bar_m.add_theme_constant_override("margin_right", 32)
	bar_m.add_theme_constant_override("margin_top", 10)
	bar_m.add_theme_constant_override("margin_bottom", 10)
	bottom_bar.add_child(bar_m)

	var bar_hbox: HBoxContainer = HBoxContainer.new()
	bar_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar_hbox.add_theme_constant_override("separation", 20)
	bar_m.add_child(bar_hbox)

	var sel_label: Label = Label.new()
	sel_label.text = "No driver selected"
	sel_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sel_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sel_label.add_theme_font_size_override("font_size", 18)
	sel_label.modulate = Color(0.6, 0.6, 0.6)
	bar_hbox.add_child(sel_label)

	var confirm_btn: Button = Button.new()
	confirm_btn.text = "Confirm Selection"
	confirm_btn.custom_minimum_size = Vector2(220, 44)
	confirm_btn.add_theme_font_size_override("font_size", 18)
	confirm_btn.disabled = true
	bar_hbox.add_child(confirm_btn)

	# Wire up selection
	for card in grid.get_children():
		if card.has_meta("driver_data"):
			var d: Dictionary = card.get_meta("driver_data")
			card.pressed.connect(func():
				_selected_driver = d
				sel_label.text = "%s  %s  —  #%d  —  %s" % [
					d["flag"], d["name"], d["number"], d["team"]
				]
				sel_label.modulate = Color.html("#" + d["color"])
				confirm_btn.disabled = false
				# Visual feedback: highlight selected card
				for other in grid.get_children():
					other.modulate = Color(0.6, 0.6, 0.6) if other != card else Color.WHITE
			)

	confirm_btn.pressed.connect(func():
		if _selected_driver.is_empty():
			return
		_profile = {
			"driver": _selected_driver,
			"name": _selected_driver["name"],
			"car_number": _selected_driver["number"],
			"team": _selected_driver["team"]
		}
		_save_profile()
		_go_to_hub()
	)


func _make_driver_card(driver: Dictionary) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(0, 100)
	btn.set_meta("driver_data", driver)
	btn.modulate = Color(0.6, 0.6, 0.6)

	# Build label text manually (Button only has .text, use it as multiline)
	var team_color: Color = Color.html("#" + driver["color"])

	# Use a VBox inside the button via a custom control
	# Godot 4: buttons can have child controls if we set clip_contents
	btn.clip_contents = false

	var inner: VBoxContainer = VBoxContainer.new()
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.add_theme_constant_override("separation", 4)
	# Small margins
	inner.offset_left = 10
	inner.offset_right = -10
	inner.offset_top = 8
	inner.offset_bottom = -8
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(inner)

	# Top: flag + number
	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(top_row)

	var flag_lbl: Label = Label.new()
	flag_lbl.text = driver["flag"]
	flag_lbl.add_theme_font_size_override("font_size", 20)
	flag_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(flag_lbl)

	var spacer_h: Control = Control.new()
	spacer_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(spacer_h)

	var num_lbl: Label = Label.new()
	num_lbl.text = "#%d" % driver["number"]
	num_lbl.add_theme_font_size_override("font_size", 22)
	num_lbl.modulate = team_color
	num_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(num_lbl)

	# Driver name
	var name_lbl: Label = Label.new()
	name_lbl.text = driver["name"]
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(name_lbl)

	# Team
	var team_lbl: Label = Label.new()
	team_lbl.text = driver["team"]
	team_lbl.add_theme_font_size_override("font_size", 11)
	team_lbl.modulate = team_color * Color(1,1,1,0.85)
	team_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(team_lbl)

	return btn


func _go_to_hub() -> void:
	GameState.career = _profile
	get_tree().change_scene_to_file("res://scenes/career/career_hub.tscn")


func _spacer(h: int) -> Control:
	var s: Control = Control.new()
	s.custom_minimum_size = Vector2(0, h)
	return s
