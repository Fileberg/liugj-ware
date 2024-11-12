extends Minigame

const MAX_ICONS := 10
const ICON_SIZE := 128.0

@onready var randy := RandomNumberGenerator.new()


func _ready():
	var x_size := ($PlayArea as Control).size.x
	var y_size := ($PlayArea as Control).size.y
	$PlayArea/Icon.set_position(Vector2(randy.randf_range(0.0, x_size - ICON_SIZE), randy.randf_range(0.0, y_size - ICON_SIZE)))
	for i in range(MAX_ICONS - 1):
		var new_icon = $PlayArea/Icon.duplicate()
		new_icon.set_position(Vector2(randy.randf_range(0.0, x_size - ICON_SIZE), randy.randf_range(0.0, y_size - ICON_SIZE)))
		$PlayArea.add_child(new_icon)


func _process(delta):
	pass


func _on_timer_timeout():
	finished.emit()
