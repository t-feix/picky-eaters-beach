extends Control

const TRAY_SLOT := preload("res://scenes/tray_cabinet/tray_slot.tscn")

@export var slot_count: int = 16
@export var columns: int = 8

@onready var grid: GridContainer = %TrayGrid

var slots: Array[TraySlot] = []

func _ready() -> void:
	grid.columns = columns
	for i in slot_count:
		var slot: TraySlot = TRAY_SLOT.instantiate()
		grid.add_child(slot)
		slots.append(slot)
	set_palette(Ingredients.all)

func set_palette(unlocked: Array[IngredientData]) -> void:
	for i in slot_count:
		slots[i].ingredient = unlocked[i] if i < unlocked.size() else null
