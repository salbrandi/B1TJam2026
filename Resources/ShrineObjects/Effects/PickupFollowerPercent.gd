class_name PickupFollowerPercent extends ShrineEffect

@export var percent: float = -0.5

func on_pickup() -> void:
	Global.gm.followers_percent(percent)
