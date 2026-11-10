class_name FollowerSteal extends ShrineEffect

@export var amount: int = 5
@export_range(0.0, 1.0) var chance: float = 0.1

func on_combat_start() -> void:
	if randf() < chance:
		Global.gm.steal_followers(amount)
