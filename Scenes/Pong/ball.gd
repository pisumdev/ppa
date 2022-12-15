extends Area2D

signal player_one_scored()
signal player_two_scored()

@export var speed = 150

@export var paddle_left = Area2D
@export var paddle_right = Area2D

@onready var window_size = Vector2(240, 160)
@onready var sprite_size = $CollisionShape2D.shape.size.y
@onready var start_timer = $StartTimer
@onready var paddle_bounce_sfx = $PaddleBounce
@onready var window_bounce_sfx = $WindowBounce
@onready var ball_lost_sfx = $BallLost

var velocity = Vector2.ZERO

func _ready():
	hide()


func _process(delta):
	if visible:
		move_ball(delta)
		window_bounce()
		score()


func move_ball(delta):
	if velocity == Vector2.ZERO:
		return
	if velocity.x > 0:
		velocity.x = 1
	else:
		velocity.x = -1
	position += velocity * speed * delta


func window_bounce():
	if (position.y < 0 + sprite_size / 2):
		position.y = 0 + sprite_size / 2
	elif (position.y > window_size.y - sprite_size / 2):
		position.y = window_size.y - sprite_size / 2
	else:
		return
	velocity.y *= -1
	window_bounce_sfx.play()


func score():
	if (position.x + sprite_size / 2 < 0):
		start_timer.start()
		player_two_scored.emit()
		ball_lost_sfx.play()
	elif (position.x - sprite_size / 2 > window_size.x):
		start_timer.start()
		player_one_scored.emit()
		ball_lost_sfx.play()
	else:
		return
	position.x = window_size.x / 2
	position.y = window_size.y / 2
	velocity = Vector2.ZERO


func reset_ball(direction):	
	velocity = Vector2(randf_range(0.3, 1),randf_range(0, 1))
	
	if direction == 0:
		velocity.x *= -1
	elif direction != 1:
		print("invalid direction given for ball.reset_ball()")
	
	if (randi_range(0,1) == 0):
		velocity.y *= -1
	velocity = velocity.normalized()


func _on_interface_start_game(_play_mode, _difficult_mode, _goal_count):
	start_timer.start()
	#reset_ball(randi_range(0,1))
	show()


func paddle_bounce():
	velocity.x *= -1
	if (position.x > window_size.x / 2): # Right Paddle
		velocity.y = (paddle_right.position.y - position.y) * -1 / 10
	else: # Left Paddle
		velocity.y = (paddle_left.position.y - position.y) * -1 / 10
	velocity = velocity.normalized()
	paddle_bounce_sfx.play()

func _on_paddle_left_area_entered(_area):
	paddle_bounce()


func _on_paddle_right_area_entered(_area):
	paddle_bounce()


func _on_start_timer_timeout():
	reset_ball(randi_range(0,1))


func _on_interface_end_game():
	start_timer.stop()
	velocity = Vector2.ZERO
	position = window_size / 2
	hide()
