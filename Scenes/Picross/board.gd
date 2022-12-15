extends Control

@export var tile_scene: PackedScene

@onready var miss_counter_label = $MissCounter

@onready var board_inside = $BoardInside
@onready var row_hints_label = $RowHints

@onready var column_hints_labels = [$ColumnHints/ColumnHints0,
									$ColumnHints/ColumnHints1,
									$ColumnHints/ColumnHints2,
									$ColumnHints/ColumnHints3,
									$ColumnHints/ColumnHints4,
									$ColumnHints/ColumnHints5,
									$ColumnHints/ColumnHints6,
									$ColumnHints/ColumnHints7,
									$ColumnHints/ColumnHints8,
									$ColumnHints/ColumnHints9,
									$ColumnHints/ColumnHints10,
									$ColumnHints/ColumnHints11,
									$ColumnHints/ColumnHints12,
									$ColumnHints/ColumnHints13,
									$ColumnHints/ColumnHints14,
									$ColumnHints/ColumnHints15,]

var miss_counter = 0
var breakable_counter = 0
var broken_counter = 0

var tile_array = []
var selected_tile = Vector2.ZERO
var hint_columns = []
var hint_rows = []


func _ready():
	generate_board(false)


func _process(_delta):
	if Input.is_action_just_pressed("left"):
		move_selection(Vector2(selected_tile.x - 1, selected_tile.y))
	elif Input.is_action_just_pressed("right"):
		move_selection(Vector2(selected_tile.x + 1, selected_tile.y))
	elif Input.is_action_just_pressed("up"):
		move_selection(Vector2(selected_tile.x, selected_tile.y - 1))
	elif Input.is_action_just_pressed("down"):
		move_selection(Vector2(selected_tile.x, selected_tile.y + 1))
	if Input.is_action_just_pressed("space"):
		mark_selection()
	if Input.is_action_just_pressed("enter"):
		break_selection()
	if Input.is_action_just_pressed("backspace"):
		generate_board(true)
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")
	
	if broken_counter >= breakable_counter:
		print("WIN!")#TODO: not working + not my problem


func generate_board(clear_board):
	if clear_board:
		for i in tile_array:
			for j in i:
				j.queue_free()
		tile_array = []
		selected_tile = Vector2.ZERO
		hint_columns = []
		hint_rows = []
		miss_counter = -1
		add_miss()
	for i in range(15):
		tile_array.append([])
		for j in range(15):
			var tile = tile_scene.instantiate()
			tile.position = Vector2(i * 6 + board_inside.position.x + 1,
									j* 6 + board_inside.position.y + 1)
			tile_array[i].append(tile)
			add_child(tile)
	tile_array[0][0].toggle_cursor()
	get_hints()
	draw_hints()
	count_breakable_tiles()
	broken_counter = 0


func count_breakable_tiles():
	breakable_counter = 0
	for i in tile_array:
		for j in i:
			if j.breakable:
				breakable_counter += 1


func move_selection(next_selection):
	if next_selection.x < 0:
		next_selection.x = 14
	elif next_selection.x > 14:
		next_selection.x = 0
	if next_selection.y < 0:
		next_selection.y = 14
	elif next_selection.y > 14:
		next_selection.y = 0
	
	tile_array[selected_tile.x][selected_tile.y].toggle_cursor()
	selected_tile = next_selection
	tile_array[selected_tile.x][selected_tile.y].toggle_cursor()


func mark_selection():
	tile_array[selected_tile.x][selected_tile.y].mark_toggle()


func break_selection():
	if !tile_array[selected_tile.x][selected_tile.y].broken:
		if tile_array[selected_tile.x][selected_tile.y].breakable:
			broken_counter += 1
	if !tile_array[selected_tile.x][selected_tile.y].break_tile():
		add_miss()


func add_miss():
	miss_counter += 1
	miss_counter_label.text = str(miss_counter).pad_zeros(3)
	if miss_counter > 0:
		$MissAudio.play()


func get_hints():
	for k in range(2):
		var hint_column = []
		var hint_counter = 0
		hint_columns = []
		
		for i in tile_array:
			for j in i:
				if hint_counter >= 9:
					j.breakable = false
					hint_column.append(hint_counter)
					hint_counter = 0
				elif j.breakable:
					hint_counter += 1
				elif hint_counter == 0:
					pass
				else:
					hint_column.append(hint_counter)
					hint_counter = 0
			if hint_counter > 0:
				hint_column.append(hint_counter)
				hint_counter = 0
			hint_columns.append(hint_column)
			hint_column = []

		var hint_row = []
		hint_counter = 0
		hint_rows = []
		
		for i in tile_array.size():
			for j in tile_array:
				if hint_counter >= 9:
					j[i].breakable = false
					hint_row.append(hint_counter)
					hint_counter = 0
				elif j[i].breakable:
					hint_counter += 1
				elif hint_counter == 0:
					pass
				else:
					hint_row.append(hint_counter)
					hint_counter = 0
			if hint_counter > 0:
				hint_row.append(hint_counter)
				hint_counter = 0
			hint_rows.append(hint_row)
			hint_row = []


func draw_hints():
	var row_hints_string
	for i in hint_rows:
		row_hints_string = "\n".join(hint_rows)
	row_hints_string = row_hints_string.replace("[","")
	row_hints_string = row_hints_string.replace("]","")
	row_hints_string = row_hints_string.replace(", ","")
	row_hints_string = row_hints_string.insert(row_hints_string.length(), "\n")
	row_hints_label.text = row_hints_string
	
	var column_hints_string
	var column_hints_current_row = 0
	for i in hint_columns:
		column_hints_string = "\n".join(hint_columns[column_hints_current_row])
		column_hints_string = column_hints_string.replace("[", "")
		column_hints_string = column_hints_string.replace("]", "")
		column_hints_string = column_hints_string.replace(", ", "\n")
		column_hints_labels[column_hints_current_row].text = column_hints_string
		column_hints_current_row += 1
