extends Control


@export var offering_pool: Array[ShrineObject] = []
@export var dice_pool: Array[ShrineDice] = []
@export var cursed_pool: Array[ShrineObject] = []

@onready var offering_slot: ShopItem = $VBoxContainer/GridContainer/ItemSlot/ShopItem
@onready var dice_slot: ShopItem = $VBoxContainer/GridContainer/DiceSlot/ShopItem
@onready var cursed_slot: ShopItem = $VBoxContainer/GridContainer/CurseSlot/ShopItem

func _ready():
	visibility_changed.connect(_on_visibility_changed)
	roll_pool()

func _on_visibility_changed():
	if visible:
		roll_pool()

	
func roll_pool():
	offering_slot.shrineObject = offering_pool.pick_random()
	dice_slot.shrineObject = dice_pool.pick_random()
	cursed_slot.shrineObject = cursed_pool.pick_random()