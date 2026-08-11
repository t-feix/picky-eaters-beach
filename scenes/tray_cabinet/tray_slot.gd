class_name TraySlot
extends Control

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
	if ingredient == null or ingredient.layer_texture == null:
		return null
	var sz := ingredient.layer_size()

	var img := TextureRect.new()
	img.texture = ingredient.layer_texture
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_SCALE
	img.custom_minimum_size = sz
	img.size = sz
	img.position = -sz * 0.5
	img.modulate.a = 0.75
	img.rotation = deg_to_rad(-3) 

	var wrapper := Control.new()
	wrapper.add_child(img)
	set_drag_preview(wrapper)

	return { &"ingredient_id": ingredient.id }
