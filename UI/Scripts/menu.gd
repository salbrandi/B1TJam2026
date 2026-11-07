extends Control

@onready var follower = $GridContainer/BottomThird/FollowerContainer/Follower
@onready var follower_container = $GridContainer/BottomThird/FollowerContainer
@onready var follower_container_size = [$GridContainer.size.x, $GridContainer/BottomThird.size.y]

signal screen_change_request(from_scene: String, to_scene: String)

func _ready() -> void:
	randomly_generate_crowd()
	pass


func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	screen_change_request.emit("title", "battle")
	pass


func _on_exit_game_pressed() -> void:
	get_tree().quit()
	pass
	
func randomly_generate_crowd() -> void:	
	for i in range(500):
		var duplicated_follower = follower.duplicate()
		var random_x  = randf_range(0.0, follower_container_size[0])
		var random_y = randf_range(0.0, follower_container_size[1])
		
		follower_container.add_child(duplicated_follower)
		duplicated_follower.position = Vector2(random_x, random_y)
		
	pass
