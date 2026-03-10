extends Node
class_name TireModel

enum Compound { SOFT, MEDIUM, HARD }

# Grip multipliers per compound
const GRIP: Dictionary = {
	Compound.SOFT:   1.10,
	Compound.MEDIUM: 1.00,
	Compound.HARD:   0.92,
}

# Degradation rate per lap (0..1 range, 1=fully degraded)
const DEG_RATE: Dictionary = {
	Compound.SOFT:   0.045,
	Compound.MEDIUM: 0.028,
	Compound.HARD:   0.018,
}

# Thermal: laps to reach peak grip
const WARMUP_LAPS: Dictionary = {
	Compound.SOFT:   1.0,
	Compound.MEDIUM: 1.5,
	Compound.HARD:   2.5,
}

var compound: Compound = Compound.MEDIUM
var degradation: float = 0.0   # 0=new, 1=fully worn
var laps_on_tire: int = 0
var deg_rate_multiplier: float = 1.0  # from upgrades


func set_compound(c: Compound) -> void:
	compound = c
	degradation = 0.0
	laps_on_tire = 0


func on_lap_completed() -> void:
	laps_on_tire += 1
	var rate: float = DEG_RATE[compound] * deg_rate_multiplier
	degradation = clampf(degradation + rate, 0.0, 1.0)


func get_grip_factor() -> float:
	var base_grip: float = GRIP[compound]
	# Warmup penalty: below peak until warmed up
	var warmup: float = WARMUP_LAPS[compound]
	var warmup_factor: float = clampf(float(laps_on_tire) / warmup, 0.2, 1.0)
	# Degradation reduces grip linearly once past 50%
	var deg_factor: float = 1.0 - clampf((degradation - 0.5) * 2.0, 0.0, 0.35)
	return base_grip * warmup_factor * deg_factor


func get_deg_percentage() -> float:
	return degradation * 100.0


func get_compound_name() -> String:
	match compound:
		Compound.SOFT:   return "SOFT"
		Compound.MEDIUM: return "MEDIUM"
		Compound.HARD:   return "HARD"
	return "MEDIUM"


func should_pit_recommend() -> bool:
	return degradation > 0.75


func apply_tire_upgrade(level: int) -> void:
	deg_rate_multiplier = 1.0 - level * 0.08  # up to 32% less deg at lvl 4
	deg_rate_multiplier = maxf(deg_rate_multiplier, 0.5)
