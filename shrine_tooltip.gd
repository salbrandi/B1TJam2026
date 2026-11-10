extends Control


func setup(shrine: ShrineObject) -> void:
	%ItemName.text = shrine.name
	%ItemEffect.text = shrine.effect
