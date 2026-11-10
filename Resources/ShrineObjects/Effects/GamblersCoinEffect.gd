class_name GamblersCoinEffect extends ShrineEffect

func on_adjacent_die_rolled(die: ShrineDice) -> void:
	die.current_value = die.current_value * 2 if randf() < 0.5 else 0
