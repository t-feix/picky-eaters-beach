class_name SandwichLayer
extends TextureRect

const LAYER_WIDTH := 300.0

signal remove_requested(idx: int)
signal drag_started(idx: int)
var ingredient_id: StringName

var index: int = -1

var _tween: Tween
var _target := Vector2.INF

func setup(i: int, ing: IngredientData) -> void:
	index = i
	ingredient_id = ing.id
	texture = ing.layer_texture
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = ing.layer_size()

func snap_to(target: Vector2) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_target = target
	position = target

func move_to(target: Vector2, duration := 0.16) -> void:
	if _target.is_equal_approx(target):
		return
	_target = target
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not is_inside_tree():
		position = target
		return
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", target, duration)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_RIGHT \
	and event.pressed:
		remove_requested.emit(index)

func _can_drop_data(_pos: Vector2, _data) -> bool:
	return false

func _get_drag_data(_pos: Vector2):
	var sz := custom_minimum_size
	var img := TextureRect.new()
	img.texture = texture
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_SCALE
	img.custom_minimum_size = sz
	img.size = sz
	img.position = -sz * 0.5
	img.modulate.a = 0.75
	var wrapper := Control.new()
	wrapper.add_child(img)
	set_drag_preview(wrapper)
	drag_started.emit(index)
	return { &"ingredient_id": ingredient_id }
