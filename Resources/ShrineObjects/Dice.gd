class_name ShrineDice extends ShrineObject

@export var num_sides: int
@export var current_value: int
@export var faces_atlas = AtlasTexture

func roll() -> int:
	current_value = randi() % num_sides + 1
	return current_value

func apply_dice_effect() -> void:
	# Implement the effect of the dice here
	pass