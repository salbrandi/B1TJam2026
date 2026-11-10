extends Node

const DICE_RECT_SCENE := preload("res://UI/DiceRect.tscn")

var _is_roll_enabled: bool

@export var is_player_dice: bool = false

func _ready() -> void:
	await get_tree().process_frame
	Global.gm.initalize_combat.connect(intialize_combat)

func intialize_combat(current_shrine_objects: Array[ShrineObject], current_player_dice: Array[ShrineDice], current_enemy_dice: Array[ShrineDice], player_follower_count: int, enemy_follower_count: int) -> void:
	_is_roll_enabled = true
	for child in get_children():
		child.queue_free()
	# create a dice for each ShrineDice in the grid
	var typed_dice = Global.gm.current_player_dice if is_player_dice else Global.gm.current_enemy_dice
	for dice in typed_dice:
		var dicerect := DICE_RECT_SCENE.instantiate() as DiceRect
		var die := dice.duplicate() as ShrineDice
		if is_player_dice:
			for effect in Global.gm.all_effects():
				effect.modify_die(die)
		dicerect.dice = die
		dicerect.roll_finished.connect(_on_dice_rect_roll_finished)
		add_child(dicerect)


func roll_all_dice() -> Array[int]:
	await _roll_dice_rects(get_children())

	if is_player_dice:
		var rerolls: Array[Node] = []
		for child in get_children():
			if _should_reroll((child as DiceRect).dice.current_value):
				rerolls.append(child)
		await _roll_dice_rects(rerolls)

	var rolls: Array[int] = []
	for child in get_children():
		rolls.append((child as DiceRect).dice.current_value)
	return rolls


func _roll_dice_rects(rects: Array) -> void:
	var tweens: Array[Tween] = []
	for rect in rects:
		tweens.append((rect as DiceRect).roll())

	for tween in tweens:
		if tween.is_running():
			await tween.finished



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
	Global.gm.score_rolls(rolls, is_player_dice)