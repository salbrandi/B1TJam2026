class_name RerollOnValue extends ShrineEffect

@export var value: int = 1

func should_reroll(rolled: int) -> bool:
	return rolled == value
