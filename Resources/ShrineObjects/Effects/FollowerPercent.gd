class_name FollowerPercent extends ShrineEffect

@export var percent: float = -0.05

func on_combat_end() -> void:
	Global.gm.followers_percent(percent)
