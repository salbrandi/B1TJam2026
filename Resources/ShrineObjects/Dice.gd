class_name ShrineDice extends ShrineObject

@export var values: Array[int] = []
@export var current_value: int

func roll() -> int:
	current_value = values.pick_random()
	return current_value
