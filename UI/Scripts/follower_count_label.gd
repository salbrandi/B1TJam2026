extends "res://UI/battle_score_label.gd"

@export var player_label: bool = true

func _init() -> void:
	animate_decreases = true

func _get_target_value() -> int:
	return Global.gm.player_follower_count if player_label else Global.gm.enemy_follower_count
