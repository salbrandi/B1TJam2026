extends Label

func _process(delta: float) -> void:
	text = str(Global.gm.player_follower_count)