class_name FollowerDelta extends ShrineEffect

@export var amount: int = -5
@export_range(0.0, 1.0) var chance: float = 1.0

func on_combat_end() -> void:
	if randf() < chance:
		Global.gm.add_followers(amount)
