extends Sprite2D

func _ready() -> void:
	var rnd_seek = randf_range(0.0, $AnimationPlayer.get_animation("jump").length)
	$AnimationPlayer.play("jump")
	$AnimationPlayer.seek(rnd_seek,true)
	
	pass
