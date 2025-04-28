class_name GameDifficulty
extends Resource

@export_range(5, 15, 1, "or_greater") var row_size: int = 10
@export_range(4, 8, 1) var palette_size: int = 6:
	set(val):
		palette_size = clampi(val, 4, 8)
		emit_changed()
@export_range(5, 30, 1.0, "or_greater") var continuous_speed: float = 10

@warning_ignore("shadowed_variable")


func _init(
	row_size: int = self.row_size,
	palette_size: int = self.palette_size,
	continuous_speed: float = self.continuous_speed
) -> void:
	self.row_size = row_size
	self.palette_size = palette_size
	self.continuous_speed = continuous_speed
