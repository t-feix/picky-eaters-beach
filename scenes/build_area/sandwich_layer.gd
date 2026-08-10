class_name SandwichLayer
extends TextureRect

signal remove_requested(idx: int)

var index: int = -1

func setup(i: int, ing: IngredientData) -> void:
	index = i
	texture = ing.texture
	modulate = ing.color
	custom_minimum_size = Vector2(300, 40)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_RIGHT \
	and event.pressed:
		remove_requested.emit(index)

func _can_drop_data(_pos: Vector2, _data) -> bool:
	return false
