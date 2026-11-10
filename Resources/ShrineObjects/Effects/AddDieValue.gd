class_name AddDieValue extends ShrineEffect

@export var amount: int = 1

func modify_die(die: ShrineDice) -> void:
	var values: Array[int] = []
	for value in die.values:
		values.append(value + amount)
	die.values = values
