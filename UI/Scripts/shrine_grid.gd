class_name ShrineGrid
extends Container

signal placements_changed

@export var columns: int = 8:
	set(value):
		columns = value
		if is_inside_tree():
			_sync_cells()
		refresh()

@export var rows: int = 8:
	set(value):
		rows = value
		if is_inside_tree():
			_sync_cells()
		refresh()

@export var cell_size := Vector2(96, 96):
	set(value):
		cell_size = value
		refresh()

@export var default_objects: Array[ShrineObject] = []

@export var is_player_grid: bool = false

const TOOLTIP_SCENE := preload("res://shrine_tooltip.tscn")

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
	_sync_cells()
	refresh()
	show_markers(false)
	initialize_combat()
	if is_player_grid:
		Global.gm.player_grid = self
		Global.gm.shrine_object_added.connect(_on_shrine_object_added)
		Global.gm.shrine_object_removed.connect(_on_shrine_object_removed)
	ThemeDB.get_default_theme().set_stylebox("panel", "TooltipPanel", StyleBoxEmpty.new())


func _on_shrine_object_added(item: ShrineObject) -> void:
	for i in columns * rows:
		if place_object(item, Vector2i(i % columns, i / columns)):
			return


func _on_shrine_object_removed(item: ShrineObject) -> void:
	for placement in _placements.duplicate():
		if placement["shrine"] == item:
			_placements.erase(placement)
	handle_grid_update()


func initialize_combat(extra_objects: Array[ShrineObject] = []):
	_placements.clear()
	current_dice.clear()
	for shrineObj in default_objects + extra_objects:
		if shrineObj is ShrineDice:
			current_dice.append(shrineObj as ShrineDice)
		for i in columns * rows:
			if place_object(shrineObj, Vector2i(i % columns, i / columns)):
				break
	if is_player_grid:
		Global.gm.current_player_dice = current_dice
	else:
		Global.gm.current_enemy_dice = current_dice
	publish_dice_adjacency()

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
	return Vector2(columns, rows) * cell_size


func refresh() -> void:
	update_minimum_size()
	queue_sort()
	_layer.queue_redraw()


func handle_grid_update() -> void:
	_layer.queue_redraw()
	publish_dice_adjacency()
	placements_changed.emit()


func publish_dice_adjacency() -> void:
	if is_player_grid:
		Global.gm.player_dice_adjacency = adjacent_dice_counts()
		Global.gm.player_dice_right_neighbour = right_neighbour_indices()
		Global.gm.player_dice_neighbours = edge_neighbour_indices()
		Global.gm.player_item_dice = item_dice_neighbours()


func _get_tooltip(at_position: Vector2) -> String:
	var placement := get_object_at(cell_at_position(at_position))
	if placement.is_empty():
		return ""
	var shrine: ShrineObject = placement["shrine"]
	return "%s\n%s" % [shrine.name, shrine.effect]


func _make_custom_tooltip(for_text: String) -> Object:
	var placement := get_object_at(cell_at_position(get_local_mouse_position()))
	if placement.is_empty():
		return null
	var tooltip := TOOLTIP_SCENE.instantiate()
	tooltip.setup(placement["shrine"])
	return tooltip

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
	if not is_player_grid:
		return null
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
	if not is_player_grid:
		return false
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
	if not is_player_grid:
		return
	var origin := determine_drop_origin(at_position, data)
	if _dragged.is_empty():
		_placements.append({"shrine": data["shrine"], "cell": origin})
	else:
		_dragged["cell"] = origin
	end_drag()
	handle_grid_update()


func determine_drop_origin(at_position: Vector2, data: Dictionary) -> Vector2i:
	var shrine: ShrineObject = data["shrine"]
	var max_origin := Vector2i(columns, rows) - Vector2i(shrine.grid_width, shrine.grid_height)
	return (cell_at_position(at_position) - data["grab"]).clamp(Vector2i.ZERO, max_origin)


func can_place(shrine: ShrineObject, origin: Vector2i, ignore: Dictionary = {}) -> bool:
	var new_area := area(shrine, origin)
	if not Rect2i(Vector2i.ZERO, Vector2i(columns, rows)).encloses(new_area):
		return false
	for placement in _placements:
		if placement != ignore and area(placement["shrine"], placement["cell"]).intersects(new_area):
			return false
	return true


func has_room_for(shrine: ShrineObject) -> bool:
	for i in columns * rows:
		if can_place(shrine, Vector2i(i % columns, i / columns)):
			return true
	return false


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
		if child != _layer and child is Control:
			cells.append(child as Control)
	return cells


func show_markers(on: bool) -> void:
	for cell in get_cells():
		cell.visible = on



func _sync_cells() -> void:
	var cells := get_cells()
	var target := columns * rows
	while cells.size() < target:
		var cell: Control
		if cells.is_empty():
			cell = TextureRect.new()
		else:
			cell = cells[0].duplicate() as Control
		add_child(cell)
		cells.append(cell)
	while cells.size() > target:
		var cell := cells.pop_back() as Control
		remove_child(cell)
		cell.queue_free()


func adjacent_dice_counts() -> Array[int]:
	var areas := get_dice_areas()
	var counts: Array[int] = []
	for i in areas.size():
		var count := 0
		for j in areas.size():
			if i != j and _edge_adjacent(areas[i], areas[j]):
				count += 1
		counts.append(count)
	return counts


func right_neighbour_indices() -> Array[int]:
	var areas := get_dice_areas()
	var neighbours: Array[int] = []
	for i in areas.size():
		var found := -1
		for j in areas.size():
			if i != j and _touches_right(areas[i], areas[j]):
				found = j
				break
		neighbours.append(found)
	return neighbours


func edge_neighbour_indices() -> Array:
	var areas := get_dice_areas()
	var neighbours: Array = []
	for i in areas.size():
		var found: Array[int] = []
		for j in areas.size():
			if i != j and _edge_adjacent(areas[i], areas[j]):
				found.append(j)
		neighbours.append(found)
	return neighbours


func item_dice_neighbours() -> Array[Dictionary]:
	var areas := get_dice_areas()
	var result: Array[Dictionary] = []
	for placement in _placements:
		var shrine: ShrineObject = placement["shrine"]
		if shrine is ShrineDice:
			continue
		var item_area := area(shrine, placement["cell"])
		var dice: Array[int] = []
		var right: Array[int] = []
		for i in areas.size():
			if _edge_adjacent(item_area, areas[i]):
				dice.append(i)
			if _touches_right(item_area, areas[i]):
				right.append(i)
		result.append({"item": shrine, "dice": dice, "right": right})
	return result


func get_dice_areas() -> Array[Rect2i]:
	var unclaimed := _placements.duplicate()
	var result: Array[Rect2i] = []
	for die in current_dice:
		var found := {}
		for placement in unclaimed:
			if placement["shrine"] == die:
				found = placement
				break
		if found.is_empty():
			result.append(Rect2i())
		else:
			unclaimed.erase(found)
			result.append(area(found["shrine"], found["cell"]))
	return result


func _touches_right(a: Rect2i, b: Rect2i) -> bool:
	return a.has_area() and b.position.x == a.end.x and b.position.y < a.end.y and b.end.y > a.position.y


func _edge_adjacent(a: Rect2i, b: Rect2i) -> bool:
	for x in range(a.position.x, a.end.x):
		for y in range(a.position.y, a.end.y):
			for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if b.has_point(Vector2i(x, y) + offset):
					return true
	return false
