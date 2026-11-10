extends "res://UI/battle_score_label.gd"

func _init() -> void:
	animate_decreases = true

func _get_target_value() -> int:
	return Global.gm.player_follower_count
