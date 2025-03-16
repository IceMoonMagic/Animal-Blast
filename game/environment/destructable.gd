@tool

extends Area2D

## Texture2D object to draw
@export var texture: Texture2D:
	get:
		return sprite.texture
	set(val):
		if not is_node_ready():
			await ready
		sprite.texture = val
		sprite.offset.y = -val.get_height() / 2.0
		collision_shape.a.x = -val.get_width() / 2.0
		collision_shape.b.x = val.get_width() / 2.0
## Weather to flip over or destroy when run over
## [br]True: Flips[br]False: Deletes
@export var flip_on_break: bool = true
## Y component of collision line
@export var collision_height: float = -10:
	set(val):
		if not is_node_ready():
			await ready
		collision_height = val
		collision_shape.a.y = val
		collision_shape.b.y = val
@export var destroyed: bool = false:
	set(val):
		destroyed = val
		if destroyed:
			if not flip_on_break:
				queue_free()
			self.monitoring = false
			sprite.flip_v = true
			sprite.offset.y = (
				sprite.texture.get_height() / 2.0 + collision_height
			)
		else:
			self.monitoring = true
			sprite.flip_v = false
			sprite.offset.y = -sprite.texture.get_height() / 2.0

@onready var collision_shape: SegmentShape2D = $CollisionShape2D.shape
@onready var sprite: Sprite2D = $Sprite2D


func _on_body_entered(_body: Node2D) -> void:
	set_deferred("destroyed", true)
