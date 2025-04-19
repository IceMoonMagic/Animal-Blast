class_name AnimalPalette
extends Resource

@export var animals: Array[Ball.Animal] = [
	Ball.Animal.CHICKEN,
	Ball.Animal.COW,
	Ball.Animal.PIG,
	Ball.Animal.CHICK,
	Ball.Animal.HORSE,
	Ball.Animal.DUCK,
	Ball.Animal.RABBIT,
	Ball.Animal.HIPPO,
]:
	set(val):
		if animals != val:
			animals = val
			emit_changed()


func get_limited(amount: int) -> Array[Ball.Animal]:
	return animals.slice(0, amount)


func get_limited_unused(amount: int) -> Array[Ball.Animal]:
	return animals.slice(amount)
