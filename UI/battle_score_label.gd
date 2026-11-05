extends Label

@export var is_player_score: bool = true
@export var count_duration: float = 0.5
@export var bounce_scale: float = 1.3
@export var bounce_duration: float = 0.15

var value: int = 0
var displayed: int = 0
var count_tween: Tween
var bounce_tween: Tween


func _ready() -> void:
	value = text.to_int()
	displayed = value

func _process(delta: float) -> void:
	if is_player_score:
		set_score(Global.gm.current_player_score)
	else:
		set_score(Global.gm.current_enemy_score)

func set_score(new_value: int) -> void:
	if new_value == value:
		return
	var from := displayed
	value = new_value
	if count_tween:
		count_tween.kill()
	if new_value <= from:
		_show(new_value)
		return
	count_tween = create_tween()
	count_tween.tween_method(_on_count_step, float(from), float(new_value), count_duration)


func _on_count_step(step: float) -> void:
	_show(roundi(step))


func _show(number: int) -> void:
	text = str(number)
	if number > displayed:
		_bounce()
	displayed = number


func _bounce() -> void:
	if bounce_tween:
		bounce_tween.kill()
	pivot_offset = size / 2
	scale = Vector2.ONE
	bounce_tween = create_tween()
	bounce_tween.tween_property(self, "scale", Vector2.ONE * bounce_scale, bounce_duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "scale", Vector2.ONE, bounce_duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

