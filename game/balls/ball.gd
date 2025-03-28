class_name Ball
extends AnimatableBody2D

enum Animal {
	BEAR,
	BUFFALO,
	CHICK,
	CHICKEN,
	COW,
	CROCODILE,
	DOG,
	DUCK,
	ELEPHANT,
	FROG,
	GIRAFFE,
	GOAT,
	GORILLA,
	HIPPO,
	HORSE,
	MONKEY,
	MOOSE,
	NARWHAL,
	OWL,
	PANDA,
	PARROT,
	PENGUIN,
	PIG,
	RABBIT,
	RHINO,
	SLOTH,
	SNAKE,
	WALRUS,
	WHALE,
	ZEBRA,
}

static var variants: Dictionary[int, BallVariant] = {}

@export var animal: Animal:
	set(val):
		animal = val
		ball_variant = get_variant(animal)
@export var radius: float = 68.0:
	set(r):
		if not is_node_ready():
			await ready
		radius = r
		sprite.scale = Vector2.ONE * (r / 68.0)
		collision_shape.shape.radius = r
		$VisibleOnScreenNotifier2D.scale = Vector2.ONE * (r / 68.0)
var popped: bool = false
var ball_variant: BallVariant
var _visible: bool = false
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@warning_ignore("shadowed_variable")


static func get_variant(animal: Animal) -> BallVariant:
	if variants.has(animal):
		return variants.get(animal)

	var animal_name: String = Animal.keys()[animal].to_lower()
	@warning_ignore("shadowed_variable")
	var ball_variant := BallVariant.new()
	ball_variant.animal_name = animal_name
	ball_variant.ball_form = load(
		"res://game/balls/variants/%s_nodetail.png" % animal_name
	)
	ball_variant.popped_form = load(
		"res://game/balls/variants/%s_detailed.png" % animal_name
	)
	variants.set(animal, ball_variant)
	return ball_variant


func _ready() -> void:
	sprite.texture = ball_variant.ball_form


func _physics_process(delta: float) -> void:
	if not popped:
		return

	constant_linear_velocity += -get_gravity() * delta
	position += constant_linear_velocity * delta
	rotation += constant_angular_velocity * delta


func pop() -> void:
	if self.popped:
		return
	popped = true
	sprite.texture = ball_variant.popped_form
	collision_shape.disabled = true
	z_index = 10


func _on_screen_entered() -> void:
	_visible = true


func _on_screen_exited() -> void:
	_visible = false
	if popped:
		queue_free()


class BallVariant:
	extends Resource

	var animal_name: String
	var ball_form: Texture2D
	var popped_form: Texture2D
