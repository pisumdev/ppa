extends Control

signal start_game(play_mode, difficulty_mode, goal_count)
signal end_game()

@onready var winner_text = $WinnerText
@onready var game_rules = $GameRules
@onready var game_rules_goal_select_rects = $GameRules/GoalSelect/SelectRects
@onready var game_rules_diff_select_rects = $GameRules/DifficultySelect/SelectRects
@onready var game_rules_goal_select = $GameRules/GoalSelect
@onready var game_rules_diff_select = $GameRules/DifficultySelect
@onready var hud = $HUD
@onready var player_one_score_text = $HUD/PlayerOneScore
@onready var player_two_score_text = $HUD/PlayerTwoScore
@onready var title_screen = $TitleScreen
@onready var one_player_select = $TitleScreen/OnePlayerSelect
@onready var one_player_select_rect = $TitleScreen/OnePlayerSelect/SelectRect
@onready var two_player_select = $TitleScreen/TwoPlayerSelect
@onready var two_player_select_rect = $TitleScreen/TwoPlayerSelect/SelectRect
@onready var selection_position_x = one_player_select.position.x

var difficulty = 0
var goal = 10
var one_player_selected = false
var player_one_score = 0
var player_two_score = 0
var player_count

func _ready():
	winner_text.hide()
	title_screen_switch_selected()
	game_rules_switch_selected()
	game_rules_switch_selected()
	hud.hide()
	game_rules.hide()


func _process(delta):
	if title_screen.visible:
		title_screen_logic()
	elif hud.visible:
		hud_logic()
		if (winner_text.visible and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("space"))):
			switch_to_title_screen_interface()
	elif game_rules.visible:
		game_rules_logic()

func title_screen_logic():
	if Input.is_action_just_pressed("up_or_down"):
		title_screen_switch_selected()
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("space")):
		if one_player_selected:
			switch_to_game_rules_interface()
			player_count = 1
		else:
			switch_to_game_rules_interface()
			player_count = 2
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")


func hud_logic():
	if Input.is_action_just_pressed("escape"):
		switch_to_title_screen_interface()
	if (player_one_score >= goal or player_two_score >= goal):
		switch_to_winner_screen_interface()


func game_rules_logic():
	if Input.is_action_just_pressed("escape"):
		switch_to_title_screen_interface()
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("space")):
		switch_to_game_interface()
	if Input.is_action_just_pressed("up_or_down"):
		game_rules_switch_selected()
	if Input.is_action_just_pressed("left_or_right"):
		if game_rules_diff_select_rects.visible:
			if Input.is_action_just_pressed("right"):
				difficulty -= 1
			else:
				difficulty += 1
			if difficulty > 2:
				difficulty = 0
			elif difficulty < 0:
				difficulty = 2
		else:
			if Input.is_action_just_pressed("left"):
				goal -= 5
			else:
				goal += 5
			if goal > 95:
				goal = 10
			elif goal < 10:
				goal = 95
	
	game_rules_goal_select.text = str(goal)
	if difficulty == 0:
		game_rules_diff_select.text = "easy"
	elif difficulty == 1:
		game_rules_diff_select.text = "norm"
	else:
		game_rules_diff_select.text = "hard"


func title_screen_switch_selected():
	if !one_player_selected:
		one_player_select_rect.show()
		one_player_select.position.x = selection_position_x + 2
		two_player_select_rect.hide()
		two_player_select.position.x = selection_position_x
	else:
		two_player_select_rect.show()
		two_player_select.position.x = selection_position_x + 2
		one_player_select_rect.hide()
		one_player_select.position.x = selection_position_x
	one_player_selected = !one_player_selected


func game_rules_switch_selected():
	if game_rules_diff_select_rects.visible:
		game_rules_diff_select_rects.hide()
		game_rules_goal_select_rects.show()
	else:
		game_rules_diff_select_rects.show()
		game_rules_goal_select_rects.hide()


func switch_to_game_interface():
	emit_signal("start_game", player_count, difficulty, goal)
	game_rules.hide()
	hud.show()
	update_score_text()


func switch_to_game_rules_interface():
	game_rules.show()
	title_screen.hide()


func switch_to_title_screen_interface():
	emit_signal("end_game")
	player_one_score = 0
	player_two_score = 0
	winner_text.hide()
	hud.hide()
	game_rules.hide()
	title_screen.show()

func switch_to_winner_screen_interface():
	emit_signal("end_game")
	if player_one_score > player_two_score:
		winner_text.text = "Player one wins!"
	elif one_player_selected:
		winner_text.text = "CPU wins!"
	else:
		winner_text.text = "Player two wins!"
	winner_text.show()

func update_score_text():
	player_one_score_text.text = str(player_one_score)
	player_two_score_text.text = str(player_two_score)


func _on_ball_player_one_scored():
	player_one_score += 1
	update_score_text()


func _on_ball_player_two_scored():
	player_two_score += 1
	update_score_text()

func _on_return_timer_timeout():
	print("test")
	switch_to_title_screen_interface()
	winner_text.hide()
