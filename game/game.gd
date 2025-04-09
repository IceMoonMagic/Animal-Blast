extends Node2D

signal game_over


func _ready() -> void:
	$Environment/LoseLine/CollisionShape2D.shape.distance = -(
		784 + 30 + min($Balls._ball_radius, 44)
	)


func _on_lose_line_body_entered(_body: Node2D) -> void:
	game_over.emit()
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
