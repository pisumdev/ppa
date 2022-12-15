extends Control

@export var platformer: PackedScene
@export var picross: PackedScene
@export var pong: PackedScene

@onready var games = [platformer, picross, pong]
@onready var selected_game_label = $SelectedGame
var selected_game = 0


func _process(_delta):
	if (Input.is_action_just_pressed("left") or
		Input.is_action_just_pressed("up")):
			change_selection(1)
	elif (Input.is_action_just_pressed("right") or
		Input.is_action_just_pressed("down")):
			change_selection(-1)
	if (Input.is_action_just_pressed("enter") or
		Input.is_action_just_pressed("jump")):
		load_game()

func load_game():
	get_tree().change_scene_to_packed(games[selected_game])

func change_selection(amount):
	print(selected_game)
	selected_game += amount
	if selected_game >= games.size():
		selected_game = 0
	elif selected_game < 0:
		selected_game = games.size() - 1
	
	if selected_game == 0:
		selected_game_label.text = "< PISUM PLATFORMER >"
	elif selected_game == 1:
		selected_game_label.text = "< PISUM PICROSS >"
	elif selected_game == 2:
		selected_game_label.text = "< PISUM PONG >"
	else:
		selected_game_label.text = "ERROR"
