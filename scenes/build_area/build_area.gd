extends Control

signal sandwich_changed(layers: Array[StringName])

const LAYER_SCENE := preload("res://scenes/build_area/sandwich_layer.tscn")

@onready var stack: Control = %StackBox

@export var separation: float = 10.0:
	set(value):
		separation = value
		if is_node_ready():
			_position_layers()

var layers: Array[StringName] = []
var preview_idx := -1
var preview_h := 0.0

func _ready() -> void:
	mouse_exited.connect(_clear_preview)

func _advance(ing: IngredientData) -> float:
	return ing.layer_size().y - ing.overlap + separation

func _can_drop_data(pos: Vector2, data) -> bool:
	if not (data is Dictionary and data.has(&"ingredient_id")):
		return false
	var idx := _drop_index_at(pos)
	if idx != preview_idx:
		preview_idx = idx
		var ing: IngredientData = Ingredients.by_id[data[&"ingredient_id"]]
		preview_h = _advance(ing)
		_position_layers()
	return true

func _drop_data(pos: Vector2, data) -> void:
	var idx := _drop_index_at(pos)
	preview_idx = -1
	layers.insert(idx, data[&"ingredient_id"])
	_rebuild()

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_clear_preview()

func _clear_preview() -> void:
	if preview_idx != -1:
		preview_idx = -1
		_position_layers()

func _drop_index_at(pos: Vector2) -> int:
	var gy := global_position.y + pos.y
	var base := stack.global_position.y
	var y := 0.0
	for i in layers.size():
		var ing: IngredientData = Ingredients.by_id[layers[i]]
		var h := ing.layer_size().y
		if gy > base - y - h * 0.5:
			return i
		y += _advance(ing)
	return layers.size()

func remove_at(idx: int) -> void:
	layers.remove_at(idx)
	_rebuild()

func clear() -> void:
	layers.clear()
	_rebuild()

func _rebuild() -> void:
	for child in stack.get_children():
		stack.remove_child(child)
		child.queue_free()
	for i in layers.size():
		var node: SandwichLayer = LAYER_SCENE.instantiate()
		stack.add_child(node)
		node.setup(i, Ingredients.by_id[layers[i]])
		node.z_index = i
		node.remove_requested.connect(remove_at)
	_position_layers()
	sandwich_changed.emit(layers)

func _position_layers() -> void:
	var y := 0.0
	for i in stack.get_child_count():
		if i == preview_idx:
			y += preview_h
		var node: Control = stack.get_child(i)
		var ing: IngredientData = Ingredients.by_id[layers[i]]
		node.size = node.custom_minimum_size
		node.position = Vector2(-node.size.x * 0.5, -y - node.size.y)
		y += _advance(ing)
