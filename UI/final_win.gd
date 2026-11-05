extends Control

@onready var firework = $Firework

func _ready() -> void:
	spawn_fireworks()
	pass


func _process(delta: float) -> void:
	pass
	
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
	get_tree().change_scene_to_file("res://UI/Menu.tscn")
	pass
