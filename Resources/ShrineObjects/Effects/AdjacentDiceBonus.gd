class_name AdjacentDiceBonus extends ShrineEffect

@export var amount_per_die: int = 1
@export var min_adjacent_dice: int = 1

func modify_die_adjacency(die: ShrineDice, adjacent_count: int) -> void:
	if adjacent_count < min_adjacent_dice:
		return
	var bonus := amount_per_die * adjacent_count
	if bonus == 0:
		return
	var values: Array[int] = []
	for value in die.values:
		values.append(value + bonus)
	die.values = values
