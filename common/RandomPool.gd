class_name RandomPool
extends RefCounted

var items: Array[Variant] = []
var cooldown_size: int = -1:
	set(val):
		cooldown_size = val
		if val < 0:
			return
		items.append_array(_cooling_down.slice(val))
		_cooling_down.resize(val)
var rng: RandomNumberGenerator = null
var _cooling_down: Array[Variant] = []

@warning_ignore("shadowed_variable")


func _init(
	items := self.items,
	cooldown_size := self.cooldown_size,
	rng := self.rng,
) -> void:
	self.items = items
	self.cooldown_size = cooldown_size
	self.rng = rng


func get_item() -> Variant:
	var result: Variant = items.pop_at(
		(
			rng.randi_range(0, len(items) - 1)
			if rng
			else randi_range(0, len(items) - 1)
		)
	)

	_cooling_down.append(result)
	if (
		(cooldown_size >= 0 and len(_cooling_down) > cooldown_size)
		or len(items) == 0
	):
		var item: Variant = _cooling_down.pop_front()
		if item != null:
			items.push_back(item)
	return result


func reset_cooldowns() -> void:
	items.append_array(_cooling_down)
	_cooling_down.resize(0)
