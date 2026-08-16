extends Control

const TRAY_SLOT := preload("res://scenes/tray_cabinet/tray_slot.tscn")

@export var slot_count: int = 24
@export var columns: int = 12

@export var rows: int = 2
@export var padding: int = 16
@export var gap: int = 8

@onready var grid: GridContainer = %TrayGrid

var slots: Array[TraySlot] = []

func _ready() -> void:
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", gap)
	grid.add_theme_constant_override("v_separation", gap)
	for i in slot_count:
		var slot: TraySlot = TRAY_SLOT.instantiate()
		grid.add_child(slot)
		slots.append(slot)
	set_palette(Ingredients.tray)
	resized.connect(_resize_slots)
	_resize_slots()

func set_palette(unlocked: Array[IngredientData]) -> void:
	for i in slot_count:
		slots[i].ingredient = unlocked[i] if i < unlocked.size() else null


func _resize_slots() -> void:
	var avail := size.y - padding * 2.0 - gap * (rows - 1)
	var s := floorf(avail / rows)
	if s <= 0.0:
		return
	for slot in slots:
		slot.custom_minimum_size = Vector2(s, s)

func _can_drop_data(_pos: Vector2, data) -> bool:
	return data is Dictionary and data.has(&"ingredient_id")

func _drop_data(_pos: Vector2, _data) -> void:
	pass
