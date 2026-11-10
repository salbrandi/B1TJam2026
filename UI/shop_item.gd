extends VBoxContainer

class_name ShopItem

const NAME_MAX_FONT_SIZE := 48
const NAME_MIN_FONT_SIZE := 12

@export var shrineObject: ShrineObject
@export var button: Button

signal purchased(item: ShrineObject)

func _ready():
	button.pressed.connect(_on_button_pressed)
	$Name.resized.connect(_fit_name)
	set_item(shrineObject)


func set_item(item: ShrineObject):
	shrineObject = item
	if not shrineObject:
		return
	$Name.text = shrineObject.name
	_fit_name()
	$Description.text = shrineObject.effect
	$Icon.texture = shrineObject.icon
	button.get_node("HBoxContainer/Price").text = str(shrineObject.price)
	show()
	button.disabled = false
	button.modulate = Color.WHITE

func _fit_name():
	var font: Font = $Name.get_theme_font("font")
	var width: float = $Name.size.x
	if not font or width <= 0:
		return

	var font_size := NAME_MAX_FONT_SIZE
	while font_size > NAME_MIN_FONT_SIZE:
		if font.get_string_size($Name.text, $Name.horizontal_alignment, -1, font_size).x <= width:
			break
		font_size -= 1
	$Name.add_theme_font_size_override("font_size", font_size)


func _on_button_pressed():
	if not Global.gm.spend_followers(shrineObject.price):
		return
	Global.gm.add_shrine_object(shrineObject)
	button.disabled = true
	button.modulate = Color.BLACK
	purchased.emit(shrineObject)
