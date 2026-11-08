extends VBoxContainer

@export var shrineObject: ShrineObject

func _ready():
	if not shrineObject:
		return
	$Name.text = shrineObject.name
	$Description.text = shrineObject.effect
	$Icon.texture = shrineObject.icon
	$HBoxContainer/Price.text = str(shrineObject.price)
	
