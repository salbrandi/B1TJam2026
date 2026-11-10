class_name AlienSkullEffect extends ShrineEffect

func modify_die_next_to_item(die: ShrineDice) -> void:
	die.values = [die.values.max()]

func consumes_random_adjacent_die() -> bool:
	return true
