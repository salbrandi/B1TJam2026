extends AudioStreamPlayer

@export var sounds: Array[AudioStream] = []

var base_volume_db: float

@export var fade_start_time: float = 0
@export var fade_time: float = 0


func _ready() -> void:
	base_volume_db = volume_db


func play_random_sound() -> void:
	if sounds.is_empty():
		return
	var player := AudioStreamPlayer.new()
	player.stream = sounds.pick_random()
	player.volume_db = base_volume_db
	player.bus = bus
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	if fade_time > 0.0:
		_fade_out(player)


func _fade_out(player: AudioStreamPlayer) -> void:
	var tween := player.create_tween()
	tween.tween_property(player, "volume_linear", 0.0, fade_time).set_delay(fade_start_time)
	tween.tween_callback(player.queue_free)