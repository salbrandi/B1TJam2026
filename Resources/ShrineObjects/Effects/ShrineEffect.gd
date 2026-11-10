class_name ShrineEffect extends Resource

func on_pickup() -> void:
	pass

func on_die_rolled(value: int) -> void:
	pass

func modify_score(score: float) -> float:
	return score

func on_roll_complete() -> void:
	pass

func on_combat_end() -> void:
	pass

func modify_die(die: ShrineDice) -> void:
	pass

func should_reroll(value: int) -> bool:
	return false
