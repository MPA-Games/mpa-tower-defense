extends ComboEffect
class_name ElectroSlowEffect

@export_category("Virus")
@export var virusDuration: float = 6.0
@export var virusTickInterval: float = 1.5

@export var virusSpeedMultiplier: float = 0.75
@export var stunDuration: float = 0.35

@export_category("Virus Spread")
@export var spreadRadius: float = 2.5
@export var maxSpreadTargets: int = 2

@export_category("Upgrade")
@export var upgradeScaling: float = 0.5


func activate(target: Enemy, runtime: Dictionary) -> void:
	if not is_instance_valid(target):
		return

	var comboPower: float = 1.0

	if runtime.has("combo_context"):
		var comboContext: ComboContext = runtime["combo_context"]

		if comboContext != null:
			comboPower = comboContext.powerMultiplier

	var adjustedPower := 1.0 + (
		(comboPower - 1.0) * upgradeScaling
	)

	# -----------------------------------------------------
	# SLOW DEL VIRUS
	# -----------------------------------------------------

	var slowStrength := 1.0 - virusSpeedMultiplier

	slowStrength *= adjustedPower
	slowStrength = clamp(slowStrength, 0.0, 0.95)

	var finalSpeedMultiplier := 1.0 - slowStrength

	# -----------------------------------------------------
	# STUN DEL VIRUS
	# -----------------------------------------------------

	var finalStunDuration := stunDuration * adjustedPower

	# -----------------------------------------------------
	# CREAR VIRUS ORIGINAL
	# -----------------------------------------------------

	var virus := VirusModifier.new()

	virus.duration = virusDuration
	virus.tick_interval = virusTickInterval

	virus.speedMultiplier = finalSpeedMultiplier
	virus.stunDuration = finalStunDuration

	virus.spreadRadius = spreadRadius
	virus.maxSpreadTargets = maxSpreadTargets

	# Solo este primer virus puede contagiar.
	virus.canSpread = true

	target.statusEffectController.add_effect(
		virus,
		&"virus"
	)
	ComboFeedback.show_virus(
	target,
	virusDuration
	)

	runtime["virus_speed_multiplier"] = finalSpeedMultiplier
	runtime["virus_stun_duration"] = finalStunDuration
