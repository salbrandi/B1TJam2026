extends Control

const ENEMY_FOLLOWERS_PER_WIN := Vector2i(200, 300)

@onready var roll_button: Button = $GridContainer/PlayerContainer/VBoxContainer/Button
@onready var enemy_grid: ShrineGrid = $GridContainer/EnemyContainer/VBoxContainer/MarginContainer2/ShrineGrid
@onready var deity_icon: TextureRect = $GridContainer/EnemyContainer/VBoxContainer/DeityIcon
@onready var win_loss_label: Label = $ColorRect/CenterContainer/WinLossLabel
@onready var win_loss_label_container: ColorRect = $ColorRect

@export var enemy_icons: Array[Texture2D] = []

var _enemy_icon_index := 0

func _ready() -> void:
	Global.gm.initalize_combat.connect(_on_initalize_combat)
	Global.gm.combat_over.connect(process_win_loss)
	roll_button.pressed.connect(_set_roll_button_visible.bind(false))


func _on_initalize_combat(_current_shrine_objects, _current_player_dice, _current_enemy_dice, _player_follower_count, _enemy_follower_count) -> void:
	Global.gm.current_player_score = 0
	Global.gm.current_enemy_score = 0
	_set_roll_button_visible(true)
	_next_enemy_icon()
	_build_enemy_board()
	win_loss_label_container.visible = false


func _next_enemy_icon() -> void:
	if enemy_icons.is_empty():
		return
	deity_icon.texture = enemy_icons[_enemy_icon_index % enemy_icons.size()]
	_enemy_icon_index += 1


func _build_enemy_board() -> void:
	var shop = Global.gm.all_screens["shop"]
	var tiers: Dictionary = shop.build_rarity_tiers(shop.offering_pool + shop.dice_pool)
	var items: Array[ShrineObject] = []
	var followers := 0
	followers += randi_range(ENEMY_FOLLOWERS_PER_WIN.x, ENEMY_FOLLOWERS_PER_WIN.y) * (Global.gm.player_total_wins + 1 + 10 - Global.gm.player_lives_remaining)
	for _i in Global.gm.player_total_wins + 10 - Global.gm.player_lives_remaining + Global.gm.current_player_shrine_objects.size():
		var item: ShrineObject = shop.roll_from_tiers(tiers)
		if item == null:
			break
		items.append(item)
		followers -= item.price

	followers = maxi(50, followers)
	Global.gm.enemy_follower_count = followers
	enemy_grid.initialize_combat(items)

func process_win_loss():
	if self.visible:
		if Global.gm._is_win:
			win_loss_label.text = "Win!\n\nClick to continue..."
			win_loss_label_container.visible = true
		else:
			win_loss_label.text = "Loss!\n\nClick to continue..."
			win_loss_label_container.visible = true

func _set_roll_button_visible(is_visible: bool) -> void:
	roll_button.modulate.a = 1.0 if is_visible else 0.0
	# roll_button.disabled = not is_visible
