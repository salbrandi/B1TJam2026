extends Node

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
		var dicerect = DiceRect.new()
		dicerect.dice = dice
		add_child(dicerect)


func roll_all_dice() -> Array[int]:
	var rolls: Array[int] = []
	for child in get_children():
		var dice = child as DiceRect
		rolls.append(dice.roll())

	return rolls


func _on_button_pressed():
	Global.gm.dice_rolled(roll_all_dice(), is_player_dice)
	%SoundManager/DiceRoll.play_random_sound()
	%SoundManager/SweepingSynth.play_random_sound()
