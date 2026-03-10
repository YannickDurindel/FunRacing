extends Node
class_name SeasonGenerator

# 19 fictional AI drivers across 10 teams (2 per team). Player is Aurora #1.
const DRIVERS: Array = [
	# Aurora (player team)
	{"driver_id": "ai_aurora_2", "team_id": "team_aurora",   "name": "Luca Ferrante",     "number": 16, "skill": 0.82, "aggression": 0.60},
	# Vortex
	{"driver_id": "vortex_1",    "team_id": "team_vortex",    "name": "Max Steinberg",      "number": 1,  "skill": 0.95, "aggression": 0.75},
	{"driver_id": "vortex_2",    "team_id": "team_vortex",    "name": "Remi Leclair",       "number": 23, "skill": 0.88, "aggression": 0.55},
	# Meridian
	{"driver_id": "meridian_1",  "team_id": "team_meridian",  "name": "Carlos Vega",        "number": 14, "skill": 0.85, "aggression": 0.70},
	{"driver_id": "meridian_2",  "team_id": "team_meridian",  "name": "Oliver Hunt",        "number": 31, "skill": 0.78, "aggression": 0.50},
	# Solace
	{"driver_id": "solace_1",    "team_id": "team_solace",    "name": "Yuki Tanaka",        "number": 7,  "skill": 0.83, "aggression": 0.65},
	{"driver_id": "solace_2",    "team_id": "team_solace",    "name": "Pierre Moreau",      "number": 22, "skill": 0.77, "aggression": 0.45},
	# Neon
	{"driver_id": "neon_1",      "team_id": "team_neon",      "name": "Ethan Clarke",       "number": 5,  "skill": 0.80, "aggression": 0.80},
	{"driver_id": "neon_2",      "team_id": "team_neon",      "name": "Nico Braun",         "number": 18, "skill": 0.74, "aggression": 0.60},
	# Apex
	{"driver_id": "apex_1",      "team_id": "team_apex",      "name": "Daniel Ruiz",        "number": 11, "skill": 0.76, "aggression": 0.55},
	{"driver_id": "apex_2",      "team_id": "team_apex",      "name": "Seb Fischer",        "number": 27, "skill": 0.72, "aggression": 0.40},
	# Cascade
	{"driver_id": "cascade_1",   "team_id": "team_cascade",   "name": "Mikhail Petrov",     "number": 3,  "skill": 0.73, "aggression": 0.70},
	{"driver_id": "cascade_2",   "team_id": "team_cascade",   "name": "James Whitfield",    "number": 33, "skill": 0.69, "aggression": 0.45},
	# Drift
	{"driver_id": "drift_1",     "team_id": "team_drift",     "name": "Lucas Montoya",      "number": 8,  "skill": 0.70, "aggression": 0.75},
	{"driver_id": "drift_2",     "team_id": "team_drift",     "name": "Takeshi Ando",       "number": 21, "skill": 0.65, "aggression": 0.50},
	# Quantum
	{"driver_id": "quantum_1",   "team_id": "team_quantum",   "name": "Arjun Sharma",       "number": 10, "skill": 0.67, "aggression": 0.60},
	{"driver_id": "quantum_2",   "team_id": "team_quantum",   "name": "Tom Bradley",        "number": 34, "skill": 0.62, "aggression": 0.35},
	# Eclipse
	{"driver_id": "eclipse_1",   "team_id": "team_eclipse",   "name": "Alexei Volkov",      "number": 19, "skill": 0.64, "aggression": 0.55},
	{"driver_id": "eclipse_2",   "team_id": "team_eclipse",   "name": "Marco Bianchi",      "number": 37, "skill": 0.60, "aggression": 0.40},
]

# 6-race calendar: 3 tracks × 2 visits. First race = mixed (medium circuit).
const CALENDAR_TEMPLATE: Array = [
	{"track_id": "track_02_mixed",     "track_name": "Harrowstone Park"},
	{"track_id": "track_01_street",    "track_name": "Circuit Azur"},
	{"track_id": "track_03_highspeed", "track_name": "Veloce Nazionale"},
	{"track_id": "track_02_mixed",     "track_name": "Harrowstone Park"},
	{"track_id": "track_03_highspeed", "track_name": "Veloce Nazionale"},
	{"track_id": "track_01_street",    "track_name": "Circuit Azur"},
]


static func generate_calendar() -> Array:
	var calendar: Array = []
	for i in range(CALENDAR_TEMPLATE.size()):
		var tmpl: Dictionary = CALENDAR_TEMPLATE[i]
		calendar.append({
			"track_id": tmpl["track_id"],
			"track_name": tmpl["track_name"],
			"weekend_index": i,
			"state": "upcoming",
			"qualifying_position": null,
			"race_position": null,
			"points_scored": 0
		})
	return calendar


static func generate_championship_standings(player_driver_id: String = "player") -> Array:
	var standings: Array = [{"driver_id": player_driver_id, "points": 0, "wins": 0}]
	for d in DRIVERS:
		standings.append({"driver_id": d["driver_id"], "points": 0, "wins": 0})
	return standings


static func generate_constructor_standings() -> Array:
	var teams: Array = ["team_aurora", "team_vortex", "team_meridian", "team_solace",
						"team_neon", "team_apex", "team_cascade", "team_drift",
						"team_quantum", "team_eclipse"]
	var standings: Array = []
	for t in teams:
		standings.append({"team_id": t, "points": 0})
	return standings
