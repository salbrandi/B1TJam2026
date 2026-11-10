class_name ConsumeRightDie extends ShrineEffect

func consume_die(consumer: ShrineDice, consumed: ShrineDice) -> bool:
	var bonus: int = consumed.values.pick_random()
	var values: Array[int] = []
	for value in consumer.values:
		values.append(value + bonus)
	consumer.values = values
	return true
