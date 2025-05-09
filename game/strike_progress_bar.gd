class_name StrikeProgress
extends Range

const FILL_DURATION := 0.5
const MIN_POSITION := 4.0
@export var empty_texture: Texture2D
@export var strike_texture: Texture2D

var strikes := 0:
	set(s):
		s = clampi(s, 0, max_strikes)
		if strikes == s:
			return
		strikes = s
		for i in range(len(_strike_markers)):
			var marker: TextureRect = _strike_markers[i]
			marker.texture = (
				strike_texture if i + 1 <= strikes else empty_texture
			)
var max_strikes := GameMode.difficulty_settings.allowed_strikes - 1
var max_position: float:
	get:
		return (
			bouncer_bar.size.x - MIN_POSITION - bouncer.size.x * bouncer.scale.x
		)

var _display_value: float = self.value
var _strike_markers: Array[TextureRect] = []
@onready var bouncer_bar: Panel = $BouncerBar
@onready var bouncer: TextureRect = $BouncerBar/Bouncer
@onready var strike_bar: HBoxContainer = $StrikeBar
@onready var strike_template: TextureRect = $StrikeBar/StrikeTemplate


func _ready() -> void:
	if not GameMode.continuous:
		strike_template.texture = empty_texture
		_strike_markers = [strike_template]
		for _i in range(1, max_strikes):
			var strike_marker := strike_template.duplicate()
			strike_bar.add_child(strike_marker)
			_strike_markers.append(strike_marker)

	bouncer_bar.visible = GameMode.continuous
	strike_bar.visible = not GameMode.continuous


func _process(delta: float) -> void:
	if GameMode.continuous:
		_display_value = move_toward(_display_value, value, delta)
		bouncer.position.x = (
			(max_position - MIN_POSITION) * _display_value + MIN_POSITION
		)
