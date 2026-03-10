extends Resource
class_name CareerData

@export var schema_version: int = 1
@export var player_name: String = "Player"
@export var player_team_id: String = "team_aurora"
@export var car_number: int = 44
@export var season_number: int = 1
@export var prize_money: int = 0

@export var calendar: Array = []
@export var driver_championship: Array = []
@export var constructor_championship: Array = []
@export var personal_bests: Dictionary = {}

@export var upgrades: Dictionary = {
	"engine": {"level": 0, "spent": 0},
	"aero":   {"level": 0, "spent": 0},
	"brakes": {"level": 0, "spent": 0},
	"tires":  {"level": 0, "spent": 0},
	"ers":    {"level": 0, "spent": 0}
}


func to_dict() -> Dictionary:
	return {
		"schema_version": schema_version,
		"player": {
			"name": player_name,
			"team_id": player_team_id,
			"car_number": car_number
		},
		"season_number": season_number,
		"calendar": calendar,
		"driver_championship": driver_championship,
		"constructor_championship": constructor_championship,
		"upgrades": upgrades,
		"prize_money": prize_money,
		"personal_bests": personal_bests
	}


static func from_dict(d: Dictionary):
	var cd = load("res://scripts/career/career_data.gd").new()
	cd.schema_version = d.get("schema_version", 1)
	var player: Dictionary = d.get("player", {})
	cd.player_name = player.get("name", "Player")
	cd.player_team_id = player.get("team_id", "team_aurora")
	cd.car_number = player.get("car_number", 44)
	cd.season_number = d.get("season_number", 1)
	cd.calendar = d.get("calendar", [])
	cd.driver_championship = d.get("driver_championship", [])
	cd.constructor_championship = d.get("constructor_championship", [])
	cd.upgrades = d.get("upgrades", cd.upgrades)
	cd.prize_money = d.get("prize_money", 0)
	cd.personal_bests = d.get("personal_bests", {})
	return cd
