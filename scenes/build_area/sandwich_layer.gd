class_name SandwichLayer
extends TextureRect

const LAYER_WIDTH := 300.0

signal remove_requested(idx: int)

var index: int = -1

func setup(i: int, ing: IngredientData) -> void:
	index = i
	texture = ing.layer_texture
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = ing.layer_size()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_RIGHT \
	and event.pressed:
		remove_requested.emit(index)

func _can_drop_data(_pos: Vector2, _data) -> bool:
	return false
