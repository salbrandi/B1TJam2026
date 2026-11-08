class_name FollowerGainOnDieValue extends ShrineEffect

@export var die_value: int = 6
@export var gain: int = 1

func on_die_rolled(value: int) -> void:
	if value == die_value:
		Global.gm.add_followers(gain)
