class_name GameManager
extends Node2D

var player_follower_count: int = 50
var enemy_follower_count: int = 0

var current_player_score: int = 0
var current_enemy_score: int = 0

func dice_rolled(dice: Array[int]) -> void:
	var dice_sum: int = 0
	# TODO apply dice and shrine object effects here
	
	for result in dice:
		dice_sum += result
	current_player_score += dice_sum * player_follower_count
	
