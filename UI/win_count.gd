extends HBoxContainer

func _ready() -> void:
	Global.gm.win_gained.connect(update_ticker)
	pass

	
func update_ticker():
	$WinsLabel.text = str(Global.gm.player_total_wins)
