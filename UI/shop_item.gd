extends VBoxContainer

class_name ShopItem

@export var shrineObject: ShrineObject

func _ready():
	if not shrineObject:
		return
	$Name.text = shrineObject.name
	$Description.text = shrineObject.effect
	$Icon.texture = shrineObject.icon
	$Button/HBoxContainer/Price.text = str(shrineObject.price)
	$Button.connect("pressed", _on_button_pressed)
	


func _on_button_pressed():
	Global.gm.current_player_shrine_objects.append(shrineObject)
