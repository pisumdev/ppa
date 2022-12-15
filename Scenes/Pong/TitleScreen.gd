extends Control

signal start_game(play_mode)

@onready var one_player_select = $OnePlayerSelect
@onready var one_player_select_rect = $OnePlayerSelect/SelectRect
@onready var two_player_select = $TwoPlayerSelect
@onready var two_player_select_rect = $TwoPlayerSelect/SelectRect
@onready var selection_position_x = one_player_select.position.x

var one_player_selected = true

# Called when the node enters the scene tree for the first time.
func _ready():
	switch_selected()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("up_or_down"):
		switch_selected()
	if Input.is_action_just_pressed("ui_accept"):
		if one_player_selected:
			emit_signal("start_game", 1)
			hide()
		else:
			emit_signal("start_game", 2)
			hide()

func switch_selected():
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
