extends Control

@onready var title_text = $GridContainer/TopThird/WinOrLossTitle
@onready var progress_container = $GridContainer/MiddleThird/ProgressContainer
@onready var follower = $GridContainer/BottomThird/FollowerContainer/Follower
@onready var follower_container = $GridContainer/BottomThird/FollowerContainer
@onready var follower_container_size = [$GridContainer.size.x, $GridContainer/BottomThird.size.y]

@onready var filled_trophy = load("res://UI/Sprites/filled_trophy.png")
@onready var empty_trophy = load("res://UI/Sprites/empty_trophy.png")
@onready var filled_heart = load("res://UI/Sprites/filled_heart.png")
@onready var empty_heart = load("res://UI/Sprites/empty_heart.png")

func _ready() -> void:
	Global.gm.battle_over.connect(process_battle)
	randomly_generate_crowd()
	pass

func _process(delta: float) -> void:
	pass

func process_battle():
	if is_inside_tree() and is_visible_in_tree():
		if Global.gm._is_win:
			process_win()
		else:
			process_loss()
	pass
	
func process_win():
	var next_win: TextureRect = null
	var index = 1
	
	title_text.text = "Win"
	
	for child in progress_container.get_children():
		if index < Global.gm.player_total_wins:
			child.texture = filled_trophy
		else:
			child.texture = empty_trophy
		
		if index == Global.gm.player_total_wins:
			next_win = child
		index += 1
			
	await get_tree().create_timer(1.0).timeout
	if next_win:
		next_win.texture = filled_trophy
	pass
	
func process_loss():
	var next_loss: TextureRect = null
	var index = 1
	
	title_text.text = "Loss"
	
	for child in progress_container.get_children():
		if index <= Global.gm.player_lives_remaining:
			child.texture = filled_heart
		else:
			child.texture = empty_heart
		
		if index == Global.gm.player_lives_remaining:
			next_loss = child
		index += 1
	
	await get_tree().create_timer(1.0).timeout
	if next_loss:
		next_loss.texture = empty_heart
	pass
	
func randomly_generate_crowd() -> void:	
	for i in range(500):
		var duplicated_follower = follower.duplicate()
		var random_x  = randf_range(0.0, follower_container_size[0])
		var random_y = randf_range(0.0, follower_container_size[1])
		
		follower_container.add_child(duplicated_follower)
		duplicated_follower.position = Vector2(random_x, random_y)
		
	pass
