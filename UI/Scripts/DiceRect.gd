class_name DiceRect
extends TextureRect

@export var dice: ShrineDice


func _ready() -> void:
	if dice:
		texture = dice.icon
	else:
		dice = preload("res://Resources/ShrineObjects/Dice/dice.tres")


func roll() -> int:
	var value := dice.roll()
	var icon := dice.icon as AtlasTexture

	var face_size := icon.region.size
	var face := AtlasTexture.new()
	face.atlas = icon.atlas
	face.region = Rect2(icon.region.position + Vector2(face_size.x * (value - 1), 0), face_size)
	texture = face
	return value
