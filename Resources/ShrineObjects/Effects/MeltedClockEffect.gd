class_name MeltedClockEffect extends ShrineEffect

func on_combat_end() -> void:
	var gm := Global.gm
	var candidates: Array[ShrineObject] = []
	for item in gm.current_player_shrine_objects:
		if not item.effects.has(self):
			candidates.append(item)
	if candidates.is_empty():
		return
	gm.remove_shrine_object(candidates.pick_random())

	var shop = gm.all_screens["shop"]
	var replacement: ShrineObject = shop.roll_from_tiers(shop.build_rarity_tiers(shop.offering_pool + shop.dice_pool))
	if replacement:
		gm.add_shrine_object(replacement)
