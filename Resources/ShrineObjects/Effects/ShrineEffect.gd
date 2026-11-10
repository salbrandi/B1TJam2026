class_name ShrineEffect extends Resource

func on_pickup() -> void:
	pass

func on_die_rolled(value: int) -> void:
	pass

func on_die_settled(die: ShrineDice, value: int) -> void:
	pass

func modify_score(score: float) -> float:
	return score

func on_roll_complete() -> void:
	pass

func on_combat_start() -> void:
	pass

func on_combat_end() -> void:
	pass

func modify_die(die: ShrineDice) -> void:
	pass

func modify_die_adjacency(die: ShrineDice, adjacent_count: int) -> void:
	pass

func consume_die(consumer: ShrineDice, consumed: ShrineDice) -> bool:
	return false

func modify_neighbour_roll(die: ShrineDice, value: int, neighbour: ShrineDice) -> void:
	pass

func should_reroll(value: int) -> bool:
	return false

func extra_rolls() -> int:
	return 0

func consumes_random_die() -> bool:
	return false

func on_random_die_consumed() -> void:
	pass

func modify_die_next_to_item(die: ShrineDice) -> void:
	pass

func on_right_dice_rolled(count: int) -> void:
	pass

func on_adjacent_die_rolled(die: ShrineDice) -> void:
	pass

func consumes_random_adjacent_die() -> bool:
	return false

func on_all_rolls(rolls: Array[int], owned_dice: int) -> void:
	pass
