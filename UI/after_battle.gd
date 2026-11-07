extends Control

@onready var title_text = $GridContainer/TopThird/WinOrLossTitle
@onready var progress_containter = $GridContainer/MiddleThird/ProgressContainer
@onready var progress_item = $GridContainer/MiddleThird/ProgressContainer/ProgressItem
@onready var follower = $GridContainer/BottomThird/FollowerContainer/Follower
@onready var follower_container = $GridContainer/BottomThird/FollowerContainer
@onready var follower_container_size = [$GridContainer.size.x, $GridContainer/BottomThird.size.y]

var is_win = false

func _ready() -> void:
	if is_win:
		process_win()
	else:
		process_loss()
	pass


func _process(delta: float) -> void:
	pass
	
func process_win():
	for i in range(9):
		progress_item.texture = load("res://UI/Sprites/empty_trophy.png")
		var duplicated_item = progress_item.duplicate()
		progress_containter.add_child(duplicated_item)
	
	randomly_generate_crowd()
	title_text.text = "Win"
	pass
	
func process_loss():
	for i in range(10):
		progress_item.texture = load("res://UI/Sprites/filled_heart.png")
		var duplicated_item = progress_item.duplicate()
		progress_containter.add_child(duplicated_item)
	
	randomly_generate_crowd()
	title_text.text = "Loss"
	pass
	
func randomly_generate_crowd() -> void:	
	for i in range(500):
		var duplicated_follower = follower.duplicate()
		var random_x  = randf_range(0.0, follower_container_size[0])
		var random_y = randf_range(0.0, follower_container_size[1])
		
		follower_container.add_child(duplicated_follower)
		duplicated_follower.position = Vector2(random_x, random_y)
		
	pass
