class_name GamblingTicketEffect extends ShrineEffect

func on_all_rolls(rolls: Array[int], owned_dice: int) -> void:
	if rolls.is_empty():
		return
	for value in rolls:
		if value != rolls[0]:
			return
	Global.gm.player_follower_count *= owned_dice
