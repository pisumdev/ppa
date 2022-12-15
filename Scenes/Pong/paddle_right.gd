extends Area2D

@export var speed = 240
@export var gap_offset = 5
@export var ball = Area2D

@onready var window_size = Vector2(240, 160)
@onready var sprite_height = $CollisionShape2D.shape.size.y
@onready var cpu_timer = $CpuTimer

var cpu_controlled = false
var cpu_velocity = 0

func _ready():
	hide()


func _process(delta):
	if visible:
		if not cpu_controlled:
			player2_input(delta)
		else:
			cpu_input(delta)
	
	
func player2_input(delta):
	if (Input.is_action_pressed("player2_up") and position.y - sprite_height / 2 - gap_offset > 0):
		position.y -= speed * delta
	if (Input.is_action_pressed("player2_down") and position.y + sprite_height / 2 + gap_offset < window_size.y):
		position.y += speed * delta


func cpu_input(delta):
	position.y += cpu_velocity * speed * delta
	if (position.y - sprite_height / 2 - gap_offset < 0 or position.y + sprite_height / 2 + gap_offset > window_size.y):
		cpu_velocity = 0


func _on_interface_start_game(play_mode, difficult_mode, _goal_count):
	show()
	if play_mode == 1:
		cpu_controlled = true
		if (difficult_mode == 2):
			cpu_timer.wait_time = 0.25
		elif (difficult_mode == 1):
			cpu_timer.wait_time = 0.35
		else:
			cpu_timer.wait_time = 0.45
		cpu_timer.start()
	else:
		cpu_controlled = false


func _on_interface_end_game():
	position.y = window_size.y / 2
	hide()


func _on_cpu_timer_timeout():
	if ball.velocity.x < 0:
		cpu_velocity = 0
		return
	if position.y - sprite_height > ball.position.y:
		cpu_velocity = -1
	elif position.y + sprite_height < ball.position.y:
		cpu_velocity = 1
	else:
		cpu_velocity = 0
