extends CharacterBody2D

@onready var sfx_jump = $sfx_jump
@onready var sfx_ghosted = $sfx_ghosted
@onready var sfx_unghosted = $sfx_unghosted
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME = 0.2
const JUMP_HOLD_TIME = 0.2
const JUMP_HOLD_MULTIPLIER = 2.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = true
var last_grounded_position
var time_since_grounded = COYOTE_TIME
var time_since_jumped = JUMP_HOLD_TIME
var is_ghost = false

func _ready():
	floor_constant_speed = true


func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")


func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	movement(delta, direction)
	update_animation_state(direction)


func movement(delta, direction):
	# Jump through cloud when ghost
	if (is_ghost and velocity.y <0):
		collision_mask = 4
	elif is_ghost:
		collision_mask = 4 + 32
	
	# Reset when falling off map
	if is_on_floor():
		last_grounded_position = position
	if position.y > 270:
		position = last_grounded_position
		velocity = Vector2.ZERO
		if !is_ghost:
			toggle_ghost()
		
	# Handle Gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle Jump.
	if is_on_floor():
		time_since_grounded = 0
	else:
		time_since_grounded += delta
	
	if Input.is_action_pressed("jump"):
		if time_since_grounded < COYOTE_TIME:
			sfx_jump.play()
			velocity.y = JUMP_VELOCITY
			time_since_grounded = COYOTE_TIME
			time_since_jumped = 0
		elif time_since_jumped < JUMP_HOLD_TIME:
			time_since_jumped += delta
			velocity.y += JUMP_VELOCITY * JUMP_HOLD_MULTIPLIER * delta
			
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()


func update_animation_state(direction):
	if direction < 0:
		facing_right = false
	elif direction > 0:
		facing_right = true
	
	if is_ghost:
		if facing_right:
			state_machine.travel("ghost_right")
		else:
			state_machine.travel("ghost_left")
		return
	if velocity == Vector2.ZERO:
		if facing_right:
			state_machine.travel("idle_right")
		else:
			state_machine.travel("idle_left")
	elif time_since_grounded < COYOTE_TIME:
		if facing_right:
			state_machine.travel("walk_right")
		else:
			state_machine.travel("walk_left")
	else:
		if facing_right:
			state_machine.travel("fall_right")
		else:
			state_machine.travel("fall_left")


func toggle_ghost():
	is_ghost = !is_ghost
	if is_ghost:
		sfx_ghosted.play()
		collision_mask = 4 + 32 # (Ground + Cloud)
	else:
		sfx_unghosted.play()
		collision_mask = 4 + 8 # (Ground + Brick)


func _on_mob_detector_body_entered(body):
	if (body.collision_layer == 2 and !is_ghost): # Mob layer
		toggle_ghost()
	elif (body.collision_layer == 16 and is_ghost): # Coin layer
		toggle_ghost()
