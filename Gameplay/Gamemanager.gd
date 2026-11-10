class_name GameManager
extends Node2D

@onready var all_screens = {
	"after_combat": $AfterCombat,
	"battle": $ShrineBattleScreen,
	"game_over": $GameOver,
	"shop": $Shop,
	"title": $Menu
}

@export var followers_gained_per_life_lost: int = 50
@export var player_follower_count: int = 100
var enemy_follower_count: int = 50

var current_player_score: int = 0
var current_enemy_score: int = 0
var total_scores_reported: int = 0

var current_player_shrine_objects: Array[ShrineObject] = []
var current_enemy_shrine_objects: Array[ShrineObject] = []

var _waiting_for_player_input: bool = false
const AUTO_ADVANCE_SECONDS := 2.5

@export var current_player_dice: Array[ShrineDice] = []
@export var current_enemy_dice: Array[ShrineDice] = []
var player_dice_adjacency: Array[int] = []
var player_dice_right_neighbour: Array[int] = []
var player_dice_neighbours: Array = []
var player_item_dice: Array[Dictionary] = []
@export var follower_requirement_to_win: int = 10000
@export var player_total_wins: int = 0
@export var player_lives_remaining: int = 10
@export var _is_win: bool
@export var _is_victory: bool


signal initalize_combat(current_shrine_objects: Array[ShrineObject], current_player_dice: Array[ShrineDice], current_enemy_dice: Array[ShrineDice], player_follower_count: int, enemy_follower_count: int)
signal shop_opened
signal shrine_object_added(item: ShrineObject)
signal shrine_object_removed(item: ShrineObject)
signal battle_over
signal game_over
signal getting_player_input
signal lost_life
signal win_gained

var pending_rolls: Dictionary = {}

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

func all_effects() -> Array[ShrineEffect]:
	var effects: Array[ShrineEffect] = []
	for item in current_player_shrine_objects:
		effects.append_array(item.effects)
	return effects

func add_shrine_object(item: ShrineObject) -> void:
	current_player_shrine_objects.append(item)
	if item is ShrineDice:
		current_player_dice.append(item as ShrineDice)
	for effect in item.effects:
		effect.on_pickup()
	shrine_object_added.emit(item)

func remove_shrine_object(item: ShrineObject) -> void:
	current_player_shrine_objects.erase(item)
	if item is ShrineDice:
		current_player_dice.erase(item as ShrineDice)
	shrine_object_removed.emit(item)

func add_score(amount: int) -> void:
	current_player_score += amount

func add_followers(amount: int) -> void:
	player_follower_count = maxi(0, player_follower_count + amount)

func spend_followers(amount: int) -> bool:
	if player_follower_count < amount:
		return false
	player_follower_count -= amount
	return true

func followers_percent(percent: float) -> void:
	player_follower_count = maxi(0, int(player_follower_count * (1.0 + percent)))

func steal_followers(amount: int) -> void:
	var taken := mini(amount, enemy_follower_count)
	enemy_follower_count -= taken
	player_follower_count += taken

func score_rolls(rolls: Array[int], dice: Array[ShrineDice], is_player_dice: bool) -> void:
	pending_rolls[is_player_dice] = rolls
	var total := 0
	for value in rolls:
		total += value
	if is_player_dice:
		var effects := all_effects()
		for effect in effects:
			effect.on_all_rolls(rolls, current_player_dice.size())
		for value in rolls:
			for effect in effects:
				effect.on_die_rolled(value)
		var score := float(total * player_follower_count)
		for effect in effects:
			score = effect.modify_score(score)
		current_player_score += int(score)
		for i in rolls.size():
			for effect in effects:
				effect.on_die_settled(dice[i], rolls[i])
			for effect in dice[i].effects:
				effect.on_die_settled(dice[i], rolls[i])
		for effect in effects:
			effect.on_roll_complete()

	else:
		current_enemy_score += total * enemy_follower_count
	if pending_rolls.size() == 2:
		end_combat()
		pending_rolls.clear()

func end_combat() -> void:
	for effect in all_effects():
		effect.on_combat_end()
	
	calculate_wins_losses()
	
func calculate_wins_losses():
	if current_player_score >= current_enemy_score:
		_is_win = true
		player_total_wins += 1
		player_follower_count += enemy_follower_count/2
	else:
		_is_win = false
		player_lives_remaining = maxi(0, player_lives_remaining - 1)
		player_follower_count = maxi(0, player_follower_count - (player_follower_count/2 - 10))
		add_followers(followers_gained_per_life_lost * (10 - player_lives_remaining))
		
	await _wait_for_advance()
		
	transition_to_after_combat("battle")
	
	after_combat_input()

func _wait_for_advance() -> void:
	_waiting_for_player_input = true
	var timer := get_tree().create_timer(AUTO_ADVANCE_SECONDS)
	while _waiting_for_player_input and timer.time_left > 0.0:
		await get_tree().process_frame
	_waiting_for_player_input = false
	
func after_combat_input():
	await _wait_for_advance()
	
	if _is_win:
		emit_signal("win_gained")
	else:
		emit_signal("life_lost")
	
	if player_total_wins == 10:
		_is_victory = true
		transition_to_game_over("battle")
		return
	
	if player_lives_remaining == 0:
		_is_victory = false
		transition_to_game_over("battle")
		return
		
	transition_to_shop("after_combat")	
