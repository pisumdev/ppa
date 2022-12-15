extends ColorRect

@onready var marker = $Marker
@onready var mistake_label = $MistakeLabel
@onready var mistake_label_original_position = mistake_label.position.y

@export var breakable_percentage = 70

var missed = false
var breakable = false
var broken = false


func _ready():
	randomize()
	if randi() % 100 + 1 < breakable_percentage:
		breakable = true
		#color = Color(1, 0, 0, 1)


func _process(delta):
	if mistake_label.visible:
		mistake_label_fader(delta)


func toggle_cursor():
	var sprite = $CursorSprite
	var highlight = $CursorHighlight
	if sprite.visible:
		sprite.hide()
		highlight.hide()
	else:
		sprite.show()
		highlight.show()


func mark_toggle():
	if missed:
		return
	if marker.visible or broken:
		marker.hide()
	else:
		marker.show()


func break_tile():
	if missed:
		return true
	if marker.visible:
		mark_toggle()
	if breakable:
		broken = true
		color = Color(0, 0, 0, 0)
	else:
		marker.show()
		mistake_label.show()
	return breakable


func mistake_label_fader(delta):
	missed = true
	mistake_label.position.y -= 20 * delta
	if mistake_label.position.y < mistake_label_original_position - 20:
		mistake_label.hide()
