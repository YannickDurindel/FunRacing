extends Node
class_name PointsTable

const TABLE: Dictionary = {
	1: 25, 2: 18, 3: 15, 4: 12, 5: 10,
	6: 8,  7: 6,  8: 4,  9: 2,  10: 1
}


static func get_points(position: int) -> int:
	return TABLE.get(position, 0)


static func format_results(results: Array) -> Array:
	# results: [{car_id, driver_id, position, ...}]
	var formatted: Array = []
	for r in results:
		formatted.append({
			"driver_id": r["driver_id"],
			"team_id":   r.get("team_id", ""),
			"position":  r["position"],
			"points":    TABLE.get(r["position"], 0),
			"best_lap":  r.get("best_lap", 0.0)
		})
	return formatted
