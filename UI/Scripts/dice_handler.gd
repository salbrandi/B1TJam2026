extends Node

const DICE_RECT_SCENE := preload("res://UI/DiceRect.tscn")

var _is_roll_enabled: bool
var _rect_by_index: Dictionary = {}

@export var is_player_dice: bool = false

func _ready() -> void:
	await get_tree().process_frame
	Global.gm.initalize_combat.connect(intialize_combat)
	if is_player_dice:
		Global.gm.shrine_object_removed.connect(_on_shrine_object_removed)

func intialize_combat(current_shrine_objects: Array[ShrineObject], current_player_dice: Array[ShrineDice], current_enemy_dice: Array[ShrineDice], player_follower_count: int, enemy_follower_count: int) -> void:
	_is_roll_enabled = true
	_spawn_dice(true)


func _on_shrine_object_removed(item: ShrineObject) -> void:
	if item is ShrineDice:
		_spawn_dice(false)


func _spawn_dice(apply_consumption: bool) -> void:
	for child in get_children():
		child.queue_free()
	var typed_dice = Global.gm.current_player_dice if is_player_dice else Global.gm.current_enemy_dice
	var adjacency: Array[int] = Global.gm.player_dice_adjacency
	var dice_copies: Array[ShrineDice] = []
	for i in typed_dice.size():
		var die := (typed_dice[i] as ShrineDice).duplicate() as ShrineDice
		if is_player_dice:
			var adjacent_count := adjacency[i] if i < adjacency.size() else 0
			for effect in Global.gm.all_effects():
				effect.modify_die(die)
				effect.modify_die_adjacency(die, adjacent_count)
		dice_copies.append(die)
	if is_player_dice:
		_apply_item_neighbour_effects(dice_copies)
	var consumed: Dictionary = {}
	if is_player_dice:
		if apply_consumption:
			for index in _apply_consumption(typed_dice, dice_copies):
				Global.gm.dice_consumed_this_combat.append(typed_dice[index])
		for i in typed_dice.size():
			if Global.gm.dice_consumed_this_combat.has(typed_dice[i]):
				consumed[i] = true
	_rect_by_index.clear()
	for i in dice_copies.size():
		if consumed.has(i):
			continue
		var dicerect := DICE_RECT_SCENE.instantiate() as DiceRect
		dicerect.dice = dice_copies[i]
		dicerect.roll_finished.connect(_on_dice_rect_roll_finished)
		_rect_by_index[i] = dicerect
		add_child(dicerect)


func _apply_consumption(sources: Array, dice: Array[ShrineDice]) -> Dictionary:
	var consumed := {}
	var right: Array[int] = Global.gm.player_dice_right_neighbour
	for i in dice.size():
		if consumed.has(i) or i >= right.size() or right[i] < 0 or consumed.has(right[i]):
			continue
		var j := right[i]
		for effect in (sources[i] as ShrineDice).effects:
			if effect.consume_die(dice[i], dice[j]):
				consumed[j] = true
				break
	return consumed


func _apply_item_neighbour_effects(dice: Array[ShrineDice]) -> void:
	for entry in Global.gm.player_item_dice:
		var item := entry["item"] as ShrineObject
		for index in entry["dice"]:
			for effect in item.effects:
				effect.modify_die_next_to_item(dice[index])


func roll_all_dice() -> Array[int]:
	await _roll_dice_rects(get_children())

	if is_player_dice:
		await _apply_extra_rolls()
		var rerolls: Array[Node] = []
		for child in get_children():
			if _should_reroll((child as DiceRect).dice.current_value):
				rerolls.append(child)
		await _roll_dice_rects(rerolls)

	if is_player_dice:
		_apply_neighbour_effects()
		_apply_right_roll_effects()
		_apply_adjacent_roll_effects()

	var rolls: Array[int] = []
	for child in get_children():
		rolls.append((child as DiceRect).dice.current_value)
	return rolls


func _apply_adjacent_roll_effects() -> void:
	for entry in Global.gm.player_item_dice:
		var item := entry["item"] as ShrineObject
		for index in entry["dice"]:
			if not _rect_by_index.has(index):
				continue
			var rect := _rect_by_index[index] as DiceRect
			for effect in item.effects:
				effect.on_adjacent_die_rolled(rect.dice)
			rect.set_value_text(rect.dice.current_value)


func _apply_right_roll_effects() -> void:
	for entry in Global.gm.player_item_dice:
		var item := entry["item"] as ShrineObject
		var rolled_right := 0
		for index in entry["right"]:
			if _rect_by_index.has(index):
				rolled_right += 1
		for effect in item.effects:
			effect.on_right_dice_rolled(rolled_right)


func _apply_neighbour_effects() -> void:
	var neighbours: Array = Global.gm.player_dice_neighbours
	var snapshot := {}
	for index in _rect_by_index:
		snapshot[index] = (_rect_by_index[index] as DiceRect).dice.current_value
	for index in _rect_by_index:
		var source := (_rect_by_index[index] as DiceRect).dice
		if index >= neighbours.size():
			continue
		for j in neighbours[index]:
			if not _rect_by_index.has(j):
				continue
			var target := (_rect_by_index[j] as DiceRect).dice
			for effect in source.effects:
				effect.modify_neighbour_roll(source, snapshot[index], target)
	for index in _rect_by_index:
		var rect := _rect_by_index[index] as DiceRect
		rect.set_value_text(rect.dice.current_value)


func _roll_dice_rects(rects: Array) -> void:
	var tweens: Array[Tween] = []
	for rect in rects:
		tweens.append((rect as DiceRect).roll())

	for tween in tweens:
		if tween.is_running():
			await tween.finished



func _apply_extra_rolls() -> void:
	var remaining := {}
	for child in get_children():
		var count := _extra_rolls_for((child as DiceRect).dice)
		if count > 0:
			remaining[child] = count
	while not remaining.is_empty():
		var batch: Array = remaining.keys()
		await _roll_dice_rects(batch)
		for child in batch:
			remaining[child] -= 1
			if remaining[child] <= 0:
				remaining.erase(child)


func _extra_rolls_for(die: ShrineDice) -> int:
	var total := 0
	for effect in die.effects:
		total += effect.extra_rolls()
	return total


func _should_reroll(value: int) -> bool:
	for effect in Global.gm.all_effects():
		if effect.should_reroll(value):
			return true
	return false



func _on_dice_rect_roll_finished() -> void:
	%SoundManager/DiceRoll.play_random_sound()


func _on_button_pressed():
	if not _is_roll_enabled:
		return
		
	_is_roll_enabled = false
	%SoundManager/SweepingSynth.play_random_sound()
	var rolls := await roll_all_dice()
	Global.gm.score_rolls(rolls, get_dice(), is_player_dice)


func get_dice() -> Array[ShrineDice]:
	var dice: Array[ShrineDice] = []
	for child in get_children():
		dice.append((child as DiceRect).dice)
	return dice
