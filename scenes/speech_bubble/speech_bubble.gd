extends Control

const ROW := preload("res://scenes/speech_bubble/demand_row.tscn")

@onready var list: VBoxContainer = %DemandList

func show_demands(entries: Array) -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	for e in entries:
		var row: DemandRow = ROW.instantiate()
		list.add_child(row)
		row.setup(e.text, e.status)

func set_status(idx: int, s: DemandRow.Status) -> void:
	if idx < 0 or idx >= list.get_child_count():
		return
	var row: DemandRow = list.get_child(idx)
	row.status = s
