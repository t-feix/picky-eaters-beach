class_name TraySlot
extends TextureRect

const LAYER_WIDTH := 300

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
	var tex: Texture2D = ingredient.layer_texture
	if tex == null:
		return null
	var sz := ingredient.layer_size()

	var preview := TextureRect.new()
	preview.texture = tex
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_SCALE
	preview.custom_minimum_size = sz
	preview.size = sz
	set_drag_preview(preview)
	return { &"ingredient_id": ingredient.id }
