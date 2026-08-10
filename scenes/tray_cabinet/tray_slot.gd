class_name TraySlot
extends TextureRect

@onready var icon: TextureRect = %IngredientTexture

var ingredient: IngredientData = null:
	set(value):
		ingredient = value
		if is_node_ready():
			_refresh()

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if ingredient:
		icon.texture = ingredient.texture
		icon.modulate = ingredient.color
	else:
		icon.texture = null
		
const PREVIEW_SIZE := Vector2(300, 40)

func _get_drag_data(_pos: Vector2):
	if ingredient == null:
		return null
	var preview := TextureRect.new()
	preview.texture = ingredient.texture
	preview.modulate = ingredient.color
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = PREVIEW_SIZE
	preview.size = PREVIEW_SIZE
	set_drag_preview(preview)
	return { &"ingredient_id": ingredient.id }
