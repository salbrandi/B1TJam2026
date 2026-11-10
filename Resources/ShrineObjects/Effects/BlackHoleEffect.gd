class_name BlackHoleEffect extends ShrineEffect

func consumes_random_die() -> bool:
	return true

func on_random_die_consumed() -> void:
	Global.gm.player_follower_count = roundi(Global.gm.player_follower_count * 1.1)
