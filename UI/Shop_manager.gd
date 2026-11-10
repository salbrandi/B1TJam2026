extends Control


@export var offering_pool: Array[ShrineObject] = []
@export var dice_pool: Array[ShrineDice] = []
@export var cursed_pool: Array[ShrineObject] = []

@onready var offering_slot: ShopItem = $ItemCards/GridContainer/ItemSlot/MarginContainer/ShopItem
@onready var dice_slot: ShopItem = $ItemCards/GridContainer/DiceSlot/ShopItem
@onready var cursed_slot: ShopItem = $ItemCards/GridContainer/CurseSlot/ShopItem

@export var base_reroll_cost: int = 5

var offering_tiers: Dictionary = {}
var dice_tiers: Dictionary = {}
var cursed_tiers: Dictionary = {}
var reroll_cost: int

@onready var reroll_price_label: Label = $VBoxContainer2/RerollButton/HBoxContainer/HBoxContainer/Price
@onready var random_label: RandomLabel = $Panel/RandomLabel

func _ready():
	offering_tiers = build_rarity_tiers(offering_pool)
	dice_tiers = build_rarity_tiers(dice_pool)
	cursed_tiers = build_rarity_tiers(cursed_pool)
	cursed_slot.purchased.connect(_on_cursed_purchased)
	await get_tree().process_frame
	Global.gm.shop_opened.connect(_on_shop_opened)
	_on_shop_opened()


func _on_cursed_purchased(item: ShrineObject) -> void:
	cursed_pool.erase(item)
	cursed_tiers = build_rarity_tiers(cursed_pool)


func _on_shop_opened():
	reroll_cost = base_reroll_cost
	roll_pool()
	_update_reroll_price()
	random_label.set_random_text()


func _update_reroll_price():
	reroll_price_label.text = str(reroll_cost)


func build_rarity_tiers(pool: Array) -> Dictionary:
	var tiers := {}
	for item in pool:
		if not tiers.has(item.rarity):
			tiers[item.rarity] = []
		tiers[item.rarity].append(item)
	return tiers


func roll_from_tiers(tiers: Dictionary) -> ShrineObject:
	if tiers.is_empty():
		return null
	var rarities: Array = tiers.keys()
	rarities.sort()
	rarities.reverse()
	for i in rarities.size():
		var rarity: int = rarities[i]
		var is_lowest := i == rarities.size() - 1
		var roll := randi_range(1, 100)
		if roll > rarity or is_lowest:
			return tiers[rarity].pick_random()
	return null


func roll_pool():
	offering_slot.set_item(roll_from_tiers(offering_tiers))
	dice_slot.set_item(roll_from_tiers(dice_tiers))
	cursed_slot.set_item(roll_from_tiers(cursed_tiers))


func _on_reroll_pressed():
	if not Global.gm.spend_followers(reroll_cost):
		return
	roll_pool()
	reroll_cost *= 2
	_update_reroll_price()



func _on_proceed_button_pressed() -> void:
	Global.gm.transition_to_combat("shop")
	get_viewport().set_input_as_handled()
	pass
