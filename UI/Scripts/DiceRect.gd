class_name DiceRect
extends TextureRect

signal roll_finished

@export var dice: ShrineDice

@export var ROLL_DURATION := 1.2
@export var ROLL_START_JITTER := 0.15
@export var ROLL_START_SCALE := 1.2
@export var SHAKE_CYCLES := 1.0
@export var SHAKE_ANGLE := 12.0

var animator: AnimationPlayer
var label: Label
var rolling_texture: AtlasTexture

func _ready() -> void:
	texture = (texture as AtlasTexture).duplicate()
	rolling_texture = texture as AtlasTexture
	animator = $AnimationPlayer
	if animator:
		animator.clear_caches()
	label = $Label
	if dice:
		pass
	else:
		dice = preload("res://Resources/ShrineObjects/Dice/d6.tres")
	



func roll() -> Tween:
	texture = rolling_texture
	dice.roll()
	var base_rotation := offset_transform_rotation
	pivot_offset = size / 2.0
	scale = Vector2.ONE * ROLL_START_SCALE
	var cycles := SHAKE_CYCLES * randf_range(0.7, 1.3)
	var direction := 1.0 if randf() < 0.5 else -1.0
	var angle := SHAKE_ANGLE * randf_range(0.3, 1) * direction
	var duration := ROLL_DURATION * randf_range(0.5, 2)
	# animator.speed_scale = randf_range(-1, 1.5)
	animator.play("roll")
	var tween := create_tween()
	tween.tween_interval(randf_range(0.0, ROLL_START_JITTER))
	tween.tween_method(animate_roll.bind(base_rotation, cycles, angle), 0.0, 1.0, duration)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, duration)
	tween.tween_callback(finish_roll)
	return tween


func finish_roll() -> void:
	animator.play("RESET")
	label.text = str(dice.current_value)
	label.show()
	roll_finished.emit()


func animate_roll(t: float, base_rotation: float, cycles: float, angle: float) -> void:
	label.hide()
	var wobble := sin(t * TAU * cycles) * (1.0 - t)
	offset_transform_rotation = base_rotation + wobble * angle
