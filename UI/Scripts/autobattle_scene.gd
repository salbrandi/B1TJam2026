extends Control

@onready var roll_button: Button = $GridContainer/PlayerContainer/VBoxContainer/Button


func _ready() -> void:
	await get_tree().process_frame
	Global.gm.initalize_combat.connect(_on_initalize_combat)
	roll_button.pressed.connect(_set_roll_button_visible.bind(false))


func _on_initalize_combat(_current_shrine_objects, _current_player_dice, _current_enemy_dice, _player_follower_count, _enemy_follower_count) -> void:
	_set_roll_button_visible(true)


# Fade instead of hide() so the VBoxContainer keeps the button's space.
func _set_roll_button_visible(is_visible: bool) -> void:
	roll_button.modulate.a = 1.0 if is_visible else 0.0
	# roll_button.disabled = not is_visible
