extends CharacterBody2D


const SPEED = 50.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = -1
@onready var sprite = $Sprite2D

func _ready():
	floor_constant_speed = true
	randomize()
	if randi_range(0, 1):
		change_direction()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func change_direction():
	direction *= -1
	sprite.flip_h = !sprite.flip_h

func _on_mob_detector_body_entered(body):
	change_direction()
