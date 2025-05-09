class_name StrikeProgress
extends Range

const FILL_DURATION := 0.5
const MIN_POSITION := 4.0
var max_position: float:
	get:
		return (
			$Panel.size.x
			- MIN_POSITION
			- $Panel/NinePatchRect.size.x * $Panel/NinePatchRect.scale.x
		)

var _display_value: float = self.value


func _process(delta: float) -> void:
	_display_value = move_toward(_display_value, value, delta)
	$Panel/NinePatchRect.position.x = (
		(max_position - MIN_POSITION) * _display_value + MIN_POSITION
	)
