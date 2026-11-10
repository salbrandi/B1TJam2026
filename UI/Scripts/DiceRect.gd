class_name DiceRect
extends TextureRect

signal roll_finished

@export var dice: ShrineDice

@export var ROLL_DURATION := 1.2
@export var ROLL_START_JITTER := 0.15
@export var ROLL_START_SCALE := 1.2
@export var SHAKE_CYCLES := 1.0
@export var SHAKE_ANGLE := 12.0

const LABEL_MIN_FONT_SIZE := 8

var animator: AnimationPlayer
var label: Label
var rolling_texture: AtlasTexture
var label_max_font_size: int

func _ready() -> void:
	texture = (texture as AtlasTexture).duplicate()
	rolling_texture = texture as AtlasTexture
	animator = $AnimationPlayer
	if animator:
		animator.clear_caches()
	label = get_node_or_null("Label")
	if label:
		label_max_font_size = label.get_theme_font_size("font_size")
		label.resized.connect(_fit_label)
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
	set_value_text(dice.current_value)
	label.show()
	roll_finished.emit()


func set_value_text(value: int) -> void:
	label.text = str(value)
	_fit_label()


func _fit_label() -> void:
	var font := label.get_theme_font("font")
	var width := label.size.x
	var height := label.size.y
	if not font or width <= 0 or height <= 0:
		return
	var font_size := label_max_font_size
	while font_size > LABEL_MIN_FONT_SIZE:
		var text_size := font.get_string_size(label.text, label.horizontal_alignment, -1, font_size)
		if text_size.x <= width and text_size.y <= height:
			break
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)


func animate_roll(t: float, base_rotation: float, cycles: float, angle: float) -> void:
	label.hide()
	var wobble := sin(t * TAU * cycles) * (1.0 - t)
	offset_transform_rotation = base_rotation + wobble * angle
