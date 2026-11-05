extends AudioStreamPlayer

@export var sounds: Array[AudioStream] = []

var volume_tween: Tween
var base_volume_db: float

@export var fade_start_time: float = 0
@export var fade_time: float = 0


func _ready() -> void:
	base_volume_db = volume_db


func play_random_sound() -> void:
	if sounds.is_empty():
		return
	if volume_tween:
		volume_tween.kill()
	volume_db = base_volume_db
	stream = sounds.pick_random()
	play()
	if fade_time > 0.0:
		fade_out(fade_time)


func fade_out(duration: float = fade_time) -> void:
	if volume_tween:
		volume_tween.kill()
	volume_tween = create_tween()
	volume_tween.tween_property(self, "volume_linear", 0.0, duration).set_delay(fade_start_time)
	volume_tween.tween_callback(stop)