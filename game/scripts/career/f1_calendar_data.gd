extends Node
class_name F1CalendarData

# ── Session format templates ──────────────────────────────────────────────────
# Standard weekend (used since forever)
const FMT_STANDARD: Array = [
	{"id":"fp1",    "label":"Free Practice 1",  "icon":"⏱"},
	{"id":"fp2",    "label":"Free Practice 2",  "icon":"⏱"},
	{"id":"fp3",    "label":"Free Practice 3",  "icon":"⏱"},
	{"id":"qual",   "label":"Qualifying",        "icon":"🏁"},
	{"id":"race",   "label":"Race",              "icon":"🏎"},
]

# 2021 sprint: FP1 → Sprint Qualifying → FP2 → Sprint → Race
const FMT_SPRINT_2021: Array = [
	{"id":"fp1",    "label":"Free Practice 1",  "icon":"⏱"},
	{"id":"sq",     "label":"Sprint Qualifying","icon":"⚡"},
	{"id":"fp2",    "label":"Free Practice 2",  "icon":"⏱"},
	{"id":"sprint", "label":"Sprint",           "icon":"⚡"},
	{"id":"race",   "label":"Race",             "icon":"🏎"},
]

# 2022 sprint: FP1 → Qualifying → FP2 → Sprint → Race
const FMT_SPRINT_2022: Array = [
	{"id":"fp1",    "label":"Free Practice 1",  "icon":"⏱"},
	{"id":"qual",   "label":"Qualifying",        "icon":"🏁"},
	{"id":"fp2",    "label":"Free Practice 2",  "icon":"⏱"},
	{"id":"sprint", "label":"Sprint",           "icon":"⚡"},
	{"id":"race",   "label":"Race",             "icon":"🏎"},
]

# 2023+ sprint: FP1 → Sprint Shootout → Sprint → Qualifying → Race
const FMT_SPRINT_2023: Array = [
	{"id":"fp1",    "label":"Free Practice 1",  "icon":"⏱"},
	{"id":"sq",     "label":"Sprint Shootout",  "icon":"⚡"},
	{"id":"sprint", "label":"Sprint",           "icon":"⚡"},
	{"id":"qual",   "label":"Qualifying",        "icon":"🏁"},
	{"id":"race",   "label":"Race",             "icon":"🏎"},
]


# ── Helper ────────────────────────────────────────────────────────────────────
static func gp(r:int,n:String,c:String,co:String,f:String,s:bool=false) -> Dictionary:
	return {"round":r,"name":n,"circuit":c,"country":co,"flag":f,"sprint":s}


# ── Full season calendars ─────────────────────────────────────────────────────

static func get_calendar(year: int) -> Array:
	match year:
		2019: return _2019()
		2020: return _2020()
		2021: return _2021()
		2022: return _2022()
		2023: return _2023()
		2024: return _2024()
		2025: return _2025()
		2026: return _2026()
	return []


static func get_circuit_type(circuit: String) -> String:
	match circuit:
		"Circuit de Monaco", "Baku City Circuit", "Marina Bay Street Circuit", \
		"Jeddah Corniche Circuit", "Miami International Autodrome", \
		"Las Vegas Strip Circuit":
			return "street"
		"Autodromo Nazionale Monza", "Circuit de Spa-Francorchamps", \
		"Silverstone Circuit", "Suzuka Circuit", "Red Bull Ring", \
		"Circuit Zandvoort":
			return "highspeed"
		"Hungaroring", "Circuit de Barcelona-Catalunya", "Yas Marina Circuit", \
		"Bahrain Int'l Circuit", "Losail International Circuit", \
		"Lusail International Circuit":
			return "technical"
		_:
			return "mixed"


static func get_session_format(year: int, is_sprint: bool) -> Array:
	if not is_sprint:
		return FMT_STANDARD
	match year:
		2021: return FMT_SPRINT_2021
		2022: return FMT_SPRINT_2022
		_:    return FMT_SPRINT_2023  # 2023, 2024, 2025, 2026


static func _2019() -> Array:
	# 21 rounds, no sprints
	return [
		gp(1, "Australian Grand Prix",    "Albert Park Circuit",             "Australia",     "🇦🇺"),
		gp(2, "Bahrain Grand Prix",        "Bahrain Int'l Circuit",           "Bahrain",       "🇧🇭"),
		gp(3, "Chinese Grand Prix",        "Shanghai International Circuit",  "China",         "🇨🇳"),
		gp(4, "Azerbaijan Grand Prix",     "Baku City Circuit",               "Azerbaijan",    "🇦🇿"),
		gp(5, "Spanish Grand Prix",        "Circuit de Barcelona-Catalunya",  "Spain",         "🇪🇸"),
		gp(6, "Monaco Grand Prix",         "Circuit de Monaco",               "Monaco",        "🇲🇨"),
		gp(7, "Canadian Grand Prix",       "Circuit Gilles Villeneuve",       "Canada",        "🇨🇦"),
		gp(8, "French Grand Prix",         "Circuit Paul Ricard",             "France",        "🇫🇷"),
		gp(9, "Austrian Grand Prix",       "Red Bull Ring",                   "Austria",       "🇦🇹"),
		gp(10,"British Grand Prix",        "Silverstone Circuit",             "United Kingdom","🇬🇧"),
		gp(11,"German Grand Prix",         "Hockenheimring",                  "Germany",       "🇩🇪"),
		gp(12,"Hungarian Grand Prix",      "Hungaroring",                     "Hungary",       "🇭🇺"),
		gp(13,"Belgian Grand Prix",        "Circuit de Spa-Francorchamps",   "Belgium",       "🇧🇪"),
		gp(14,"Italian Grand Prix",        "Autodromo Nazionale Monza",      "Italy",         "🇮🇹"),
		gp(15,"Singapore Grand Prix",      "Marina Bay Street Circuit",      "Singapore",     "🇸🇬"),
		gp(16,"Russian Grand Prix",        "Sochi Autodrom",                  "Russia",        "🇷🇺"),
		gp(17,"Japanese Grand Prix",       "Suzuka Circuit",                  "Japan",         "🇯🇵"),
		gp(18,"Mexican Grand Prix",        "Autodromo Hermanos Rodriguez",   "Mexico",        "🇲🇽"),
		gp(19,"United States Grand Prix",  "Circuit of the Americas",        "USA",           "🇺🇸"),
		gp(20,"Brazilian Grand Prix",      "Autodromo Jose Carlos Pace",     "Brazil",        "🇧🇷"),
		gp(21,"Abu Dhabi Grand Prix",      "Yas Marina Circuit",             "UAE",           "🇦🇪"),
	]


static func _2020() -> Array:
	# 17 rounds (COVID), no sprints
	return [
		gp(1, "Austrian Grand Prix",       "Red Bull Ring",                   "Austria",       "🇦🇹"),
		gp(2, "Styrian Grand Prix",         "Red Bull Ring",                   "Austria",       "🇦🇹"),
		gp(3, "Hungarian Grand Prix",      "Hungaroring",                     "Hungary",       "🇭🇺"),
		gp(4, "British Grand Prix",        "Silverstone Circuit",             "United Kingdom","🇬🇧"),
		gp(5, "70th Anniversary Grand Prix","Silverstone Circuit",            "United Kingdom","🇬🇧"),
		gp(6, "Spanish Grand Prix",        "Circuit de Barcelona-Catalunya",  "Spain",         "🇪🇸"),
		gp(7, "Belgian Grand Prix",        "Circuit de Spa-Francorchamps",   "Belgium",       "🇧🇪"),
		gp(8, "Italian Grand Prix",        "Autodromo Nazionale Monza",      "Italy",         "🇮🇹"),
		gp(9, "Tuscan Grand Prix",         "Autodromo del Mugello",           "Italy",         "🇮🇹"),
		gp(10,"Russian Grand Prix",        "Sochi Autodrom",                  "Russia",        "🇷🇺"),
		gp(11,"Eifel Grand Prix",          "Nürburgring",                     "Germany",       "🇩🇪"),
		gp(12,"Portuguese Grand Prix",     "Autodromo Internacional do Algarve","Portugal",    "🇵🇹"),
		gp(13,"Emilia Romagna Grand Prix", "Autodromo Enzo e Dino Ferrari",   "Italy",         "🇮🇹"),
		gp(14,"Turkish Grand Prix",        "Istanbul Park",                   "Turkey",        "🇹🇷"),
		gp(15,"Bahrain Grand Prix",        "Bahrain Int'l Circuit",           "Bahrain",       "🇧🇭"),
		gp(16,"Sakhir Grand Prix",         "Bahrain Int'l Circuit (Outer)",   "Bahrain",       "🇧🇭"),
		gp(17,"Abu Dhabi Grand Prix",      "Yas Marina Circuit",             "UAE",           "🇦🇪"),
	]


static func _2021() -> Array:
	# 22 rounds, 3 sprints: British (R10), Italian (R14), Brazilian (R19)
	return [
		gp(1, "Bahrain Grand Prix",        "Bahrain Int'l Circuit",           "Bahrain",       "🇧🇭"),
		gp(2, "Emilia Romagna Grand Prix", "Autodromo Enzo e Dino Ferrari",   "Italy",         "🇮🇹"),
		gp(3, "Portuguese Grand Prix",     "Autodromo Internacional do Algarve","Portugal",    "🇵🇹"),
		gp(4, "Spanish Grand Prix",        "Circuit de Barcelona-Catalunya",  "Spain",         "🇪🇸"),
		gp(5, "Monaco Grand Prix",         "Circuit de Monaco",               "Monaco",        "🇲🇨"),
		gp(6, "Azerbaijan Grand Prix",     "Baku City Circuit",               "Azerbaijan",    "🇦🇿"),
		gp(7, "French Grand Prix",         "Circuit Paul Ricard",             "France",        "🇫🇷"),
		gp(8, "Styrian Grand Prix",         "Red Bull Ring",                   "Austria",       "🇦🇹"),
		gp(9, "Austrian Grand Prix",       "Red Bull Ring",                   "Austria",       "🇦🇹"),
		gp(10,"British Grand Prix",        "Silverstone Circuit",             "United Kingdom","🇬🇧", true),
		gp(11,"Hungarian Grand Prix",      "Hungaroring",                     "Hungary",       "🇭🇺"),
		gp(12,"Belgian Grand Prix",        "Circuit de Spa-Francorchamps",   "Belgium",       "🇧🇪"),
		gp(13,"Dutch Grand Prix",          "Circuit Zandvoort",               "Netherlands",   "🇳🇱"),
		gp(14,"Italian Grand Prix",        "Autodromo Nazionale Monza",      "Italy",         "🇮🇹", true),
		gp(15,"Russian Grand Prix",        "Sochi Autodrom",                  "Russia",        "🇷🇺"),
		gp(16,"Turkish Grand Prix",        "Istanbul Park",                   "Turkey",        "🇹🇷"),
		gp(17,"United States Grand Prix",  "Circuit of the Americas",        "USA",           "🇺🇸"),
		gp(18,"Mexican Grand Prix",        "Autodromo Hermanos Rodriguez",   "Mexico",        "🇲🇽"),
		gp(19,"Brazilian Grand Prix",      "Autodromo Jose Carlos Pace",     "Brazil",        "🇧🇷", true),
		gp(20,"Qatar Grand Prix",          "Losail International Circuit",    "Qatar",         "🇶🇦"),
		gp(21,"Saudi Arabian Grand Prix",  "Jeddah Corniche Circuit",         "Saudi Arabia",  "🇸🇦"),
		gp(22,"Abu Dhabi Grand Prix",      "Yas Marina Circuit",             "UAE",           "🇦🇪"),
	]


static func _2022() -> Array:
	# 22 rounds, 3 sprints: Emilia Romagna (R4), Austria (R11), Brazil (R21)
	return [
		gp(1, "Bahrain Grand Prix",        "Bahrain Int'l Circuit",           "Bahrain",       "🇧🇭"),
		gp(2, "Saudi Arabian Grand Prix",  "Jeddah Corniche Circuit",         "Saudi Arabia",  "🇸🇦"),
		gp(3, "Australian Grand Prix",     "Albert Park Circuit",             "Australia",     "🇦🇺"),
		gp(4, "Emilia Romagna Grand Prix", "Autodromo Enzo e Dino Ferrari",   "Italy",         "🇮🇹", true),
		gp(5, "Miami Grand Prix",          "Miami International Autodrome",   "USA",           "🇺🇸"),
		gp(6, "Spanish Grand Prix",        "Circuit de Barcelona-Catalunya",  "Spain",         "🇪🇸"),
		gp(7, "Monaco Grand Prix",         "Circuit de Monaco",               "Monaco",        "🇲🇨"),
		gp(8, "Azerbaijan Grand Prix",     "Baku City Circuit",               "Azerbaijan",    "🇦🇿"),
		gp(9, "Canadian Grand Prix",       "Circuit Gilles Villeneuve",       "Canada",        "🇨🇦"),
		gp(10,"British Grand Prix",        "Silverstone Circuit",             "United Kingdom","🇬🇧"),
		gp(11,"Austrian Grand Prix",       "Red Bull Ring",                   "Austria",       "🇦🇹", true),
		gp(12,"French Grand Prix",         "Circuit Paul Ricard",             "France",        "🇫🇷"),
		gp(13,"Hungarian Grand Prix",      "Hungaroring",                     "Hungary",       "🇭🇺"),
		gp(14,"Belgian Grand Prix",        "Circuit de Spa-Francorchamps",   "Belgium",       "🇧🇪"),
		gp(15,"Dutch Grand Prix",          "Circuit Zandvoort",               "Netherlands",   "🇳🇱"),
		gp(16,"Italian Grand Prix",        "Autodromo Nazionale Monza",      "Italy",         "🇮🇹"),
		gp(17,"Singapore Grand Prix",      "Marina Bay Street Circuit",      "Singapore",     "🇸🇬"),
		gp(18,"Japanese Grand Prix",       "Suzuka Circuit",                  "Japan",         "🇯🇵"),
		gp(19,"United States Grand Prix",  "Circuit of the Americas",        "USA",           "🇺🇸"),
		gp(20,"Mexican Grand Prix",        "Autodromo Hermanos Rodriguez",   "Mexico",        "🇲🇽"),
		gp(21,"Brazilian Grand Prix",      "Autodromo Jose Carlos Pace",     "Brazil",        "🇧🇷", true),
		gp(22,"Abu Dhabi Grand Prix",      "Yas Marina Circuit",             "UAE",           "🇦🇪"),
	]


static func _2023() -> Array:
	# 22 rounds, 6 sprints: Azerbaijan (R4), Austria (R9), Belgium (R12), Qatar (R17), USA (R18), Brazil (R20)
	return [
		gp(1, "Bahrain Grand Prix",        "Bahrain Int'l Circuit",           "Bahrain",       "🇧🇭"),
		gp(2, "Saudi Arabian Grand Prix",  "Jeddah Corniche Circuit",         "Saudi Arabia",  "🇸🇦"),
		gp(3, "Australian Grand Prix",     "Albert Park Circuit",             "Australia",     "🇦🇺"),
		gp(4, "Azerbaijan Grand Prix",     "Baku City Circuit",               "Azerbaijan",    "🇦🇿", true),
		gp(5, "Miami Grand Prix",          "Miami International Autodrome",   "USA",           "🇺🇸"),
		gp(6, "Monaco Grand Prix",         "Circuit de Monaco",               "Monaco",        "🇲🇨"),
		gp(7, "Spanish Grand Prix",        "Circuit de Barcelona-Catalunya",  "Spain",         "🇪🇸"),
		gp(8, "Canadian Grand Prix",       "Circuit Gilles Villeneuve",       "Canada",        "🇨🇦"),
		gp(9, "Austrian Grand Prix",       "Red Bull Ring",                   "Austria",       "🇦🇹", true),
		gp(10,"British Grand Prix",        "Silverstone Circuit",             "United Kingdom","🇬🇧"),
		gp(11,"Hungarian Grand Prix",      "Hungaroring",                     "Hungary",       "🇭🇺"),
		gp(12,"Belgian Grand Prix",        "Circuit de Spa-Francorchamps",   "Belgium",       "🇧🇪", true),
		gp(13,"Dutch Grand Prix",          "Circuit Zandvoort",               "Netherlands",   "🇳🇱"),
		gp(14,"Italian Grand Prix",        "Autodromo Nazionale Monza",      "Italy",         "🇮🇹"),
		gp(15,"Singapore Grand Prix",      "Marina Bay Street Circuit",      "Singapore",     "🇸🇬"),
		gp(16,"Japanese Grand Prix",       "Suzuka Circuit",                  "Japan",         "🇯🇵"),
		gp(17,"Qatar Grand Prix",          "Losail International Circuit",    "Qatar",         "🇶🇦", true),
		gp(18,"United States Grand Prix",  "Circuit of the Americas",        "USA",           "🇺🇸", true),
		gp(19,"Mexican Grand Prix",        "Autodromo Hermanos Rodriguez",   "Mexico",        "🇲🇽"),
		gp(20,"Brazilian Grand Prix",      "Autodromo Jose Carlos Pace",     "Brazil",        "🇧🇷", true),
		gp(21,"Las Vegas Grand Prix",      "Las Vegas Strip Circuit",        "USA",           "🇺🇸"),
		gp(22,"Abu Dhabi Grand Prix",      "Yas Marina Circuit",             "UAE",           "🇦🇪"),
	]


static func _2024() -> Array:
	# 24 rounds, 6 sprints: China (R5), Miami (R6), Austria (R11), USA/COTA (R19), Brazil (R21), Qatar (R23)
	return [
		gp(1, "Bahrain Grand Prix",        "Bahrain Int'l Circuit",           "Bahrain",       "🇧🇭"),
		gp(2, "Saudi Arabian Grand Prix",  "Jeddah Corniche Circuit",         "Saudi Arabia",  "🇸🇦"),
		gp(3, "Australian Grand Prix",     "Albert Park Circuit",             "Australia",     "🇦🇺"),
		gp(4, "Japanese Grand Prix",       "Suzuka Circuit",                  "Japan",         "🇯🇵"),
		gp(5, "Chinese Grand Prix",        "Shanghai International Circuit",  "China",         "🇨🇳", true),
		gp(6, "Miami Grand Prix",          "Miami International Autodrome",   "USA",           "🇺🇸", true),
		gp(7, "Emilia Romagna Grand Prix", "Autodromo Enzo e Dino Ferrari",   "Italy",         "🇮🇹"),
		gp(8, "Monaco Grand Prix",         "Circuit de Monaco",               "Monaco",        "🇲🇨"),
		gp(9, "Canadian Grand Prix",       "Circuit Gilles Villeneuve",       "Canada",        "🇨🇦"),
		gp(10,"Spanish Grand Prix",        "Circuit de Barcelona-Catalunya",  "Spain",         "🇪🇸"),
		gp(11,"Austrian Grand Prix",       "Red Bull Ring",                   "Austria",       "🇦🇹", true),
		gp(12,"British Grand Prix",        "Silverstone Circuit",             "United Kingdom","🇬🇧"),
		gp(13,"Hungarian Grand Prix",      "Hungaroring",                     "Hungary",       "🇭🇺"),
		gp(14,"Belgian Grand Prix",        "Circuit de Spa-Francorchamps",   "Belgium",       "🇧🇪"),
		gp(15,"Dutch Grand Prix",          "Circuit Zandvoort",               "Netherlands",   "🇳🇱"),
		gp(16,"Italian Grand Prix",        "Autodromo Nazionale Monza",      "Italy",         "🇮🇹"),
		gp(17,"Azerbaijan Grand Prix",     "Baku City Circuit",               "Azerbaijan",    "🇦🇿"),
		gp(18,"Singapore Grand Prix",      "Marina Bay Street Circuit",      "Singapore",     "🇸🇬"),
		gp(19,"United States Grand Prix",  "Circuit of the Americas",        "USA",           "🇺🇸", true),
		gp(20,"Mexican Grand Prix",        "Autodromo Hermanos Rodriguez",   "Mexico",        "🇲🇽"),
		gp(21,"São Paulo Grand Prix",      "Autodromo Jose Carlos Pace",     "Brazil",        "🇧🇷", true),
		gp(22,"Las Vegas Grand Prix",      "Las Vegas Strip Circuit",        "USA",           "🇺🇸"),
		gp(23,"Qatar Grand Prix",          "Lusail International Circuit",    "Qatar",         "🇶🇦", true),
		gp(24,"Abu Dhabi Grand Prix",      "Yas Marina Circuit",             "UAE",           "🇦🇪"),
	]


static func _2025() -> Array:
	# 24 rounds, 6 sprints: China (R2), Miami (R6), Belgium (R13), USA/COTA (R19), Brazil (R21), Qatar (R23)
	return [
		gp(1, "Australian Grand Prix",     "Albert Park Circuit",             "Australia",     "🇦🇺"),
		gp(2, "Chinese Grand Prix",        "Shanghai International Circuit",  "China",         "🇨🇳", true),
		gp(3, "Japanese Grand Prix",       "Suzuka Circuit",                  "Japan",         "🇯🇵"),
		gp(4, "Bahrain Grand Prix",        "Bahrain Int'l Circuit",           "Bahrain",       "🇧🇭"),
		gp(5, "Saudi Arabian Grand Prix",  "Jeddah Corniche Circuit",         "Saudi Arabia",  "🇸🇦"),
		gp(6, "Miami Grand Prix",          "Miami International Autodrome",   "USA",           "🇺🇸", true),
		gp(7, "Emilia Romagna Grand Prix", "Autodromo Enzo e Dino Ferrari",   "Italy",         "🇮🇹"),
		gp(8, "Monaco Grand Prix",         "Circuit de Monaco",               "Monaco",        "🇲🇨"),
		gp(9, "Spanish Grand Prix",        "Circuit de Barcelona-Catalunya",  "Spain",         "🇪🇸"),
		gp(10,"Canadian Grand Prix",       "Circuit Gilles Villeneuve",       "Canada",        "🇨🇦"),
		gp(11,"Austrian Grand Prix",       "Red Bull Ring",                   "Austria",       "🇦🇹"),
		gp(12,"British Grand Prix",        "Silverstone Circuit",             "United Kingdom","🇬🇧"),
		gp(13,"Belgian Grand Prix",        "Circuit de Spa-Francorchamps",   "Belgium",       "🇧🇪", true),
		gp(14,"Hungarian Grand Prix",      "Hungaroring",                     "Hungary",       "🇭🇺"),
		gp(15,"Dutch Grand Prix",          "Circuit Zandvoort",               "Netherlands",   "🇳🇱"),
		gp(16,"Italian Grand Prix",        "Autodromo Nazionale Monza",      "Italy",         "🇮🇹"),
		gp(17,"Azerbaijan Grand Prix",     "Baku City Circuit",               "Azerbaijan",    "🇦🇿"),
		gp(18,"Singapore Grand Prix",      "Marina Bay Street Circuit",      "Singapore",     "🇸🇬"),
		gp(19,"United States Grand Prix",  "Circuit of the Americas",        "USA",           "🇺🇸", true),
		gp(20,"Mexican Grand Prix",        "Autodromo Hermanos Rodriguez",   "Mexico",        "🇲🇽"),
		gp(21,"São Paulo Grand Prix",      "Autodromo Jose Carlos Pace",     "Brazil",        "🇧🇷", true),
		gp(22,"Las Vegas Grand Prix",      "Las Vegas Strip Circuit",        "USA",           "🇺🇸"),
		gp(23,"Qatar Grand Prix",          "Lusail International Circuit",    "Qatar",         "🇶🇦", true),
		gp(24,"Abu Dhabi Grand Prix",      "Yas Marina Circuit",             "UAE",           "🇦🇪"),
	]


static func _2026() -> Array:
	# 24 rounds, 6 sprints: China (R2), Miami (R6), Belgium (R13), USA/COTA (R19), Brazil (R21), Qatar (R23)
	# New teams join: Cadillac (formerly Andretti), Audi replaces Sauber/Alfa Romeo
	return [
		gp(1, "Australian Grand Prix",     "Albert Park Circuit",             "Australia",     "🇦🇺"),
		gp(2, "Chinese Grand Prix",        "Shanghai International Circuit",  "China",         "🇨🇳", true),
		gp(3, "Japanese Grand Prix",       "Suzuka Circuit",                  "Japan",         "🇯🇵"),
		gp(4, "Bahrain Grand Prix",        "Bahrain Int'l Circuit",           "Bahrain",       "🇧🇭"),
		gp(5, "Saudi Arabian Grand Prix",  "Jeddah Corniche Circuit",         "Saudi Arabia",  "🇸🇦"),
		gp(6, "Miami Grand Prix",          "Miami International Autodrome",   "USA",           "🇺🇸", true),
		gp(7, "Emilia Romagna Grand Prix", "Autodromo Enzo e Dino Ferrari",   "Italy",         "🇮🇹"),
		gp(8, "Monaco Grand Prix",         "Circuit de Monaco",               "Monaco",        "🇲🇨"),
		gp(9, "Spanish Grand Prix",        "Circuit de Barcelona-Catalunya",  "Spain",         "🇪🇸"),
		gp(10,"Canadian Grand Prix",       "Circuit Gilles Villeneuve",       "Canada",        "🇨🇦"),
		gp(11,"Austrian Grand Prix",       "Red Bull Ring",                   "Austria",       "🇦🇹"),
		gp(12,"British Grand Prix",        "Silverstone Circuit",             "United Kingdom","🇬🇧"),
		gp(13,"Belgian Grand Prix",        "Circuit de Spa-Francorchamps",   "Belgium",       "🇧🇪", true),
		gp(14,"Hungarian Grand Prix",      "Hungaroring",                     "Hungary",       "🇭🇺"),
		gp(15,"Dutch Grand Prix",          "Circuit Zandvoort",               "Netherlands",   "🇳🇱"),
		gp(16,"Italian Grand Prix",        "Autodromo Nazionale Monza",      "Italy",         "🇮🇹"),
		gp(17,"Azerbaijan Grand Prix",     "Baku City Circuit",               "Azerbaijan",    "🇦🇿"),
		gp(18,"Singapore Grand Prix",      "Marina Bay Street Circuit",      "Singapore",     "🇸🇬"),
		gp(19,"United States Grand Prix",  "Circuit of the Americas",        "USA",           "🇺🇸", true),
		gp(20,"Mexican Grand Prix",        "Autodromo Hermanos Rodriguez",   "Mexico",        "🇲🇽"),
		gp(21,"São Paulo Grand Prix",      "Autodromo Jose Carlos Pace",     "Brazil",        "🇧🇷", true),
		gp(22,"Las Vegas Grand Prix",      "Las Vegas Strip Circuit",        "USA",           "🇺🇸"),
		gp(23,"Qatar Grand Prix",          "Lusail International Circuit",    "Qatar",         "🇶🇦", true),
		gp(24,"Abu Dhabi Grand Prix",      "Yas Marina Circuit",             "UAE",           "🇦🇪"),
	]
