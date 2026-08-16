extends Control

const SLOT := preload("res://scenes/tray_cabinet/tray_slot.tscn")

@onready var row: HBoxContainer = %Row

var slots: Array[TraySlot] = []

func _ready() -> void:
	for ing in Ingredients.sauces:
		var s: TraySlot = SLOT.instantiate()
		row.add_child(s)
		s.show_frame = false
		s.custom_minimum_size = Vector2(90, 200)
		s.ingredient = ing
		slots.append(s)
	print("sauces: ", Ingredients.sauces.size())

var locked := true:
	set(value):
		locked = value
		for s in slots:
			s.locked = value
