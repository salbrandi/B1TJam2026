extends Node

func _ready() -> void:
	for child in get_children():
		child.queue_free()
	# create a dice for each ShrineDice in the grid
	for dice in Global.gm.current_dice:
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
	Global.gm.dice_rolled(roll_all_dice())
	%SoundManager/DiceRoll.play_random_sound()
	%SoundManager/SweepingSynth.play_random_sound()
