extends Control

var playerStats = PlayerStats

onready var fuel_full = $FuelGauge/FuelFull
onready var fuel_label = $FuelGauge/Label

func _process(delta: float) -> void:
	var fuel_amt = playerStats.FUEL_AMT
	fuel_label.text = str(fuel_amt) + "/100"
	fuel_full.rect_size.x = fuel_amt * 5
