class_name RerollOnValue extends ShrineEffect

@export var value: int = 1
@export var once_per_combat: bool = false

var _used_this_combat := false

func should_reroll(rolled: int) -> bool:
	if rolled != value:
		return false
	if once_per_combat:
		if _used_this_combat:
			return false
		_used_this_combat = true
	return true

func on_combat_end() -> void:
	_used_this_combat = false
