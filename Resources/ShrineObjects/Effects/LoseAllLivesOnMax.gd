class_name LoseAllLivesOnMax extends ShrineEffect

func on_die_settled(die: ShrineDice, value: int) -> void:
	if value == die.values.max():
		Global.gm.player_lives_remaining = 0
