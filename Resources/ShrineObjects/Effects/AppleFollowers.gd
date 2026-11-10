class_name AppleFollowers extends ShrineEffect

func on_combat_end() -> void:
	var apple_count := 0
	for effect in Global.gm.all_effects():
		if effect is AppleFollowers:
			apple_count += 1
	Global.gm.add_followers(apple_count)
