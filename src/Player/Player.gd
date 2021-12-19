extends KinematicBody2D

# Jet speeds
export var jet_speed := 100
export var max_speed := 200

# Collision Speeds
export var friction := 10
export var collision_friction := 140

# Falling Speeds
export var max_fall_speed := 400
export var gravity := 100
export var gravity_enabled = true

onready var forehead := $Position2D
onready var raycast_n := $Raycasts/RayCastNorth
onready var raycast_s := $Raycasts/RayCastSouth
onready var raycast_e := $Raycasts/RayCastEast
onready var raycast_w := $Raycasts/RayCastWest


var velocity := Vector2.ZERO
var input_vector := Vector2.ZERO

func _ready() -> void:
	is_on_collider()

func _process(delta: float) -> void:
	update()
	
func _draw() -> void:
	var forehead_pos = forehead.position
	draw_line(forehead_pos, (forehead_pos + input_vector) * 100, Color.coral)

func _physics_process(delta: float) -> void:
	input_vector = calculate_input_vector()
	if Input.is_action_pressed("jet"):
		if gravity_enabled:
			var new_vector = Vector2.ZERO
			new_vector.x = input_vector.x * -max_speed
			new_vector.y = input_vector.y * -max_speed + gravity
			velocity = velocity.move_toward(new_vector, jet_speed * delta)			
		else:
			velocity = velocity.move_toward(input_vector * -max_speed, jet_speed * delta)
	elif is_on_collider():
		velocity = velocity.move_toward(Vector2.ZERO, collision_friction * delta)
	elif gravity_enabled:
		var falling_velocity = Vector2(velocity.x, gravity)
		velocity = velocity.move_toward(falling_velocity, max_speed * delta)
	velocity = move_and_slide(velocity)
	
func is_on_collider() -> bool:
	return raycast_n.is_colliding() or raycast_s.is_colliding() or raycast_e.is_colliding() or raycast_w.is_colliding()

func calculate_input_vector() -> Vector2:
	var vector = Vector2.ZERO
	vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	vector = vector.normalized()
	
	return vector

func is_moving_diagonally(vector: Vector2) -> bool:
	var moving_diagonally = false
	
	if vector.x == 1 or vector.x == -1:
		if vector.y == 1 or vector.y == -1:
			moving_diagonally = true
	
	return moving_diagonally

# TODO: Remove this
func _on_UI_toggle_gravity(enabled: bool) -> void:
	gravity_enabled = enabled
