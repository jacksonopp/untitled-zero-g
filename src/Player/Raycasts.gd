extends Node2D


onready var south := $RayCastSouth
onready var north := $RayCastNorth
onready var east := $RayCastEast
onready var west := $RayCastWest

var raycasts = []
var collision_emitted = false

signal landed_on_surface

func _ready() -> void:
	raycasts = get_children()

func _physics_process(_delta: float) -> void:
	var number_of_collisions = 0
	for raycast in raycasts:
		if raycast.is_colliding():
			number_of_collisions += 1
	
	if number_of_collisions > 0:
		if !collision_emitted:
			emit_signal("landed_on_surface")
			collision_emitted = true
	else:
		collision_emitted = false
