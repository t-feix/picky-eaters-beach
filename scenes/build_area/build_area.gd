extends Control

signal sandwich_changed(layers: Array[StringName])

const LAYER_SCENE := preload("res://scenes/build_area/sandwich_layer.tscn")

@onready var stack: Control = %StackBox

const SQUASH = 0.15

var _stack_home: Vector2

@export var separation: float = 10.0:
	set(value):
		separation = value
		if is_node_ready():
			_position_layers()

var layers: Array[StringName] = []
var preview_idx := -1
var preview_h := 0.0

var _lifted_idx := -1
var _lifted_id := &""

func _ready() -> void:
	_stack_home = stack.position
	mouse_exited.connect(_clear_preview)
	
func _on_layer_drag_started(idx: int) -> void:
	_lifted_idx = idx
	_lifted_id = layers[idx]
	_lift.call_deferred(idx)

func _lift(idx: int) -> void:
	remove_at(idx)

func _can_drop_data(pos: Vector2, data) -> bool:
	print("CAN_DROP ", data)
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
	_lifted_idx = -1
	insert_layer(idx, data[&"ingredient_id"])


func _notification(what: int) -> void:
	if what != NOTIFICATION_DRAG_END:
		return
	_clear_preview()
	if _lifted_idx != -1:
		var i := mini(_lifted_idx, layers.size())
		var id := _lifted_id
		_lifted_idx = -1
		insert_layer(i, id)

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


func _advance(ing: IngredientData) -> float:
	return ing.layer_size().y - ing.overlap + separation

func _target_position(idx: int) -> Vector2:
	var y := 0.0
	for i in layers.size():
		if i == preview_idx:
			y += preview_h
		var ing: IngredientData = Ingredients.by_id[layers[i]]
		var sz := ing.layer_size()
		if i == idx:
			return Vector2(-sz.x * 0.5, -y - sz.y)
		y += _advance(ing)
	return Vector2.ZERO

func _position_layers(animate := true) -> void:
	for i in stack.get_child_count():
		var node: SandwichLayer = stack.get_child(i)
		node.size = node.custom_minimum_size
		if animate:
			node.move_to(_target_position(i))
		else:
			node.snap_to(_target_position(i))

func _reindex() -> void:
	for i in stack.get_child_count():
		var node: SandwichLayer = stack.get_child(i)
		node.index = i
		node.z_index = i

func insert_layer(idx: int, id: StringName) -> void:
	layers.insert(idx, id)
	var node: SandwichLayer = LAYER_SCENE.instantiate()
	stack.add_child(node)
	stack.move_child(node, idx)
	node.setup(idx, Ingredients.by_id[id])
	node.remove_requested.connect(remove_at)
	node.drag_started.connect(_on_layer_drag_started)
	_reindex()
	node.snap_to(_target_position(idx))
	_position_layers(true)
	sandwich_changed.emit(layers)

func remove_at(idx: int) -> void:
	layers.remove_at(idx)
	var node: SandwichLayer = stack.get_child(idx)
	stack.remove_child(node)
	node.queue_free()
	_reindex()
	_position_layers(true)
	sandwich_changed.emit(layers)

func collapse(duration := 0.45) -> void:
	if layers.is_empty():
		return
	var y := 0.0
	var tw := create_tween().set_parallel(true)
	tw.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	for i in stack.get_child_count():
		var node: SandwichLayer = stack.get_child(i)
		var target := Vector2(-node.size.x * 0.5, -y - node.size.y)
		tw.tween_property(node, "position", target, duration).set_delay(i * 0.04)
		node.set_target(target)
		y += node.size.y * SQUASH
	await tw.finished

func move_to_customer(delta: Vector2, duration := 0.5) -> void:
	if layers.is_empty():
		return
	var t := create_tween().set_parallel(true)
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(stack, "position", stack.position + delta, duration)
	t.tween_property(stack, "scale", Vector2(0.45, 0.45), duration)
	await t.finished

func ride_out(delta_x: float, duration := 0.5) -> void:
	if layers.is_empty():
		return
	var t := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	t.tween_property(stack, "position:x", stack.position.x + delta_x, duration)
	await t.finished
	_reset_stack()

func _reset_stack() -> void:
	clear()
	stack.position = _stack_home
	stack.scale = Vector2.ONE
	stack.modulate.a = 1.0
