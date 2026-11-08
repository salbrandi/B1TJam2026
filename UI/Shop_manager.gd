extends Control


@export var offering_pool: Array[ShrineObject] = []
@export var dice_pool: Array[ShrineDice] = []
@export var cursed_pool: Array[ShrineObject] = []

@onready var offering_slot: ShopItem = $VBoxContainer/GridContainer/ItemSlot/ShopItem
@onready var dice_slot: ShopItem = $VBoxContainer/GridContainer/DiceSlot/ShopItem
@onready var cursed_slot: ShopItem = $VBoxContainer/GridContainer/CurseSlot/ShopItem

func _ready():
	await get_tree().process_frame
	Global.gm.shop_opened.connect(roll_pool)
	roll_pool()

	
func roll_pool():
	offering_slot.shrineObject = offering_pool.pick_random()
	dice_slot.shrineObject = dice_pool.pick_random()
	cursed_slot.shrineObject = cursed_pool.pick_random()


func _on_proceed_button_pressed() -> void:
	Global.gm.transition_to_combat("shop")
	get_viewport().set_input_as_handled()
	pass
