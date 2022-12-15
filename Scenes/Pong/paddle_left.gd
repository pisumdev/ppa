extends Area2D

@export var speed = 240
@export var gap_offset = 5

@onready var window_size = Vector2(240, 160)
@onready var sprite_height = $CollisionShape2D.shape.size.y


func _ready():
	hide()


func _process(delta):
	if visible:
		if (Input.is_action_pressed("player1_up") and position.y - sprite_height / 2 - gap_offset > 0):
			position.y -= speed * delta
		if (Input.is_action_pressed("player1_down") and position.y + sprite_height / 2 + gap_offset < window_size.y):
			position.y += speed * delta


func _on_interface_start_game(_play_mode, _difficult_mode, _goal_count):
	show()


func _on_interface_end_game():
	position.y = window_size.y / 2
	hide()
