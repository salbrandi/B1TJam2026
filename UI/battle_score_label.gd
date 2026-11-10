extends Label

@export var is_player_score: bool = true
@export var count_duration: float = 0.5
@export var bounce_scale: float = 1.3
@export var bounce_duration: float = 0.15
@export var animate_decreases: bool = false

var value: int = 0
var displayed: int = 0
var count_tween: Tween
var bounce_tween: Tween


func _ready() -> void:
	value = text.to_int()
	displayed = value

func _process(_delta: float) -> void:
	set_score(_get_target_value())

func _get_target_value() -> int:
	return Global.gm.current_player_score if is_player_score else Global.gm.current_enemy_score

func set_score(new_value: int) -> void:
	if new_value == value:
		return
	var from := displayed
	value = new_value
	if count_tween:
		count_tween.kill()
	if new_value <= from and not animate_decreases:
		_show(new_value)
		return
	count_tween = create_tween()
	count_tween.tween_method(_on_count_step, float(from), float(new_value), count_duration)


func _on_count_step(step: float) -> void:
	_show(roundi(step))


func _show(number: int) -> void:
	text = format_number(number)
	if number > displayed:
		_bounce()
	displayed = number


func format_number(number: int) -> String:
	var digits := str(absi(number))
	var result := ""
	for i in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0:
			result += " "
		result += digits[i]
	return "-" + result if number < 0 else result


func _bounce() -> void:
	if bounce_tween:
		bounce_tween.kill()
	pivot_offset = size / 2
	scale = Vector2.ONE
	bounce_tween = create_tween()
	bounce_tween.tween_property(self, "scale", Vector2.ONE * bounce_scale, bounce_duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "scale", Vector2.ONE, bounce_duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
