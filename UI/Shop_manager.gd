extends Control


@export var offering_pool: Array[ShrineObject] = []
@export var dice_pool: Array[ShrineDice] = []
@export var cursed_pool: Array[ShrineObject] = []

@onready var offering_slot: ShopItem = $ItemCards/GridContainer/ItemSlot/ShopItem
@onready var dice_slot: ShopItem = $ItemCards/GridContainer/DiceSlot/ShopItem
@onready var cursed_slot: ShopItem = $ItemCards/GridContainer/CurseSlot/ShopItem

func _ready():
	await get_tree().process_frame
	Global.gm.shop_opened.connect(roll_pool)
	roll_pool()

	
func roll_pool():
	offering_slot.set_item(offering_pool.pick_random())
	dice_slot.set_item(dice_pool.pick_random())
	cursed_slot.set_item(cursed_pool.pick_random())


func _on_reroll_pressed():
	roll_pool()



func _on_proceed_button_pressed() -> void:
	Global.gm.transition_to_combat("shop")
	get_viewport().set_input_as_handled()
	pass
