extends Control

@onready var roll_button: Button = $GridContainer/PlayerContainer/VBoxContainer/Button


func _ready() -> void:
	await get_tree().process_frame
	Global.gm.initalize_combat.connect(_on_initalize_combat)
	roll_button.pressed.connect(roll_button.hide)


func _on_initalize_combat(_current_shrine_objects, _current_player_dice, _current_enemy_dice, _player_follower_count, _enemy_follower_count) -> void:
	roll_button.show()
