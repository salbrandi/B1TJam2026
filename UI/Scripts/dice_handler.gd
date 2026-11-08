extends Node

const DICE_RECT_SCENE := preload("res://UI/DiceRect.tscn")

@export var is_player_dice: bool = false

func _ready() -> void:
	await get_tree().process_frame
	intialize_combat()

func intialize_combat() -> void:
	for child in get_children():
		child.queue_free()
	# create a dice for each ShrineDice in the grid
	var typed_dice = Global.gm.current_player_dice if is_player_dice else Global.gm.current_enemy_dice
	for dice in typed_dice:
		var dicerect := DICE_RECT_SCENE.instantiate() as DiceRect
		dicerect.dice = dice.duplicate() as ShrineDice
		add_child(dicerect)


func roll_all_dice() -> Array[int]:
	var tweens: Array[Tween] = []
	for child in get_children():
		tweens.append((child as DiceRect).roll())

	for tween in tweens:
		if tween.is_running():
			await tween.finished

	var rolls: Array[int] = []
	for child in get_children():
		rolls.append((child as DiceRect).dice.current_value)
	return rolls


func _on_button_pressed():
		
	var rolls := await roll_all_dice()
	Global.gm.dice_rolled(rolls, is_player_dice)
	%SoundManager/DiceRoll.play_random_sound()
	%SoundManager/SweepingSynth.play_random_sound()
