extends KinematicBody2D

var playerStats := PlayerStats

# boost speeds
export var fuel_burn_rate := 10
export var boost_speed := 100
export var max_speed := 200

# Collision Speeds
export var friction := 10
export var collision_friction := 140

# Falling Speeds
export var max_fall_speed := 400
export var gravity := 100
export var gravity_enabled = true

# Where to draw the booster line
onready var forehead := $Position2D
# The raycasts
onready var raycast_n := $Raycasts/RayCastNorth
onready var raycast_s := $Raycasts/RayCastSouth
onready var raycast_e := $Raycasts/RayCastEast
onready var raycast_w := $Raycasts/RayCastWest
onready var boost_timer := $BoostTimer

enum State {
	BOOST,
	IDLE,
}

var state = State.IDLE
var velocity := Vector2.ZERO
var input_vector := Vector2.ZERO

# TODO: Remove this
func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		playerStats.FUEL_AMT = 100
		print("refueling:", playerStats.FUEL_AMT)
		
func _process(delta: float) -> void:
	update()
	
func _draw() -> void:
	var forehead_pos = forehead.position
	draw_line(forehead_pos, (forehead_pos + input_vector) * 100, Color.coral)

func _physics_process(delta: float) -> void:
	toggle_timer_state()

#	Calculate input vector
	input_vector = calculate_input_vector()
	
	match state:
		State.BOOST:
			boost(delta)
		State.IDLE:
			if is_on_surface(): 
				stick_to_surface(delta)
			elif gravity_enabled:
				fall(delta)

	if Input.is_action_pressed("jet") and playerStats.FUEL_AMT > 0:
		state = State.BOOST
	else:
		state = State.IDLE
	
	velocity = move_and_slide(velocity)

func toggle_timer_state() -> void:
	if Input.is_action_just_pressed("jet"):
		boost_timer.start(0.1)
	if Input.is_action_just_released("jet"):
		boost_timer.stop()

func boost(delta: float) -> void:
	if gravity_enabled:
		var new_vector = Vector2.ZERO
		new_vector.x = input_vector.x * -max_speed
		new_vector.y = input_vector.y * -max_speed + gravity
		velocity = velocity.move_toward(new_vector, boost_speed * delta)
	else:
		velocity = velocity.move_toward(input_vector * -max_speed, boost_speed * delta)

func stick_to_surface(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, collision_friction * delta)

func fall(delta: float) -> void:
	var falling_velocity = Vector2(velocity.x, gravity)
	velocity = velocity.move_toward(falling_velocity, max_speed * delta)

func is_on_surface() -> bool:
	return raycast_n.is_colliding() or raycast_s.is_colliding() or raycast_e.is_colliding() or raycast_w.is_colliding()

func calculate_input_vector() -> Vector2:
	var vector = Vector2.ZERO
	vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	vector = vector.normalized()
	
	return vector

# TODO: Remove this
func _on_UI_toggle_gravity(enabled: bool) -> void:
	gravity_enabled = enabled


func _on_BoostTimer_timeout() -> void:
	var burn_rate = fuel_burn_rate / 10
	if state == State.BOOST and playerStats.FUEL_AMT > 0:
		playerStats.FUEL_AMT -= burn_rate
	print("loosing fuel:",playerStats.FUEL_AMT)
