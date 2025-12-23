# Player.gd
extends CharacterBody2D

@onready var camera = $Camera2D
# Movement Constants
const SPEED_WALK = 150.0 / 2       # Horizontal movement speed (pixels/second)
const SPEED_SPRINT = SPEED_WALK * 2       # Horizontal movement speed (pixels/second)
const JUMP_VELOCITY = -300.0 # Jump strength (negative because Y goes down)

# Gravity - you can get it from project settings or define it here
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Other variables you might need
var air_jumps = 1         # For a double jump
var current_air_jumps = 0

# Variables for "game feel" techniques (we'll initialize them later)
var sprint = false
var coyote_timer = 0.0
const COYOTE_TIME_THRESHOLD = 0.1 # 100 milliseconds of coyote time

var jump_buffer_timer = 0.0
const JUMP_BUFFER_TIME_THRESHOLD = 0.1 # 100 milliseconds for jump buffer

var door = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Action"):
		#camera.limit_enabled = not camera.limit_enabled
		pass

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Reset air jumps and coyote time when on the floor
		current_air_jumps = air_jumps
		coyote_timer = COYOTE_TIME_THRESHOLD # Reload coyote time

	# Update timers
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Handle Jump input (with buffer and coyote time)
	if Input.is_action_just_pressed("jump"): # "jump" is an action defined in InputMap
		jump_buffer_timer = JUMP_BUFFER_TIME_THRESHOLD
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5 # Short jump when releasing jump button early

	if jump_buffer_timer > 0:
		if is_on_floor() or coyote_timer > 0: # Normal jump or coyote time jump
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0 # Consume buffer
			coyote_timer = 0 # Consume coyote time if used
		elif current_air_jumps > 0: # Air jump (double jump, etc.)
			velocity.y = JUMP_VELOCITY * 0.8 # Perhaps a bit weaker
			current_air_jumps -= 1
			jump_buffer_timer = 0 # Consume buffer

	# Handle Horizontal input
	var direction = Input.get_axis("move_left", "move_right") # "move_left" & "move_right" from InputMap
	if Input.is_action_just_pressed("sprint"):
		sprint = true
	elif Input.is_action_just_released("sprint"):
		sprint = false
	# Movement with simple acceleration/deceleration
	if sprint and direction:
		velocity.x = move_toward(velocity.x, direction * SPEED_SPRINT, SPEED_SPRINT * 2.0 * delta)
	elif direction:
		# We use move_toward for basic acceleration/deceleration
		velocity.x = move_toward(velocity.x, direction * SPEED_WALK, SPEED_WALK * 2.0 * delta) # Last value is acceleration
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_SPRINT * 2.0 * delta) # Decelerate to a stop
	
	# Flip sprite based on velocity direction, not input direction
	if $AnimatedSprite2D: # Ensure the node exists
		# Only flip when velocity is significant enough to avoid jittering
		if abs(velocity.x) > 10: # Threshold to prevent flipping when barely moving
			# Flip when moving left (negative velocity)
			$AnimatedSprite2D.flip_h = (velocity.x < 0)
		# Note: when velocity.x is 0, we don't change the flip state
		# This maintains the last facing direction when stopping

	# Rooms
	if door and Input.is_action_just_pressed("Action"):
		if self.collision_layer == 2:
			self.set_collision_layer_value(2, false)
			self.set_collision_mask_value(2, false)
			self.set_collision_layer_value(3, true)
			self.set_collision_mask_value(3, true)
		elif self.collision_layer == 3:
			self.set_collision_layer_value(3, false)
			self.set_collision_mask_value(3, false)
			self.set_collision_layer_value(2, true)
			self.set_collision_mask_value(2, true)

		$"../Rooms".visible = not $"../Rooms".visible
		$"../Building hall".visible = not $"../Building hall".visible

	move_and_slide()

	# Update animations
	update_animations()

func update_animations():
	if not $AnimatedSprite2D: return # Exit if no AnimatedSprite2D

	if not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.play("jump")
		else:
			$AnimatedSprite2D.play("fall")
	else:
		if sprint and abs(velocity.x) > 5:
			$AnimatedSprite2D.play("run")
		elif abs(velocity.x) > 5: # A small threshold to avoid switching to "run" if barely moving
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")

func _on_door_body_entered(body: Node2D) -> void:
	print("DOOR") # Replace with function body.
	door = true
	
	
 # Replace with function body.
func _on_door_body_exited(body: Node2D) -> void:
	door = false # Replace with function body.


func _on_door_2_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_door_2_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
