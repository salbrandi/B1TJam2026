extends Control

@onready var follower = $GridContainer/BottomThird/FollowerContainer/Follower
@onready var followerContainer = $GridContainer/BottomThird/FollowerContainer
@onready var followerContainerSize = [$GridContainer.size.x, $GridContainer/BottomThird.size.y]

func _ready() -> void:
	randomly_generate_crowd()
	pass


func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main Scene.tscn")
	pass


func _on_exit_game_pressed() -> void:
	get_tree().quit()
	pass
	
func randomly_generate_crowd() -> void:	
	for i in range(500):
		var duplicated_follower = follower.duplicate()
		var random_x  = randf_range(0.0, followerContainerSize[0])
		var random_y = randf_range(0.0, followerContainerSize[1])
		
		followerContainer.add_child(duplicated_follower)
		duplicated_follower.position = Vector2(random_x, random_y)
		
	pass
