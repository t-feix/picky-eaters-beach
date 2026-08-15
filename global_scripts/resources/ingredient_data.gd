class_name IngredientData
extends Resource

const LAYER_WIDTH := 300

@export var id: StringName
@export var display_name: String
@export var texture: Texture2D
@export var color: Color = Color.WHITE
@export var tags: Array[StringName] = []
@export var layer_texture: Texture2D
@export var overlap: int = 10
@export var color_tag: StringName
@export var unit_singular: String
@export var unit_plural: String

func layer_size() -> Vector2:
	if layer_texture == null:
		return Vector2(LAYER_WIDTH, 40.0)
	var s := LAYER_WIDTH / float(layer_texture.get_width())
	return Vector2(LAYER_WIDTH, layer_texture.get_height() * s)
