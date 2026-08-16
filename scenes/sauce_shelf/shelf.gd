extends Control

const SLOT := preload("res://scenes/tray_cabinet/tray_slot.tscn")

@onready var row: BoxContainer = %Row
@export var vertical: bool = false

@export var sep: int


@export var station: IngredientData.Station = IngredientData.Station.SAUCE
@export var slot_size := Vector2(90, 200)
@export var show_frames := false

var slots: Array[TraySlot] = []

func _can_drop_data(_pos: Vector2, data) -> bool:
	return data is Dictionary and data.has(&"ingredient_id")

func _ready() -> void:
	row.vertical = vertical
	row.add_theme_constant_override(&"separation", sep)
	var source: Array = Ingredients.sauces if station == IngredientData.Station.SAUCE else Ingredients.breads
	for ing in source:
		var s: TraySlot = SLOT.instantiate()
		row.add_child(s)
		s.show_frame = show_frames
		s.custom_minimum_size = slot_size
		s.ingredient = ing
		slots.append(s)

var locked := true:
	set(value):
		locked = value
		for s in slots:
			s.locked = value
