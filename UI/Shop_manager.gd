extends Control


@export var offering_pool: Array[ShrineObject] = []
@export var dice_pool: Array[ShrineDice] = []
@export var cursed_pool: Array[ShrineObject] = []

@onready var offering_slot: ShopItem = $VBoxContainer/GridContainer/ItemSlot/ShopItem
@onready var dice_slot: ShopItem = $VBoxContainer/GridContainer/DiceSlot/ShopItem
@onready var cursed_slot: ShopItem = $VBoxContainer/GridContainer/CurseSlot/ShopItem

func _ready():
	Global.gm.shop_opened.connect(roll_pool)
	roll_pool()

	
func roll_pool():
	offering_slot.shrineObject = offering_pool.pick_random()
	dice_slot.shrineObject = dice_pool.pick_random()
	cursed_slot.shrineObject = cursed_pool.pick_random()