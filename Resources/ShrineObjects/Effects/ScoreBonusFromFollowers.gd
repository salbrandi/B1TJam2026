class_name ScoreBonusFromFollowers extends ShrineEffect

@export var bonus: float = 0.1

func modify_score(score: float) -> float:
	return score * (1.0 + bonus)
