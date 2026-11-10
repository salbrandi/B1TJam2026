extends Control

func _ready() -> void:
	pass


func _on_unpause_button_pressed() -> void:
	Global.gm.toggle_pause()
	pass


func _on_back_to_menu_button_pressed() -> void:
	Global.gm.reset_game()
	Global.gm.transition_to_title("pause")
	get_tree().paused = !get_tree().paused


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
	pass
