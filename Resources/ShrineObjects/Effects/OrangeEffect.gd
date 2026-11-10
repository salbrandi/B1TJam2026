class_name OrangeEffect extends ShrineEffect

func on_right_dice_rolled(count: int) -> void:
	Global.gm.add_followers(count)
