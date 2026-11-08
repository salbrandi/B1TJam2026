extends VBoxContainer

class_name ShopItem

@export var shrineObject: ShrineObject

func _ready():
	$Button.pressed.connect(_on_button_pressed)
	set_item(shrineObject)


func set_item(item: ShrineObject):
	shrineObject = item
	if not shrineObject:
		return
	$Name.text = shrineObject.name
	$Description.text = shrineObject.effect
	$Icon.texture = shrineObject.icon
	$Button/HBoxContainer/Price.text = str(shrineObject.price)


func _on_button_pressed():
	Global.gm.add_shrine_object(shrineObject)
	hide()
