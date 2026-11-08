class_name GameManager
extends Node2D

@onready var all_screens = {
	"after_combat": $AfterCombat,
	"battle": $ShrineBattleScreen,
	"game_over": $GameOver,
	"shop": $Shop,
	"title": $Menu
}

var player_follower_count: int = 50
var enemy_follower_count: int = 10

var current_player_score: int = 0
var current_enemy_score: int = 0
var total_scores_reported: int = 0

var current_player_shrine_objects: Array[ShrineObject] = []
var current_enemy_shrine_objects: Array[ShrineObject] = []

var _waiting_for_player_input: bool = false

@export var current_player_dice: Array[ShrineDice] = []
@export var current_enemy_dice: Array[ShrineDice] = []
@export var follower_requirement_to_win: int = 10000
@export var player_total_wins: int = 0
@export var player_lives_remaining: int = 10
@export var _is_win: bool
@export var _is_victory: bool


signal initalize_combat(current_shrine_objects: Array[ShrineObject], current_player_dice: Array[ShrineDice], current_enemy_dice: Array[ShrineDice], player_follower_count: int, enemy_follower_count: int)
signal shop_opened
signal battle_over
signal game_over
signal getting_player_input

func _init() -> void:
	Global.gm = self

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if not _waiting_for_player_input:
		return
	
	if event.is_pressed() and not event.is_echo():
		_waiting_for_player_input = false
		get_viewport().set_input_as_handled()
		getting_player_input.emit()

func transition_scenes(from_scene: String, to_scene: String) -> void:
	if all_screens.has(from_scene):
		all_screens[from_scene].hide()
	if all_screens.has(to_scene):
		all_screens[to_scene].show()

func transition_to_combat(from_scene: String) -> void:
	emit_signal("initalize_combat", current_player_shrine_objects, current_player_dice, current_enemy_dice, player_follower_count, enemy_follower_count)
	transition_scenes(from_scene, "battle")
	
func transition_to_after_combat(from_scene: String) -> void:
	transition_scenes(from_scene, "after_combat")
	emit_signal("battle_over")
	

func transition_to_shop(from_scene: String) -> void:
	transition_scenes(from_scene, "shop")
	emit_signal("shop_opened")

func transition_to_game_over(from_scene: String) -> void:
	transition_scenes(from_scene, "game_over")
	emit_signal("game_over")
	
func transition_to_title(from_scene: String) -> void:
	transition_scenes(from_scene, "title")

func dice_rolled(dice: Array[int], is_player_dice: bool) -> void:
	var dice_sum: int = 0
	# TODO apply dice and shrine object effects here
	
	for result in dice:
		dice_sum += result
	if is_player_dice:
		current_player_score += dice_sum * player_follower_count
		total_scores_reported += 1
	else:
		current_enemy_score += dice_sum * enemy_follower_count
		total_scores_reported += 1
	
	if total_scores_reported == 2:
		total_scores_reported = 0
		end_combat()
	
func end_combat():
	if current_player_score >= current_enemy_score:
		_is_win = true
		player_total_wins += 1
		player_follower_count += enemy_follower_count/2
	else:
		_is_win = false
		player_lives_remaining -= 1
		player_follower_count -= player_follower_count/2 - 10
		
	_waiting_for_player_input = true
	await getting_player_input
		
	if player_total_wins == 10:
		_is_victory = true
		transition_to_game_over("battle")
		return
	
	if player_lives_remaining == 0:
		_is_victory = false
		transition_to_game_over("battle")
		return
		
	transition_to_after_combat("battle")
	
	_waiting_for_player_input = true
	await getting_player_input
	transition_to_shop("after_combat")
