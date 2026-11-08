class_name AddScore extends ShrineEffect

@export var amount: int = 150

func on_roll_complete() -> void:
	Global.gm.add_score(amount)
