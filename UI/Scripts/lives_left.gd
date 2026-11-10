extends HBoxContainer

func _ready() -> void:
	Global.gm.lost_life.connect(update_ticker)
	pass

	
func update_ticker():
	$LivesLabel.text = str(Global.gm.player_lives_remaining)
