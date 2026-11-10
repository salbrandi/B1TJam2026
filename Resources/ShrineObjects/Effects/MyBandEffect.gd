class_name MyBandEffect extends ShrineEffect

func modify_neighbour_roll(die: ShrineDice, value: int, neighbour: ShrineDice) -> void:
	neighbour.current_value += value
