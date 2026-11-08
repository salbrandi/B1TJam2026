class_name DiceRect
extends TextureRect

@export var dice: ShrineDice

const ROLL_DURATION := 1.2
const ROLL_START_JITTER := 0.15
const SHAKE_CYCLES := 1.0
const SHAKE_ANGLE := 12.0

var animator: AnimationPlayer
var rolling_texture: AtlasTexture

func _ready() -> void:
	rolling_texture = texture as AtlasTexture
	animator = $AnimationPlayer
	if dice:
		pass
	else:
		dice = preload("res://Resources/ShrineObjects/Dice/dice.tres")
	


## Starts this die's roll animation and returns its tween. The rolled value is in dice.current_value.
## Each roll gets randomised timing and shake so the dice don't move in unison.
func roll() -> Tween:
	texture = rolling_texture
	dice.roll()
	var base_rotation := offset_transform_rotation
	pivot_offset = size / 2.0
	var cycles := SHAKE_CYCLES * randf_range(0.7, 1.3)
	var direction := 1.0 if randf() < 0.5 else -1.0
	var angle := SHAKE_ANGLE * randf_range(0.3, 1) * direction
	var duration := ROLL_DURATION * randf_range(0.6, 1.2)
	# animator.speed_scale = randf_range(-1, 1.5)
	animator.play("roll")
	var tween := create_tween()
	tween.tween_interval(randf_range(0.0, ROLL_START_JITTER))
	tween.tween_method(animate_roll.bind(base_rotation, cycles, angle), 0.0, 1.0, duration)
	tween.tween_callback(finish_roll)
	return tween


func finish_roll() -> void:
	animator.stop()
	show_face(dice.current_value)


func animate_roll(t: float, base_rotation: float, cycles: float, angle: float) -> void:
	var wobble := sin(t * TAU * cycles) * (1.0 - t)
	offset_transform_rotation = base_rotation + wobble * angle


func show_face(value: int) -> void:
	var atlas := dice.faces_atlas as AtlasTexture
	var face_size := atlas.region.size
	var face := AtlasTexture.new()
	face.atlas = atlas.atlas
	face.region = Rect2(atlas.region.position + Vector2(face_size.x * (value - 1), 0), face_size)
	texture = face