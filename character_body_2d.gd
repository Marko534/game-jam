extends CharacterBody2D

const max_speed := 40.0
const min_speed := 8.0
const time_to_max_speed := 0.1
const time_to_stop := 0.05
const time_to_turn := 0.05

# Add sprint multiplier
const sprint_multiplier := 2.0  # 50% faster when sprinting

var acceleration := max_speed / time_to_max_speed
var friction := max_speed / time_to_stop
var turn_speed := max_speed / time_to_turn

var dir_input := Vector2.ZERO

func _physics_process(delta: float) -> void:
	dir_input = Input.get_vector("West", "East", "North", "South")
	
	# Check if sprint key is pressed (assuming it's mapped to "sprint" action)
	var is_sprinting = Input.is_action_pressed("Sprint")
	
	# Calculate current max speed based on sprinting
	var current_max_speed = max_speed * sprint_multiplier if is_sprinting else max_speed
	
	if dir_input != Vector2.ZERO:
		if !dir_input.normalized().is_equal_approx(velocity.normalized()):
			velocity += dir_input * turn_speed * delta
		else:
			velocity += dir_input * acceleration * delta
		
		# Use current_max_speed instead of max_speed
		if velocity.length() > current_max_speed:
			velocity = velocity.normalized() * current_max_speed
	elif velocity != Vector2.ZERO:
		velocity -= velocity.normalized() * friction * delta 
		if velocity.length() < min_speed:
			velocity = Vector2.ZERO
	
	move_and_slide()
