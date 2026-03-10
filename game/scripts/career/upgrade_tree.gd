extends Node
class_name UpgradeTree

const COSTS: Array = [0, 50000, 100000, 200000, 350000, 500000]
const MAX_LEVEL: int = 5

const BRANCHES: Array = ["engine", "aero", "brakes", "tires", "ers"]

const DESCRIPTIONS: Dictionary = {
	"engine": ["Base", "+3% Power", "+6% Power", "+9% Power", "+12% Power", "+15% Power"],
	"aero":   ["Base", "+5% Downforce", "+10% Downforce", "+15% Downforce", "+20% Downforce", "+25% Downforce"],
	"brakes": ["Base", "+8% Brake Force", "+16% Brake Force", "+24% Brake Force", "+32% Brake Force", "+40% Brake Force"],
	"tires":  ["Base", "-8% Deg", "-16% Deg", "-24% Deg", "-32% Deg", "-40% Deg"],
	"ers":    ["Base", "+400kJ", "+800kJ", "+1200kJ", "+1600kJ", "+2000kJ"],
}


static func can_afford(career, branch: String) -> bool:
	var current_level: int = career.upgrades[branch]["level"]
	if current_level >= MAX_LEVEL:
		return false
	var cost: int = COSTS[current_level + 1]
	return career.prize_money >= cost


static func purchase(career, branch: String) -> bool:
	if not can_afford(career, branch):
		return false
	var current_level: int = career.upgrades[branch]["level"]
	var cost: int = COSTS[current_level + 1]
	career.prize_money -= cost
	career.upgrades[branch]["level"] += 1
	career.upgrades[branch]["spent"] = career.upgrades[branch].get("spent", 0) + cost
	SaveManager.save_career(career)
	return true


static func get_next_cost(career, branch: String) -> int:
	var current_level: int = career.upgrades[branch]["level"]
	if current_level >= MAX_LEVEL:
		return -1  # maxed
	return COSTS[current_level + 1]


static func get_description(branch: String, level: int) -> String:
	var descs: Array = DESCRIPTIONS.get(branch, [])
	if level < descs.size():
		return descs[level]
	return ""
