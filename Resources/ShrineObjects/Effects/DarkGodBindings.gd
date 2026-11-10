class_name DarkGodBindings extends ShrineEffect

func on_pickup() -> void:
	Global.gm.player_follower_count = 0

func on_die_settled(die: ShrineDice, value: int) -> void:
	if value == die.values.max():
		Global.gm.followers_percent(0.5)
	else:
		Global.gm.add_followers(value)
