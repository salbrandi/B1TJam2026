extends Label

class_name RandomLabel

@export var random_texts: Array[String] = []
@export var max_font_size: int = 48
@export var min_font_size: int = 24

var _box_size := Vector2.ZERO

func _ready() -> void:
	_box_size = size
	resized.connect(_on_resized)
	if random_texts.size() > 0:
		set_fitted_text(random_texts.pick_random())

func _on_resized() -> void:
	if _box_size == Vector2.ZERO or size.x != _box_size.x:
		_box_size = size
		fit_text()

func set_random_text() -> void:
	if random_texts.size() > 0:
		set_fitted_text(random_texts.pick_random())

func set_fitted_text(new_text: String) -> void:
	text = new_text
	fit_text()

func fit_text() -> void:
	var font: Font = get_theme_font("font")
	if not font or _box_size.x <= 0 or _box_size.y <= 0:
		return

	var current_size: int = max_font_size
	while current_size > min_font_size:
		var text_size: Vector2
		if autowrap_mode == TextServer.AUTOWRAP_OFF:
			text_size = font.get_string_size(text, horizontal_alignment, -1, current_size)
		else:
			text_size = font.get_multiline_string_size(text, horizontal_alignment, _box_size.x, current_size)

		if text_size.x <= _box_size.x and text_size.y <= _box_size.y:
			break
		current_size -= 1

	add_theme_font_size_override("font_size", current_size)
