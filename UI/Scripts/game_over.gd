extends Control

@onready var firework = $Firework
@onready var final_title = $CenterContainer/VBoxContainer/FinalWinOrLossTitle

func _ready() -> void:
	Global.gm.game_over.connect(process_game_over)
	pass

func _process(delta: float) -> void:
	pass
	
func process_game_over():
	if is_inside_tree() and is_visible_in_tree():
		if Global.gm._is_victory:
			process_victory()
		else:
			process_loss()
	pass

func process_victory() -> void:
	final_title.text = "You Win!"
	spawn_fireworks()
	
func process_loss() -> void:
	final_title.text = "You Lost!"
	
func spawn_fireworks() -> void:
	var window_size = get_viewport_rect().size	
	var max_x = window_size.x
	var max_y = window_size.y
	
	for i in range(500):
		var duplicated_firework = firework.duplicate()
		var random_x  = randf_range(0.0, max_x)
		var random_y = randf_range(0.0, max_y)
		
		duplicated_firework.show()
		add_child(duplicated_firework)
		duplicated_firework.position = Vector2(random_x, random_y)
		
		await get_tree().create_timer(1.5).timeout
		
	pass


func _on_back_to_menu_pressed() -> void:
	Global.gm.transition_to_title("game_over")
	pass
