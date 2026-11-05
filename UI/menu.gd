extends Control

@onready var follower = $FollowerContainer/Follower
@onready var followerContainer = $FollowerContainer

func _ready() -> void:
	randomly_generate_crowd()
	pass


func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Shop.tscn")
	pass


func _on_exit_game_pressed() -> void:
	get_tree().quit()
	pass
	
func randomly_generate_crowd() -> void:
	var container_size = followerContainer.size
	
	var max_x = container_size.x
	var max_y = container_size.y
	
	for i in range(500):
		var duplicated_follower = follower.duplicate()
		var random_x  = randf_range(0.0, max_x)
		var random_y = randf_range(0.0, max_y)
		
		followerContainer.add_child(duplicated_follower)
		duplicated_follower.position = Vector2(random_x, random_y)
		
	pass
