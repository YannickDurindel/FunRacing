extends Control

const CalData = preload("res://scripts/career/f1_calendar_data.gd")

const MISSIONS: Dictionary = {
	"street": {
		"fp1": [
			{"name":"Barrier Familiarisation",    "desc":"Drive 3 laps staying within 20 cm of barriers at the key pinch points. Precision over speed on these walls."},
			{"name":"Low-Speed Corner Attack",    "desc":"Post a clean sector time through the tightest sequence. No margin for error when the walls are this close."},
			{"name":"Tyre Warm-Up Protocol",      "desc":"Complete 4 laps on mediums keeping tyre temps in the optimal window before the first hot lap."},
		],
		"fp2": [
			{"name":"Street Qualifying Sim",      "desc":"Set your fastest lap on a fresh set of softs. The walls are inches away — leave nothing on the table."},
			{"name":"Compound Comparison",        "desc":"Back-to-back laps on softs then mediums. Understand tyre behaviour on the bumpy street surface."},
			{"name":"Traffic Avoidance",          "desc":"Complete 3 clean flying laps in a row without being impeded. Nail your out-lap gap."},
		],
		"fp3": [
			{"name":"Final Street Qualifying Prep","desc":"Match the projected pole time within 0.3 seconds on a fresh set of softs. No second chances here."},
			{"name":"Pit Stop Procedure",         "desc":"Execute 2 pit stops with a stationary time under 2.6 seconds each. Every tenth matters on a street circuit."},
			{"name":"Zero-Margin Hot Lap",        "desc":"Complete 1 clean hot lap without any barrier contact. One mistake ends your qualifying weekend."},
		],
	},
	"highspeed": {
		"fp1": [
			{"name":"High-Speed Circuit Entry",   "desc":"Complete 2 installation laps at full commitment through the fast sections. Feel the downforce loading."},
			{"name":"Flat-Out Sector Run",        "desc":"Post a sector time without lifting through the quickest sequence of corners. Trust your aero package."},
			{"name":"Long Run Pace",              "desc":"Complete 6 laps on medium tyres within 104% of target pace. Manage rear deg in the high-speed sweeps."},
		],
		"fp2": [
			{"name":"Slipstream Study",           "desc":"Complete 2 timed laps using DRS behind an AI car. Find the optimal DRS activation point on the main straight."},
			{"name":"Qualifying Simulation",      "desc":"Set your fastest lap on a fresh set of soft tyres. Every aero efficiency gain earns tenths here."},
			{"name":"High-Speed Tyre Life",       "desc":"Complete 7 laps on mediums without going past the thermal cliff in the high-load corners."},
		],
		"fp3": [
			{"name":"Final Qualifying Prep",      "desc":"Match the projected pole time within 0.5 seconds. This circuit rewards full commitment — no half-measures."},
			{"name":"Race Start Practice",        "desc":"Execute 3 race starts with a reaction time under 0.25 s. The run to Turn 1 at high speed is decisive."},
			{"name":"Draft Defence",              "desc":"Follow an AI car within 0.5 seconds for 2 full laps at race pace, fighting dirty-air instability at high speed."},
		],
	},
	"technical": {
		"fp1": [
			{"name":"Technical Layout Mapping",   "desc":"Complete a formation lap focused on braking points and apex selection through the tight technical sections."},
			{"name":"Sector 2 Time Attack",       "desc":"Set a clean sector 2 time through the twisty middle complex within the target delta."},
			{"name":"Long Run Pace",              "desc":"Complete 5 laps on medium tyres within 105% of target pace. Consistency wins at technical circuits."},
		],
		"fp2": [
			{"name":"Qualifying Simulation",      "desc":"Set your fastest lap on a fresh set of soft tyres. Traction out of slow corners is the defining factor."},
			{"name":"Brake Bias Test",            "desc":"Complete 3 laps varying front brake bias. Find the setting that gives rotation without understeer."},
			{"name":"Traffic Management",         "desc":"Complete 3 consecutive clean laps without being impeded. Track position in qualifying is critical here."},
		],
		"fp3": [
			{"name":"Final Qualifying Prep",      "desc":"Match the projected pole time within 0.5 seconds. Technical circuits reward lap building, not raw pace."},
			{"name":"Race Start Practice",        "desc":"Execute 3 race starts with a reaction time under 0.25 s. Overtaking is rare — start position is everything."},
			{"name":"Dirty Air Test",             "desc":"Follow an AI car within 1 second for 2 full laps. Feel how the technical layout amplifies dirty-air loss."},
		],
	},
	"mixed": {
		"fp1": [
			{"name":"Installation Lap",           "desc":"Complete a formation lap. No time pressure — get familiar with the circuit and confirm systems are green."},
			{"name":"Sector 1 Time Attack",       "desc":"Set a Sector 1 time under the target. One lap, clean execution."},
			{"name":"Long Run Pace",              "desc":"Complete 5 laps on medium tyres within 105% of the target pace."},
		],
		"fp2": [
			{"name":"Qualifying Simulation",      "desc":"Set your fastest possible lap on a fresh set of soft tyres."},
			{"name":"Tyre Comparison",            "desc":"Set a lap on softs, then mediums. Feel the difference and adjust your setup."},
			{"name":"Traffic Management",         "desc":"Complete 3 consecutive clean laps without being impeded."},
		],
		"fp3": [
			{"name":"Final Qualifying Prep",      "desc":"Match the projected pole time within 0.5 seconds."},
			{"name":"Race Start Practice",        "desc":"Execute 3 race starts with a reaction time under 0.25 s."},
			{"name":"Dirty Air Test",             "desc":"Follow an AI car within 1 second for 2 full laps."},
		],
	},
}

const SEASONS: Array = [2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026]

enum View { SEASONS, GPS, SESSIONS, MISSIONS }
var _view: View = View.SEASONS
var _sel_season: int = 0
var _sel_gp: Dictionary = {}
var _sel_session: Dictionary = {}

var _back_btn: Button
var _title_lbl: Label
var _driver_lbl: Label
var _content: VBoxContainer


func _ready() -> void:
	_build_chrome()
	_show_seasons()


func _build_chrome() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	# Header
	var header: PanelContainer = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 64)
	root.add_child(header)

	var m: MarginContainer = MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 16)
	m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_top", 6)
	m.add_theme_constant_override("margin_bottom", 6)
	header.add_child(m)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 12)
	m.add_child(hbox)

	_back_btn = Button.new()
	_back_btn.custom_minimum_size = Vector2(148, 40)
	_back_btn.visible = false
	_back_btn.pressed.connect(_on_back)
	hbox.add_child(_back_btn)

	_title_lbl = Label.new()
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.add_theme_font_size_override("font_size", 22)
	_title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(_title_lbl)

	_driver_lbl = Label.new()
	_driver_lbl.modulate = Color(0.6, 0.85, 1.0)
	_driver_lbl.add_theme_font_size_override("font_size", 14)
	_driver_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var profile = GameState.career
	if profile is Dictionary:
		_driver_lbl.text = profile.get("name", "Driver") + "  ·  Team Aurora  ·  #44"
	hbox.add_child(_driver_lbl)

	# Scroll + content
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var pad: MarginContainer = MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_left", 20)
	pad.add_theme_constant_override("margin_right", 20)
	pad.add_theme_constant_override("margin_top", 16)
	pad.add_theme_constant_override("margin_bottom", 16)
	scroll.add_child(pad)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 6)
	pad.add_child(_content)


func _clear() -> void:
	for c in _content.get_children():
		c.queue_free()


# ── SEASONS ───────────────────────────────────────────────────────────────────
func _show_seasons() -> void:
	_view = View.SEASONS
	_clear()
	_title_lbl.text = "Select Season"
	_back_btn.visible = false

	var grid: GridContainer = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	_content.add_child(grid)

	for yr in SEASONS:
		var cal: Array = CalData.get_calendar(yr)
		var sprint_count: int = 0
		for g in cal:
			if g.get("sprint", false):
				sprint_count += 1

		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(220, 96)
		var sprint_line: String = ""
		if sprint_count > 0:
			sprint_line = "\n%d sprint weekends" % sprint_count
		btn.text = "%d\n%d Grands Prix%s" % [yr, cal.size(), sprint_line]
		btn.pressed.connect(_on_season.bind(yr))
		grid.add_child(btn)


# ── GP LIST ───────────────────────────────────────────────────────────────────
func _on_season(yr: int) -> void:
	_sel_season = yr
	_view = View.GPS
	_clear()
	_title_lbl.text = "%d F1 World Championship" % yr
	_back_btn.text = "← Seasons"
	_back_btn.visible = true

	for gp in CalData.get_calendar(yr):
		var is_sprint: bool = gp.get("sprint", false)

		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(0, 52)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 15)
		var sprint_tag: String = "  ⚡ SPRINT" if is_sprint else ""
		btn.text = "  %s  R%02d  %s%s   —   %s" % [
			gp["flag"], gp["round"], gp["name"], sprint_tag, gp["circuit"]
		]
		btn.pressed.connect(_on_gp.bind(gp))
		_content.add_child(btn)

		# Session pills
		var pills: HBoxContainer = HBoxContainer.new()
		pills.add_theme_constant_override("separation", 2)
		pills.modulate = Color(0.5, 0.5, 0.5)
		var sessions: Array = CalData.get_session_format(yr, is_sprint)
		for s in sessions:
			var pill: Label = Label.new()
			pill.text = "  %s  " % _session_short(s["id"])
			pill.add_theme_font_size_override("font_size", 11)
			pills.add_child(pill)
		_content.add_child(pills)
		_content.add_child(_sep())


func _session_short(sid: String) -> String:
	match sid:
		"fp1":    return "FP1"
		"fp2":    return "FP2"
		"fp3":    return "FP3"
		"qual":   return "QUALI"
		"race":   return "RACE"
		"sq":     return "SQ"
		"sprint": return "SPRINT"
	return sid.to_upper()


# ── SESSION LIST ──────────────────────────────────────────────────────────────
func _on_gp(gp: Dictionary) -> void:
	_sel_gp = gp
	_view = View.SESSIONS
	_clear()
	var sprint_tag: String = "  ⚡ Sprint Weekend" if gp.get("sprint", false) else ""
	_title_lbl.text = "%s %s%s" % [gp["flag"], gp["name"], sprint_tag]
	_back_btn.text = "← %d Calendar" % _sel_season
	_back_btn.visible = true

	var info: Label = Label.new()
	info.text = "%s  ·  %s  ·  Round %d / %d" % [
		gp["circuit"], gp["country"], gp["round"],
		CalData.get_calendar(_sel_season).size()
	]
	info.modulate = Color(0.6, 0.6, 0.6)
	info.add_theme_font_size_override("font_size", 13)
	_content.add_child(info)
	_content.add_child(_spacer(10))

	var sessions: Array = CalData.get_session_format(_sel_season, gp.get("sprint", false))
	for session in sessions:
		var is_fp: bool = session["id"].begins_with("fp")
		_add_session_card(session, is_fp, gp)


func _get_missions(gp: Dictionary, session_id: String) -> Array:
	var ctype: String = CalData.get_circuit_type(gp.get("circuit", ""))
	return MISSIONS.get(ctype, MISSIONS["mixed"]).get(session_id, [])


func _add_session_card(session: Dictionary, is_fp: bool, gp: Dictionary = {}) -> void:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 68)

	var inner: MarginContainer = MarginContainer.new()
	inner.add_theme_constant_override("margin_left", 16)
	inner.add_theme_constant_override("margin_right", 16)
	inner.add_theme_constant_override("margin_top", 8)
	inner.add_theme_constant_override("margin_bottom", 8)
	card.add_child(inner)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	inner.add_child(hbox)

	var icon_lbl: Label = Label.new()
	icon_lbl.text = session["icon"]
	icon_lbl.add_theme_font_size_override("font_size", 24)
	icon_lbl.custom_minimum_size = Vector2(32, 0)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var name_lbl: Label = Label.new()
	name_lbl.text = session["label"]
	name_lbl.add_theme_font_size_override("font_size", 17)
	vbox.add_child(name_lbl)

	if is_fp:
		var missions: Array = _get_missions(gp, session["id"])
		var sub: Label = Label.new()
		sub.text = "%d practice missions" % missions.size()
		sub.modulate = Color(0.5, 0.82, 1.0)
		sub.add_theme_font_size_override("font_size", 12)
		vbox.add_child(sub)

	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(160, 38)
	hbox.add_child(btn)

	if is_fp and not _get_missions(gp, session["id"]).is_empty():
		btn.text = "View Missions"
		btn.pressed.connect(_on_missions.bind(session))
	else:
		btn.text = "Coming Soon"
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5)

	_content.add_child(card)
	_content.add_child(_spacer(4))


# ── MISSION LIST ──────────────────────────────────────────────────────────────
func _on_missions(session: Dictionary) -> void:
	_sel_session = session
	_view = View.MISSIONS
	_clear()
	_title_lbl.text = "%s  ·  %s  ·  Missions" % [_sel_gp["flag"], session["label"]]
	_back_btn.text = "← Sessions"
	_back_btn.visible = true

	var mission_list: Array = _get_missions(_sel_gp, session["id"])
	for i in range(mission_list.size()):
		var m: Dictionary = mission_list[i]

		var card: PanelContainer = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 84)

		var inner: MarginContainer = MarginContainer.new()
		inner.add_theme_constant_override("margin_left", 20)
		inner.add_theme_constant_override("margin_right", 20)
		inner.add_theme_constant_override("margin_top", 12)
		inner.add_theme_constant_override("margin_bottom", 12)
		card.add_child(inner)

		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 20)
		inner.add_child(hbox)

		var num: Label = Label.new()
		num.text = str(i + 1)
		num.add_theme_font_size_override("font_size", 28)
		num.modulate = Color(0.5, 0.82, 1.0)
		num.custom_minimum_size = Vector2(36, 0)
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(num)

		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)

		var title: Label = Label.new()
		title.text = m["name"]
		title.add_theme_font_size_override("font_size", 17)
		vbox.add_child(title)

		var desc: Label = Label.new()
		desc.text = m["desc"]
		desc.modulate = Color(0.62, 0.62, 0.62)
		desc.add_theme_font_size_override("font_size", 13)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(desc)

		var start: Button = Button.new()
		start.text = "Coming Soon"
		start.custom_minimum_size = Vector2(148, 38)
		start.disabled = true
		start.modulate = Color(0.45, 0.45, 0.45)
		hbox.add_child(start)

		_content.add_child(card)
		_content.add_child(_spacer(6))


# ── BACK ──────────────────────────────────────────────────────────────────────
func _on_back() -> void:
	match _view:
		View.GPS:      _show_seasons()
		View.SESSIONS: _on_season(_sel_season)
		View.MISSIONS: _on_gp(_sel_gp)


func _sep() -> HSeparator:
	return HSeparator.new()

func _spacer(h: int) -> Control:
	var s: Control = Control.new()
	s.custom_minimum_size = Vector2(0, h)
	return s
