extends Control

signal sandwich_changed(layers: Array[StringName])

const LAYER_SCENE := preload("res://scenes/build_area/sandwich_layer.tscn")

@onready var stack: VBoxContainer = %StackBox

var layers: Array[StringName] = []

func _can_drop_data(_pos: Vector2, data) -> bool:
	return data is Dictionary and data.has(&"ingredient_id")

func _drop_data(pos: Vector2, data) -> void:
	layers.insert(_drop_index_at(pos), data[&"ingredient_id"])
	_rebuild()

func _drop_index_at(pos: Vector2) -> int:
	for i in stack.get_child_count():
		var child: Control = stack.get_child(i)
		var mid := stack.position.y + child.position.y + child.size.y * 0.5
		if pos.y < mid:
			return layers.size() - i
	return 0

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
	for i in range(layers.size() - 1, -1, -1):
		var node: SandwichLayer = LAYER_SCENE.instantiate()
		stack.add_child(node)
		node.setup(i, Ingredients.by_id[layers[i]])
		node.remove_requested.connect(remove_at)
	sandwich_changed.emit(layers)
