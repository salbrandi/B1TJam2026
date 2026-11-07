class_name ShrineGrid
extends Container

signal placements_changed

@export var columns: int = 6:
	set(value):
		columns = value
		refresh()

@export var cell_size := Vector2(96, 96):
	set(value):
		cell_size = value
		refresh()

@export var default_objects: Array[ShrineObject] = []

@export var is_player_grid: bool = false

var _placements: Array[Dictionary] = []
var _dragged: Dictionary = {}
var _target := Rect2i()
var _layer := Control.new()
var current_dice: Array[ShrineDice] = []

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	_layer.mouse_filter = MOUSE_FILTER_IGNORE
	_layer.draw.connect(draw_placements)
	add_child(_layer)
	child_entered_tree.connect(func(_node): move_child.call_deferred(_layer, -1))
	refresh()
	show_markers(false)
	initialize_combat()


func initialize_combat():
	current_dice.clear()
	for shrineObj in default_objects:
		if shrineObj is ShrineDice:
			current_dice.append(shrineObj as ShrineDice)
		for i in columns * rows():
			if place_object(shrineObj, Vector2i(i % columns, i / columns)):
				break
	if is_player_grid:
		Global.gm.current_player_dice = current_dice
	else:
		Global.gm.current_enemy_dice = current_dice

# Arrange children
func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var cells := get_cells()
		for i in cells.size():
			cells[i].mouse_filter = MOUSE_FILTER_IGNORE
			fit_child_in_rect(cells[i], Rect2(Vector2(i % columns, i / columns) * cell_size, cell_size))
		fit_child_in_rect(_layer, Rect2(Vector2.ZERO, get_minimum_size()))
		_layer.queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT and not get_viewport().gui_is_dragging():
		show_markers(false)
	elif what == NOTIFICATION_DRAG_END:
		end_drag()


func _process(_delta: float) -> void:
	if _dragged.is_empty() or Rect2(Vector2.ZERO, get_minimum_size()).has_point(get_local_mouse_position()):
		return
	_target = area(_dragged["shrine"], _dragged["cell"])
	_layer.queue_redraw()


func _get_minimum_size() -> Vector2:
	return Vector2(columns, rows()) * cell_size


func refresh() -> void:
	update_minimum_size()
	queue_sort()
	_layer.queue_redraw()


func handle_grid_update() -> void:
	_layer.queue_redraw()
	placements_changed.emit()


func place_object(shrine: ShrineObject, cell: Vector2i) -> bool:
	if not can_place(shrine, cell):
		return false
	_placements.append({"shrine": shrine, "cell": cell})
	handle_grid_update()
	return true


func remove_object_at(cell: Vector2i) -> void:
	_placements.erase(get_object_at(cell))
	handle_grid_update()


func get_placements() -> Array[Dictionary]:
	return _placements.duplicate()


func cell_at_position(pos: Vector2) -> Vector2i:
	return Vector2i((pos / cell_size).floor())


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		show_markers(not get_object_at(cell_at_position(event.position)).is_empty())


func end_drag() -> void:
	_dragged = {}
	_target = Rect2i()
	show_markers(false)
	_layer.queue_redraw()


func _get_drag_data(at_position: Vector2) -> Variant:
	var cell := cell_at_position(at_position)
	var placement := get_object_at(cell)
	if placement.is_empty():
		return null

	var shrine: ShrineObject = placement["shrine"]
	var grab: Vector2i = cell - placement["cell"]
	_dragged = placement
	show_markers(true)
	_layer.queue_redraw()

	var holder := Control.new()
	var preview := Control.new()
	var preview_size := shrine.icon.get_size()
	preview.size = preview_size
	preview.position = -preview_size / 2
	preview.draw.connect(func(): draw_object(preview, shrine, Rect2(Vector2.ZERO, preview_size)))
	holder.add_child(preview)
	set_drag_preview(holder)

	return {"shrine": shrine, "grab": grab}


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.has("shrine")):
		return false
	show_markers(true)
	var inside := Rect2(Vector2.ZERO, get_minimum_size()).has_point(at_position)
	var origin := determine_drop_origin(at_position, data)
	_target = area(data["shrine"], origin) if inside else Rect2i()
	if not inside and not _dragged.is_empty():
		_target = area(_dragged["shrine"], _dragged["cell"])
	_layer.queue_redraw()
	return inside and can_place(data["shrine"], origin, _dragged)


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var origin := determine_drop_origin(at_position, data)
	if _dragged.is_empty():
		_placements.append({"shrine": data["shrine"], "cell": origin})
	else:
		_dragged["cell"] = origin
	end_drag()
	handle_grid_update()


func determine_drop_origin(at_position: Vector2, data: Dictionary) -> Vector2i:
	var shrine: ShrineObject = data["shrine"]
	var max_origin := Vector2i(columns, rows()) - Vector2i(shrine.grid_width, shrine.grid_height)
	return (cell_at_position(at_position) - data["grab"]).clamp(Vector2i.ZERO, max_origin)


func can_place(shrine: ShrineObject, origin: Vector2i, ignore: Dictionary = {}) -> bool:
	var new_area := area(shrine, origin)
	if not Rect2i(Vector2i.ZERO, Vector2i(columns, rows())).encloses(new_area):
		return false
	for placement in _placements:
		if placement != ignore and area(placement["shrine"], placement["cell"]).intersects(new_area):
			return false
	return true


func get_object_at(cell: Vector2i) -> Dictionary:
	for placement in _placements:
		if area(placement["shrine"], placement["cell"]).has_point(cell):
			return placement
	return {}


func area(shrine: ShrineObject, origin: Vector2i) -> Rect2i:
	return Rect2i(origin, Vector2i(shrine.grid_width, shrine.grid_height))


func cell_rect(cells: Rect2i) -> Rect2:
	return Rect2(Vector2(cells.position) * cell_size, Vector2(cells.size) * cell_size)


func draw_placements() -> void:
	for placement in _placements:
		if placement != _dragged:
			draw_object(_layer, placement["shrine"], cell_rect(area(placement["shrine"], placement["cell"])))
	if _target.has_area():
		_layer.draw_rect(cell_rect(_target), Color.WHITE, false, 1.0)


func draw_object(canvas: CanvasItem, shrine: ShrineObject, rect: Rect2) -> void:
	canvas.draw_texture_rect(shrine.icon, rect, false)


func get_cells() -> Array[Control]:
	var cells: Array[Control] = []
	for child in get_children():
		if child != _layer:
			cells.append(child as Control)
	return cells


func show_markers(on: bool) -> void:
	for cell in get_cells():
		cell.visible = on


func rows() -> int:
	return ceili(float(get_cells().size()) / columns)
