extends Label

@export var player_label: bool = true

func _process(delta: float) -> void:
	if player_label:
		text = str(Global.gm.player_follower_count)
	else:
		text = str(Global.gm.enemy_follower_count)
