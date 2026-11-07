class_name GameManager
extends Node2D

var player_follower_count: int = 50
var enemy_follower_count: int = 10

var current_player_score: int = 0
var current_enemy_score: int = 0
@export var current_player_dice: Array[ShrineDice] = []
@export var current_enemy_dice: Array[ShrineDice] = []
@export var follower_requirement_to_win: int = 10000


signal initalize_combat(current_player_dice: Array[ShrineDice], current_enemy_dice: Array[ShrineDice], player_follower_count: int, enemy_follower_count: int)

func transition_to_combat() -> void:
	emit_signal("initalize_combat", current_player_dice, current_enemy_dice, player_follower_count, enemy_follower_count)

func transition_to_shop(player_follower_count: int) -> void:
	pass

func transition_to_game_over() -> void:
	# Implement game over transition logic here
	pass


func dice_rolled(dice: Array[int], is_player_dice: bool) -> void:
	var dice_sum: int = 0
	# TODO apply dice and shrine object effects here
	
	for result in dice:
		dice_sum += result
	if is_player_dice:
		current_player_score += dice_sum * player_follower_count
	else:
		current_enemy_score += dice_sum * enemy_follower_count
	
	if current_player_score >= current_enemy_score:
		player_follower_count += enemy_follower_count/2
	else:
		player_follower_count -= player_follower_count/2 - 10
	
	if player_follower_count <= 0:
		# await get_tree().create_timer(2.5).timeout
		transition_to_game_over()

	# await get_tree().create_timer(2.5).timeout
	transition_to_shop(player_follower_count)
