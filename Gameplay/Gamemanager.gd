class_name GameManager
extends Node2D

@onready var all_screens = {
	"after_battle": $AfterBattle,
	"battle": $ShrineBattleScreen,
	"final": $FinalOutcome,
	"shop": $Shop,
	"title": $Menu
}

var player_follower_count: int = 50
var enemy_follower_count: int = 10

var current_player_score: int = 0
var current_enemy_score: int = 0

var current_player_shrine_objects: Array[ShrineObject] = []
var current_enemy_shrine_objects: Array[ShrineObject] = []

@export var current_player_dice: Array[ShrineDice] = []
@export var current_enemy_dice: Array[ShrineDice] = []
@export var follower_requirement_to_win: int = 10000


signal initalize_combat(current_shrine_objects: Array[ShrineObject], current_player_dice: Array[ShrineDice], current_enemy_dice: Array[ShrineDice], player_follower_count: int, enemy_follower_count: int)
signal shop_opened

var pending_rolls: Dictionary = {}

func _init() -> void:
	Global.gm = self

func _ready() -> void:
	for child in get_children():
		if child is Control and child.has_signal("screen_change_request"):
			child.screen_change_request.connect(transition_scenes)

func transition_scenes(from_scene: String, to_scene: String) -> void:
	if all_screens.has(from_scene):
		all_screens[from_scene].hide()
	if all_screens.has(to_scene):
		all_screens[to_scene].show()

func transition_to_combat() -> void:
	emit_signal("initalize_combat", current_player_shrine_objects, current_player_dice, current_enemy_dice, player_follower_count, enemy_follower_count)

func transition_to_shop(player_follower_count: int) -> void:
	transition_scenes("battle", "shop")
	emit_signal("shop_opened")

func all_effects() -> Array[ShrineEffect]:
	var effects: Array[ShrineEffect] = []
	for item in current_player_shrine_objects:
		effects.append_array(item.effects)
	return effects

func add_shrine_object(item: ShrineObject) -> void:
	current_player_shrine_objects.append(item)
	for effect in item.effects:
		effect.on_pickup()

func add_score(amount: int) -> void:
	current_player_score += amount

func add_followers(amount: int) -> void:
	player_follower_count += amount

func followers_percent(percent: float) -> void:
	player_follower_count = int(player_follower_count * (1.0 + percent))

func steal_followers(amount: int) -> void:
	var taken := mini(amount, enemy_follower_count)
	enemy_follower_count -= taken
	player_follower_count += taken

func score_rolls(rolls: Array[int], is_player_dice: bool) -> void:
	pending_rolls[is_player_dice] = rolls
	var total := 0
	for value in rolls:
		total += value
	if is_player_dice:
		var effects := all_effects()
		for value in rolls:
			for effect in effects:
				effect.on_die_rolled(value)
		var score := float(total * player_follower_count)
		for effect in effects:
			score = effect.modify_score(score)
		current_player_score += int(score)
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
