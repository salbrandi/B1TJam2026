extends VBoxContainer

@export var shrineObject: Object

func ready():
	$Name.text = shrineObject.name
	$Description.text = shrineObject.description
	$Icon.texture = shrineObject.icon
	$price.text = str(shrineObject.price)
	